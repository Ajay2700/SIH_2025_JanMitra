const { supabase } = require('../config/supabase');
const { asyncHandler, AppError } = require('../middleware/errorHandler');

// Record analytics metric
const recordMetric = asyncHandler(async (req, res) => {
  const { metric, value } = req.body;

  const { data: analytics, error } = await supabase
    .from('analytics')
    .insert({
      metric,
      value,
      recorded_at: new Date().toISOString()
    })
    .select()
    .single();

  if (error) {
    throw new AppError('Failed to record analytics metric', 500);
  }

  res.status(201).json({
    success: true,
    message: 'Analytics metric recorded successfully',
    data: { analytics }
  });
});

// Get analytics metrics
const getAnalytics = asyncHandler(async (req, res) => {
  const { 
    page = 1, 
    limit = 10, 
    metric, 
    start_date, 
    end_date,
    sort_by = 'recorded_at',
    sort_order = 'desc'
  } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('analytics')
    .select('*', { count: 'exact' });

  // Apply filters
  if (metric) {
    query = query.eq('metric', metric);
  }
  if (start_date) {
    query = query.gte('recorded_at', start_date);
  }
  if (end_date) {
    query = query.lte('recorded_at', end_date);
  }

  // Apply sorting
  const ascending = sort_order === 'asc';
  query = query.order(sort_by, { ascending });

  // Apply pagination
  query = query.range(offset, offset + limit - 1);

  const { data: analytics, error, count } = await query;

  if (error) {
    throw new AppError('Failed to fetch analytics', 500);
  }

  res.json({
    success: true,
    data: {
      analytics,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get analytics summary
const getAnalyticsSummary = asyncHandler(async (req, res) => {
  const { start_date, end_date } = req.query;

  let query = supabase
    .from('analytics')
    .select('metric, value, recorded_at');

  if (start_date) {
    query = query.gte('recorded_at', start_date);
  }
  if (end_date) {
    query = query.lte('recorded_at', end_date);
  }

  const { data: analytics, error } = await query;

  if (error) {
    throw new AppError('Failed to fetch analytics summary', 500);
  }

  // Group by metric and calculate statistics
  const summary = analytics.reduce((acc, item) => {
    if (!acc[item.metric]) {
      acc[item.metric] = {
        values: [],
        count: 0,
        sum: 0,
        min: Infinity,
        max: -Infinity
      };
    }

    const value = parseFloat(item.value);
    acc[item.metric].values.push(value);
    acc[item.metric].count++;
    acc[item.metric].sum += value;
    acc[item.metric].min = Math.min(acc[item.metric].min, value);
    acc[item.metric].max = Math.max(acc[item.metric].max, value);
  }, {});

  // Calculate averages
  Object.keys(summary).forEach(metric => {
    summary[metric].average = summary[metric].sum / summary[metric].count;
  });

  res.json({
    success: true,
    data: { summary }
  });
});

// Get dashboard analytics
const getDashboardAnalytics = asyncHandler(async (req, res) => {
  const { start_date, end_date } = req.query;

  // Get date range
  const startDate = start_date ? new Date(start_date) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000); // 30 days ago
  const endDate = end_date ? new Date(end_date) : new Date();

  // Get ticket statistics
  const { data: ticketStats, error: ticketError } = await supabase
    .from('tickets')
    .select('status, priority, created_at, department_id')
    .gte('created_at', startDate.toISOString())
    .lte('created_at', endDate.toISOString());

  if (ticketError) {
    throw new AppError('Failed to fetch ticket statistics', 500);
  }

  // Get issue statistics
  const { data: issueStats, error: issueError } = await supabase
    .from('issues')
    .select('status, created_at, category_id')
    .gte('created_at', startDate.toISOString())
    .lte('created_at', endDate.toISOString());

  if (issueError) {
    throw new AppError('Failed to fetch issue statistics', 500);
  }

  // Get user statistics
  const { data: userStats, error: userError } = await supabase
    .from('users')
    .select('role, created_at, department_id')
    .gte('created_at', startDate.toISOString())
    .lte('created_at', endDate.toISOString());

  if (userError) {
    throw new AppError('Failed to fetch user statistics', 500);
  }

  // Get feedback statistics
  const { data: feedbackStats, error: feedbackError } = await supabase
    .from('feedback')
    .select('rating, created_at')
    .gte('created_at', startDate.toISOString())
    .lte('created_at', endDate.toISOString());

  if (feedbackError) {
    throw new AppError('Failed to fetch feedback statistics', 500);
  }

  // Process ticket statistics
  const ticketStatusCounts = ticketStats.reduce((acc, ticket) => {
    acc[ticket.status] = (acc[ticket.status] || 0) + 1;
    return acc;
  }, {});

  const ticketPriorityCounts = ticketStats.reduce((acc, ticket) => {
    acc[ticket.priority] = (acc[ticket.priority] || 0) + 1;
    return acc;
  }, {});

  // Process issue statistics
  const issueStatusCounts = issueStats.reduce((acc, issue) => {
    acc[issue.status] = (acc[issue.status] || 0) + 1;
    return acc;
  }, {});

  // Process user statistics
  const userRoleCounts = userStats.reduce((acc, user) => {
    acc[user.role] = (acc[user.role] || 0) + 1;
    return acc;
  }, {});

  // Process feedback statistics
  const feedbackRatingCounts = feedbackStats.reduce((acc, feedback) => {
    acc[feedback.rating] = (acc[feedback.rating] || 0) + 1;
    return acc;
  }, {});

  const averageRating = feedbackStats.length > 0 
    ? feedbackStats.reduce((sum, feedback) => sum + feedback.rating, 0) / feedbackStats.length 
    : 0;

  // Get daily trends
  const dailyTrends = {};
  const currentDate = new Date(startDate);
  while (currentDate <= endDate) {
    const dateStr = currentDate.toISOString().split('T')[0];
    dailyTrends[dateStr] = {
      tickets: 0,
      issues: 0,
      users: 0,
      feedback: 0
    };
    currentDate.setDate(currentDate.getDate() + 1);
  }

  // Populate daily trends
  ticketStats.forEach(ticket => {
    const dateStr = ticket.created_at.split('T')[0];
    if (dailyTrends[dateStr]) {
      dailyTrends[dateStr].tickets++;
    }
  });

  issueStats.forEach(issue => {
    const dateStr = issue.created_at.split('T')[0];
    if (dailyTrends[dateStr]) {
      dailyTrends[dateStr].issues++;
    }
  });

  userStats.forEach(user => {
    const dateStr = user.created_at.split('T')[0];
    if (dailyTrends[dateStr]) {
      dailyTrends[dateStr].users++;
    }
  });

  feedbackStats.forEach(feedback => {
    const dateStr = feedback.created_at.split('T')[0];
    if (dailyTrends[dateStr]) {
      dailyTrends[dateStr].feedback++;
    }
  });

  res.json({
    success: true,
    data: {
      period: {
        start_date: startDate.toISOString(),
        end_date: endDate.toISOString()
      },
      tickets: {
        total: ticketStats.length,
        by_status: ticketStatusCounts,
        by_priority: ticketPriorityCounts
      },
      issues: {
        total: issueStats.length,
        by_status: issueStatusCounts
      },
      users: {
        total: userStats.length,
        by_role: userRoleCounts
      },
      feedback: {
        total: feedbackStats.length,
        average_rating: averageRating.toFixed(2),
        by_rating: feedbackRatingCounts
      },
      daily_trends: dailyTrends
    }
  });
});

// Get department performance analytics
const getDepartmentPerformance = asyncHandler(async (req, res) => {
  const { start_date, end_date } = req.query;

  const startDate = start_date ? new Date(start_date) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const endDate = end_date ? new Date(end_date) : new Date();

  // Get department statistics
  const { data: deptStats, error: deptError } = await supabase
    .from('departments')
    .select(`
      id,
      name,
      tickets:tickets!department_id (
        id,
        status,
        priority,
        created_at,
        updated_at
      ),
      users:users!department_id (
        id,
        role
      )
    `);

  if (deptError) {
    throw new AppError('Failed to fetch department statistics', 500);
  }

  // Process department data
  const departmentPerformance = deptStats.map(dept => {
    const tickets = dept.tickets.filter(ticket => {
      const ticketDate = new Date(ticket.created_at);
      return ticketDate >= startDate && ticketDate <= endDate;
    });

    const openTickets = tickets.filter(t => ['open', 'in_progress'].includes(t.status)).length;
    const resolvedTickets = tickets.filter(t => t.status === 'resolved').length;
    const closedTickets = tickets.filter(t => t.status === 'closed').length;
    const totalTickets = tickets.length;

    const staffCount = dept.users.filter(u => ['staff', 'admin'].includes(u.role)).length;

    // Calculate average resolution time
    const resolvedTicketsWithTime = tickets.filter(t => t.status === 'resolved' && t.updated_at);
    const avgResolutionTime = resolvedTicketsWithTime.length > 0 
      ? resolvedTicketsWithTime.reduce((sum, ticket) => {
          const created = new Date(ticket.created_at);
          const updated = new Date(ticket.updated_at);
          return sum + (updated - created);
        }, 0) / resolvedTicketsWithTime.length
      : 0;

    return {
      department_id: dept.id,
      department_name: dept.name,
      total_tickets: totalTickets,
      open_tickets: openTickets,
      resolved_tickets: resolvedTickets,
      closed_tickets: closedTickets,
      staff_count: staffCount,
      resolution_rate: totalTickets > 0 ? ((resolvedTickets + closedTickets) / totalTickets * 100).toFixed(2) : 0,
      average_resolution_time_hours: (avgResolutionTime / (1000 * 60 * 60)).toFixed(2)
    };
  });

  res.json({
    success: true,
    data: {
      period: {
        start_date: startDate.toISOString(),
        end_date: endDate.toISOString()
      },
      departments: departmentPerformance
    }
  });
});

// Get category analytics
const getCategoryAnalytics = asyncHandler(async (req, res) => {
  const { start_date, end_date } = req.query;

  const startDate = start_date ? new Date(start_date) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const endDate = end_date ? new Date(end_date) : new Date();

  // Get category statistics
  const { data: categoryStats, error: categoryError } = await supabase
    .from('ticket_categories')
    .select(`
      id,
      name,
      department_id,
      issues:issues!category_id (
        id,
        status,
        created_at,
        updated_at
      ),
      department:department_id (
        id,
        name
      )
    `);

  if (categoryError) {
    throw new AppError('Failed to fetch category statistics', 500);
  }

  // Process category data
  const categoryAnalytics = categoryStats.map(category => {
    const issues = category.issues.filter(issue => {
      const issueDate = new Date(issue.created_at);
      return issueDate >= startDate && issueDate <= endDate;
    });

    const openIssues = issues.filter(i => ['open', 'in_progress'].includes(i.status)).length;
    const resolvedIssues = issues.filter(i => i.status === 'resolved').length;
    const closedIssues = issues.filter(i => i.status === 'closed').length;
    const totalIssues = issues.length;

    return {
      category_id: category.id,
      category_name: category.name,
      department_name: category.department?.name || 'N/A',
      total_issues: totalIssues,
      open_issues: openIssues,
      resolved_issues: resolvedIssues,
      closed_issues: closedIssues,
      resolution_rate: totalIssues > 0 ? ((resolvedIssues + closedIssues) / totalIssues * 100).toFixed(2) : 0
    };
  });

  res.json({
    success: true,
    data: {
      period: {
        start_date: startDate.toISOString(),
        end_date: endDate.toISOString()
      },
      categories: categoryAnalytics
    }
  });
});

module.exports = {
  recordMetric,
  getAnalytics,
  getAnalyticsSummary,
  getDashboardAnalytics,
  getDepartmentPerformance,
  getCategoryAnalytics
};
