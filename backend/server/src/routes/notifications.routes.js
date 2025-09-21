const express = require('express');
const router = express.Router();
const notificationsController = require('../controllers/notifications.controller');
const { validate, schemas } = require('../middleware/validation');
const { authenticateToken, requireAdmin, requireOwnershipOrAdmin } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Public routes (for authenticated users)
router.get('/my', notificationsController.getMyNotifications);
router.get('/unread-count', notificationsController.getUnreadCount);
router.get('/user/:user_id', requireOwnershipOrAdmin('user_id'), notificationsController.getNotificationsByUser);
router.get('/user/:user_id/stats', requireOwnershipOrAdmin('user_id'), notificationsController.getNotificationStats);
router.get('/:id', notificationsController.getNotificationById);

// User routes
router.put('/:id/read', notificationsController.markAsRead);
router.put('/mark-all-read', notificationsController.markAllAsRead);
router.delete('/:id', requireOwnershipOrAdmin('user_id'), notificationsController.deleteNotification);

// Admin routes
router.post('/', requireAdmin, validate(schemas.notification.create), notificationsController.createNotification);
router.post('/bulk', requireAdmin, notificationsController.sendBulkNotification);

module.exports = router;
