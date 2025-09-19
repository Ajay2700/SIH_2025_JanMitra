import bcrypt from 'bcryptjs';
import { supabase } from '../config/supabase.js';
import { signToken } from '../middleware/auth.js';

export async function login(req, res) {
  const { email, password } = req.body || {};
  if (!email || !password) return res.status(400).json({ error: 'email and password required' });

  const { data: user, error } = await supabase
    .from('users')
    .select('id, email, password, role, full_name')
    .eq('email', email)
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!user) return res.status(401).json({ error: 'Invalid credentials' });

  let isValid = false;
  const stored = user.password || '';
  const looksHashed = typeof stored === 'string' && stored.startsWith('$2');
  if (looksHashed) {
    isValid = await bcrypt.compare(password, stored);
  } else {
    // fallback for plaintext records; migrate to hash on successful login
    isValid = stored === password;
    if (isValid) {
      try {
        const newHash = await bcrypt.hash(password, 10);
        await supabase.from('users').update({ password: newHash }).eq('id', user.id);
      } catch {
        // ignore migration failure; login will still proceed
      }
    }
  }

  if (!isValid) return res.status(401).json({ error: 'Invalid credentials' });

  const token = signToken(user);
  return res.json({ token, role: user.role, user: { id: user.id, email: user.email, full_name: user.full_name, role: user.role } });
}


