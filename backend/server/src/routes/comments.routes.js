const express = require('express');
const router = express.Router();
const commentsController = require('../controllers/comments.controller');
const { validate, schemas } = require('../middleware/validation');
const { authenticateToken, requireOwnershipOrAdmin } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Public routes (for authenticated users)
router.get('/ticket/:ticket_id', commentsController.getCommentsByTicket);
router.get('/user/:user_id', requireOwnershipOrAdmin('user_id'), commentsController.getCommentsByUser);
router.get('/ticket/:ticket_id/stats', commentsController.getCommentStats);
router.get('/:id', commentsController.getCommentById);

// User routes
router.post('/', validate(schemas.comment.create), commentsController.createComment);
router.put('/:id', requireOwnershipOrAdmin('user_id'), validate(schemas.comment.update), commentsController.updateComment);
router.delete('/:id', requireOwnershipOrAdmin('user_id'), commentsController.deleteComment);

module.exports = router;
