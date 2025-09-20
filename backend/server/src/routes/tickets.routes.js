import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { createTicket, listMyTickets, getTicket, deleteTicket, listTicketComments, addTicketComment } from '../controllers/tickets.controller.js';

const router = Router();

router.post('/', requireAuth(['citizen','staff','admin']), createTicket);
router.get('/', requireAuth(['citizen','staff','admin']), listMyTickets);
router.get('/:id', requireAuth(['citizen','staff','admin']), getTicket);
router.delete('/:id', requireAuth(['citizen','staff','admin']), deleteTicket);
router.get('/:id/comments', requireAuth(['citizen','staff','admin']), listTicketComments);
router.post('/:id/comments', requireAuth(['citizen','staff','admin']), addTicketComment);

export default router;


