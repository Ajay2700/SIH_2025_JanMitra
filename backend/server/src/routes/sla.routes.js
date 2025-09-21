const express = require('express');
const router = express.Router();
const slaController = require('../controllers/sla.controller');
const { validate, schemas } = require('../middleware/validation');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Public routes (for authenticated users)
router.get('/', slaController.getAllSLAs);
router.get('/category/:category_id', slaController.getSLAsByCategory);
router.get('/stats', slaController.getSLAStats);
router.get('/:id', slaController.getSLAById);

// Admin routes
router.post('/', requireAdmin, validate(schemas.sla.create), slaController.createSLA);
router.put('/:id', requireAdmin, validate(schemas.sla.update), slaController.updateSLA);
router.delete('/:id', requireAdmin, slaController.deleteSLA);
router.post('/ticket/:ticket_id/apply', requireAdmin, slaController.applySLAToTicket);
router.post('/check-breaches', requireAdmin, slaController.checkSLABreaches);

module.exports = router;
