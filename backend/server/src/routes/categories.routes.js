import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { listCategories, getCategory, createCategory, updateCategory, deleteCategory } from '../controllers/categories.controller.js';

const router = Router();

// Public routes (no auth required for listing categories)
router.get('/', listCategories);
router.get('/:id', getCategory);

// Admin-only routes
router.post('/', requireAuth(['admin']), createCategory);
router.patch('/:id', requireAuth(['admin']), updateCategory);
router.delete('/:id', requireAuth(['admin']), deleteCategory);

export default router;
