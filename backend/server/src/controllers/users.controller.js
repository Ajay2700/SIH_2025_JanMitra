const { supabase, supabaseAdmin } = require('../config/supabase');
const { asyncHandler, AppError } = require('../middleware/errorHandler');
const { USER_ROLE } = require('../models/types');

// Get all users (admin only)
const getAllUsers = asyncHandler(async (req, res) => {
  const { page = 1, limit = 10, role, department_id, search } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('users')
    .select('*', { count: 'exact' });

  // Apply filters
  if (role) {
    query = query.eq('role', role);
  }
  if (department_id) {
    query = query.eq('department_id', department_id);
  }
  if (search) {
    query = query.or(`full_name.ilike.%${search}%,email.ilike.%${search}%`);
  }

  // Apply pagination and ordering
  query = query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  const { data: users, error, count } = await query;

  if (error) {
    throw new AppError('Failed to fetch users', 500);
  }

  res.json({
    success: true,
    data: {
      users,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get user by ID
const getUserById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data: user, error } = await supabase
    .from('users')
    .select(`
      id,
      email,
      full_name,
      phone,
      role,
      department_id,
      created_at,
      updated_at,
      last_sign_in_at,
      departments (
        id,
        name,
        description
      )
    `)
    .eq('id', id)
    .single();

  if (error) {
    throw new AppError('User not found', 404);
  }

  res.json({
    success: true,
    data: { user }
  });
});

// Create new user (admin only)
const createUser = asyncHandler(async (req, res) => {
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

  // Create user in Supabase Auth
  const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: {
      full_name,
      phone,
      role,
      department_id
    }
  });

  if (authError) {
    throw new AppError(authError.message, 400);
  }

  // Create user record in database
  const { data: userData, error: userError } = await supabase
    .from('users')
    .insert({
      id: authData.user.id,
      email,
      full_name,
      phone,
      role,
      department_id,
      created_at: new Date().toISOString()
    })
    .select()
    .single();

  if (userError) {
    // Clean up auth user if database insert fails
    await supabaseAdmin.auth.admin.deleteUser(authData.user.id);
    throw new AppError('Failed to create user record', 500);
  }

  res.status(201).json({
    success: true,
    message: 'User created successfully',
    data: { user: userData }
  });
});

// Update user (admin only)
const updateUser = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { full_name, phone, role, department_id } = req.body;

  const { data: userData, error } = await supabase
    .from('users')
    .update({
      full_name,
      phone,
      role,
      department_id,
      updated_at: new Date().toISOString()
    })
    .eq('id', id)
    .select()
    .single();

  if (error) {
    throw new AppError('Failed to update user', 500);
  }

  res.json({
    success: true,
    message: 'User updated successfully',
    data: { user: userData }
  });
});

// Delete user (admin only)
const deleteUser = asyncHandler(async (req, res) => {
  const { id } = req.params;

  // Check if user exists
  const { data: user, error: userError } = await supabase
    .from('users')
    .select('id')
    .eq('id', id)
    .single();

  if (userError) {
    throw new AppError('User not found', 404);
  }

  // Delete from Supabase Auth
  const { error: authError } = await supabaseAdmin.auth.admin.deleteUser(id);

  if (authError) {
    throw new AppError('Failed to delete user from auth', 500);
  }

  // Delete from database
  const { error: deleteError } = await supabase
    .from('users')
    .delete()
    .eq('id', id);

  if (deleteError) {
    throw new AppError('Failed to delete user from database', 500);
  }

  res.json({
    success: true,
    message: 'User deleted successfully'
  });
});

// Get users by department
const getUsersByDepartment = asyncHandler(async (req, res) => {
  const { department_id } = req.params;
  const { page = 1, limit = 10 } = req.query;
  const offset = (page - 1) * limit;

  const { data: users, error, count } = await supabase
    .from('users')
    .select(`
      id,
      email,
      full_name,
      phone,
      role,
      created_at,
      departments (
        id,
        name
      )
    `, { count: 'exact' })
    .eq('department_id', department_id)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) {
    throw new AppError('Failed to fetch users', 500);
  }

  res.json({
    success: true,
    data: {
      users,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get user statistics
const getUserStats = asyncHandler(async (req, res) => {
  const { data: stats, error } = await supabase
    .from('users')
    .select('role')
    .then(({ data }) => {
      const roleCounts = data.reduce((acc, user) => {
        acc[user.role] = (acc[user.role] || 0) + 1;
        return acc;
      }, {});

      return {
        data: {
          total: data.length,
          by_role: roleCounts
        }
      };
    });

  if (error) {
    throw new AppError('Failed to fetch user statistics', 500);
  }

  res.json({
    success: true,
    data: stats
  });
});

module.exports = {
  getAllUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser,
  getUsersByDepartment,
  getUserStats
};
