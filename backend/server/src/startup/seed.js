import bcrypt from 'bcryptjs';
import { supabase } from '../config/supabase.js';
import { env } from '../config/env.js';

async function upsertUser(defaultUser) {
  const { email, password, full_name, phone_number, address, role } = defaultUser;
  const { data: existing, error: selectErr } = await supabase
    .from('users')
    .select('id')
    .eq('email', email)
    .maybeSingle();
  if (selectErr) throw selectErr;
  if (existing) return existing.id;

  const hashed = await bcrypt.hash(password, 10);
  const { data: inserted, error: insertErr } = await supabase
    .from('users')
    .insert({ email, password: hashed, full_name, phone_number, address, role })
    .select('id')
    .single();
  if (insertErr) throw insertErr;
  return inserted.id;
}

export async function ensureDefaultUsers() {
  const users = env.DEFAULT_USERS;
  await upsertUser(users.citizen);
  await upsertUser(users.staff);
  await upsertUser(users.admin);
}


