// Database table types and enums based on the schema

const TICKET_STATUS = {
  OPEN: 'open',
  IN_PROGRESS: 'in_progress',
  RESOLVED: 'resolved',
  CLOSED: 'closed',
  CANCELLED: 'cancelled'
};

const TICKET_PRIORITY = {
  LOW: 'low',
  MEDIUM: 'medium',
  HIGH: 'high',
  URGENT: 'urgent'
};

const USER_ROLE = {
  CITIZEN: 'citizen',
  STAFF: 'staff',
  ADMIN: 'admin',
  SUPER_ADMIN: 'super_admin'
};

const NOTIFICATION_TYPE = {
  TICKET_CREATED: 'ticket_created',
  TICKET_UPDATED: 'ticket_updated',
  TICKET_ASSIGNED: 'ticket_assigned',
  TICKET_RESOLVED: 'ticket_resolved',
  COMMENT_ADDED: 'comment_added',
  ESCALATION: 'escalation',
  SLA_BREACH: 'sla_breach',
  FEEDBACK_RECEIVED: 'feedback_received'
};

const PRIORITY_LEVEL = {
  LOW: 'low',
  MEDIUM: 'medium',
  HIGH: 'high',
  URGENT: 'urgent'
};

// Table names
const TABLES = {
  USERS: 'users',
  DEPARTMENTS: 'departments',
  TICKET_CATEGORIES: 'ticket_categories',
  ISSUES: 'issues',
  TICKETS: 'tickets',
  COMMENTS: 'comments',
  ATTACHMENTS: 'attachments',
  NOTIFICATIONS: 'notifications',
  FEEDBACK: 'feedback',
  ANALYTICS: 'analytics',
  SLA: 'sla',
  TICKET_SLA: 'ticket_sla',
  ESCALATION_MATRIX: 'escalation_matrix',
  ISSUE_HISTORY: 'issue_history',
  TICKET_HISTORY: 'ticket_history',
  SYSTEM_SETTINGS: 'system_settings'
};

module.exports = {
  TICKET_STATUS,
  TICKET_PRIORITY,
  USER_ROLE,
  NOTIFICATION_TYPE,
  PRIORITY_LEVEL,
  TABLES
};
