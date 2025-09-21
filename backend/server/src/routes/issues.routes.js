const express = require('express');
const router = express.Router();
const issuesController = require('../controllers/issues.controller');
const { validate, schemas } = require('../middleware/validation');
const { authenticateToken, requireOwnershipOrAdmin } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Public routes (for authenticated users)
router.get('/', issuesController.getAllIssues);
router.get('/stats', issuesController.getIssueStats);
router.get('/citizen/:citizen_id', requireOwnershipOrAdmin('citizen_id'), issuesController.getIssuesByCitizen);
router.get('/:id', issuesController.getIssueById);
router.get('/:id/history', issuesController.getIssueHistory);

// Citizen and admin routes
router.post('/', validate(schemas.issue.create), issuesController.createIssue);
router.put('/:id', requireOwnershipOrAdmin('citizen_id'), validate(schemas.issue.update), issuesController.updateIssue);
router.delete('/:id', requireOwnershipOrAdmin('citizen_id'), issuesController.deleteIssue);

module.exports = router;
