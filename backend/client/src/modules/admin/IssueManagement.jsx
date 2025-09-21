import { useEffect, useState } from 'react'
import { useAuth } from '../auth/useAuth.jsx'
import { issuesAPI, departmentsAPI, categoriesAPI } from '../../services/api.js'
import { Card, Alert, Button } from '../../components/UI/index.js'

export default function IssueManagement() {
  const { token } = useAuth()
  const [allIssues, setAllIssues] = useState([])
  const [issues, setIssues] = useState([])
  const [departments, setDepartments] = useState([])
  const [categories, setCategories] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [filters, setFilters] = useState({
    status: '',
    priority: '',
    department_id: '',
    category_id: ''
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
  }, [filters, allIssues])

  const loadData = async () => {
    setLoading(true)
    setError('')
    try {
      const [issuesData, departmentsData, categoriesData] = await Promise.all([
        issuesAPI.getAll(token),
        departmentsAPI.getAll(token),
        categoriesAPI.getAll(token)
      ])
      const issuesArray = issuesData?.data?.issues || issuesData?.issues || []
      setAllIssues(issuesArray)
      setIssues(issuesArray)
      setDepartments(departmentsData?.data?.departments || departmentsData?.departments || [])
      setCategories(categoriesData?.data?.categories || categoriesData?.categories || [])
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const applyFilters = () => {
    let filteredIssues = [...allIssues]
    
    // Apply client-side filtering
    if (filters.status) {
      filteredIssues = filteredIssues.filter(i => i.status === filters.status)
    }
    if (filters.priority) {
      filteredIssues = filteredIssues.filter(i => i.priority === filters.priority)
    }
    if (filters.department_id) {
      filteredIssues = filteredIssues.filter(i => i.department_id === filters.department_id)
    }
    if (filters.category_id) {
      filteredIssues = filteredIssues.filter(i => i.category_id === filters.category_id)
    }
    
    setIssues(filteredIssues)
  }

  const handleStatusUpdate = async (issueId, newStatus) => {
    try {
      await issuesAPI.update(issueId, { status: newStatus }, token)
      // Update the issue in both allIssues and filtered issues
      setAllIssues(prev => prev.map(issue => 
        issue.id === issueId ? { ...issue, status: newStatus } : issue
      ))
      applyFilters()
    } catch (err) {
      setError(err.message)
    }
  }

  const handlePriorityUpdate = async (issueId, newPriority) => {
    try {
      await issuesAPI.update(issueId, { priority: newPriority }, token)
      // Update the issue in both allIssues and filtered issues
      setAllIssues(prev => prev.map(issue => 
        issue.id === issueId ? { ...issue, priority: newPriority } : issue
      ))
      applyFilters()
    } catch (err) {
      setError(err.message)
    }
  }

  const getStatusColor = (status) => {
    switch (status) {
      case 'open': return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-300'
      case 'in_progress': return 'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-300'
      case 'resolved': return 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-300'
      case 'closed': return 'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-300'
      default: return 'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-300'
    }
  }

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'low': return 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-300'
      case 'medium': return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-300'
      case 'high': return 'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-300'
      default: return 'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-300'
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white">Issue Management</h1>
        <p className="mt-2 text-gray-600 dark:text-gray-400">Manage and track citizen issues</p>
      </div>

      {error && (
        <Alert variant="error" title="Error Loading Issues">
          {error}
        </Alert>
      )}

      {/* Filters */}
      <Card title="Filters" subtitle="Filter issues by status, priority, department, and category">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">Status</label>
            <select
              value={filters.status}
              onChange={(e) => setFilters({ ...filters, status: e.target.value })}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              <option value="">All Status</option>
              <option value="open">Open</option>
              <option value="in_progress">In Progress</option>
              <option value="resolved">Resolved</option>
              <option value="closed">Closed</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Priority</label>
            <select
              value={filters.priority}
              onChange={(e) => setFilters({ ...filters, priority: e.target.value })}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              <option value="">All Priority</option>
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Department</label>
            <select
              value={filters.department_id}
              onChange={(e) => setFilters({ ...filters, department_id: e.target.value })}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              <option value="">All Departments</option>
              {(departments || []).map((dept) => (
                <option key={dept.id} value={dept.id}>
                  {dept.name}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Category</label>
            <select
              value={filters.category_id}
              onChange={(e) => setFilters({ ...filters, category_id: e.target.value })}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              <option value="">All Categories</option>
              {(categories || []).map((cat) => (
                <option key={cat.id} value={cat.id}>
                  {cat.name}
                </option>
              ))}
            </select>
          </div>
        </div>
      </Card>

      {/* Issues Table */}
      <Card title="Issues" subtitle={`${issues.length} issue${issues.length !== 1 ? 's' : ''} found`}>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
              <thead className="bg-gray-50 dark:bg-gray-700">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                    Issue
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                    Priority
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                    Category
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                    Department
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                    Created
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
                {loading ? (
                  <tr>
                    <td colSpan="7" className="px-6 py-4 text-center text-gray-500 dark:text-gray-400">
                      Loading issues...
                    </td>
                  </tr>
                ) : issues.length === 0 ? (
                  <tr>
                    <td colSpan="7" className="px-6 py-4 text-center text-gray-500 dark:text-gray-400">
                      No issues found
                    </td>
                  </tr>
                ) : (
                  issues.map((issue) => (
                    <tr key={issue.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4">
                        <div className="text-sm font-medium text-gray-900">
                          #{issue.id}
                        </div>
                        <div className="text-sm text-gray-500 max-w-xs truncate">
                          {issue.description || issue.title || 'No description'}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <select
                          value={issue.status || 'open'}
                          onChange={(e) => handleStatusUpdate(issue.id, e.target.value)}
                          className={`text-xs font-semibold rounded-full border-0 focus:ring-2 focus:ring-indigo-500 ${getStatusColor(issue.status || 'open')}`}
                        >
                          <option value="open">Open</option>
                          <option value="in_progress">In Progress</option>
                          <option value="resolved">Resolved</option>
                          <option value="closed">Closed</option>
                        </select>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <select
                          value={issue.priority || 'medium'}
                          onChange={(e) => handlePriorityUpdate(issue.id, e.target.value)}
                          className={`text-xs font-semibold rounded-full border-0 focus:ring-2 focus:ring-indigo-500 ${getPriorityColor(issue.priority || 'medium')}`}
                        >
                          <option value="low">Low</option>
                          <option value="medium">Medium</option>
                          <option value="high">High</option>
                        </select>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {(categories || []).find(c => c.id === issue.category_id)?.name || 'No category'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {(departments || []).find(d => d.id === issue.department_id)?.name || 'No department'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {issue.created_at ? new Date(issue.created_at).toLocaleDateString() : 'Unknown'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button className="text-indigo-600 hover:text-indigo-900 mr-3">
                          View
                        </button>
                        <button className="text-red-600 hover:text-red-900">
                          Delete
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
      </Card>
    </div>
  )
}
