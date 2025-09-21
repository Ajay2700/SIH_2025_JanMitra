const express = require('express');
const router = express.Router();
const attachmentsController = require('../controllers/attachments.controller');
const { authenticateToken, requireOwnershipOrAdmin } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Public routes (for authenticated users)
router.get('/ticket/:ticket_id', attachmentsController.getAttachmentsByTicket);
router.get('/issue/:issue_id', attachmentsController.getAttachmentsByIssue);
router.get('/ticket/:ticket_id/stats', attachmentsController.getAttachmentStats);
router.get('/issue/:issue_id/stats', attachmentsController.getAttachmentStats);
router.get('/:id', attachmentsController.getAttachmentById);
router.get('/:id/download', attachmentsController.downloadAttachment);

// User routes
router.post('/ticket/:ticket_id', attachmentsController.upload.single('file'), attachmentsController.uploadTicketAttachment);
router.post('/issue/:issue_id', attachmentsController.upload.single('file'), attachmentsController.uploadIssueAttachment);
router.delete('/:id', requireOwnershipOrAdmin('uploaded_by'), attachmentsController.deleteAttachment);

module.exports = router;
