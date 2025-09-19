import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { createTicket, listMyTickets, getTicket, deleteTicket, listTicketUpdates } from '../controllers/tickets.controller.js';

const router = Router();

router.post('/', requireAuth(['citizen','staff','admin']), createTicket);
router.get('/', requireAuth(['citizen','staff','admin']), listMyTickets);
router.get('/:id', requireAuth(['citizen','staff','admin']), getTicket);
router.delete('/:id', requireAuth(['citizen','staff','admin']), deleteTicket);
router.get('/:id/updates', requireAuth(['citizen','staff','admin']), listTicketUpdates);

export default router;


