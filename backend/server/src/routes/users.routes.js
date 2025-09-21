const express = require('express');
const router = express.Router();
const usersController = require('../controllers/users.controller');
const { validate, schemas } = require('../middleware/validation');
const { authenticateToken, requireAdmin, requireOwnershipOrAdmin } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Admin only routes
router.get('/', requireAdmin, usersController.getAllUsers);
router.post('/', requireAdmin, validate(schemas.user.create), usersController.createUser);
router.get('/stats', requireAdmin, usersController.getUserStats);

// Public routes (for authenticated users)
router.get('/:id', requireOwnershipOrAdmin('id'), usersController.getUserById);
router.put('/:id', requireOwnershipOrAdmin('id'), validate(schemas.user.update), usersController.updateUser);
router.delete('/:id', requireAdmin, usersController.deleteUser);
router.get('/department/:department_id', requireAdmin, usersController.getUsersByDepartment);

module.exports = router;
