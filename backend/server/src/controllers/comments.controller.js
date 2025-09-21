const { supabase } = require('../config/supabase');
const { asyncHandler, AppError } = require('../middleware/errorHandler');

// Get all comments for a ticket
const getCommentsByTicket = asyncHandler(async (req, res) => {
  const { ticket_id } = req.params;
  const { page = 1, limit = 10 } = req.query;
  const offset = (page - 1) * limit;

  const { data: comments, error, count } = await supabase
    .from('comments')
    .select(`
      id,
      content,
      created_at,
      updated_at,
      user:user_id (
        id,
        full_name,
        email,
        role
      )
    `, { count: 'exact' })
    .eq('ticket_id', ticket_id)
    .order('created_at', { ascending: true })
    .range(offset, offset + limit - 1);

  if (error) {
    throw new AppError('Failed to fetch comments', 500);
  }

  res.json({
    success: true,
    data: {
      comments,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get comment by ID
const getCommentById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data: comment, error } = await supabase
    .from('comments')
    .select(`
      id,
      ticket_id,
      content,
      created_at,
      updated_at,
      user:user_id (
        id,
        full_name,
        email,
        role
      )
    `)
    .eq('id', id)
    .single();

  if (error) {
    throw new AppError('Comment not found', 404);
  }

  res.json({
    success: true,
    data: { comment }
  });
});

// Create new comment
const createComment = asyncHandler(async (req, res) => {
  const { ticket_id, content } = req.body;
  const user_id = req.user.id;

  // Validate ticket exists
  const { data: ticket, error: ticketError } = await supabase
    .from('tickets')
    .select('id, status')
    .eq('id', ticket_id)
    .single();

  if (ticketError) {
    throw new AppError('Ticket not found', 400);
  }

  // Check if ticket is closed (citizens can't comment on closed tickets)
  if (ticket.status === 'closed' && req.user.role === 'citizen') {
    throw new AppError('Cannot comment on closed tickets', 400);
  }

  const { data: comment, error } = await supabase
    .from('comments')
    .insert({
      ticket_id,
      user_id,
      content,
      created_at: new Date().toISOString()
    })
    .select(`
      id,
      ticket_id,
      content,
      created_at,
      user:user_id (
        id,
        full_name,
        email,
        role
      )
    `)
    .single();

  if (error) {
    throw new AppError('Failed to create comment', 500);
  }

  // Log comment addition in ticket history
  await supabase
    .from('ticket_history')
    .insert({
      ticket_id,
      action: 'Comment added',
      performed_by: user_id,
      created_at: new Date().toISOString()
    });

  res.status(201).json({
    success: true,
    message: 'Comment created successfully',
    data: { comment }
  });
});

// Update comment
const updateComment = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { content } = req.body;
  const user_id = req.user.id;

  // Check if comment exists and user has permission
  const { data: existingComment, error: commentError } = await supabase
    .from('comments')
    .select('id, user_id, ticket_id')
    .eq('id', id)
    .single();

  if (commentError) {
    throw new AppError('Comment not found', 404);
  }

  // Check permissions (user can only update their own comments, admins can update any)
  if (req.user.role === 'citizen' && existingComment.user_id !== user_id) {
    throw new AppError('You can only update your own comments', 403);
  }

  // Check if ticket is closed (citizens can't update comments on closed tickets)
  if (req.user.role === 'citizen') {
    const { data: ticket, error: ticketError } = await supabase
      .from('tickets')
      .select('status')
      .eq('id', existingComment.ticket_id)
      .single();

    if (ticketError) {
      throw new AppError('Ticket not found', 400);
    }

    if (ticket.status === 'closed') {
      throw new AppError('Cannot update comments on closed tickets', 400);
    }
  }

  const { data: comment, error } = await supabase
    .from('comments')
    .update({
      content,
      updated_at: new Date().toISOString()
    })
    .eq('id', id)
    .select(`
      id,
      ticket_id,
      content,
      created_at,
      updated_at,
      user:user_id (
        id,
        full_name,
        email,
        role
      )
    `)
    .single();

  if (error) {
    throw new AppError('Failed to update comment', 500);
  }

  res.json({
    success: true,
    message: 'Comment updated successfully',
    data: { comment }
  });
});

// Delete comment
const deleteComment = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const user_id = req.user.id;

  // Check if comment exists and user has permission
  const { data: comment, error: commentError } = await supabase
    .from('comments')
    .select('id, user_id, ticket_id')
    .eq('id', id)
    .single();

  if (commentError) {
    throw new AppError('Comment not found', 404);
  }

  // Check permissions (user can only delete their own comments, admins can delete any)
  if (req.user.role === 'citizen' && comment.user_id !== user_id) {
    throw new AppError('You can only delete your own comments', 403);
  }

  // Check if ticket is closed (citizens can't delete comments on closed tickets)
  if (req.user.role === 'citizen') {
    const { data: ticket, error: ticketError } = await supabase
      .from('tickets')
      .select('status')
      .eq('id', comment.ticket_id)
      .single();

    if (ticketError) {
      throw new AppError('Ticket not found', 400);
    }

    if (ticket.status === 'closed') {
      throw new AppError('Cannot delete comments on closed tickets', 400);
    }
  }

  const { error: deleteError } = await supabase
    .from('comments')
    .delete()
    .eq('id', id);

  if (deleteError) {
    throw new AppError('Failed to delete comment', 500);
  }

  res.json({
    success: true,
    message: 'Comment deleted successfully'
  });
});

// Get comments by user
const getCommentsByUser = asyncHandler(async (req, res) => {
  const { user_id } = req.params;
  const { page = 1, limit = 10 } = req.query;
  const offset = (page - 1) * limit;

  const { data: comments, error, count } = await supabase
    .from('comments')
    .select(`
      id,
      ticket_id,
      content,
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
    .eq('user_id', user_id)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) {
    throw new AppError('Failed to fetch comments', 500);
  }

  res.json({
    success: true,
    data: {
      comments,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get comment statistics
const getCommentStats = asyncHandler(async (req, res) => {
  const { ticket_id } = req.params;

  const { data: stats, error } = await supabase
    .from('comments')
    .select('id, user_id, created_at')
    .eq('ticket_id', ticket_id)
    .then(({ data }) => {
      const userCounts = data.reduce((acc, comment) => {
        acc[comment.user_id] = (acc[comment.user_id] || 0) + 1;
        return acc;
      }, {});

      return {
        data: {
          total: data.length,
          by_user: userCounts,
          first_comment: data.length > 0 ? data[data.length - 1].created_at : null,
          last_comment: data.length > 0 ? data[0].created_at : null
        }
      };
    });

  if (error) {
    throw new AppError('Failed to fetch comment statistics', 500);
  }

  res.json({
    success: true,
    data: stats
  });
});

module.exports = {
  getCommentsByTicket,
  getCommentById,
  createComment,
  updateComment,
  deleteComment,
  getCommentsByUser,
  getCommentStats
};
