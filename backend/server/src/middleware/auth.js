const jwt = require('jsonwebtoken');
const { supabase } = require('../config/supabase');
const config = require('../config/env');
const { USER_ROLE } = require('../models/types');

// Middleware to verify JWT token
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({ 
        success: false, 
        message: 'Access token required' 
      });
    }

    // Verify JWT token
    let decoded;
    try {
      decoded = jwt.verify(token, config.jwtSecret);
    } catch (jwtError) {
      console.error('JWT verification error:', jwtError.message);
      return res.status(401).json({ 
        success: false, 
        message: 'Invalid or expired token. Please login again.' 
      });
    }

    // Get user details from database
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('*')
      .eq('id', decoded.userId)
      .single();

    if (userError || !userData) {
      return res.status(403).json({ 
        success: false, 
        message: 'User not found' 
      });
    }

    req.user = userData;
    req.token = token;
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ 
        success: false, 
        message: 'Invalid token' 
      });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        success: false, 
        message: 'Token expired' 
      });
    }
    return res.status(500).json({ 
      success: false, 
      message: 'Authentication error' 
    });
  }
};

// Middleware to check user role
const requireRole = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ 
        success: false, 
        message: 'Authentication required' 
      });
    }

    const userRole = req.user.role;
    const allowedRoles = Array.isArray(roles) ? roles : [roles];

    if (!allowedRoles.includes(userRole)) {
      return res.status(403).json({ 
        success: false, 
        message: 'Insufficient permissions' 
      });
    }

    next();
  };
};

// Middleware to check if user is admin or super admin
const requireAdmin = requireRole([USER_ROLE.ADMIN, USER_ROLE.SUPER_ADMIN]);

// Middleware to check if user is super admin only
const requireSuperAdmin = requireRole(USER_ROLE.SUPER_ADMIN);

// Middleware to check if user can access resource (owner or admin)
const requireOwnershipOrAdmin = (resourceUserIdField = 'user_id') => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ 
        success: false, 
        message: 'Authentication required' 
      });
    }

    const userRole = req.user.role;
    const userId = req.user.id;
    const resourceUserId = req.params[resourceUserIdField] || req.body[resourceUserIdField];

    // Allow if user is admin/super admin or owns the resource
    if ([USER_ROLE.ADMIN, USER_ROLE.SUPER_ADMIN].includes(userRole) || 
        userId === resourceUserId) {
      return next();
    }

    return res.status(403).json({ 
      success: false, 
      message: 'Access denied' 
    });
  };
};

module.exports = {
  authenticateToken,
  requireRole,
  requireAdmin,
  requireSuperAdmin,
  requireOwnershipOrAdmin
};
