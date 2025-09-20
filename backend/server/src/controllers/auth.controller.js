import { supabase } from '../config/supabase.js';

export async function login(req, res) {
  const { email, password } = req.body || {};
  if (!email || !password) return res.status(400).json({ error: 'email and password required' });

  try {
    // Use Supabase Auth for authentication
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (authError) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Get user profile from our users table
    const { data: userProfile, error: profileError } = await supabase
      .from('users')
      .select('id, email, name, user_type, department_id, phone, address')
      .eq('id', authData.user.id)
      .single();

    if (profileError) {
      console.error('Profile fetch error:', profileError);
      return res.status(500).json({ error: 'Failed to fetch user profile' });
    }

    return res.json({
      token: authData.session.access_token,
      refresh_token: authData.session.refresh_token,
      user_type: userProfile.user_type,
      user: {
        id: userProfile.id,
        email: userProfile.email,
        name: userProfile.name,
        user_type: userProfile.user_type,
        department_id: userProfile.department_id,
        phone: userProfile.phone,
        address: userProfile.address
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function register(req, res) {
  const { email, password, name, phone, user_type = 'citizen' } = req.body || {};
  if (!email || !password || !name) {
    return res.status(400).json({ error: 'email, password, and name required' });
  }

  try {
    // Create user in Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
    });

    if (authError) {
      return res.status(400).json({ error: authError.message });
    }

    // Create user profile in our users table
    const { data: userProfile, error: profileError } = await supabase
      .from('users')
      .insert({
        id: authData.user.id,
        email,
        name,
        phone,
        user_type
      })
      .select('id, email, name, user_type, department_id, phone, address')
      .single();

    if (profileError) {
      console.error('Profile creation error:', profileError);
      return res.status(500).json({ error: 'Failed to create user profile' });
    }

    return res.status(201).json({
      user: userProfile,
      message: 'User created successfully. Please check your email for verification.'
    });
  } catch (error) {
    console.error('Registration error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}


