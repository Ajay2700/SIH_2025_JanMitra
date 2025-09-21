const express = require('express');
const router = express.Router();
const settingsController = require('../controllers/settings.controller');
const { validate, schemas } = require('../middleware/validation');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Public routes (for authenticated users)
router.get('/config', settingsController.getAppConfig);
router.get('/health', settingsController.getSystemHealth);
router.get('/stats', requireAdmin, settingsController.getSystemStats);
router.get('/keys', settingsController.getSettingsByKeys);
router.get('/:key', settingsController.getSettingByKey);
router.get('/', settingsController.getAllSettings);

// Admin routes
router.post('/', requireAdmin, validate(schemas.systemSetting.create), settingsController.createSetting);
router.put('/:key', requireAdmin, validate(schemas.systemSetting.update), settingsController.updateSetting);
router.put('/', requireAdmin, settingsController.updateMultipleSettings);
router.delete('/:key', requireAdmin, settingsController.deleteSetting);
router.post('/reset-defaults', requireAdmin, settingsController.resetToDefaults);

module.exports = router;
