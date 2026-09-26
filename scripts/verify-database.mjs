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
  const tests = new URL('../supabase/tests/', import.meta.url);
  for (const name of (await readdir(tests)).filter(n => n.endsWith('.sql')).sort()) {
    await db.exec(await readFile(new URL(name, tests), 'utf8'));
    console.log(`PASS: ${name} (PostgreSQL / PGlite Auth shim).`);
  }
} finally {
  await db.close();
}
