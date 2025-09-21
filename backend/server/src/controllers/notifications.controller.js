const { supabase } = require('../config/supabase');
const { asyncHandler, AppError } = require('../middleware/errorHandler');
const { NOTIFICATION_TYPE } = require('../models/types');

// Get all notifications for a user
const getNotificationsByUser = asyncHandler(async (req, res) => {
  const { user_id } = req.params;
  const { page = 1, limit = 10, read, type } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('notifications')
    .select(`
      id,
      type,
      content,
      read,
      created_at,
      user:user_id (
        id,
        full_name,
        email
      )
    `, { count: 'exact' })
    .eq('user_id', user_id);

  // Apply filters
  if (read !== undefined) {
    query = query.eq('read', read === 'true');
  }
  if (type) {
    query = query.eq('type', type);
  }

  query = query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  const { data: notifications, error, count } = await query;

  if (error) {
    throw new AppError('Failed to fetch notifications', 500);
  }

  res.json({
    success: true,
    data: {
      notifications,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get current user's notifications
const getMyNotifications = asyncHandler(async (req, res) => {
  const user_id = req.user.id;
  const { page = 1, limit = 10, read, type } = req.query;
  const offset = (page - 1) * limit;

  let query = supabase
    .from('notifications')
    .select(`
      id,
      type,
      content,
      read,
      created_at
    `, { count: 'exact' })
    .eq('user_id', user_id);

  // Apply filters
  if (read !== undefined) {
    query = query.eq('read', read === 'true');
  }
  if (type) {
    query = query.eq('type', type);
  }

  query = query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  const { data: notifications, error, count } = await query;

  if (error) {
    throw new AppError('Failed to fetch notifications', 500);
  }

  res.json({
    success: true,
    data: {
      notifications,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    }
  });
});

// Get notification by ID
const getNotificationById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const { data: notification, error } = await supabase
    .from('notifications')
    .select(`
      id,
      user_id,
      type,
      content,
      read,
      created_at,
      user:user_id (
        id,
        full_name,
        email
      )
    `)
    .eq('id', id)
    .single();

  if (error) {
    throw new AppError('Notification not found', 404);
  }

  res.json({
    success: true,
    data: { notification }
  });
});

// Create new notification
const createNotification = asyncHandler(async (req, res) => {
  const { user_id, type, content } = req.body;

  // Validate user exists
  const { data: user, error: userError } = await supabase
    .from('users')
    .select('id')
    .eq('id', user_id)
    .single();

  if (userError) {
    throw new AppError('User not found', 400);
  }

  const { data: notification, error } = await supabase
    .from('notifications')
    .insert({
      user_id,
      type,
      content,
      read: false,
      created_at: new Date().toISOString()
    })
    .select(`
      id,
      user_id,
      type,
      content,
      read,
      created_at
    `)
    .single();

  if (error) {
    throw new AppError('Failed to create notification', 500);
  }

  res.status(201).json({
    success: true,
    message: 'Notification created successfully',
    data: { notification }
  });
});

// Mark notification as read
const markAsRead = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const user_id = req.user.id;

  // Check if notification exists and belongs to user
  const { data: notification, error: notificationError } = await supabase
    .from('notifications')
    .select('id, user_id, read')
    .eq('id', id)
    .eq('user_id', user_id)
    .single();

  if (notificationError) {
    throw new AppError('Notification not found', 404);
  }

  if (notification.read) {
    return res.json({
      success: true,
      message: 'Notification already marked as read'
    });
  }

  const { data: updatedNotification, error } = await supabase
    .from('notifications')
    .update({
      read: true,
      updated_at: new Date().toISOString()
    })
    .eq('id', id)
    .select(`
      id,
      type,
      content,
      read,
      created_at,
      updated_at
    `)
    .single();

  if (error) {
    throw new AppError('Failed to mark notification as read', 500);
  }

  res.json({
    success: true,
    message: 'Notification marked as read',
    data: { notification: updatedNotification }
  });
});

// Mark all notifications as read for current user
const markAllAsRead = asyncHandler(async (req, res) => {
  const user_id = req.user.id;

  const { data: notifications, error } = await supabase
    .from('notifications')
    .update({
      read: true,
      updated_at: new Date().toISOString()
    })
    .eq('user_id', user_id)
    .eq('read', false)
    .select('id');

  if (error) {
    throw new AppError('Failed to mark notifications as read', 500);
  }

  res.json({
    success: true,
    message: `${notifications.length} notifications marked as read`,
    data: { count: notifications.length }
  });
});

// Delete notification
const deleteNotification = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const user_id = req.user.id;

  // Check if notification exists and belongs to user
  const { data: notification, error: notificationError } = await supabase
    .from('notifications')
    .select('id, user_id')
    .eq('id', id)
    .eq('user_id', user_id)
    .single();

  if (notificationError) {
    throw new AppError('Notification not found', 404);
  }

  const { error: deleteError } = await supabase
    .from('notifications')
    .delete()
    .eq('id', id);

  if (deleteError) {
    throw new AppError('Failed to delete notification', 500);
  }

  res.json({
    success: true,
    message: 'Notification deleted successfully'
  });
});

// Get notification statistics
const getNotificationStats = asyncHandler(async (req, res) => {
  const { user_id } = req.params;

  const { data: stats, error } = await supabase
    .from('notifications')
    .select('type, read, created_at')
    .eq('user_id', user_id)
    .then(({ data }) => {
      const typeCounts = data.reduce((acc, notification) => {
        acc[notification.type] = (acc[notification.type] || 0) + 1;
        return acc;
      }, {});

      const readCount = data.filter(n => n.read).length;
      const unreadCount = data.length - readCount;

      return {
        data: {
          total: data.length,
          read: readCount,
          unread: unreadCount,
          by_type: typeCounts
        }
      };
    });

  if (error) {
    throw new AppError('Failed to fetch notification statistics', 500);
  }

  res.json({
    success: true,
    data: stats
  });
});

// Get unread notification count for current user
const getUnreadCount = asyncHandler(async (req, res) => {
  const user_id = req.user.id;

  const { count, error } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('user_id', user_id)
    .eq('read', false);

  if (error) {
    throw new AppError('Failed to fetch unread count', 500);
  }

  res.json({
    success: true,
    data: { unread_count: count }
  });
});

// Send notification to multiple users
const sendBulkNotification = asyncHandler(async (req, res) => {
  const { user_ids, type, content } = req.body;

  if (!Array.isArray(user_ids) || user_ids.length === 0) {
    throw new AppError('User IDs array is required', 400);
  }

  // Validate all users exist
  const { data: users, error: usersError } = await supabase
    .from('users')
    .select('id')
    .in('id', user_ids);

  if (usersError) {
    throw new AppError('Failed to validate users', 500);
  }

  if (users.length !== user_ids.length) {
    throw new AppError('Some users not found', 400);
  }

  // Create notifications for all users
  const notifications = user_ids.map(user_id => ({
    user_id,
    type,
    content,
    read: false,
    created_at: new Date().toISOString()
  }));

  const { data: createdNotifications, error } = await supabase
    .from('notifications')
    .insert(notifications)
    .select('id, user_id, type, content, created_at');

  if (error) {
    throw new AppError('Failed to create notifications', 500);
  }

  res.status(201).json({
    success: true,
    message: `Notifications sent to ${createdNotifications.length} users`,
    data: { notifications: createdNotifications }
  });
});

module.exports = {
  getNotificationsByUser,
  getMyNotifications,
  getNotificationById,
  createNotification,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  getNotificationStats,
  getUnreadCount,
  sendBulkNotification
};
