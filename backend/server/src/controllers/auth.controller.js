const { supabase, supabaseAdmin } = require('../config/supabase');
const { asyncHandler, AppError } = require('../middleware/errorHandler');
const { USER_ROLE } = require('../models/types');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require('../config/env');

// Register new user
const register = asyncHandler(async (req, res) => {
  const { email, password, full_name, phone, role = 'citizen', department_id } = req.body;

  // Check if user already exists
  const { data: existingUser } = await supabase
    .from('users')
    .select('id')
    .eq('email', email)
    .single();

  if (existingUser) {
    throw new AppError('User with this email already exists', 409);
  }

  // Hash password
  const saltRounds = 12;
  const hashedPassword = await bcrypt.hash(password, saltRounds);

  // Create user record in database
  const { data: userData, error: userError } = await supabase
    .from('users')
    .insert({
      email,
      password_hash: hashedPassword,
      full_name,
      phone,
      role,
      department_id,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    })
    .select()
    .single();

  if (userError) {
    console.error('Database Error:', userError);
    throw new AppError(`Database error: ${userError.message}`, 500);
  }

  // Generate JWT token
  const token = jwt.sign(
    { 
      userId: userData.id, 
      email: userData.email, 
      role: userData.role 
    },
    config.jwtSecret,
    { expiresIn: config.jwtExpiresIn }
  );

  res.status(201).json({
    success: true,
    message: 'User registered successfully',
    data: {
      user: {
        id: userData.id,
        email: userData.email,
        full_name: userData.full_name,
        phone: userData.phone,
        role: userData.role,
        department_id: userData.department_id,
        created_at: userData.created_at
      },
      token
    }
  });
});

// Login user
const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  // Get user from database
  const { data: userData, error: userError } = await supabase
    .from('users')
    .select('*')
    .eq('email', email)
    .single();

  if (userError || !userData) {
    throw new AppError('Invalid email or password', 401);
  }

  // Check password
  const isPasswordValid = await bcrypt.compare(password, userData.password_hash);
  if (!isPasswordValid) {
    throw new AppError('Invalid email or password', 401);
  }

  // Update last sign in
  await supabase
    .from('users')
    .update({ 
      last_sign_in_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    })
    .eq('id', userData.id);

  // Generate JWT token
  const token = jwt.sign(
    { 
      userId: userData.id, 
      email: userData.email, 
      role: userData.role 
    },
    config.jwtSecret,
    { expiresIn: config.jwtExpiresIn }
  );

  res.json({
    success: true,
    message: 'Login successful',
    data: {
      user: {
        id: userData.id,
        email: userData.email,
        full_name: userData.full_name,
        phone: userData.phone,
        role: userData.role,
        department_id: userData.department_id,
        created_at: userData.created_at,
        last_sign_in_at: new Date().toISOString()
      },
      token
    }
  });
});

// Logout user
const logout = asyncHandler(async (req, res) => {
  // Since we're using JWT, logout is handled client-side by removing the token
  // We can optionally track logout in the database if needed
  res.json({
    success: true,
    message: 'Logout successful'
  });
});

// Refresh token
const refreshToken = asyncHandler(async (req, res) => {
  const { token } = req.body;

  if (!token) {
    throw new AppError('Token required', 400);
  }

  try {
    // Verify the existing token
    const decoded = jwt.verify(token, config.jwtSecret);
    
    // Get user from database
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('id, email, role')
      .eq('id', decoded.userId)
      .single();

    if (userError || !userData) {
      throw new AppError('User not found', 401);
    }

    // Generate new token
    const newToken = jwt.sign(
      { 
        userId: userData.id, 
        email: userData.email, 
        role: userData.role 
      },
      config.jwtSecret,
      { expiresIn: config.jwtExpiresIn }
    );

    res.json({
      success: true,
      message: 'Token refreshed successfully',
      data: {
        token: newToken
      }
    });
  } catch (error) {
    throw new AppError('Invalid token', 401);
  }
});

// Get current user profile
const getProfile = asyncHandler(async (req, res) => {
  // User is already available from the authentication middleware
  const userData = req.user;

  // Remove sensitive information
  const { password_hash, ...safeUserData } = userData;

  res.json({
    success: true,
    data: { user: safeUserData }
  });
});

// Update user profile
const updateProfile = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { full_name, phone } = req.body;

  const { data: userData, error } = await supabase
    .from('users')
    .update({
      full_name,
      phone,
      updated_at: new Date().toISOString()
    })
    .eq('id', userId)
    .select()
    .single();

  if (error) {
    throw new AppError('Failed to update profile', 500);
  }

  res.json({
    success: true,
    message: 'Profile updated successfully',
    data: { user: userData }
  });
});

// Change password
const changePassword = asyncHandler(async (req, res) => {
  const { current_password, new_password } = req.body;
  const userId = req.user.id;

  // Get user from database
  const { data: userData, error: userError } = await supabase
    .from('users')
    .select('password_hash')
    .eq('id', userId)
    .single();

  if (userError || !userData) {
    throw new AppError('User not found', 404);
  }

  // Verify current password
  const isCurrentPasswordValid = await bcrypt.compare(current_password, userData.password_hash);
  if (!isCurrentPasswordValid) {
    throw new AppError('Current password is incorrect', 400);
  }

  // Hash new password
  const saltRounds = 12;
  const hashedNewPassword = await bcrypt.hash(new_password, saltRounds);

  // Update password
  const { error: updateError } = await supabase
    .from('users')
    .update({ 
      password_hash: hashedNewPassword,
      updated_at: new Date().toISOString()
    })
    .eq('id', userId);

  if (updateError) {
    throw new AppError('Failed to update password', 500);
  }

  res.json({
    success: true,
    message: 'Password updated successfully'
  });
});

// Forgot password
const forgotPassword = asyncHandler(async (req, res) => {
  const { email } = req.body;

  // Check if user exists
  const { data: userData, error: userError } = await supabase
    .from('users')
    .select('id, email')
    .eq('email', email)
    .single();

  if (userError || !userData) {
    // Don't reveal if user exists or not for security
    res.json({
      success: true,
      message: 'If the email exists, a password reset link has been sent'
    });
    return;
  }

  // Generate reset token
  const resetToken = jwt.sign(
    { userId: userData.id, email: userData.email, type: 'password_reset' },
    config.jwtSecret,
    { expiresIn: '1h' }
  );

  // In a real application, you would send this token via email
  // For now, we'll just return it (remove this in production)
  res.json({
    success: true,
    message: 'Password reset token generated',
    reset_token: resetToken // Remove this in production
  });
});

// Reset password
const resetPassword = asyncHandler(async (req, res) => {
  const { reset_token, new_password } = req.body;

  try {
    // Verify reset token
    const decoded = jwt.verify(reset_token, config.jwtSecret);
    
    if (decoded.type !== 'password_reset') {
      throw new AppError('Invalid reset token', 400);
    }

    // Hash new password
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(new_password, saltRounds);

    // Update password
    const { error: updateError } = await supabase
      .from('users')
      .update({ 
        password_hash: hashedPassword,
        updated_at: new Date().toISOString()
      })
      .eq('id', decoded.userId);

    if (updateError) {
      throw new AppError('Failed to reset password', 500);
    }

    res.json({
      success: true,
      message: 'Password reset successfully'
    });
  } catch (error) {
    throw new AppError('Invalid or expired reset token', 400);
  }
});

module.exports = {
  register,
  login,
  logout,
  refreshToken,
  getProfile,
  updateProfile,
  changePassword,
  forgotPassword,
  resetPassword
};
