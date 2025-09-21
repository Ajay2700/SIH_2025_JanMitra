import { useEffect, useState } from 'react'
import { useAuth } from '../auth/useAuth.jsx'
import { ticketsAPI, usersAPI, departmentsAPI, categoriesAPI } from '../../services/api.js'

export default function TicketManagement() {
  const { token } = useAuth()
  const [allTickets, setAllTickets] = useState([])
  const [tickets, setTickets] = useState([])
  const [users, setUsers] = useState([])
  const [departments, setDepartments] = useState([])
  const [categories, setCategories] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [filters, setFilters] = useState({
    status: '',
    priority: '',
    department_id: '',
    assigned_to: ''
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
      const [ticketsData, usersData, departmentsData, categoriesData] = await Promise.all([
        ticketsAPI.getAll(token),
        usersAPI.getAll(token),
        departmentsAPI.getAll(token),
        categoriesAPI.getAll(token)
      ])
      const ticketsArray = ticketsData?.data?.tickets || ticketsData?.tickets || []
      setAllTickets(ticketsArray)
      setTickets(ticketsArray)
      setUsers(usersData?.data?.users || usersData?.users || [])
      setDepartments(departmentsData?.data?.departments || departmentsData?.departments || [])
      setCategories(categoriesData?.data?.categories || categoriesData?.categories || [])
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const applyFilters = () => {
    let filteredTickets = [...allTickets]
    
    // Apply client-side filtering
    if (filters.status) {
      filteredTickets = filteredTickets.filter(t => t.status === filters.status)
    }
    if (filters.priority) {
      filteredTickets = filteredTickets.filter(t => t.priority === filters.priority)
    }
    if (filters.department_id) {
      filteredTickets = filteredTickets.filter(t => t.department_id === filters.department_id)
    }
    if (filters.assigned_to) {
      filteredTickets = filteredTickets.filter(t => t.assigned_to === filters.assigned_to)
    }
    
    setTickets(filteredTickets)
  }

  const handleStatusUpdate = async (ticketId, newStatus) => {
    try {
      await ticketsAPI.update(ticketId, { status: newStatus }, token)
      // Update the ticket in both allTickets and filtered tickets
      setAllTickets(prev => prev.map(ticket => 
        ticket.id === ticketId ? { ...ticket, status: newStatus } : ticket
      ))
      applyFilters()
    } catch (err) {
      setError(err.message)
    }
  }

  const handlePriorityUpdate = async (ticketId, newPriority) => {
    try {
      await ticketsAPI.update(ticketId, { priority: newPriority }, token)
      // Update the ticket in both allTickets and filtered tickets
      setAllTickets(prev => prev.map(ticket => 
        ticket.id === ticketId ? { ...ticket, priority: newPriority } : ticket
      ))
      applyFilters()
    } catch (err) {
      setError(err.message)
    }
  }

  const handleAssignmentUpdate = async (ticketId, assignedTo) => {
    try {
      await ticketsAPI.update(ticketId, { assigned_to: assignedTo }, token)
      // Update the ticket in both allTickets and filtered tickets
      setAllTickets(prev => prev.map(ticket => 
        ticket.id === ticketId ? { ...ticket, assigned_to: assignedTo } : ticket
      ))
      applyFilters()
    } catch (err) {
      setError(err.message)
    }
  }

  const getStatusColor = (status) => {
    switch (status) {
      case 'open': return 'bg-yellow-100 text-yellow-800'
      case 'assigned': return 'bg-blue-100 text-blue-800'
      case 'in_progress': return 'bg-purple-100 text-purple-800'
      case 'resolved': return 'bg-green-100 text-green-800'
      case 'closed': return 'bg-gray-100 text-gray-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'low': return 'bg-green-100 text-green-800'
      case 'medium': return 'bg-yellow-100 text-yellow-800'
      case 'high': return 'bg-red-100 text-red-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Ticket Management</h1>
        <p className="mt-1 text-sm text-gray-500">Manage and track support tickets</p>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-md p-4">
          <div className="text-sm text-red-700">{error}</div>
        </div>
      )}

      {/* Filters */}
      <div className="bg-white shadow rounded-lg p-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Filters</h3>
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
              <option value="assigned">Assigned</option>
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
            <label className="block text-sm font-medium text-gray-700">Assigned To</label>
            <select
              value={filters.assigned_to}
              onChange={(e) => setFilters({ ...filters, assigned_to: e.target.value })}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              <option value="">All Users</option>
              {(users || []).map((user) => (
                <option key={user.id} value={user.id}>
                  {user.full_name || user.email}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Tickets Table */}
      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ticket
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Priority
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Assigned To
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Department
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Created
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {loading ? (
                  <tr>
                    <td colSpan="7" className="px-6 py-4 text-center text-gray-500">
                      Loading tickets...
                    </td>
                  </tr>
                ) : tickets.length === 0 ? (
                  <tr>
                    <td colSpan="7" className="px-6 py-4 text-center text-gray-500">
                      No tickets found
                    </td>
                  </tr>
                ) : (
                  (tickets || []).map((ticket) => (
                    <tr key={ticket.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4">
                        <div className="text-sm font-medium text-gray-900">
                          #{ticket.id}
                        </div>
                        <div className="text-sm text-gray-500 max-w-xs truncate">
                          {ticket.description || ticket.title || 'No description'}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <select
                          value={ticket.status || 'open'}
                          onChange={(e) => handleStatusUpdate(ticket.id, e.target.value)}
                          className={`text-xs font-semibold rounded-full border-0 focus:ring-2 focus:ring-indigo-500 ${getStatusColor(ticket.status || 'open')}`}
                        >
                          <option value="open">Open</option>
                          <option value="assigned">Assigned</option>
                          <option value="in_progress">In Progress</option>
                          <option value="resolved">Resolved</option>
                          <option value="closed">Closed</option>
                        </select>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <select
                          value={ticket.priority || 'medium'}
                          onChange={(e) => handlePriorityUpdate(ticket.id, e.target.value)}
                          className={`text-xs font-semibold rounded-full border-0 focus:ring-2 focus:ring-indigo-500 ${getPriorityColor(ticket.priority || 'medium')}`}
                        >
                          <option value="low">Low</option>
                          <option value="medium">Medium</option>
                          <option value="high">High</option>
                        </select>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <select
                          value={ticket.assigned_to || ''}
                          onChange={(e) => handleAssignmentUpdate(ticket.id, e.target.value)}
                          className="text-sm border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
                        >
                          <option value="">Unassigned</option>
                          {(users || []).map((user) => (
                            <option key={user.id} value={user.id}>
                              {user.full_name || user.email}
                            </option>
                          ))}
                        </select>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {departments.find(d => d.id === ticket.department_id)?.name || 'No department'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {ticket.created_at ? new Date(ticket.created_at).toLocaleDateString() : 'Unknown'}
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
        </div>
      </div>
    </div>
  )
}
