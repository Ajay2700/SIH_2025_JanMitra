const express = require('express');
const router = express.Router();
const departmentsController = require('../controllers/departments.controller');
const { validate, schemas } = require('../middleware/validation');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Public routes (for authenticated users)
router.get('/', departmentsController.getAllDepartments);
router.get('/hierarchy', departmentsController.getDepartmentHierarchy);
router.get('/:id', departmentsController.getDepartmentById);
router.get('/:id/stats', departmentsController.getDepartmentStats);

// Admin only routes
router.post('/', requireAdmin, validate(schemas.department.create), departmentsController.createDepartment);
router.put('/:id', requireAdmin, validate(schemas.department.update), departmentsController.updateDepartment);
router.delete('/:id', requireAdmin, departmentsController.deleteDepartment);

module.exports = router;
