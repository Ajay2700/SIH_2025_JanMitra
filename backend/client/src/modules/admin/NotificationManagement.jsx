import { useEffect, useState } from 'react'
import { useAuth } from '../auth/useAuth.jsx'
import { notificationsAPI, usersAPI } from '../../services/api.js'
import { Card, Alert, Button } from '../../components/UI/index.js'

export default function NotificationManagement() {
  const { token } = useAuth()
  const [notifications, setNotifications] = useState([])
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [showModal, setShowModal] = useState(false)
  const [unreadCount, setUnreadCount] = useState(0)
  const [formData, setFormData] = useState({
    title: '',
    message: '',
    type: 'info',
    target_users: [],
    send_to_all: false
  })

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    setLoading(true)
    setError('')
    try {
      const [notificationsData, usersData, unreadData] = await Promise.all([
        notificationsAPI.getMy(token),
        usersAPI.getAll(token),
        notificationsAPI.getUnreadCount(token).catch(() => ({ count: 0 }))
      ])
      
      // Extract data from API responses, handling different response structures
      const notificationsArray = notificationsData?.data?.notifications || notificationsData?.data || notificationsData || []
      const usersArray = usersData?.data?.users || usersData?.users || usersData || []
      
      setNotifications(Array.isArray(notificationsArray) ? notificationsArray : [])
      setUsers(Array.isArray(usersArray) ? usersArray : [])
      setUnreadCount(unreadData?.count || unreadData?.data?.count || 0)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      if (formData.send_to_all) {
        await notificationsAPI.sendBulk({
          title: formData.title,
          message: formData.message,
          type: formData.type,
          send_to_all: true
        }, token)
      } else {
        await notificationsAPI.create({
          title: formData.title,
          message: formData.message,
          type: formData.type,
          target_users: formData.target_users
        }, token)
      }
      setShowModal(false)
      setFormData({
        title: '',
        message: '',
        type: 'info',
        target_users: [],
        send_to_all: false
      })
      loadData()
    } catch (err) {
      setError(err.message)
    }
  }

  const handleMarkAsRead = async (notificationId) => {
    try {
      await notificationsAPI.markAsRead(notificationId, token)
      loadData()
    } catch (err) {
      setError(err.message)
    }
  }

  const handleMarkAllAsRead = async () => {
    try {
      await notificationsAPI.markAllAsRead(token)
      loadData()
    } catch (err) {
      setError(err.message)
    }
  }

  const handleDelete = async (notificationId) => {
    if (window.confirm('Are you sure you want to delete this notification?')) {
      try {
        await notificationsAPI.delete(notificationId, token)
        loadData()
      } catch (err) {
        setError(err.message)
      }
    }
  }

  const getTypeColor = (type) => {
    switch (type) {
      case 'success': return 'bg-green-100 text-green-800'
      case 'warning': return 'bg-yellow-100 text-yellow-800'
      case 'error': return 'bg-red-100 text-red-800'
      case 'info': return 'bg-blue-100 text-blue-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getTypeIcon = (type) => {
    switch (type) {
      case 'success': return 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'
      case 'warning': return 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z'
      case 'error': return 'M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z'
      case 'info': return 'M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z'
      default: return 'M15 17h5l-5 5v-5zM4.828 7l2.586 2.586a2 2 0 002.828 0L12.828 7H4.828zm0 10h8l-2.586-2.586a2 2 0 00-2.828 0L4.828 17z'
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">Notification Management</h1>
          <p className="mt-2 text-gray-600 dark:text-gray-400">Manage system notifications and alerts</p>
        </div>
        <div className="flex space-x-3">
          {unreadCount > 0 && (
            <button
              onClick={handleMarkAllAsRead}
              className="bg-blue-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-blue-700"
            >
              Mark All Read
            </button>
          )}
          <button
            onClick={() => setShowModal(true)}
            className="bg-indigo-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-indigo-700"
          >
            Send Notification
          </button>
        </div>
      </div>

      {error && (
        <Alert variant="error" title="Error Loading Notifications">
          {error}
        </Alert>
      )}

      {/* Notification Stats */}
      <div className="bg-white shadow rounded-lg p-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="text-center">
            <div className="flex items-center justify-center mb-2">
              <svg className="h-6 w-6 text-gray-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-5 5v-5zM4.828 7l2.586 2.586a2 2 0 002.828 0L12.828 7H4.828zm0 10h8l-2.586-2.586a2 2 0 00-2.828 0L4.828 17z" />
              </svg>
            </div>
            <div className="text-2xl font-bold text-gray-900">{notifications.length}</div>
            <div className="text-sm text-gray-500">Total Notifications</div>
          </div>
          <div className="text-center">
            <div className="flex items-center justify-center mb-2">
              <svg className="h-6 w-6 text-red-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
              </svg>
            </div>
            <div className="text-2xl font-bold text-red-600">{unreadCount}</div>
            <div className="text-sm text-gray-500">Unread</div>
          </div>
          <div className="text-center">
            <div className="flex items-center justify-center mb-2">
              <svg className="h-6 w-6 text-green-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div className="text-2xl font-bold text-green-600">{notifications.length - unreadCount}</div>
            <div className="text-sm text-gray-500">Read</div>
          </div>
        </div>
      </div>

      {/* Notifications List */}
      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          {loading ? (
            <div className="flex items-center justify-center py-8">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
              <span className="ml-3 text-gray-600 dark:text-gray-400">Loading notifications...</span>
            </div>
          ) : notifications.length === 0 ? (
            <div className="text-center py-8 text-gray-500">No notifications found</div>
          ) : (
            <div className="space-y-4">
              {(notifications || []).map((notification) => (
                <div
                  key={notification.id}
                  className={`border rounded-lg p-4 ${
                    notification.is_read ? 'bg-gray-50 border-gray-200' : 'bg-white border-blue-200 shadow-sm'
                  }`}
                >
                  <div className="flex items-start justify-between">
                    <div className="flex items-start space-x-3">
                      <div className="flex-shrink-0">
                        <svg className="h-5 w-5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={getTypeIcon(notification.type)} />
                        </svg>
                      </div>
                      <div className="flex-1">
                        <div className="flex items-center space-x-2">
                          <h3 className={`text-sm font-medium ${
                            notification.is_read ? 'text-gray-900' : 'text-gray-900 font-semibold'
                          }`}>
                            {notification.title}
                          </h3>
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getTypeColor(notification.type)}`}>
                            {notification.type}
                          </span>
                        </div>
                        <p className="mt-1 text-sm text-gray-600">{notification.message}</p>
                        <p className="mt-2 text-xs text-gray-500">
                          {notification.created_at ? new Date(notification.created_at).toLocaleString() : 'Unknown time'}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center space-x-2">
                      {!notification.is_read && (
                        <button
                          onClick={() => handleMarkAsRead(notification.id)}
                          className="text-blue-600 hover:text-blue-900 text-sm"
                        >
                          Mark Read
                        </button>
                      )}
                      <button
                        onClick={() => handleDelete(notification.id)}
                        className="text-red-600 hover:text-red-900 text-sm"
                      >
                        Delete
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Send Notification Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-full max-w-md shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">Send Notification</h3>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Title</label>
                  <input
                    type="text"
                    required
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Message</label>
                  <textarea
                    required
                    value={formData.message}
                    onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                    rows={3}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Type</label>
                  <select
                    value={formData.type}
                    onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                  >
                    <option value="info">Info</option>
                    <option value="success">Success</option>
                    <option value="warning">Warning</option>
                    <option value="error">Error</option>
                  </select>
                </div>
                <div className="flex items-center">
                  <input
                    type="checkbox"
                    id="send_to_all"
                    checked={formData.send_to_all}
                    onChange={(e) => setFormData({ ...formData, send_to_all: e.target.checked })}
                    className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                  />
                  <label htmlFor="send_to_all" className="ml-2 block text-sm text-gray-900">
                    Send to all users
                  </label>
                </div>
                {!formData.send_to_all && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Target Users</label>
                    <select
                      multiple
                      value={formData.target_users}
                      onChange={(e) => {
                        const values = Array.from(e.target.selectedOptions, option => option.value)
                        setFormData({ ...formData, target_users: values })
                      }}
                      className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                    >
                      {(users || []).map((user) => (
                        <option key={user.id} value={user.id}>
                          {user.full_name || user.email}
                        </option>
                      ))}
                    </select>
                    <p className="mt-1 text-xs text-gray-500">Hold Ctrl/Cmd to select multiple users</p>
                  </div>
                )}
                <div className="flex justify-end space-x-3">
                  <button
                    type="button"
                    onClick={() => setShowModal(false)}
                    className="bg-gray-300 text-gray-700 px-4 py-2 rounded-md text-sm font-medium hover:bg-gray-400"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="bg-indigo-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-indigo-700"
                  >
                    Send Notification
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
