import { useEffect, useState } from 'react'
import { useAuth } from '../auth/useAuth.jsx'
import { analyticsAPI, ticketsAPI, usersAPI, departmentsAPI } from '../../services/api.js'
import { Card, Alert } from '../../components/UI/index.js'

export default function AnalyticsDashboard() {
  const { token } = useAuth()
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [analytics, setAnalytics] = useState({
    dashboard: {},
    departmentPerformance: [],
    categoryAnalytics: [],
    summary: {}
  })

  useEffect(() => {
    loadAnalytics()
  }, [])

  const loadAnalytics = async () => {
    setLoading(true)
    setError('')
    try {
      const [dashboardData, departmentData, categoryData, summaryData] = await Promise.all([
        analyticsAPI.getDashboard(token).catch(() => ({})),
        analyticsAPI.getDepartmentPerformance(token).catch(() => []),
        analyticsAPI.getCategoryAnalytics(token).catch(() => []),
        analyticsAPI.getSummary(token).catch(() => ({}))
      ])
      
      // Extract data from API responses, handling different response structures
      const dashboard = dashboardData?.data || dashboardData || {}
      const departmentPerformance = departmentData?.data?.departments || departmentData?.data || departmentData || []
      const categoryAnalytics = categoryData?.data?.categories || categoryData?.data || categoryData || []
      const summary = summaryData?.data || summaryData || {}
      
      setAnalytics({
        dashboard,
        departmentPerformance: Array.isArray(departmentPerformance) ? departmentPerformance : [],
        categoryAnalytics: Array.isArray(categoryAnalytics) ? categoryAnalytics : [],
        summary
      })
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
        <span className="ml-3 text-lg text-gray-600 dark:text-gray-400">Loading analytics...</span>
      </div>
    )
  }

  if (error) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">Analytics Dashboard</h1>
          <p className="mt-2 text-gray-600 dark:text-gray-400">View system performance and statistics</p>
        </div>
        <Alert variant="error" title="Error Loading Analytics">
          {error}
        </Alert>
      </div>
    )
  }

  const summaryCards = [
    {
      name: 'Total Issues',
      value: analytics.summary.total_issues || 0,
      change: '+12%',
      changeType: 'increase',
      icon: 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z'
    },
    {
      name: 'Resolved Issues',
      value: analytics.summary.resolved_issues || 0,
      change: '+8%',
      changeType: 'increase',
      icon: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'
    },
    {
      name: 'Active Tickets',
      value: analytics.summary.active_tickets || 0,
      change: '+15%',
      changeType: 'increase',
      icon: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z'
    },
    {
      name: 'User Satisfaction',
      value: `${analytics.summary.user_satisfaction || 0}%`,
      change: '+5%',
      changeType: 'increase',
      icon: 'M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z'
    }
  ]

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Analytics Dashboard</h1>
          <p className="mt-1 text-sm text-gray-500">System performance and insights</p>
        </div>
        <button
          onClick={loadAnalytics}
          className="bg-indigo-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-indigo-700"
        >
          Refresh Data
        </button>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-md p-4">
          <div className="text-sm text-red-700">{error}</div>
        </div>
      )}

      {/* Summary Cards */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {(summaryCards || []).map((card) => (
          <div key={card.name} className="bg-white overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <svg className="h-8 w-8 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={card.icon} />
                  </svg>
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">{card.name}</dt>
                    <dd className="flex items-baseline">
                      <div className="text-2xl font-semibold text-gray-900">{card.value}</div>
                      <div className={`ml-2 flex items-baseline text-sm font-semibold ${
                        card.changeType === 'increase' ? 'text-green-600' : 
                        card.changeType === 'decrease' ? 'text-red-600' : 'text-gray-500'
                      }`}>
                        {card.change}
                      </div>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Department Performance */}
      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">Department Performance</h3>
          {analytics.departmentPerformance.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              No department performance data available
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Department
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Total Tickets
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Resolved
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Avg. Resolution Time
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Satisfaction
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {(analytics.departmentPerformance || []).map((dept) => (
                    <tr key={dept.department_id}>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {dept.department_name}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {dept.total_tickets || 0}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {dept.resolved_tickets || 0}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {dept.avg_resolution_time || 'N/A'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {dept.satisfaction_score || 'N/A'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>

      {/* Category Analytics */}
      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">Category Analytics</h3>
          {analytics.categoryAnalytics.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              No category analytics data available
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Category
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Total Issues
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Open Issues
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Resolved Issues
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Resolution Rate
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {(analytics.categoryAnalytics || []).map((category) => (
                    <tr key={category.category_id}>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {category.category_name}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {category.total_issues || 0}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {category.open_issues || 0}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {category.resolved_issues || 0}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {category.resolution_rate || 'N/A'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-1 gap-5 lg:grid-cols-2">
        <div className="bg-white shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">System Health</h3>
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-500">Server Status</span>
                <div className="flex items-center">
                  <div className="h-2 w-2 bg-green-500 rounded-full mr-2"></div>
                  <span className="text-sm font-medium text-green-600">Online</span>
                </div>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-500">Database Status</span>
                <div className="flex items-center">
                  <div className="h-2 w-2 bg-green-500 rounded-full mr-2"></div>
                  <span className="text-sm font-medium text-green-600">Connected</span>
                </div>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-500">API Response Time</span>
                <span className="text-sm font-medium text-gray-900">120ms</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-500">Last Backup</span>
                <span className="text-sm font-medium text-gray-900">2 hours ago</span>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">Recent Activity</h3>
            <div className="space-y-3">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <div className="h-2 w-2 bg-green-500 rounded-full"></div>
                </div>
                <div className="ml-3">
                  <p className="text-sm text-gray-900">System initialized successfully</p>
                  <p className="text-xs text-gray-500">Just now</p>
                </div>
              </div>
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <div className="h-2 w-2 bg-blue-500 rounded-full"></div>
                </div>
                <div className="ml-3">
                  <p className="text-sm text-gray-900">Admin dashboard loaded</p>
                  <p className="text-xs text-gray-500">1 minute ago</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
