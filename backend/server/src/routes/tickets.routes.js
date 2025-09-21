const express = require('express');
const router = express.Router();
const ticketsController = require('../controllers/tickets.controller');
const { validate, schemas } = require('../middleware/validation');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Public routes (for authenticated users)
router.get('/', ticketsController.getAllTickets);
router.get('/stats', ticketsController.getTicketStats);
router.get('/department/:department_id', ticketsController.getTicketsByDepartment);
router.get('/assigned/:user_id', ticketsController.getTicketsByAssignedUser);
router.get('/:id', ticketsController.getTicketById);
router.get('/:id/history', ticketsController.getTicketHistory);

// Staff and admin routes
router.post('/', validate(schemas.ticket.create), ticketsController.createTicket);
router.put('/:id', validate(schemas.ticket.update), ticketsController.updateTicket);
router.delete('/:id', requireAdmin, ticketsController.deleteTicket);

module.exports = router;
