import { supabase } from '../config/supabase.js';

export function requireAuth(roles = []) {
  return async (req, res, next) => {
    try {
      const header = req.headers.authorization || '';
      const token = header.startsWith('Bearer ') ? header.slice(7) : null;
      
      if (!token) {
        return res.status(401).json({ error: 'Unauthorized - No token provided' });
      }

      // Verify the JWT token with Supabase
      const { data: { user }, error } = await supabase.auth.getUser(token);
      
      if (error || !user) {
        return res.status(401).json({ error: 'Unauthorized - Invalid token' });
      }

      // Get user profile from our users table
      const { data: userProfile, error: profileError } = await supabase
        .from('users')
        .select('id, email, name, user_type, department_id, phone, address')
        .eq('id', user.id)
        .single();

      if (profileError) {
        return res.status(401).json({ error: 'Unauthorized - User profile not found' });
      }

      // Set user data in request
      req.user = {
        id: userProfile.id,
        email: userProfile.email,
        name: userProfile.name,
        user_type: userProfile.user_type,
        department_id: userProfile.department_id,
        phone: userProfile.phone,
        address: userProfile.address
      };

      // Check role-based access
      if (roles.length > 0 && !roles.includes(userProfile.user_type)) {
        return res.status(403).json({ error: 'Forbidden - Insufficient permissions' });
      }

      next();
    } catch (err) {
      console.error('Auth middleware error:', err);
      return res.status(401).json({ error: 'Unauthorized - Token verification failed' });
    }
  };
}


