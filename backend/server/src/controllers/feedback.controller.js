const { supabase } = require('../config/supabase');
const { asyncHandler, AppError } = require('../middleware/errorHandler');

// Get all feedback
const getAllFeedback = asyncHandler(async (req, res) => {
  const { page = 1, limit = 10, rating, ticket_id, citizen_id } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('feedback')
    .select(`
      id,
      ticket_id,
      citizen_id,
      rating,
      comments,
      created_at,
      ticket:ticket_id (
        id,
        ticket_number,
        status,
        issue:issue_id (
          id,
          title
        )
      ),
      citizen:citizen_id (
        id,
        full_name,
        email
      )
    `, { count: 'exact' });

  // Apply filters
  if (rating) {
    query = query.eq('rating', parseInt(rating));
  }
  if (ticket_id) {
    query = query.eq('ticket_id', ticket_id);
  }
  if (citizen_id) {
    query = query.eq('citizen_id', citizen_id);
  }

  query = query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  const { data: feedback, error, count } = await query;

  if (error) {
    throw new AppError('Failed to fetch feedback', 500);
  }

  res.json({
    success: true,
    data: {
      feedback,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get feedback by ID
const getFeedbackById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data: feedback, error } = await supabase
    .from('feedback')
    .select(`
      id,
      ticket_id,
      citizen_id,
      rating,
      comments,
      created_at,
      ticket:ticket_id (
        id,
        ticket_number,
        status,
        priority,
        created_at,
        issue:issue_id (
          id,
          title,
          description,
          citizen:citizen_id (
            id,
            full_name,
            email
          )
        )
      ),
      citizen:citizen_id (
        id,
        full_name,
        email,
        phone
      )
    `)
    .eq('id', id)
    .single();

  if (error) {
    throw new AppError('Feedback not found', 404);
  }

  res.json({
    success: true,
    data: { feedback }
  });
});

// Create new feedback
const createFeedback = asyncHandler(async (req, res) => {
  const { ticket_id, rating, comments } = req.body;
  const citizen_id = req.user.id;

  // Validate ticket exists and is resolved/closed
  const { data: ticket, error: ticketError } = await supabase
    .from('tickets')
    .select('id, status, issue_id')
    .eq('id', ticket_id)
    .single();

  if (ticketError) {
    throw new AppError('Ticket not found', 400);
  }

  // Check if ticket is resolved or closed
  if (!['resolved', 'closed'].includes(ticket.status)) {
    throw new AppError('Feedback can only be provided for resolved or closed tickets', 400);
  }

  // Check if user has already provided feedback for this ticket
  const { data: existingFeedback, error: existingError } = await supabase
    .from('feedback')
    .select('id')
    .eq('ticket_id', ticket_id)
    .eq('citizen_id', citizen_id)
    .single();

  if (existingFeedback) {
    throw new AppError('Feedback already provided for this ticket', 409);
  }

  // Verify that the citizen is the one who created the original issue
  const { data: issue, error: issueError } = await supabase
    .from('issues')
    .select('citizen_id')
    .eq('id', ticket.issue_id)
    .single();

  if (issueError) {
    throw new AppError('Issue not found', 400);
  }

  if (issue.citizen_id !== citizen_id) {
    throw new AppError('You can only provide feedback for tickets related to your issues', 403);
  }

  const { data: feedback, error } = await supabase
    .from('feedback')
    .insert({
      ticket_id,
      citizen_id,
      rating,
      comments,
      created_at: new Date().toISOString()
    })
    .select(`
      id,
      ticket_id,
      citizen_id,
      rating,
      comments,
      created_at,
      ticket:ticket_id (
        id,
        ticket_number,
        status
      ),
      citizen:citizen_id (
        id,
        full_name,
        email
      )
    `)
    .single();

  if (error) {
    throw new AppError('Failed to create feedback', 500);
  }

  res.status(201).json({
    success: true,
    message: 'Feedback submitted successfully',
    data: { feedback }
  });
});

// Update feedback (only by the citizen who created it)
const updateFeedback = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { rating, comments } = req.body;
  const citizen_id = req.user.id;

  // Check if feedback exists and belongs to user
  const { data: existingFeedback, error: feedbackError } = await supabase
    .from('feedback')
    .select('id, citizen_id, created_at')
    .eq('id', id)
    .eq('citizen_id', citizen_id)
    .single();

  if (feedbackError) {
    throw new AppError('Feedback not found or you do not have permission to update it', 404);
  }

  // Check if feedback is too old to update (e.g., more than 7 days)
  const feedbackDate = new Date(existingFeedback.created_at);
  const now = new Date();
  const daysDiff = (now - feedbackDate) / (1000 * 60 * 60 * 24);

  if (daysDiff > 7) {
    throw new AppError('Feedback cannot be updated after 7 days', 400);
  }

  const { data: feedback, error } = await supabase
    .from('feedback')
    .update({
      rating,
      comments,
      updated_at: new Date().toISOString()
    })
    .eq('id', id)
    .select(`
      id,
      ticket_id,
      citizen_id,
      rating,
      comments,
      created_at,
      updated_at,
      ticket:ticket_id (
        id,
        ticket_number,
        status
      ),
      citizen:citizen_id (
        id,
        full_name,
        email
      )
    `)
    .single();

  if (error) {
    throw new AppError('Failed to update feedback', 500);
  }

  res.json({
    success: true,
    message: 'Feedback updated successfully',
    data: { feedback }
  });
});

// Delete feedback (only by the citizen who created it)
const deleteFeedback = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const citizen_id = req.user.id;

  // Check if feedback exists and belongs to user
  const { data: feedback, error: feedbackError } = await supabase
    .from('feedback')
    .select('id, citizen_id')
    .eq('id', id)
    .eq('citizen_id', citizen_id)
    .single();

  if (feedbackError) {
    throw new AppError('Feedback not found or you do not have permission to delete it', 404);
  }

  const { error: deleteError } = await supabase
    .from('feedback')
    .delete()
    .eq('id', id);

  if (deleteError) {
    throw new AppError('Failed to delete feedback', 500);
  }

  res.json({
    success: true,
    message: 'Feedback deleted successfully'
  });
});

// Get feedback by ticket
const getFeedbackByTicket = asyncHandler(async (req, res) => {
  const { ticket_id } = req.params;

  const { data: feedback, error } = await supabase
    .from('feedback')
    .select(`
      id,
      citizen_id,
      rating,
      comments,
      created_at,
      updated_at,
      citizen:citizen_id (
        id,
        full_name,
        email
      )
    `)
    .eq('ticket_id', ticket_id)
    .single();

  if (error) {
    throw new AppError('No feedback found for this ticket', 404);
  }

  res.json({
    success: true,
    data: { feedback }
  });
});

// Get feedback by citizen
const getFeedbackByCitizen = asyncHandler(async (req, res) => {
  const { citizen_id } = req.params;
  const { page = 1, limit = 10, rating } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('feedback')
    .select(`
      id,
      ticket_id,
      rating,
      comments,
      created_at,
      updated_at,
      ticket:ticket_id (
        id,
        ticket_number,
        status,
        issue:issue_id (
          id,
          title
        )
      )
    `, { count: 'exact' })
    .eq('citizen_id', citizen_id);

  if (rating) {
    query = query.eq('rating', parseInt(rating));
  }

  query = query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  const { data: feedback, error, count } = await query;

  if (error) {
    throw new AppError('Failed to fetch feedback', 500);
  }

  res.json({
    success: true,
    data: {
      feedback,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get feedback statistics
const getFeedbackStats = asyncHandler(async (req, res) => {
  const { data: stats, error } = await supabase
    .from('feedback')
    .select('rating, created_at')
    .then(({ data }) => {
      const ratingCounts = data.reduce((acc, feedback) => {
        acc[feedback.rating] = (acc[feedback.rating] || 0) + 1;
        return acc;
      }, {});

      const total = data.length;
      const average = total > 0 ? data.reduce((sum, feedback) => sum + feedback.rating, 0) / total : 0;

      // Calculate distribution percentages
      const distribution = {};
      for (let i = 1; i <= 5; i++) {
        distribution[i] = {
          count: ratingCounts[i] || 0,
          percentage: total > 0 ? ((ratingCounts[i] || 0) / total * 100).toFixed(2) : 0
        };
      }

      return {
        data: {
          total,
          average: average.toFixed(2),
          distribution,
          by_rating: ratingCounts
        }
      };
    });

  if (error) {
    throw new AppError('Failed to fetch feedback statistics', 500);
  }

  res.json({
    success: true,
    data: stats
  });
});

// Get feedback statistics by department
const getFeedbackStatsByDepartment = asyncHandler(async (req, res) => {
  const { department_id } = req.params;

  const { data: stats, error } = await supabase
    .from('feedback')
    .select(`
      rating,
      ticket:ticket_id (
        department_id
      )
    `)
    .eq('ticket.department_id', department_id)
    .then(({ data }) => {
      const ratingCounts = data.reduce((acc, feedback) => {
        acc[feedback.rating] = (acc[feedback.rating] || 0) + 1;
        return acc;
      }, {});

      const total = data.length;
      const average = total > 0 ? data.reduce((sum, feedback) => sum + feedback.rating, 0) / total : 0;

      return {
        data: {
          total,
          average: average.toFixed(2),
          by_rating: ratingCounts
        }
      };
    });

  if (error) {
    throw new AppError('Failed to fetch feedback statistics', 500);
  }

  res.json({
    success: true,
    data: stats
  });
});

module.exports = {
  getAllFeedback,
  getFeedbackById,
  createFeedback,
  updateFeedback,
  deleteFeedback,
  getFeedbackByTicket,
  getFeedbackByCitizen,
  getFeedbackStats,
  getFeedbackStatsByDepartment
};
