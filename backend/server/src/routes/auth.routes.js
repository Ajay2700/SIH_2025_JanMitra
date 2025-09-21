const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { validate, schemas } = require('../middleware/validation');
const { authenticateToken } = require('../middleware/auth');

// Public routes
router.post('/register', validate(schemas.user.create), authController.register);
router.post('/login', validate(schemas.user.login), authController.login);
router.post('/refresh', authController.refreshToken);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);

// Protected routes

router.use(authenticateToken);

router.post('/logout', authController.logout);
router.get('/profile', authController.getProfile);
router.put('/profile', validate(schemas.user.update), authController.updateProfile);
router.put('/change-password', authController.changePassword);


module.exports = router;
