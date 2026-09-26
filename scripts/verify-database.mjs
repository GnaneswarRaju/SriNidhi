// Fast local PostgreSQL smoke/security run. CI repeats against full Supabase.
import { PGlite } from '@electric-sql/pglite';
import { readFile, readdir } from 'node:fs/promises';

const db = new PGlite();
try {
  await db.exec(`
    create role anon nologin;
    create role authenticated nologin;
    create schema auth;
    create table auth.users(id uuid primary key);
    create function auth.uid() returns uuid language sql stable as $$
      select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
    $$;
    grant usage on schema auth, public to anon, authenticated;
    grant execute on function auth.uid() to anon, authenticated;
  `);
  const directory = new URL('../supabase/migrations/', import.meta.url);
  for (const name of (await readdir(directory)).filter(n => n.endsWith('.sql')).sort()) {
    await db.exec(await readFile(new URL(name, directory), 'utf8'));
    console.log(`Migration applied: ${name}`);
  }
  await db.exec(await readFile(new URL('../supabase/tests/foundation.sql', import.meta.url), 'utf8'));
  console.log('PASS: PostgreSQL foundation security assertions (PGlite auth shim).');
} finally {
  await db.close();
}
