const express = require('express');
const router = express.Router();
const analyticsController = require('../controllers/analytics.controller');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Public routes (for authenticated users)
router.get('/dashboard', analyticsController.getDashboardAnalytics);
router.get('/department-performance', analyticsController.getDepartmentPerformance);
router.get('/category-analytics', analyticsController.getCategoryAnalytics);
router.get('/summary', analyticsController.getAnalyticsSummary);
router.get('/', analyticsController.getAnalytics);

// Admin routes
router.post('/metric', requireAdmin, analyticsController.recordMetric);

module.exports = router;
