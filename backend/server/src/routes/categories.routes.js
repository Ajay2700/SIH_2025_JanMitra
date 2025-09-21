const express = require('express');
const router = express.Router();
const categoriesController = require('../controllers/categories.controller');
const { validate, schemas } = require('../middleware/validation');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Public routes (for authenticated users)
router.get('/', categoriesController.getAllCategories);
router.get('/hierarchy', categoriesController.getCategoryHierarchy);
router.get('/department/:department_id', categoriesController.getCategoriesByDepartment);
router.get('/:id', categoriesController.getCategoryById);
router.get('/:id/stats', categoriesController.getCategoryStats);

// Admin only routes
router.post('/', requireAdmin, validate(schemas.ticketCategory.create), categoriesController.createCategory);
router.put('/:id', requireAdmin, validate(schemas.ticketCategory.update), categoriesController.updateCategory);
router.delete('/:id', requireAdmin, categoriesController.deleteCategory);

module.exports = router;
