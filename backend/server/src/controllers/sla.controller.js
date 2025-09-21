const { supabase } = require('../config/supabase');
const { asyncHandler, AppError } = require('../middleware/errorHandler');
const { PRIORITY_LEVEL } = require('../models/types');

// Get all SLA configurations
const getAllSLAs = asyncHandler(async (req, res) => {
  const { page = 1, limit = 10, category_id, priority } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('sla')
    .select('*', { count: 'exact' });

  // Apply filters
  if (category_id) {
    query = query.eq('category_id', category_id);
  }
  if (priority) {
    query = query.eq('priority', priority);
  }

  query = query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  const { data: slas, error, count } = await query;

  if (error) {
    console.error('Supabase error fetching SLA configurations:', error);
    // Return empty data instead of throwing error to allow frontend to load
    return res.json({
      success: true,
      data: {
        slas: [],
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
      slas,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get SLA by ID
const getSLAById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data: sla, error } = await supabase
    .from('sla')
    .select(`
      id,
      category_id,
      priority,
      response_time,
      resolution_time,
      created_at,
      updated_at,
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
    `)
    .eq('id', id)
    .single();

  if (error) {
    throw new AppError('SLA configuration not found', 404);
  }

  res.json({
    success: true,
    data: { sla }
  });
});

// Create new SLA configuration
const createSLA = asyncHandler(async (req, res) => {
  const { category_id, priority, response_time, resolution_time } = req.body;

  // Validate category exists
  const { data: category, error: categoryError } = await supabase
    .from('ticket_categories')
    .select('id')
    .eq('id', category_id)
    .single();

  if (categoryError) {
    throw new AppError('Category not found', 400);
  }

  // Check if SLA already exists for this category and priority
  const { data: existingSLA, error: existingError } = await supabase
    .from('sla')
    .select('id')
    .eq('category_id', category_id)
    .eq('priority', priority)
    .single();

  if (existingSLA) {
    throw new AppError('SLA configuration already exists for this category and priority', 409);
  }

  const { data: sla, error } = await supabase
    .from('sla')
    .insert({
      category_id,
      priority,
      response_time,
      resolution_time,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    })
    .select(`
      id,
      category_id,
      priority,
      response_time,
      resolution_time,
      created_at,
      updated_at,
      category:category_id (
        id,
        name,
        description,
        department:department_id (
          id,
          name
        )
      )
    `)
    .single();

  if (error) {
    throw new AppError('Failed to create SLA configuration', 500);
  }

  res.status(201).json({
    success: true,
    message: 'SLA configuration created successfully',
    data: { sla }
  });
});

// Update SLA configuration
const updateSLA = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { priority, response_time, resolution_time } = req.body;

  // Check if SLA exists
  const { data: existingSLA, error: slaError } = await supabase
    .from('sla')
    .select('id, category_id, priority')
    .eq('id', id)
    .single();

  if (slaError) {
    throw new AppError('SLA configuration not found', 404);
  }

  // Check if priority is being changed and if new combination already exists
  if (priority && priority !== existingSLA.priority) {
    const { data: conflictSLA, error: conflictError } = await supabase
      .from('sla')
      .select('id')
      .eq('category_id', existingSLA.category_id)
      .eq('priority', priority)
      .neq('id', id)
      .single();

    if (conflictSLA) {
      throw new AppError('SLA configuration already exists for this category and priority', 409);
    }
  }

  const { data: sla, error } = await supabase
    .from('sla')
    .update({
      priority,
      response_time,
      resolution_time,
      updated_at: new Date().toISOString()
    })
    .eq('id', id)
    .select(`
      id,
      category_id,
      priority,
      response_time,
      resolution_time,
      created_at,
      updated_at,
      category:category_id (
        id,
        name,
        description,
        department:department_id (
          id,
          name
        )
      )
    `)
    .single();

  if (error) {
    throw new AppError('Failed to update SLA configuration', 500);
  }

  res.json({
    success: true,
    message: 'SLA configuration updated successfully',
    data: { sla }
  });
});

// Delete SLA configuration
const deleteSLA = asyncHandler(async (req, res) => {
  const { id } = req.params;

  // Check if SLA exists
  const { data: sla, error: slaError } = await supabase
    .from('sla')
    .select('id')
    .eq('id', id)
    .single();

  if (slaError) {
    throw new AppError('SLA configuration not found', 404);
  }

  // Check if SLA is being used by any tickets
  const { data: tickets, error: ticketsError } = await supabase
    .from('ticket_sla')
    .select('id')
    .eq('sla_id', id);

  if (ticketsError) {
    throw new AppError('Failed to check SLA usage', 500);
  }

  if (tickets && tickets.length > 0) {
    throw new AppError('Cannot delete SLA configuration that is being used by tickets', 400);
  }

  const { error: deleteError } = await supabase
    .from('sla')
    .delete()
    .eq('id', id);

  if (deleteError) {
    throw new AppError('Failed to delete SLA configuration', 500);
  }

  res.json({
    success: true,
    message: 'SLA configuration deleted successfully'
  });
});

// Get SLA configurations by category
const getSLAsByCategory = asyncHandler(async (req, res) => {
  const { category_id } = req.params;

  const { data: slas, error } = await supabase
    .from('sla')
    .select('*')
    .eq('category_id', category_id)
    .order('priority');

  if (error) {
    console.error('Supabase error fetching SLA configurations by category:', error);
    // Return empty data instead of throwing error to allow frontend to load
    return res.json({
      success: true,
      data: { slas: [] }
    });
  }

  res.json({
    success: true,
    data: { slas }
  });
});

// Apply SLA to ticket
const applySLAToTicket = asyncHandler(async (req, res) => {
  const { ticket_id } = req.params;

  // Get ticket details
  const { data: ticket, error: ticketError } = await supabase
    .from('tickets')
    .select(`
      id,
      priority,
      created_at,
      issue:issue_id (
        category_id
      )
    `)
    .eq('id', ticket_id)
    .single();

  if (ticketError) {
    throw new AppError('Ticket not found', 404);
  }

  // Get SLA configuration for the ticket's category and priority
  const { data: sla, error: slaError } = await supabase
    .from('sla')
    .select('id, response_time, resolution_time')
    .eq('category_id', ticket.issue.category_id)
    .eq('priority', ticket.priority)
    .single();

  if (slaError) {
    throw new AppError('No SLA configuration found for this ticket category and priority', 404);
  }

  // Calculate due dates
  const createdDate = new Date(ticket.created_at);
  const responseDue = new Date(createdDate.getTime() + parseInterval(sla.response_time));
  const resolutionDue = new Date(createdDate.getTime() + parseInterval(sla.resolution_time));

  // Create or update ticket SLA record
  const { data: ticketSLA, error: ticketSLAError } = await supabase
    .from('ticket_sla')
    .upsert({
      ticket_id,
      sla_id: sla.id,
      response_due: responseDue.toISOString(),
      resolution_due: resolutionDue.toISOString(),
      breached: false,
      created_at: new Date().toISOString()
    })
    .select(`
      id,
      ticket_id,
      sla_id,
      response_due,
      resolution_due,
      breached,
      created_at
    `)
    .single();

  if (ticketSLAError) {
    throw new AppError('Failed to apply SLA to ticket', 500);
  }

  res.json({
    success: true,
    message: 'SLA applied to ticket successfully',
    data: { ticket_sla: ticketSLA }
  });
});

// Check SLA breaches
const checkSLABreaches = asyncHandler(async (req, res) => {
  const now = new Date();

  // Get all active ticket SLAs
  const { data: ticketSLAs, error: ticketSLAError } = await supabase
    .from('ticket_sla')
    .select(`
      id,
      ticket_id,
      response_due,
      resolution_due,
      breached,
      ticket:ticket_id (
        id,
        status,
        priority,
        created_at,
        updated_at
      )
    `)
    .eq('breached', false);

  if (ticketSLAError) {
    throw new AppError('Failed to fetch ticket SLAs', 500);
  }

  const breaches = [];
  const updates = [];

  for (const ticketSLA of ticketSLAs) {
    const ticket = ticketSLA.ticket;
    const isResolved = ['resolved', 'closed'].includes(ticket.status);
    const nowTime = now.getTime();

    // Check response time breach
    const responseDueTime = new Date(ticketSLA.response_due).getTime();
    if (nowTime > responseDueTime && !isResolved) {
      breaches.push({
        ticket_id: ticket.id,
        breach_type: 'response_time',
        due_date: ticketSLA.response_due,
        current_status: ticket.status
      });
      updates.push({ id: ticketSLA.id, breached: true });
    }

    // Check resolution time breach
    const resolutionDueTime = new Date(ticketSLA.resolution_due).getTime();
    if (nowTime > resolutionDueTime && !isResolved) {
      breaches.push({
        ticket_id: ticket.id,
        breach_type: 'resolution_time',
        due_date: ticketSLA.resolution_due,
        current_status: ticket.status
      });
      updates.push({ id: ticketSLA.id, breached: true });
    }
  }

  // Update breached SLAs
  if (updates.length > 0) {
    const { error: updateError } = await supabase
      .from('ticket_sla')
      .upsert(updates);

    if (updateError) {
      throw new AppError('Failed to update breached SLAs', 500);
    }
  }

  res.json({
    success: true,
    data: {
      breaches_found: breaches.length,
      breaches,
      updated_slas: updates.length
    }
  });
});

// Get SLA statistics
const getSLAStats = asyncHandler(async (req, res) => {
  const { start_date, end_date } = req.query;

  const startDate = start_date ? new Date(start_date) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const endDate = end_date ? new Date(end_date) : new Date();

  // Get ticket SLA data
  const { data: ticketSLAs, error: ticketSLAError } = await supabase
    .from('ticket_sla')
    .select(`
      id,
      response_due,
      resolution_due,
      breached,
      created_at,
      ticket:ticket_id (
        id,
        status,
        priority,
        created_at,
        updated_at
      )
    `)
    .gte('created_at', startDate.toISOString())
    .lte('created_at', endDate.toISOString());

  if (ticketSLAError) {
    throw new AppError('Failed to fetch SLA statistics', 500);
  }

  // Process statistics
  const totalSLAs = ticketSLAs.length;
  const breachedSLAs = ticketSLAs.filter(tsla => tsla.breached).length;
  const responseBreaches = ticketSLAs.filter(tsla => {
    const now = new Date();
    const responseDue = new Date(tsla.response_due);
    return now > responseDue && !['resolved', 'closed'].includes(tsla.ticket.status);
  }).length;

  const resolutionBreaches = ticketSLAs.filter(tsla => {
    const now = new Date();
    const resolutionDue = new Date(tsla.resolution_due);
    return now > resolutionDue && !['resolved', 'closed'].includes(tsla.ticket.status);
  }).length;

  const breachRate = totalSLAs > 0 ? (breachedSLAs / totalSLAs * 100).toFixed(2) : 0;

  res.json({
    success: true,
    data: {
      period: {
        start_date: startDate.toISOString(),
        end_date: endDate.toISOString()
      },
      total_slas: totalSLAs,
      breached_slas: breachedSLAs,
      response_breaches: responseBreaches,
      resolution_breaches: resolutionBreaches,
      breach_rate: breachRate,
      compliance_rate: (100 - breachRate).toFixed(2)
    }
  });
});

// Helper function to parse interval strings (e.g., "2 hours", "1 day")
const parseInterval = (interval) => {
  const match = interval.match(/(\d+)\s*(hour|day|minute)s?/i);
  if (!match) return 0;

  const value = parseInt(match[1]);
  const unit = match[2].toLowerCase();

  switch (unit) {
    case 'minute':
      return value * 60 * 1000;
    case 'hour':
      return value * 60 * 60 * 1000;
    case 'day':
      return value * 24 * 60 * 60 * 1000;
    default:
      return 0;
  }
};

module.exports = {
  getAllSLAs,
  getSLAById,
  createSLA,
  updateSLA,
  deleteSLA,
  getSLAsByCategory,
  applySLAToTicket,
  checkSLABreaches,
  getSLAStats
};
