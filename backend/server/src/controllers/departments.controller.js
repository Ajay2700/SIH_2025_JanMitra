const { supabase } = require('../config/supabase');
const { asyncHandler, AppError } = require('../middleware/errorHandler');

// Get all departments
const getAllDepartments = asyncHandler(async (req, res) => {
  const { page = 1, limit = 10, parent_id, search } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('departments')
    .select(`
      id,
      name,
      description,
      parent_id,
      created_at,
      updated_at,
      parent_department:parent_id (
        id,
        name
      ),
      sub_departments:departments!parent_id (
        id,
        name,
        description
      )
    `, { count: 'exact' });

  // Apply filters
  if (parent_id) {
    query = query.eq('parent_id', parent_id);
  }
  if (search) {
    query = query.or(`name.ilike.%${search}%,description.ilike.%${search}%`);
  }

  // Apply pagination and ordering
  query = query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  const { data: departments, error, count } = await query;

  if (error) {
    throw new AppError('Failed to fetch departments', 500);
  }

  res.json({
    success: true,
    data: {
      departments,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get department by ID
const getDepartmentById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data: department, error } = await supabase
    .from('departments')
    .select(`
      id,
      name,
      description,
      parent_id,
      created_at,
      updated_at,
      parent_department:parent_id (
        id,
        name,
        description
      ),
      sub_departments:departments!parent_id (
        id,
        name,
        description,
        created_at
      )
    `)
    .eq('id', id)
    .single();

  if (error) {
    throw new AppError('Department not found', 404);
  }

  res.json({
    success: true,
    data: { department }
  });
});

// Create new department
const createDepartment = asyncHandler(async (req, res) => {
  const { name, description, parent_id } = req.body;

  // Check if department with same name exists
  const { data: existingDept } = await supabase
    .from('departments')
    .select('id')
    .eq('name', name)
    .single();

  if (existingDept) {
    throw new AppError('Department with this name already exists', 409);
  }

  // Validate parent department if provided
  if (parent_id) {
    const { data: parentDept, error: parentError } = await supabase
      .from('departments')
      .select('id')
      .eq('id', parent_id)
      .single();

    if (parentError) {
      throw new AppError('Parent department not found', 400);
    }
  }

  const { data: department, error } = await supabase
    .from('departments')
    .insert({
      name,
      description,
      parent_id,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    })
    .select()
    .single();

  if (error) {
    throw new AppError('Failed to create department', 500);
  }

  res.status(201).json({
    success: true,
    message: 'Department created successfully',
    data: { department }
  });
});

// Update department
const updateDepartment = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { name, description, parent_id } = req.body;

  // Check if department exists
  const { data: existingDept, error: deptError } = await supabase
    .from('departments')
    .select('id')
    .eq('id', id)
    .single();

  if (deptError) {
    throw new AppError('Department not found', 404);
  }

  // Check if name is being changed and if new name already exists
  if (name) {
    const { data: nameConflict } = await supabase
      .from('departments')
      .select('id')
      .eq('name', name)
      .neq('id', id)
      .single();

    if (nameConflict) {
      throw new AppError('Department with this name already exists', 409);
    }
  }

  // Validate parent department if provided
  if (parent_id) {
    const { data: parentDept, error: parentError } = await supabase
      .from('departments')
      .select('id')
      .eq('id', parent_id)
      .single();

    if (parentError) {
      throw new AppError('Parent department not found', 400);
    }

    // Prevent circular reference
    if (parent_id === id) {
      throw new AppError('Department cannot be its own parent', 400);
    }
  }

  const { data: department, error } = await supabase
    .from('departments')
    .update({
      name,
      description,
      parent_id,
      updated_at: new Date().toISOString()
    })
    .eq('id', id)
    .select()
    .single();

  if (error) {
    throw new AppError('Failed to update department', 500);
  }

  res.json({
    success: true,
    message: 'Department updated successfully',
    data: { department }
  });
});

// Delete department
const deleteDepartment = asyncHandler(async (req, res) => {
  const { id } = req.params;

  // Check if department exists
  const { data: department, error: deptError } = await supabase
    .from('departments')
    .select('id')
    .eq('id', id)
    .single();

  if (deptError) {
    throw new AppError('Department not found', 404);
  }

  // Check if department has sub-departments
  const { data: subDepts, error: subError } = await supabase
    .from('departments')
    .select('id')
    .eq('parent_id', id);

  if (subError) {
    throw new AppError('Failed to check sub-departments', 500);
  }

  if (subDepts && subDepts.length > 0) {
    throw new AppError('Cannot delete department with sub-departments', 400);
  }

  // Check if department has users
  const { data: users, error: usersError } = await supabase
    .from('users')
    .select('id')
    .eq('department_id', id);

  if (usersError) {
    throw new AppError('Failed to check department users', 500);
  }

  if (users && users.length > 0) {
    throw new AppError('Cannot delete department with assigned users', 400);
  }

  // Check if department has tickets
  const { data: tickets, error: ticketsError } = await supabase
    .from('tickets')
    .select('id')
    .eq('department_id', id);

  if (ticketsError) {
    throw new AppError('Failed to check department tickets', 500);
  }

  if (tickets && tickets.length > 0) {
    throw new AppError('Cannot delete department with assigned tickets', 400);
  }

  const { error: deleteError } = await supabase
    .from('departments')
    .delete()
    .eq('id', id);

  if (deleteError) {
    throw new AppError('Failed to delete department', 500);
  }

  res.json({
    success: true,
    message: 'Department deleted successfully'
  });
});

// Get department hierarchy
const getDepartmentHierarchy = asyncHandler(async (req, res) => {
  const { data: departments, error } = await supabase
    .from('departments')
    .select(`
      id,
      name,
      description,
      parent_id,
      created_at,
      sub_departments:departments!parent_id (
        id,
        name,
        description,
        parent_id,
        created_at
      )
    `)
    .is('parent_id', null)
    .order('name');

  if (error) {
    throw new AppError('Failed to fetch department hierarchy', 500);
  }

  res.json({
    success: true,
    data: { departments }
  });
});

// Get department statistics
const getDepartmentStats = asyncHandler(async (req, res) => {
  const { id } = req.params;

  // Get user count
  const { count: userCount, error: userError } = await supabase
    .from('users')
    .select('*', { count: 'exact', head: true })
    .eq('department_id', id);

  if (userError) {
    throw new AppError('Failed to fetch user count', 500);
  }

  // Get ticket count
  const { count: ticketCount, error: ticketError } = await supabase
    .from('tickets')
    .select('*', { count: 'exact', head: true })
    .eq('department_id', id);

  if (ticketError) {
    throw new AppError('Failed to fetch ticket count', 500);
  }

  // Get open ticket count
  const { count: openTicketCount, error: openTicketError } = await supabase
    .from('tickets')
    .select('*', { count: 'exact', head: true })
    .eq('department_id', id)
    .in('status', ['open', 'in_progress']);

  if (openTicketError) {
    throw new AppError('Failed to fetch open ticket count', 500);
  }

  res.json({
    success: true,
    data: {
      user_count: userCount,
      ticket_count: ticketCount,
      open_ticket_count: openTicketCount
    }
  });
});

module.exports = {
  getAllDepartments,
  getDepartmentById,
  createDepartment,
  updateDepartment,
  deleteDepartment,
  getDepartmentHierarchy,
  getDepartmentStats
};
