// Integration check for a disposable LOCAL Supabase stack only.
// Reads `supabase status -o json` from a temporary file, never prints keys,
// passwords, tokens, response bodies or personal information. The stack is
// discarded by CI; append-only audit fixtures are intentionally retained.
import { readFile } from 'node:fs/promises';
import { randomBytes, randomUUID } from 'node:crypto';

function requireCondition(condition, message) {
  if (!condition) throw new Error(message);
}

async function main() {
  const statusPath = process.argv[2];
  requireCondition(statusPath, 'Supply a temporary local Supabase status JSON file.');
  const config = JSON.parse(await readFile(statusPath, 'utf8'));
  const base = new URL(config.API_URL);
  requireCondition(
    base.protocol === 'http:' &&
      ['127.0.0.1', 'localhost', '[::1]'].includes(base.hostname) &&
      !base.username && !base.password && !base.search && !base.hash,
    'This fixture-creating check only accepts a disposable loopback Supabase stack.',
  );
  requireCondition(config.ANON_KEY && config.SERVICE_ROLE_KEY, 'Local API keys are missing.');

  async function request(label, route, { method = 'GET', body, token, admin = false } = {}) {
    const key = admin ? config.SERVICE_ROLE_KEY : config.ANON_KEY;
    let response;
    try {
      response = await fetch(new URL(route, base), {
        method,
        headers: {
          apikey: key,
          Authorization: `Bearer ${token ?? key}`,
          'Content-Type': 'application/json',
        },
        body: body === undefined ? undefined : JSON.stringify(body),
        signal: AbortSignal.timeout(15000),
        redirect: 'error',
      });
    } catch {
      throw new Error(`${label}: request failed or timed out.`);
    }
    const raw = await response.text();
    let data;
    try { data = raw ? JSON.parse(raw) : null; } catch { data = null; }
    return { ok: response.ok, status: response.status, data };
  }

  async function success(label, route, options) {
    const result = await request(label, route, options);
    requireCondition(result.ok, `${label}: unexpected HTTP ${result.status}.`);
    return result.data;
  }

  const settings = await success('Read Auth configuration', '/auth/v1/settings');
  requireCondition(settings?.disable_signup === true && settings?.external?.email === true,
    'Auth must enable email login while disabling public signup.');

  const password = `Aa1!${randomBytes(30).toString('base64url')}`;
  const email = `foundation-${randomUUID()}@example.com`;
  const owner = await success('Create disposable owner', '/auth/v1/admin/users', {
    method: 'POST', admin: true, body: { email, password, email_confirm: true },
  });
  requireCondition(typeof owner?.id === 'string', 'Auth did not return a user identifier.');

  const rejected = await request('Reject invalid password', '/auth/v1/token?grant_type=password', {
    method: 'POST', body: { email, password: `${password}-incorrect` },
  });
  requireCondition(rejected.status === 400 &&
    (rejected.data?.error_code ?? rejected.data?.code) === 'invalid_credentials' &&
    !rejected.data?.access_token,
  `Invalid password check failed (HTTP ${rejected.status}).`);

  let session = await success('Password sign-in', '/auth/v1/token?grant_type=password', {
    method: 'POST', body: { email, password },
  });
  requireCondition(session?.user?.id === owner.id && session.access_token && session.refresh_token,
    'Password sign-in did not produce the expected session.');
  const memberships = async (token) => success('Load branch memberships',
    '/rest/v1/rpc/my_branch_memberships', { method: 'POST', body: {}, token });
  requireCondition((await memberships(session.access_token)).length === 0,
    'An unprovisioned user received branch access.');

  const businessId = randomUUID();
  const branchId = randomUUID();
  const foreignBusinessId = randomUUID();
  const foreignBranchId = randomUUID();
  await success('Create disposable businesses', '/rest/v1/businesses', {
    method: 'POST', admin: true,
    body: [{ id: businessId, name: 'Auth integration fixture' },
      { id: foreignBusinessId, name: 'Isolated auth fixture' }],
  });
  await success('Create disposable branches', '/rest/v1/branches', {
    method: 'POST', admin: true,
    body: [{ id: branchId, business_id: businessId, name: 'Main', code: 'MAIN' },
      { id: foreignBranchId, business_id: foreignBusinessId, name: 'Foreign', code: 'FOREIGN' }],
  });
  await success('Provision membership', '/rest/v1/business_memberships', {
    method: 'POST', admin: true, body: { business_id: businessId, user_id: owner.id },
  });
  await success('Provision owner role', '/rest/v1/user_roles', {
    method: 'POST', admin: true,
    body: { business_id: businessId, branch_id: branchId, user_id: owner.id, role: 'OWNER' },
  });
  const branches = await memberships(session.access_token);
  requireCondition(branches.length === 1 && branches[0].branch_id === branchId &&
    branches[0].business_id === businessId && branches[0].roles.includes('OWNER'),
  'The authenticated membership RPC returned an incorrect branch or role.');
  const visible = await success('Read branches with RLS', '/rest/v1/branches?select=id', {
    token: session.access_token,
  });
  requireCondition(visible.length === 1 && visible[0].id === branchId,
    'PostgREST exposed a foreign branch.');

  const escalation = await request('Reject role mutation',
    `/rest/v1/user_roles?user_id=eq.${owner.id}`, {
      method: 'PATCH', token: session.access_token, body: { role: 'ADMIN' },
    });
  requireCondition(escalation.status === 403, 'A client was allowed to change roles.');

  const productId = randomUUID();
  const productData = { name: 'Integration product', sku: 'AUTH-001', barcode: '190001',
    category: 'Fixtures', brand: 'Test brand', base_unit: 'KG', description: '',
    hsn_code: '', sale_price: '999999999999.99', mrp: '', reorder_quantity: '1.123456', active: true };
  const saveProduct = (version, data = productData, id = productId, target = branchId) =>
    request('Save catalogue product', '/rest/v1/rpc/save_catalogue_product', {
      method: 'POST', token: session.access_token,
      body: { p_branch_id: target, p_product_id: id, p_expected_version: version, p_data: data },
    });
  const listProducts = (extra = {}) => request('Read catalogue', '/rest/v1/rpc/catalogue_products', {
    method: 'POST', token: session.access_token, body: { p_branch_id: branchId, ...extra },
  });
  const creates = await Promise.all([saveProduct(null), saveProduct(null)]);
  requireCondition(creates.every(r => r.ok && r.data?.id === productId && r.data?.version === 1 &&
    r.data?.sale_price === '999999999999.99' && r.data?.reorder_quantity === '1.123456'),
    'Concurrent create/retry did not return one exact product.');
  let catalogue = await listProducts({ p_query: 'auth-' });
  requireCondition(catalogue.ok && catalogue.data.length === 1 && catalogue.data[0].id === productId,
    'Case-insensitive SKU search failed.');
  const duplicate = await saveProduct(null, productData, randomUUID());
  requireCondition(duplicate.status === 409 && duplicate.data?.code === '23505', 'Duplicate SKU was accepted.');
  const foreignSave = await saveProduct(null, productData, randomUUID(), foreignBranchId);
  requireCondition(foreignSave.status === 403, 'Catalogue write reached an unauthorized branch.');
  const edits = await Promise.all([
    saveProduct(1, { ...productData, sale_price: '10.01' }),
    saveProduct(1, { ...productData, sale_price: '20.02' }),
  ]);
  requireCondition(edits.filter(r => r.ok && r.data?.version === 2).length === 1 &&
    edits.filter(r => !r.ok && r.data?.code === 'P0001').length === 1,
    'Concurrent edits did not reject the stale version.');
  const winner = edits.find(r => r.ok).data;
  const retryCreate = await saveProduct(null);
  requireCondition(retryCreate.ok && retryCreate.data.version === 2 && retryCreate.data.sale_price === winner.sale_price,
    'A retried create overwrote a later edit.');
  const deactivated = await saveProduct(2, { ...productData, sale_price: winner.sale_price, active: false });
  requireCondition(deactivated.ok && deactivated.data.version === 3, 'Deactivation failed.');
  requireCondition((await listProducts()).data.length === 0 &&
    (await listProducts({ p_show_inactive: true })).data.length === 1, 'Inactive filter failed.');
  const directWrite = await request('Reject direct product write', `/rest/v1/products?id=eq.${productId}`, {
    method: 'PATCH', token: session.access_token, body: { sale_price: 0 },
  });
  requireCondition(directWrite.status === 403, 'A client bypassed the atomic product RPC.');
  const audit = await success('Count product audit records',
    `/rest/v1/audit_logs?entity_id=eq.${productId}&select=action`, { admin: true });
  requireCondition(audit.length === 3 && audit.filter(row => row.action === 'PRODUCT_CREATE').length === 1,
    'Product retries or failed writes duplicated audit records.');

  const roleRoute = `/rest/v1/user_roles?user_id=eq.${owner.id}&branch_id=eq.${branchId}`;
  await success('Set disposable cashier role', roleRoute, { method: 'PATCH', admin: true, body: { role: 'CASHIER' } });
  requireCondition((await listProducts({ p_show_inactive: true })).data.length === 1 &&
    (await saveProduct(3)).status === 403, 'Cashier catalogue permission failed.');
  await success('Restore disposable owner role', roleRoute, { method: 'PATCH', admin: true, body: { role: 'OWNER' } });
  console.log('PASS: real catalogue RPCs, exact decimals, concurrent create/edit, retries, search, deactivation and role enforcement.');

  // Persist/reuse the refresh token as a fresh client would after a restart.
  // Browser secure storage itself is checked separately in the Flutter app.
  session = await success('Restore through refresh token', '/auth/v1/token?grant_type=refresh_token', {
    method: 'POST', body: { refresh_token: session.refresh_token },
  });
  const restoredUser = await success('Validate restored session', '/auth/v1/user', {
    token: session.access_token,
  });
  requireCondition(restoredUser?.id === owner.id && (await memberships(session.access_token)).length === 1,
    'The restored session lost identity or authorized access.');

  const membershipRoute = `/rest/v1/business_memberships?business_id=eq.${businessId}&user_id=eq.${owner.id}`;
  await success('Revoke membership', membershipRoute, {
    method: 'PATCH', admin: true, body: { active: false },
  });
  requireCondition((await memberships(session.access_token)).length === 0,
    'An existing valid session retained a revoked membership.');
  requireCondition((await listProducts()).status === 403 && (await saveProduct(3)).status === 403,
    'A revoked membership retained catalogue RPC access.');
  await success('Restore membership', membershipRoute, {
    method: 'PATCH', admin: true, body: { active: true },
  });
  requireCondition((await memberships(session.access_token)).length === 1,
    'Restoring membership did not restore authorized access.');

  const anon = await request('Reject anonymous RPC', '/rest/v1/rpc/my_branch_memberships', {
    method: 'POST', body: {},
  });
  requireCondition(anon.status === 401 || anon.status === 403, 'Anonymous RPC access was allowed.');
  const signup = await request('Reject public signup', '/auth/v1/signup', {
    method: 'POST', body: { email: `disabled-${randomUUID()}@example.com`, password },
  });
  requireCondition(!signup.ok &&
    (signup.data?.error_code ?? signup.data?.code) === 'signup_disabled',
    'Public signup must remain disabled.');

  await success('Sign out current session', '/auth/v1/logout?scope=local', {
    method: 'POST', token: session.access_token,
  });
  const signedOut = await request('Reject signed-out refresh', '/auth/v1/token?grant_type=refresh_token', {
    method: 'POST', body: { refresh_token: session.refresh_token },
  });
  requireCondition(signedOut.status === 400 && !signedOut.data?.access_token,
    'Sign-out did not revoke the current refresh token.');
  console.log('PASS: real Auth password sign-in, refresh, branch RLS, revocation, disabled signup and sign-out.');
}

main().catch(error => {
  // Every application error above uses controlled text, never API response data.
  const message = error instanceof SyntaxError ? 'Invalid local status JSON.' : error.message;
  console.error(`FAIL: ${message}`);
  process.exitCode = 1;
});
