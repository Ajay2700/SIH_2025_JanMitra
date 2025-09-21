const { supabase } = require('../config/supabase');
const { asyncHandler, AppError } = require('../middleware/errorHandler');
const { TICKET_STATUS, TICKET_PRIORITY } = require('../models/types');
const { v4: uuidv4 } = require('uuid');

// Generate unique ticket number
const generateTicketNumber = async () => {
  const prefix = 'TKT';
  const timestamp = Date.now().toString().slice(-6);
  const random = Math.random().toString(36).substring(2, 5).toUpperCase();
  return `${prefix}${timestamp}${random}`;
};

// Get all tickets
const getAllTickets = asyncHandler(async (req, res) => {
  const { 
    page = 1, 
    limit = 10, 
    status, 
    priority, 
    department_id, 
    assigned_to, 
    search,
    sort_by = 'created_at',
    sort_order = 'desc'
  } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('tickets')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false });

  // Apply filters
  if (status) {
    query = query.eq('status', status);
  }
  if (priority) {
    query = query.eq('priority', priority);
  }
  if (department_id) {
    query = query.eq('department_id', department_id);
  }
  if (assigned_to) {
    query = query.eq('assigned_to', assigned_to);
  }
  if (search) {
    query = query.or(`ticket_number.ilike.%${search}%,issue.title.ilike.%${search}%`);
  }

  // Apply sorting (only if different from default)
  if (sort_by !== 'created_at' || sort_order !== 'desc') {
    const ascending = sort_order === 'asc';
    query = query.order(sort_by, { ascending });
  }

  // Apply pagination
  query = query.range(offset, offset + limit - 1);

  const { data: tickets, error, count } = await query;

  if (error) {
    console.error('Supabase error fetching tickets:', error);
    // Return empty data instead of throwing error to allow frontend to load
    return res.json({
      success: true,
      data: {
        tickets: [],
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
      tickets: tickets || [],
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count || 0,
        pages: Math.ceil((count || 0) / limit)
      }
    }
  });
});

// Get ticket by ID
const getTicketById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data: ticket, error } = await supabase
    .from('tickets')
    .select(`
      id,
      ticket_number,
      issue_id,
      assigned_to,
      department_id,
      priority,
      status,
      due_date,
      created_at,
      updated_at,
      issue:issue_id (
        id,
        title,
        description,
        citizen_id,
        category_id,
        latitude,
        longitude,
        status,
        created_at,
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
        )
      ),
      assigned_user:assigned_to (
        id,
        full_name,
        email,
        phone
      ),
      department:department_id (
        id,
        name,
        description
      ),
      comments (
        id,
        content,
        created_at,
        user:user_id (
          id,
          full_name,
          email
        )
      ),
      attachments (
        id,
        file_url,
        uploaded_by,
        created_at,
        uploaded_user:uploaded_by (
          id,
          full_name
        )
      )
    `)
    .eq('id', id)
    .single();

  if (error) {
    throw new AppError('Ticket not found', 404);
  }

  res.json({
    success: true,
    data: { ticket }
  });
});

// Create new ticket
const createTicket = asyncHandler(async (req, res) => {
  const { issue_id, assigned_to, department_id, priority = 'medium', due_date } = req.body;

  // Validate issue exists
  const { data: issue, error: issueError } = await supabase
    .from('issues')
    .select('id, citizen_id, category_id, status')
    .eq('id', issue_id)
    .single();

  if (issueError) {
    throw new AppError('Issue not found', 400);
  }

  // Validate department exists
  const { data: department, error: deptError } = await supabase
    .from('departments')
    .select('id')
    .eq('id', department_id)
    .single();

  if (deptError) {
    throw new AppError('Department not found', 400);
  }

  // Validate assigned user if provided
  if (assigned_to) {
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('id, department_id')
      .eq('id', assigned_to)
      .single();

    if (userError) {
      throw new AppError('Assigned user not found', 400);
    }

    // Ensure user belongs to the assigned department
    if (user.department_id !== department_id) {
      throw new AppError('Assigned user must belong to the selected department', 400);
    }
  }

  // Generate unique ticket number
  const ticket_number = await generateTicketNumber();

  const { data: ticket, error } = await supabase
    .from('tickets')
    .insert({
      ticket_number,
      issue_id,
      assigned_to,
      department_id,
      priority,
      status: TICKET_STATUS.OPEN,
      due_date,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    })
    .select()
    .single();

  if (error) {
    throw new AppError('Failed to create ticket', 500);
  }

  // Log ticket creation in history
  await supabase
    .from('ticket_history')
    .insert({
      ticket_id: ticket.id,
      action: 'Ticket created',
      performed_by: req.user.id,
      created_at: new Date().toISOString()
    });

  // Update issue status if needed
  if (issue.status === TICKET_STATUS.OPEN) {
    await supabase
      .from('issues')
      .update({ 
        status: TICKET_STATUS.IN_PROGRESS,
        updated_at: new Date().toISOString()
      })
      .eq('id', issue_id);
  }

  res.status(201).json({
    success: true,
    message: 'Ticket created successfully',
    data: { ticket }
  });
});

// Update ticket
const updateTicket = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { assigned_to, department_id, priority, status, due_date } = req.body;
  const user_id = req.user.id;

  // Check if ticket exists
  const { data: existingTicket, error: ticketError } = await supabase
    .from('tickets')
    .select('id, status, assigned_to, department_id')
    .eq('id', id)
    .single();

  if (ticketError) {
    throw new AppError('Ticket not found', 404);
  }

  // Validate assigned user if provided
  if (assigned_to) {
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('id, department_id')
      .eq('id', assigned_to)
      .single();

    if (userError) {
      throw new AppError('Assigned user not found', 400);
    }

    // Ensure user belongs to the assigned department
    const targetDeptId = department_id || existingTicket.department_id;
    if (user.department_id !== targetDeptId) {
      throw new AppError('Assigned user must belong to the selected department', 400);
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

  const updateData = {
    updated_at: new Date().toISOString()
  };

  if (assigned_to) updateData.assigned_to = assigned_to;
  if (department_id) updateData.department_id = department_id;
  if (priority) updateData.priority = priority;
  if (status) updateData.status = status;
  if (due_date) updateData.due_date = due_date;

  const { data: ticket, error } = await supabase
    .from('tickets')
    .update(updateData)
    .eq('id', id)
    .select()
    .single();

  if (error) {
    throw new AppError('Failed to update ticket', 500);
  }

  // Log changes in history
  const changes = [];
  if (assigned_to && assigned_to !== existingTicket.assigned_to) {
    changes.push(`Assigned to user ${assigned_to}`);
  }
  if (status && status !== existingTicket.status) {
    changes.push(`Status changed to ${status}`);
  }
  if (priority) {
    changes.push(`Priority changed to ${priority}`);
  }

  if (changes.length > 0) {
    await supabase
      .from('ticket_history')
      .insert({
        ticket_id: id,
        action: changes.join(', '),
        performed_by: user_id,
        created_at: new Date().toISOString()
      });
  }

  res.json({
    success: true,
    message: 'Ticket updated successfully',
    data: { ticket }
  });
});

// Delete ticket
const deleteTicket = asyncHandler(async (req, res) => {
  const { id } = req.params;

  // Check if ticket exists
  const { data: ticket, error: ticketError } = await supabase
    .from('tickets')
    .select('id')
    .eq('id', id)
    .single();

  if (ticketError) {
    throw new AppError('Ticket not found', 404);
  }

  // Delete related records first
  await supabase
    .from('ticket_history')
    .delete()
    .eq('ticket_id', id);

  await supabase
    .from('comments')
    .delete()
    .eq('ticket_id', id);

  await supabase
    .from('attachments')
    .delete()
    .eq('ticket_id', id);

  await supabase
    .from('ticket_sla')
    .delete()
    .eq('ticket_id', id);

  // Delete ticket
  const { error: deleteError } = await supabase
    .from('tickets')
    .delete()
    .eq('id', id);

  if (deleteError) {
    throw new AppError('Failed to delete ticket', 500);
  }

  res.json({
    success: true,
    message: 'Ticket deleted successfully'
  });
});

// Get ticket history
const getTicketHistory = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { page = 1, limit = 10 } = req.query;
  const offset = (page - 1) * limit;

  const { data: history, error, count } = await supabase
    .from('ticket_history')
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
    .eq('ticket_id', id)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) {
    throw new AppError('Failed to fetch ticket history', 500);
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

// Get tickets by department
const getTicketsByDepartment = asyncHandler(async (req, res) => {
  const { department_id } = req.params;
  const { page = 1, limit = 10, status, priority } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('tickets')
    .select(`
      id,
      ticket_number,
      issue_id,
      assigned_to,
      priority,
      status,
      due_date,
      created_at,
      updated_at,
      issue:issue_id (
        id,
        title,
        citizen:citizen_id (
          id,
          full_name,
          email
        )
      ),
      assigned_user:assigned_to (
        id,
        full_name,
        email
      )
    `, { count: 'exact' })
    .eq('department_id', department_id);

  if (status) {
    query = query.eq('status', status);
  }
  if (priority) {
    query = query.eq('priority', priority);
  }

  query = query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  const { data: tickets, error, count } = await query;

  if (error) {
    throw new AppError('Failed to fetch tickets', 500);
  }

  res.json({
    success: true,
    data: {
      tickets,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get tickets by assigned user
const getTicketsByAssignedUser = asyncHandler(async (req, res) => {
  const { user_id } = req.params;
  const { page = 1, limit = 10, status, priority } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('tickets')
    .select(`
      id,
      ticket_number,
      issue_id,
      department_id,
      priority,
      status,
      due_date,
      created_at,
      updated_at,
      issue:issue_id (
        id,
        title,
        citizen:citizen_id (
          id,
          full_name,
          email
        )
      ),
      department:department_id (
        id,
        name
      )
    `, { count: 'exact' })
    .eq('assigned_to', user_id);

  if (status) {
    query = query.eq('status', status);
  }
  if (priority) {
    query = query.eq('priority', priority);
  }

  query = query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  const { data: tickets, error, count } = await query;

  if (error) {
    throw new AppError('Failed to fetch tickets', 500);
  }

  res.json({
    success: true,
    data: {
      tickets,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get ticket statistics
const getTicketStats = asyncHandler(async (req, res) => {
  const { data: stats, error } = await supabase
    .from('tickets')
    .select('status, priority')
    .then(({ data }) => {
      const statusCounts = data.reduce((acc, ticket) => {
        acc[ticket.status] = (acc[ticket.status] || 0) + 1;
        return acc;
      }, {});

      const priorityCounts = data.reduce((acc, ticket) => {
        acc[ticket.priority] = (acc[ticket.priority] || 0) + 1;
        return acc;
      }, {});

      return {
        data: {
          total: data.length,
          by_status: statusCounts,
          by_priority: priorityCounts
        }
      };
    });

  if (error) {
    throw new AppError('Failed to fetch ticket statistics', 500);
  }

  res.json({
    success: true,
    data: stats
  });
});

module.exports = {
  getAllTickets,
  getTicketById,
  createTicket,
  updateTicket,
  deleteTicket,
  getTicketHistory,
  getTicketsByDepartment,
  getTicketsByAssignedUser,
  getTicketStats
};
