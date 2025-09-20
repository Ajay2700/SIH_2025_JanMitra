import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import {
  adminListTickets,
  adminGetTicket,
  adminAssignTicket,
  adminUpdateTicketStatus,
  adminUpdateTicketPriority,
  adminListDepartments,
  adminCreateDepartment,
  adminUpdateDepartment,
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

// Ticket management
router.get('/tickets', adminListTickets);
router.get('/tickets/:id', adminGetTicket);
router.patch('/tickets/:id/assign', adminAssignTicket);
router.patch('/tickets/:id/status', adminUpdateTicketStatus);
router.patch('/tickets/:id/priority', adminUpdateTicketPriority);

// Department management
router.get('/departments', adminListDepartments);
router.post('/departments', adminCreateDepartment);
router.patch('/departments/:id', adminUpdateDepartment);

// Staff management
router.get('/staff', adminListStaff);
router.post('/staff', adminCreateStaff);
router.patch('/staff/:id', adminUpdateStaff);
router.delete('/staff/:id', adminDeleteStaff);

// Analytics
router.get('/analytics/tickets', adminAnalyticsTickets);
router.get('/analytics/departments', adminAnalyticsDepartments);
router.get('/analytics/trends', adminAnalyticsTrends);

export default router;


