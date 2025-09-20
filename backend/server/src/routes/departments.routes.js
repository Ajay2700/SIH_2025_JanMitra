import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { listDepartments, getDepartment, getDepartmentStaff, getDepartmentTickets } from '../controllers/departments.controller.js';

const router = Router();

// Public routes (no auth required for listing departments)
router.get('/', listDepartments);
router.get('/:id', getDepartment);
router.get('/:id/staff', getDepartmentStaff);

// Staff and admin routes
router.get('/:id/tickets', requireAuth(['staff', 'admin']), getDepartmentTickets);

export default router;
