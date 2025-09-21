import { apiFetch } from '../modules/auth/useAuth.jsx'
import { getApiUrl } from '../config/api.js'

// Analytics API
export const analyticsAPI = {
  getDashboard: (token) => apiFetch('/api/analytics/dashboard', { token }),
  getDepartmentPerformance: (token) => apiFetch('/api/analytics/department-performance', { token }),
  getCategoryAnalytics: (token) => apiFetch('/api/analytics/category-analytics', { token }),
  getSummary: (token) => apiFetch('/api/analytics/summary', { token }),
  getMetrics: (token) => apiFetch('/api/analytics', { token })
}

// Users API
export const usersAPI = {
  getAll: (token) => apiFetch('/api/users', { token }),
  create: (data, token) => apiFetch('/api/users', { method: 'POST', body: data, token }),
  getById: (id, token) => apiFetch(`/api/users/${id}`, { token }),
  update: (id, data, token) => apiFetch(`/api/users/${id}`, { method: 'PUT', body: data, token }),
  delete: (id, token) => apiFetch(`/api/users/${id}`, { method: 'DELETE', token }),
  getStats: (token) => apiFetch('/api/users/stats', { token }),
  getByDepartment: (departmentId, token) => apiFetch(`/api/users/department/${departmentId}`, { token })
}

// Departments API
export const departmentsAPI = {
  getAll: (token) => apiFetch('/api/departments', { token }),
  getHierarchy: (token) => apiFetch('/api/departments/hierarchy', { token }),
  getById: (id, token) => apiFetch(`/api/departments/${id}`, { token }),
  getStats: (id, token) => apiFetch(`/api/departments/${id}/stats`, { token }),
  create: (data, token) => apiFetch('/api/departments', { method: 'POST', body: data, token }),
  update: (id, data, token) => apiFetch(`/api/departments/${id}`, { method: 'PUT', body: data, token }),
  delete: (id, token) => apiFetch(`/api/departments/${id}`, { method: 'DELETE', token })
}

// Categories API
export const categoriesAPI = {
  getAll: (token) => apiFetch('/api/categories', { token }),
  getHierarchy: (token) => apiFetch('/api/categories/hierarchy', { token }),
  getByDepartment: (departmentId, token) => apiFetch(`/api/categories/department/${departmentId}`, { token }),
  getById: (id, token) => apiFetch(`/api/categories/${id}`, { token }),
  getStats: (id, token) => apiFetch(`/api/categories/${id}/stats`, { token }),
  create: (data, token) => apiFetch('/api/categories', { method: 'POST', body: data, token }),
  update: (id, data, token) => apiFetch(`/api/categories/${id}`, { method: 'PUT', body: data, token }),
  delete: (id, token) => apiFetch(`/api/categories/${id}`, { method: 'DELETE', token })
}

// Issues API
export const issuesAPI = {
  getAll: (token) => apiFetch('/api/issues', { token }),
  getStats: (token) => apiFetch('/api/issues/stats', { token }),
  getByCitizen: (citizenId, token) => apiFetch(`/api/issues/citizen/${citizenId}`, { token }),
  getById: (id, token) => apiFetch(`/api/issues/${id}`, { token }),
  getHistory: (id, token) => apiFetch(`/api/issues/${id}/history`, { token }),
  create: (data, token) => apiFetch('/api/issues', { method: 'POST', body: data, token }),
  update: (id, data, token) => apiFetch(`/api/issues/${id}`, { method: 'PUT', body: data, token }),
  delete: (id, token) => apiFetch(`/api/issues/${id}`, { method: 'DELETE', token })
}

// Tickets API
export const ticketsAPI = {
  getAll: (token) => apiFetch('/api/tickets', { token }),
  getStats: (token) => apiFetch('/api/tickets/stats', { token }),
  getByDepartment: (departmentId, token) => apiFetch(`/api/tickets/department/${departmentId}`, { token }),
  getByAssigned: (userId, token) => apiFetch(`/api/tickets/assigned/${userId}`, { token }),
  getById: (id, token) => apiFetch(`/api/tickets/${id}`, { token }),
  getHistory: (id, token) => apiFetch(`/api/tickets/${id}/history`, { token }),
  create: (data, token) => apiFetch('/api/tickets', { method: 'POST', body: data, token }),
  update: (id, data, token) => apiFetch(`/api/tickets/${id}`, { method: 'PUT', body: data, token }),
  delete: (id, token) => apiFetch(`/api/tickets/${id}`, { method: 'DELETE', token })
}

// Comments API
export const commentsAPI = {
  getByTicket: (ticketId, token) => apiFetch(`/api/comments/ticket/${ticketId}`, { token }),
  getByUser: (userId, token) => apiFetch(`/api/comments/user/${userId}`, { token }),
  getTicketStats: (ticketId, token) => apiFetch(`/api/comments/ticket/${ticketId}/stats`, { token }),
  getById: (id, token) => apiFetch(`/api/comments/${id}`, { token }),
  create: (data, token) => apiFetch('/api/comments', { method: 'POST', body: data, token }),
  update: (id, data, token) => apiFetch(`/api/comments/${id}`, { method: 'PUT', body: data, token }),
  delete: (id, token) => apiFetch(`/api/comments/${id}`, { method: 'DELETE', token })
}

// Attachments API
export const attachmentsAPI = {
  getByTicket: (ticketId, token) => apiFetch(`/api/attachments/ticket/${ticketId}`, { token }),
  getByIssue: (issueId, token) => apiFetch(`/api/attachments/issue/${issueId}`, { token }),
  getById: (id, token) => apiFetch(`/api/attachments/${id}`, { token }),
  download: (id, token) => apiFetch(`/api/attachments/${id}/download`, { token }),
  uploadTicket: (ticketId, formData, token) => {
    const headers = {}
    if (token) headers['Authorization'] = `Bearer ${token}`
    return fetch(getApiUrl(`api/attachments/ticket/${ticketId}`), {
      method: 'POST',
      headers,
      body: formData
    }).then(async (res) => {
      if (!res.ok) {
        let err
        try { err = await res.json() } catch { err = { error: res.statusText } }
        throw new Error(err.error || 'Upload failed')
      }
      return await res.json()
    })
  },
  uploadIssue: (issueId, formData, token) => {
    const headers = {}
    if (token) headers['Authorization'] = `Bearer ${token}`
    return fetch(getApiUrl(`api/attachments/issue/${issueId}`), {
      method: 'POST',
      headers,
      body: formData
    }).then(async (res) => {
      if (!res.ok) {
        let err
        try { err = await res.json() } catch { err = { error: res.statusText } }
        throw new Error(err.error || 'Upload failed')
      }
      return await res.json()
    })
  },
  delete: (id, token) => apiFetch(`/api/attachments/${id}`, { method: 'DELETE', token })
}

// Notifications API
export const notificationsAPI = {
  getMy: (token) => apiFetch('/api/notifications/my', { token }),
  getUnreadCount: (token) => apiFetch('/api/notifications/unread-count', { token }),
  getByUser: (userId, token) => apiFetch(`/api/notifications/user/${userId}`, { token }),
  getById: (id, token) => apiFetch(`/api/notifications/${id}`, { token }),
  markAsRead: (id, token) => apiFetch(`/api/notifications/${id}/read`, { method: 'PUT', token }),
  markAllAsRead: (token) => apiFetch('/api/notifications/mark-all-read', { method: 'PUT', token }),
  delete: (id, token) => apiFetch(`/api/notifications/${id}`, { method: 'DELETE', token }),
  create: (data, token) => apiFetch('/api/notifications', { method: 'POST', body: data, token }),
  sendBulk: (data, token) => apiFetch('/api/notifications/bulk', { method: 'POST', body: data, token })
}

// Feedback API
export const feedbackAPI = {
  getAll: (token) => apiFetch('/api/feedback', { token }),
  getStats: (token) => apiFetch('/api/feedback/stats', { token }),
  getByTicket: (ticketId, token) => apiFetch(`/api/feedback/ticket/${ticketId}`, { token }),
  getByCitizen: (citizenId, token) => apiFetch(`/api/feedback/citizen/${citizenId}`, { token }),
  getById: (id, token) => apiFetch(`/api/feedback/${id}`, { token }),
  create: (data, token) => apiFetch('/api/feedback', { method: 'POST', body: data, token }),
  update: (id, data, token) => apiFetch(`/api/feedback/${id}`, { method: 'PUT', body: data, token }),
  delete: (id, token) => apiFetch(`/api/feedback/${id}`, { method: 'DELETE', token })
}

// SLA API
export const slaAPI = {
  getAll: (token) => apiFetch('/api/sla', { token }),
  getByCategory: (categoryId, token) => apiFetch(`/api/sla/category/${categoryId}`, { token }),
  getStats: (token) => apiFetch('/api/sla/stats', { token }),
  getById: (id, token) => apiFetch(`/api/sla/${id}`, { token }),
  create: (data, token) => apiFetch('/api/sla', { method: 'POST', body: data, token }),
  update: (id, data, token) => apiFetch(`/api/sla/${id}`, { method: 'PUT', body: data, token }),
  delete: (id, token) => apiFetch(`/api/sla/${id}`, { method: 'DELETE', token }),
  applyToTicket: (ticketId, data, token) => apiFetch(`/api/sla/ticket/${ticketId}/apply`, { method: 'POST', body: data, token }),
  checkBreaches: (token) => apiFetch('/api/sla/check-breaches', { method: 'POST', token })
}

// Settings API
export const settingsAPI = {
  getConfig: (token) => apiFetch('/api/settings/config', { token }),
  getHealth: (token) => apiFetch('/api/settings/health', { token }),
  getStats: (token) => apiFetch('/api/settings/stats', { token }),
  getByKeys: (keys, token) => apiFetch(`/api/settings/keys?keys=${keys.join(',')}`, { token }),
  getByKey: (key, token) => apiFetch(`/api/settings/${key}`, { token }),
  getAll: (token) => apiFetch('/api/settings', { token }),
  create: (data, token) => apiFetch('/api/settings', { method: 'POST', body: data, token }),
  update: (key, data, token) => apiFetch(`/api/settings/${key}`, { method: 'PUT', body: data, token }),
  updateMultiple: (data, token) => apiFetch('/api/settings', { method: 'PUT', body: data, token }),
  delete: (key, token) => apiFetch(`/api/settings/${key}`, { method: 'DELETE', token }),
  resetDefaults: (token) => apiFetch('/api/settings/reset-defaults', { method: 'POST', token })
}
