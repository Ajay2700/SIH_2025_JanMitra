const Joi = require('joi');

// Validation schemas
const schemas = {
  // User validation
  user: {
    create: Joi.object({
      email: Joi.string().email().required(),
      password: Joi.string().min(6).required(),
      full_name: Joi.string().min(2).max(100).required(),
      phone: Joi.string().pattern(/^[0-9+\-\s()]+$/).optional(),
      role: Joi.string().valid('citizen', 'staff', 'admin', 'super_admin').default('citizen'),
      department_id: Joi.string().uuid().optional()
    }),
    update: Joi.object({
      full_name: Joi.string().min(2).max(100).optional(),
      phone: Joi.string().pattern(/^[0-9+\-\s()]+$/).optional(),
      role: Joi.string().valid('citizen', 'staff', 'admin', 'super_admin').optional(),
      department_id: Joi.string().uuid().optional()
    }),
    login: Joi.object({
      email: Joi.string().email().required(),
      password: Joi.string().min(6).required()
    })
  },

  // Department validation
  department: {
    create: Joi.object({
      name: Joi.string().min(2).max(100).required(),
      description: Joi.string().max(500).optional(),
      parent_id: Joi.string().uuid().optional()
    }),
    update: Joi.object({
      name: Joi.string().min(2).max(100).optional(),
      description: Joi.string().max(500).optional(),
      parent_id: Joi.string().uuid().optional()
    })
  },

  // Ticket category validation
  ticketCategory: {
    create: Joi.object({
      name: Joi.string().min(2).max(100).required(),
      description: Joi.string().max(500).optional(),
      parent_id: Joi.string().uuid().optional(),
      department_id: Joi.string().uuid().optional()
    }),
    update: Joi.object({
      name: Joi.string().min(2).max(100).optional(),
      description: Joi.string().max(500).optional(),
      parent_id: Joi.string().uuid().optional(),
      department_id: Joi.string().uuid().optional()
    })
  },

  // Issue validation
  issue: {
    create: Joi.object({
      title: Joi.string().min(5).max(200).required(),
      description: Joi.string().min(10).max(2000).required(),
      category_id: Joi.string().uuid().required(),
      latitude: Joi.number().min(-90).max(90).optional(),
      longitude: Joi.number().min(-180).max(180).optional(),
      status: Joi.string().valid('open', 'in_progress', 'resolved', 'closed', 'cancelled').default('open')
    }),
    update: Joi.object({
      title: Joi.string().min(5).max(200).optional(),
      description: Joi.string().min(10).max(2000).optional(),
      category_id: Joi.string().uuid().optional(),
      latitude: Joi.number().min(-90).max(90).optional(),
      longitude: Joi.number().min(-180).max(180).optional(),
      status: Joi.string().valid('open', 'in_progress', 'resolved', 'closed', 'cancelled').optional()
    })
  },

  // Ticket validation
  ticket: {
    create: Joi.object({
      issue_id: Joi.string().uuid().required(),
      assigned_to: Joi.string().uuid().optional(),
      department_id: Joi.string().uuid().required(),
      priority: Joi.string().valid('low', 'medium', 'high', 'urgent').default('medium'),
      due_date: Joi.date().iso().optional()
    }),
    update: Joi.object({
      assigned_to: Joi.string().uuid().optional(),
      department_id: Joi.string().uuid().optional(),
      priority: Joi.string().valid('low', 'medium', 'high', 'urgent').optional(),
      status: Joi.string().valid('open', 'in_progress', 'resolved', 'closed', 'cancelled').optional(),
      due_date: Joi.date().iso().optional()
    })
  },

  // Comment validation
  comment: {
    create: Joi.object({
      ticket_id: Joi.string().uuid().required(),
      content: Joi.string().min(1).max(2000).required()
    }),
    update: Joi.object({
      content: Joi.string().min(1).max(2000).required()
    })
  },

  // Feedback validation
  feedback: {
    create: Joi.object({
      ticket_id: Joi.string().uuid().required(),
      rating: Joi.number().integer().min(1).max(5).required(),
      comments: Joi.string().max(1000).optional()
    })
  },

  // Notification validation
  notification: {
    create: Joi.object({
      user_id: Joi.string().uuid().required(),
      type: Joi.string().valid(
        'system', 'ticket_created', 'ticket_updated', 'ticket_assigned', 
        'ticket_resolved', 'comment_added', 'escalation', 
        'sla_breach', 'feedback_received', 'general'
      ).required(),
      content: Joi.string().min(1).max(500).required()
    })
  },

  // SLA validation
  sla: {
    create: Joi.object({
      category_id: Joi.string().uuid().required(),
      priority: Joi.string().valid('low', 'medium', 'high', 'urgent').required(),
      response_time: Joi.string().required(), // interval format
      resolution_time: Joi.string().required() // interval format
    }),
    update: Joi.object({
      priority: Joi.string().valid('low', 'medium', 'high', 'urgent').optional(),
      response_time: Joi.string().optional(),
      resolution_time: Joi.string().optional()
    })
  },

  // System settings validation
  systemSetting: {
    create: Joi.object({
      key: Joi.string().min(1).max(100).required(),
      value: Joi.string().max(1000).required()
    }),
    update: Joi.object({
      value: Joi.string().max(1000).required()
    })
  },

  // Pagination validation
  pagination: Joi.object({
    page: Joi.number().integer().min(1).default(1),
    limit: Joi.number().integer().min(1).max(100).default(10),
    sort_by: Joi.string().optional(),
    sort_order: Joi.string().valid('asc', 'desc').default('desc')
  }),

  // UUID parameter validation
  uuid: Joi.object({
    id: Joi.string().uuid().required()
  })
};

// Validation middleware factory
const validate = (schema, property = 'body') => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req[property], { 
      abortEarly: false,
      stripUnknown: true 
    });

    if (error) {
      const errorMessage = error.details.map(detail => detail.message).join(', ');
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors: errorMessage
      });
    }

    req[property] = value;
    next();
  };
};

module.exports = {
  schemas,
  validate
};
