import { useEffect, useState } from 'react'
import { useAuth } from '../auth/useAuth.jsx'
import { feedbackAPI, ticketsAPI } from '../../services/api.js'

export default function FeedbackManagement() {
  const { token } = useAuth()
  const [allFeedback, setAllFeedback] = useState([])
  const [feedback, setFeedback] = useState([])
  const [tickets, setTickets] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [filters, setFilters] = useState({
    rating: '',
    status: ''
  })

  useEffect(() => {
    loadData()
  }, [])

  // Debounced filter effect to prevent too many API calls
  useEffect(() => {
    const timeoutId = setTimeout(() => {
      applyFilters()
    }, 300) // 300ms debounce

    return () => clearTimeout(timeoutId)
  }, [filters])

  const loadData = async () => {
    setLoading(true)
    setError('')
    try {
      const [feedbackData, ticketsData] = await Promise.all([
        feedbackAPI.getAll(token),
        ticketsAPI.getAll(token).catch(() => [])
      ])
      const feedbackArray = feedbackData?.data?.feedback || feedbackData?.data || feedbackData || []
      setAllFeedback(Array.isArray(feedbackArray) ? feedbackArray : [])
      setFeedback(Array.isArray(feedbackArray) ? feedbackArray : [])
      setTickets(ticketsData || [])
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const applyFilters = () => {
    let filteredFeedback = [...allFeedback]
    
    // Apply client-side filtering
    if (filters.rating) {
      filteredFeedback = filteredFeedback.filter(f => f.rating === parseInt(filters.rating))
    }
    if (filters.status) {
      filteredFeedback = filteredFeedback.filter(f => f.status === filters.status)
    }
    
    setFeedback(filteredFeedback)
  }

  const handleStatusUpdate = async (feedbackId, newStatus) => {
    try {
      await feedbackAPI.update(feedbackId, { status: newStatus }, token)
      // Update the feedback in both allFeedback and filtered feedback
      setAllFeedback(prev => prev.map(fb => 
        fb.id === feedbackId ? { ...fb, status: newStatus } : fb
      ))
      applyFilters()
    } catch (err) {
      setError(err.message)
    }
  }

  const handleDelete = async (feedbackId) => {
    if (window.confirm('Are you sure you want to delete this feedback?')) {
      try {
        await feedbackAPI.delete(feedbackId, token)
        loadFeedback()
      } catch (err) {
        setError(err.message)
      }
    }
  }

  const getRatingColor = (rating) => {
    switch (rating) {
      case 5: return 'text-green-600'
      case 4: return 'text-blue-600'
      case 3: return 'text-yellow-600'
      case 2: return 'text-orange-600'
      case 1: return 'text-red-600'
      default: return 'text-gray-600'
    }
  }

  const getRatingStars = (rating) => {
    return Array.from({ length: 5 }, (_, i) => (
      <svg key={i} className={`h-4 w-4 ${i < rating ? 'text-yellow-400' : 'text-gray-300'}`} fill="currentColor" viewBox="0 0 20 20">
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
      </svg>
    ))
  }

  const getStatusColor = (status) => {
    switch (status) {
      case 'published': return 'bg-green-100 text-green-800'
      case 'pending': return 'bg-yellow-100 text-yellow-800'
      case 'rejected': return 'bg-red-100 text-red-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Feedback Management</h1>
        <p className="mt-1 text-sm text-gray-500">Manage citizen feedback and reviews</p>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-md p-4">
          <div className="text-sm text-red-700">{error}</div>
        </div>
      )}

      {/* Filters */}
      <div className="bg-white shadow rounded-lg p-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Filters</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">Rating</label>
            <select
              value={filters.rating}
              onChange={(e) => setFilters({ ...filters, rating: e.target.value })}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              <option value="">All Ratings</option>
              <option value="5">5 Stars</option>
              <option value="4">4 Stars</option>
              <option value="3">3 Stars</option>
              <option value="2">2 Stars</option>
              <option value="1">1 Star</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Status</label>
            <select
              value={filters.status}
              onChange={(e) => setFilters({ ...filters, status: e.target.value })}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              <option value="">All Status</option>
              <option value="pending">Pending</option>
              <option value="published">Published</option>
              <option value="rejected">Rejected</option>
            </select>
          </div>
        </div>
      </div>

      {/* Feedback Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white shadow rounded-lg p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <svg className="h-8 w-8 text-yellow-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
              </svg>
            </div>
            <div className="ml-3">
              <p className="text-sm font-medium text-gray-500">Average Rating</p>
              <p className="text-lg font-semibold text-gray-900">
                {feedback.length > 0 ? 
                  (feedback.reduce((sum, f) => sum + (f.rating || 0), 0) / feedback.length).toFixed(1) : 
                  'N/A'
                }
              </p>
            </div>
          </div>
        </div>
        <div className="bg-white shadow rounded-lg p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <svg className="h-8 w-8 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
            <div className="ml-3">
              <p className="text-sm font-medium text-gray-500">Total Feedback</p>
              <p className="text-lg font-semibold text-gray-900">{feedback.length}</p>
            </div>
          </div>
        </div>
        <div className="bg-white shadow rounded-lg p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <svg className="h-8 w-8 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div className="ml-3">
              <p className="text-sm font-medium text-gray-500">Published</p>
              <p className="text-lg font-semibold text-gray-900">
                {feedback.filter(f => f.status === 'published').length}
              </p>
            </div>
          </div>
        </div>
        <div className="bg-white shadow rounded-lg p-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <svg className="h-8 w-8 text-yellow-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div className="ml-3">
              <p className="text-sm font-medium text-gray-500">Pending</p>
              <p className="text-lg font-semibold text-gray-900">
                {feedback.filter(f => f.status === 'pending').length}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Feedback Table */}
      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Feedback
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Rating
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ticket
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Submitted
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {loading ? (
                  <tr>
                    <td colSpan="6" className="px-6 py-4 text-center text-gray-500">
                      Loading feedback...
                    </td>
                  </tr>
                ) : feedback.length === 0 ? (
                  <tr>
                    <td colSpan="6" className="px-6 py-4 text-center text-gray-500">
                      No feedback found
                    </td>
                  </tr>
                ) : (
                  (feedback || []).map((item) => (
                    <tr key={item.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4">
                        <div className="text-sm font-medium text-gray-900">
                          {item.title || 'No title'}
                        </div>
                        <div className="text-sm text-gray-500 max-w-xs truncate">
                          {item.comment || 'No comment'}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="flex">
                            {getRatingStars(item.rating || 0)}
                          </div>
                          <span className={`ml-2 text-sm ${getRatingColor(item.rating)}`}>
                            {item.rating || 0}/5
                          </span>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {item.ticket_id ? (
                          <span className="text-indigo-600">#{item.ticket_id}</span>
                        ) : (
                          'No ticket'
                        )}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <select
                          value={item.status || 'pending'}
                          onChange={(e) => handleStatusUpdate(item.id, e.target.value)}
                          className={`text-xs font-semibold rounded-full border-0 focus:ring-2 focus:ring-indigo-500 ${getStatusColor(item.status || 'pending')}`}
                        >
                          <option value="pending">Pending</option>
                          <option value="published">Published</option>
                          <option value="rejected">Rejected</option>
                        </select>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {item.created_at ? new Date(item.created_at).toLocaleDateString() : 'Unknown'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button className="text-indigo-600 hover:text-indigo-900 mr-3">
                          View
                        </button>
                        <button
                          onClick={() => handleDelete(item.id)}
                          className="text-red-600 hover:text-red-900"
                        >
                          Delete
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  )
}
