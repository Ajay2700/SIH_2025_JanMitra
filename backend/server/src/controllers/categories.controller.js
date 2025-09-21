const { supabase } = require('../config/supabase');
const { asyncHandler, AppError } = require('../middleware/errorHandler');

// Get all ticket categories
const getAllCategories = asyncHandler(async (req, res) => {
  const { page = 1, limit = 10, department_id, parent_id, search } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('ticket_categories')
    .select(`
      id,
      name,
      description,
      parent_id,
      department_id,
      created_at,
      updated_at,
      parent_category:parent_id (
        id,
        name
      ),
      department:department_id (
        id,
        name
      ),
      sub_categories:ticket_categories!parent_id (
        id,
        name,
        description
      )
    `, { count: 'exact' });

  // Apply filters
  if (department_id) {
    query = query.eq('department_id', department_id);
  }
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

  const { data: categories, error, count } = await query;

  if (error) {
    throw new AppError('Failed to fetch categories', 500);
  }

  res.json({
    success: true,
    data: {
      categories,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get category by ID
const getCategoryById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data: category, error } = await supabase
    .from('ticket_categories')
    .select(`
      id,
      name,
      description,
      parent_id,
      department_id,
      created_at,
      updated_at,
      parent_category:parent_id (
        id,
        name,
        description
      ),
      department:department_id (
        id,
        name,
        description
      ),
      sub_categories:ticket_categories!parent_id (
        id,
        name,
        description,
        created_at
      )
    `)
    .eq('id', id)
    .single();

  if (error) {
    throw new AppError('Category not found', 404);
  }

  res.json({
    success: true,
    data: { category }
  });
});

// Create new category
const createCategory = asyncHandler(async (req, res) => {
  const { name, description, parent_id, department_id } = req.body;

  // Check if category with same name exists in the same department
  const { data: existingCategory } = await supabase
    .from('ticket_categories')
    .select('id')
    .eq('name', name)
    .eq('department_id', department_id)
    .single();

  if (existingCategory) {
    throw new AppError('Category with this name already exists in this department', 409);
  }

  // Validate parent category if provided
  if (parent_id) {
    const { data: parentCategory, error: parentError } = await supabase
      .from('ticket_categories')
      .select('id, department_id')
      .eq('id', parent_id)
      .single();

    if (parentError) {
      throw new AppError('Parent category not found', 400);
    }

    // Ensure parent category belongs to the same department
    if (parentCategory.department_id !== department_id) {
      throw new AppError('Parent category must belong to the same department', 400);
    }
  }

  // Validate department if provided
  if (department_id) {
    const { data: department, error: deptError } = await supabase
      .from('departments')
      .select('id')
      .eq('id', department_id)
      .single();

    if (deptError) {
      throw new AppError('Department not found', 400);
    }
  }

  const { data: category, error } = await supabase
    .from('ticket_categories')
    .insert({
      name,
      description,
      parent_id,
      department_id,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    })
    .select()
    .single();

  if (error) {
    throw new AppError('Failed to create category', 500);
  }

  res.status(201).json({
    success: true,
    message: 'Category created successfully',
    data: { category }
  });
});

// Update category
const updateCategory = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { name, description, parent_id, department_id } = req.body;

  // Check if category exists
  const { data: existingCategory, error: categoryError } = await supabase
    .from('ticket_categories')
    .select('id, department_id')
    .eq('id', id)
    .single();

  if (categoryError) {
    throw new AppError('Category not found', 404);
  }

  // Check if name is being changed and if new name already exists in the same department
  if (name) {
    const { data: nameConflict } = await supabase
      .from('ticket_categories')
      .select('id')
      .eq('name', name)
      .eq('department_id', department_id || existingCategory.department_id)
      .neq('id', id)
      .single();

    if (nameConflict) {
      throw new AppError('Category with this name already exists in this department', 409);
    }
  }

  // Validate parent category if provided
  if (parent_id) {
    const { data: parentCategory, error: parentError } = await supabase
      .from('ticket_categories')
      .select('id, department_id')
      .eq('id', parent_id)
      .single();

    if (parentError) {
      throw new AppError('Parent category not found', 400);
    }

    // Prevent circular reference
    if (parent_id === id) {
      throw new AppError('Category cannot be its own parent', 400);
    }

    // Ensure parent category belongs to the same department
    const targetDeptId = department_id || existingCategory.department_id;
    if (parentCategory.department_id !== targetDeptId) {
      throw new AppError('Parent category must belong to the same department', 400);
    }
  }

  // Validate department if provided
  if (department_id) {
    const { data: department, error: deptError } = await supabase
      .from('departments')
      .select('id')
      .eq('id', department_id)
      .single();

    if (deptError) {
      throw new AppError('Department not found', 400);
    }
  }

  const { data: category, error } = await supabase
    .from('ticket_categories')
    .update({
      name,
      description,
      parent_id,
      department_id,
      updated_at: new Date().toISOString()
    })
    .eq('id', id)
    .select()
    .single();

  if (error) {
    throw new AppError('Failed to update category', 500);
  }

  res.json({
    success: true,
    message: 'Category updated successfully',
    data: { category }
  });
});

// Delete category
const deleteCategory = asyncHandler(async (req, res) => {
  const { id } = req.params;

  // Check if category exists
  const { data: category, error: categoryError } = await supabase
    .from('ticket_categories')
    .select('id')
    .eq('id', id)
    .single();

  if (categoryError) {
    throw new AppError('Category not found', 404);
  }

  // Check if category has sub-categories
  const { data: subCategories, error: subError } = await supabase
    .from('ticket_categories')
    .select('id')
    .eq('parent_id', id);

  if (subError) {
    throw new AppError('Failed to check sub-categories', 500);
  }

  if (subCategories && subCategories.length > 0) {
    throw new AppError('Cannot delete category with sub-categories', 400);
  }

  // Check if category has issues
  const { data: issues, error: issuesError } = await supabase
    .from('issues')
    .select('id')
    .eq('category_id', id);

  if (issuesError) {
    throw new AppError('Failed to check category issues', 500);
  }

  if (issues && issues.length > 0) {
    throw new AppError('Cannot delete category with associated issues', 400);
  }

  const { error: deleteError } = await supabase
    .from('ticket_categories')
    .delete()
    .eq('id', id);

  if (deleteError) {
    throw new AppError('Failed to delete category', 500);
  }

  res.json({
    success: true,
    message: 'Category deleted successfully'
  });
});

// Get category hierarchy
const getCategoryHierarchy = asyncHandler(async (req, res) => {
  const { department_id } = req.query;

  let query = supabase
    .from('ticket_categories')
    .select(`
      id,
      name,
      description,
      parent_id,
      department_id,
      created_at,
      sub_categories:ticket_categories!parent_id (
        id,
        name,
        description,
        parent_id,
        department_id,
        created_at
      )
    `)
    .is('parent_id', null);

  if (department_id) {
    query = query.eq('department_id', department_id);
  }

  query = query.order('name');

  const { data: categories, error } = await query;

  if (error) {
    throw new AppError('Failed to fetch category hierarchy', 500);
  }

  res.json({
    success: true,
    data: { categories }
  });
});

// Get categories by department
const getCategoriesByDepartment = asyncHandler(async (req, res) => {
  const { department_id } = req.params;
  const { page = 1, limit = 10 } = req.query;
  const offset = (page - 1) * limit;

  const { data: categories, error, count } = await supabase
    .from('ticket_categories')
    .select(`
      id,
      name,
      description,
      parent_id,
      created_at,
      updated_at,
      parent_category:parent_id (
        id,
        name
      ),
      sub_categories:ticket_categories!parent_id (
        id,
        name,
        description
      )
    `, { count: 'exact' })
    .eq('department_id', department_id)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) {
    throw new AppError('Failed to fetch categories', 500);
  }

  res.json({
    success: true,
    data: {
      categories,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get category statistics
const getCategoryStats = asyncHandler(async (req, res) => {
  const { id } = req.params;

  // Get issue count
  const { count: issueCount, error: issueError } = await supabase
    .from('issues')
    .select('*', { count: 'exact', head: true })
    .eq('category_id', id);

  if (issueError) {
    throw new AppError('Failed to fetch issue count', 500);
  }

  // Get open issue count
  const { count: openIssueCount, error: openIssueError } = await supabase
    .from('issues')
    .select('*', { count: 'exact', head: true })
    .eq('category_id', id)
    .in('status', ['open', 'in_progress']);

  if (openIssueError) {
    throw new AppError('Failed to fetch open issue count', 500);
  }

  // Get sub-category count
  const { count: subCategoryCount, error: subCategoryError } = await supabase
    .from('ticket_categories')
    .select('*', { count: 'exact', head: true })
    .eq('parent_id', id);

  if (subCategoryError) {
    throw new AppError('Failed to fetch sub-category count', 500);
  }

  res.json({
    success: true,
    data: {
      issue_count: issueCount,
      open_issue_count: openIssueCount,
      sub_category_count: subCategoryCount
    }
  });
});

module.exports = {
  getAllCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
  getCategoryHierarchy,
  getCategoriesByDepartment,
  getCategoryStats
};
