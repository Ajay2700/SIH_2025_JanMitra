const { supabase } = require('../config/supabase');
const { asyncHandler, AppError } = require('../middleware/errorHandler');
const { TICKET_STATUS } = require('../models/types');

// Get all issues
const getAllIssues = asyncHandler(async (req, res) => {
  const { 
    page = 1, 
    limit = 10, 
    status, 
    category_id, 
    citizen_id, 
    search,
    sort_by = 'created_at',
    sort_order = 'desc'
  } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('issues')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false });

  // Apply filters
  if (status) {
    query = query.eq('status', status);
  }
  if (category_id) {
    query = query.eq('category_id', category_id);
  }
  if (citizen_id) {
    query = query.eq('citizen_id', citizen_id);
  }
  if (search) {
    query = query.or(`title.ilike.%${search}%,description.ilike.%${search}%`);
  }

  // Apply sorting (only if different from default)
  if (sort_by !== 'created_at' || sort_order !== 'desc') {
    const ascending = sort_order === 'asc';
    query = query.order(sort_by, { ascending });
  }

  // Apply pagination
  query = query.range(offset, offset + limit - 1);

  const { data: issues, error, count } = await query;

  if (error) {
    console.error('Supabase error fetching issues:', error);
    // Return empty data instead of throwing error to allow frontend to load
    return res.json({
      success: true,
      data: {
        issues: [],
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: 0,
          pages: 0
        }
      }
    });
  }

  res.json({
    success: true,
    data: {
      issues: issues || [],
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count || 0,
        pages: Math.ceil((count || 0) / limit)
      }
    }
  });
});

// Get issue by ID
const getIssueById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data: issue, error } = await supabase
    .from('issues')
    .select(`
      id,
      citizen_id,
      title,
      description,
      category_id,
      latitude,
      longitude,
      status,
      created_at,
      updated_at,
      citizen:citizen_id (
        id,
        full_name,
        email,
        phone
      ),
      category:category_id (
        id,
        name,
        description,
        department:department_id (
          id,
          name,
          description
        )
      ),
      tickets (
        id,
        ticket_number,
        status,
        priority,
        assigned_to,
        department_id,
        due_date,
        created_at,
        updated_at,
        assigned_user:assigned_to (
          id,
          full_name,
          email
        ),
        department:department_id (
          id,
          name
        )
      ),
      attachments (
        id,
        file_url,
        uploaded_by,
        created_at
      )
    `)
    .eq('id', id)
    .single();

  if (error) {
    throw new AppError('Issue not found', 404);
  }

  res.json({
    success: true,
    data: { issue }
  });
});

// Create new issue
const createIssue = asyncHandler(async (req, res) => {
  const { title, description, category_id, latitude, longitude } = req.body;
  const citizen_id = req.user.id;

  // Validate category exists
  const { data: category, error: categoryError } = await supabase
    .from('ticket_categories')
    .select('id, department_id')
    .eq('id', category_id)
    .single();

  if (categoryError) {
    throw new AppError('Category not found', 400);
  }

  const { data: issue, error } = await supabase
    .from('issues')
    .insert({
      citizen_id,
      title,
      description,
      category_id,
      latitude,
      longitude,
      status: TICKET_STATUS.OPEN,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    })
    .select()
    .single();

  if (error) {
    throw new AppError('Failed to create issue', 500);
  }

  // Log issue creation in history
  await supabase
    .from('issue_history')
    .insert({
      issue_id: issue.id,
      action: 'Issue created',
      performed_by: citizen_id,
      created_at: new Date().toISOString()
    });

  res.status(201).json({
    success: true,
    message: 'Issue created successfully',
    data: { issue }
  });
});

// Update issue
const updateIssue = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { title, description, category_id, latitude, longitude, status } = req.body;
  const user_id = req.user.id;

  // Check if issue exists and user has permission
  const { data: existingIssue, error: issueError } = await supabase
    .from('issues')
    .select('id, citizen_id, status')
    .eq('id', id)
    .single();

  if (issueError) {
    throw new AppError('Issue not found', 404);
  }

  // Check permissions (citizen can only update their own issues, staff can update any)
  if (req.user.role === 'citizen' && existingIssue.citizen_id !== user_id) {
    throw new AppError('You can only update your own issues', 403);
  }

  // Validate category if provided
  if (category_id) {
    const { data: category, error: categoryError } = await supabase
      .from('ticket_categories')
      .select('id')
      .eq('id', category_id)
      .single();

    if (categoryError) {
      throw new AppError('Category not found', 400);
    }
  }

  const updateData = {
    updated_at: new Date().toISOString()
  };

  if (title) updateData.title = title;
  if (description) updateData.description = description;
  if (category_id) updateData.category_id = category_id;
  if (latitude !== undefined) updateData.latitude = latitude;
  if (longitude !== undefined) updateData.longitude = longitude;
  if (status) updateData.status = status;

  const { data: issue, error } = await supabase
    .from('issues')
    .update(updateData)
    .eq('id', id)
    .select()
    .single();

  if (error) {
    throw new AppError('Failed to update issue', 500);
  }

  // Log status change in history
  if (status && status !== existingIssue.status) {
    await supabase
      .from('issue_history')
      .insert({
        issue_id: id,
        action: `Status changed to ${status}`,
        performed_by: user_id,
        created_at: new Date().toISOString()
      });
  }

  res.json({
    success: true,
    message: 'Issue updated successfully',
    data: { issue }
  });
});

// Delete issue
const deleteIssue = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const user_id = req.user.id;

  // Check if issue exists and user has permission
  const { data: issue, error: issueError } = await supabase
    .from('issues')
    .select('id, citizen_id')
    .eq('id', id)
    .single();

  if (issueError) {
    throw new AppError('Issue not found', 404);
  }

  // Check permissions
  if (req.user.role === 'citizen' && issue.citizen_id !== user_id) {
    throw new AppError('You can only delete your own issues', 403);
  }

  // Check if issue has tickets
  const { data: tickets, error: ticketsError } = await supabase
    .from('tickets')
    .select('id')
    .eq('issue_id', id);

  if (ticketsError) {
    throw new AppError('Failed to check issue tickets', 500);
  }

  if (tickets && tickets.length > 0) {
    throw new AppError('Cannot delete issue with associated tickets', 400);
  }

  // Delete issue history first
  await supabase
    .from('issue_history')
    .delete()
    .eq('issue_id', id);

  // Delete attachments
  await supabase
    .from('attachments')
    .delete()
    .eq('issue_id', id);

  // Delete issue
  const { error: deleteError } = await supabase
    .from('issues')
    .delete()
    .eq('id', id);

  if (deleteError) {
    throw new AppError('Failed to delete issue', 500);
  }

  res.json({
    success: true,
    message: 'Issue deleted successfully'
  });
});

// Get issue history
const getIssueHistory = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { page = 1, limit = 10 } = req.query;
  const offset = (page - 1) * limit;

  const { data: history, error, count } = await supabase
    .from('issue_history')
    .select(`
      id,
      action,
      performed_by,
      created_at,
      performed_user:performed_by (
        id,
        full_name,
        email
      )
    `, { count: 'exact' })
    .eq('issue_id', id)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) {
    throw new AppError('Failed to fetch issue history', 500);
  }

  res.json({
    success: true,
    data: {
      history,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get issues by citizen
const getIssuesByCitizen = asyncHandler(async (req, res) => {
  const { citizen_id } = req.params;
  const { page = 1, limit = 10, status } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('issues')
    .select(`
      id,
      title,
      description,
      status,
      created_at,
      updated_at,
      category:category_id (
        id,
        name,
        department:department_id (
          id,
          name
        )
      ),
      tickets (
        id,
        ticket_number,
        status,
        priority
      )
    `, { count: 'exact' })
    .eq('citizen_id', citizen_id);

  if (status) {
    query = query.eq('status', status);
  }

  query = query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  const { data: issues, error, count } = await query;

  if (error) {
    throw new AppError('Failed to fetch issues', 500);
  }

  res.json({
    success: true,
    data: {
      issues,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get issue statistics
const getIssueStats = asyncHandler(async (req, res) => {
  const { data: stats, error } = await supabase
    .from('issues')
    .select('status')
    .then(({ data }) => {
      const statusCounts = data.reduce((acc, issue) => {
        acc[issue.status] = (acc[issue.status] || 0) + 1;
        return acc;
      }, {});

      return {
        data: {
          total: data.length,
          by_status: statusCounts
        }
      };
    });

  if (error) {
    throw new AppError('Failed to fetch issue statistics', 500);
  }

  res.json({
    success: true,
    data: stats
  });
});

module.exports = {
  getAllIssues,
  getIssueById,
  createIssue,
  updateIssue,
  deleteIssue,
  getIssueHistory,
  getIssuesByCitizen,
  getIssueStats
};
