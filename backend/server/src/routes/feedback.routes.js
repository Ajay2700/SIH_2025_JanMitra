const express = require('express');
const router = express.Router();
const feedbackController = require('../controllers/feedback.controller');
const { validate, schemas } = require('../middleware/validation');
const { authenticateToken, requireAdmin, requireOwnershipOrAdmin } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Public routes (for authenticated users)
router.get('/', requireAdmin, feedbackController.getAllFeedback);
router.get('/stats', requireAdmin, feedbackController.getFeedbackStats);
router.get('/department/:department_id/stats', requireAdmin, feedbackController.getFeedbackStatsByDepartment);
router.get('/ticket/:ticket_id', feedbackController.getFeedbackByTicket);
router.get('/citizen/:citizen_id', requireOwnershipOrAdmin('citizen_id'), feedbackController.getFeedbackByCitizen);
router.get('/:id', feedbackController.getFeedbackById);

// User routes
router.post('/', validate(schemas.feedback.create), feedbackController.createFeedback);
router.put('/:id', requireOwnershipOrAdmin('citizen_id'), feedbackController.updateFeedback);
router.delete('/:id', requireOwnershipOrAdmin('citizen_id'), feedbackController.deleteFeedback);

module.exports = router;
