const express = require('express');
const router = express.Router();

// Import all route modules
const authRoutes = require('./auth.routes');
const userRoutes = require('./users.routes');
const departmentRoutes = require('./departments.routes');
const categoryRoutes = require('./categories.routes');
const issueRoutes = require('./issues.routes');
const ticketRoutes = require('./tickets.routes');
const commentRoutes = require('./comments.routes');
const attachmentRoutes = require('./attachments.routes');
const notificationRoutes = require('./notifications.routes');
const feedbackRoutes = require('./feedback.routes');
const analyticsRoutes = require('./analytics.routes');
const slaRoutes = require('./sla.routes');
const settingsRoutes = require('./settings.routes');

// Mount routes
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/departments', departmentRoutes);
router.use('/categories', categoryRoutes);
router.use('/issues', issueRoutes);
router.use('/tickets', ticketRoutes);
router.use('/comments', commentRoutes);
router.use('/attachments', attachmentRoutes);
router.use('/notifications', notificationRoutes);
router.use('/feedback', feedbackRoutes);
router.use('/analytics', analyticsRoutes);
router.use('/sla', slaRoutes);
router.use('/settings', settingsRoutes);

// Health check endpoint
router.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'JanMitra API is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Test Supabase connection
router.get('/test-supabase', async (req, res) => {
  try {
    const { supabase, supabaseAdmin } = require('../config/supabase');
    
    // Test regular supabase connection
    const { data: testData, error: testError } = await supabase
      .from('users')
      .select('count')
      .limit(1);
    
    // Test admin connection
    const { data: adminData, error: adminError } = await supabaseAdmin
      .from('users')
      .select('count')
      .limit(1);
    
    // Test auth admin capabilities
    const { data: authTest, error: authTestError } = await supabaseAdmin.auth.admin.listUsers();
    
    res.json({
      success: true,
      message: 'Supabase connection test',
      regular_connection: testError ? `Error: ${testError.message}` : 'OK',
      admin_connection: adminError ? `Error: ${adminError.message}` : 'OK',
      auth_admin: authTestError ? `Error: ${authTestError.message}` : 'OK',
      user_count: authTest?.users?.length || 0,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Supabase connection test failed',
      error: error.message
    });
  }
});

// API documentation endpoint
router.get('/docs', (req, res) => {
  res.json({
    success: true,
    message: 'JanMitra API Documentation',
    version: '1.0.0',
    endpoints: {
      auth: {
        base: '/api/auth',
        endpoints: [
          'POST /register - Register new user',
          'POST /login - User login',
          'POST /logout - User logout',
          'POST /refresh - Refresh token',
          'GET /profile - Get user profile',
          'PUT /profile - Update user profile',
          'PUT /change-password - Change password',
          'POST /forgot-password - Forgot password',
          'POST /reset-password - Reset password'
        ]
      },
      users: {
        base: '/api/users',
        endpoints: [
          'GET / - Get all users (admin)',
          'POST / - Create user (admin)',
          'GET /:id - Get user by ID',
          'PUT /:id - Update user',
          'DELETE /:id - Delete user (admin)',
          'GET /stats - Get user statistics (admin)',
          'GET /department/:department_id - Get users by department (admin)'
        ]
      },
      departments: {
        base: '/api/departments',
        endpoints: [
          'GET / - Get all departments',
          'GET /hierarchy - Get department hierarchy',
          'GET /:id - Get department by ID',
          'GET /:id/stats - Get department statistics',
          'POST / - Create department (admin)',
          'PUT /:id - Update department (admin)',
          'DELETE /:id - Delete department (admin)'
        ]
      },
      categories: {
        base: '/api/categories',
        endpoints: [
          'GET / - Get all categories',
          'GET /hierarchy - Get category hierarchy',
          'GET /department/:department_id - Get categories by department',
          'GET /:id - Get category by ID',
          'GET /:id/stats - Get category statistics',
          'POST / - Create category (admin)',
          'PUT /:id - Update category (admin)',
          'DELETE /:id - Delete category (admin)'
        ]
      },
      issues: {
        base: '/api/issues',
        endpoints: [
          'GET / - Get all issues',
          'GET /stats - Get issue statistics',
          'GET /citizen/:citizen_id - Get issues by citizen',
          'GET /:id - Get issue by ID',
          'GET /:id/history - Get issue history',
          'POST / - Create issue',
          'PUT /:id - Update issue',
          'DELETE /:id - Delete issue'
        ]
      },
      tickets: {
        base: '/api/tickets',
        endpoints: [
          'GET / - Get all tickets',
          'GET /stats - Get ticket statistics',
          'GET /department/:department_id - Get tickets by department',
          'GET /assigned/:user_id - Get tickets by assigned user',
          'GET /:id - Get ticket by ID',
          'GET /:id/history - Get ticket history',
          'POST / - Create ticket',
          'PUT /:id - Update ticket',
          'DELETE /:id - Delete ticket (admin)'
        ]
      },
      comments: {
        base: '/api/comments',
        endpoints: [
          'GET /ticket/:ticket_id - Get comments by ticket',
          'GET /user/:user_id - Get comments by user',
          'GET /ticket/:ticket_id/stats - Get comment statistics',
          'GET /:id - Get comment by ID',
          'POST / - Create comment',
          'PUT /:id - Update comment',
          'DELETE /:id - Delete comment'
        ]
      },
      attachments: {
        base: '/api/attachments',
        endpoints: [
          'GET /ticket/:ticket_id - Get attachments by ticket',
          'GET /issue/:issue_id - Get attachments by issue',
          'GET /:id - Get attachment by ID',
          'GET /:id/download - Download attachment',
          'POST /ticket/:ticket_id - Upload ticket attachment',
          'POST /issue/:issue_id - Upload issue attachment',
          'DELETE /:id - Delete attachment'
        ]
      },
      notifications: {
        base: '/api/notifications',
        endpoints: [
          'GET /my - Get my notifications',
          'GET /unread-count - Get unread count',
          'GET /user/:user_id - Get notifications by user',
          'GET /:id - Get notification by ID',
          'PUT /:id/read - Mark as read',
          'PUT /mark-all-read - Mark all as read',
          'DELETE /:id - Delete notification',
          'POST / - Create notification (admin)',
          'POST /bulk - Send bulk notification (admin)'
        ]
      },
      feedback: {
        base: '/api/feedback',
        endpoints: [
          'GET / - Get all feedback (admin)',
          'GET /stats - Get feedback statistics (admin)',
          'GET /ticket/:ticket_id - Get feedback by ticket',
          'GET /citizen/:citizen_id - Get feedback by citizen',
          'GET /:id - Get feedback by ID',
          'POST / - Create feedback',
          'PUT /:id - Update feedback',
          'DELETE /:id - Delete feedback'
        ]
      },
      analytics: {
        base: '/api/analytics',
        endpoints: [
          'GET /dashboard - Get dashboard analytics',
          'GET /department-performance - Get department performance',
          'GET /category-analytics - Get category analytics',
          'GET /summary - Get analytics summary',
          'GET / - Get analytics metrics',
          'POST /metric - Record analytics metric (admin)'
        ]
      },
      sla: {
        base: '/api/sla',
        endpoints: [
          'GET / - Get all SLA configurations',
          'GET /category/:category_id - Get SLAs by category',
          'GET /stats - Get SLA statistics',
          'GET /:id - Get SLA by ID',
          'POST / - Create SLA (admin)',
          'PUT /:id - Update SLA (admin)',
          'DELETE /:id - Delete SLA (admin)',
          'POST /ticket/:ticket_id/apply - Apply SLA to ticket (admin)',
          'POST /check-breaches - Check SLA breaches (admin)'
        ]
      },
      settings: {
        base: '/api/settings',
        endpoints: [
          'GET /config - Get app configuration',
          'GET /health - Get system health',
          'GET /stats - Get system statistics (admin)',
          'GET /keys - Get settings by keys',
          'GET /:key - Get setting by key',
          'GET / - Get all settings',
          'POST / - Create setting (admin)',
          'PUT /:key - Update setting (admin)',
          'PUT / - Update multiple settings (admin)',
          'DELETE /:key - Delete setting (admin)',
          'POST /reset-defaults - Reset to defaults (admin)'
        ]
      }
    }
  });
});

module.exports = router;
