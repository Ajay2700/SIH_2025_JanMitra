import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import {
  adminListTickets,
  adminGetTicket,
  adminAssignTicket,
  adminUpdateTicketStatus,
  adminUpdateTicketPriority,
  adminListServiceRequests,
  adminUpdateServiceRequestStatus,
  adminListStaff,
  adminCreateStaff,
  adminUpdateStaff,
  adminDeleteStaff,
  adminAnalyticsTickets,
  adminAnalyticsDepartments,
  adminAnalyticsTrends,
} from '../controllers/admin.controller.js';

const router = Router();

router.use(requireAuth(['admin']));

router.get('/tickets', adminListTickets);
router.get('/tickets/:id', adminGetTicket);
router.patch('/tickets/:id/assign', adminAssignTicket);
router.patch('/tickets/:id/status', adminUpdateTicketStatus);
router.patch('/tickets/:id/priority', adminUpdateTicketPriority);

router.get('/service_requests', adminListServiceRequests);
router.patch('/service_requests/:id/status', adminUpdateServiceRequestStatus);

router.get('/staff', adminListStaff);
router.post('/staff', adminCreateStaff);
router.patch('/staff/:id', adminUpdateStaff);
router.delete('/staff/:id', adminDeleteStaff);

router.get('/analytics/tickets', adminAnalyticsTickets);
router.get('/analytics/departments', adminAnalyticsDepartments);
router.get('/analytics/trends', adminAnalyticsTrends);

export default router;


