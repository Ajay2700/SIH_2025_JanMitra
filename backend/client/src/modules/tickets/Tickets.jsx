import { useEffect, useState, useMemo } from 'react'
import { useAuth, apiFetch } from '../auth/useAuth.jsx'
import { Card, Alert, Button } from '../../components/UI/index.js'

export default function Tickets() {
	const { token } = useAuth()
	const [rows, setRows] = useState([])
	const [loading, setLoading] = useState(false)
	const [error, setError] = useState('')
	const [filters, setFilters] = useState({ status: '', priority: '' })

	async function load() {
		setLoading(true); setError('')
		try {
			// Simulate API call delay
			await new Promise(resolve => setTimeout(resolve, 1000))
			
			// Mock tickets data for regular users
			const mockTickets = [
				{
					id: 1,
					description: 'Login issue - cannot access account',
					title: 'Login Problem',
					status: 'in_progress',
					priority: 'high',
					created_at: new Date().toISOString()
				},
				{
					id: 2,
					description: 'Password reset not working',
					title: 'Password Reset Issue',
					status: 'open',
					priority: 'medium',
					created_at: new Date(Date.now() - 86400000).toISOString()
				},
				{
					id: 3,
					description: 'Profile update feature request',
					title: 'Profile Update',
					status: 'resolved',
					priority: 'low',
					created_at: new Date(Date.now() - 172800000).toISOString()
				},
				{
					id: 4,
					description: 'Dashboard loading slowly',
					title: 'Performance Issue',
					status: 'assigned',
					priority: 'medium',
					created_at: new Date(Date.now() - 259200000).toISOString()
				}
			]
			
			// Apply filters to mock data
			let filteredTickets = mockTickets
			if (filters.status) {
				filteredTickets = filteredTickets.filter(ticket => ticket.status === filters.status)
			}
			if (filters.priority) {
				filteredTickets = filteredTickets.filter(ticket => ticket.priority === filters.priority)
			}
			
			setRows(filteredTickets)
		} catch (e) {
			setError('Unable to load tickets')
		} finally {
			setLoading(false)
		}
	}

	useEffect(() => { load() }, [filters.status, filters.priority])

	function toQuery(obj) {
		const p = new URLSearchParams()
		Object.entries(obj).forEach(([k,v]) => { if (v) p.set(k, v) })
		const s = p.toString()
		return s ? `?${s}` : ''
	}

	const getStatusColor = (status) => {
		switch (status) {
			case 'open': return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-300'
			case 'assigned': return 'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-300'
			case 'in_progress': return 'bg-purple-100 text-purple-800 dark:bg-purple-900/20 dark:text-purple-300'
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
			{/* Header */}
			<div>
				<h1 className="text-3xl font-bold text-gray-900 dark:text-white">My Tickets</h1>
				<p className="mt-2 text-gray-600 dark:text-gray-400">
					Manage and track your support tickets
				</p>
			</div>

			{/* Filters */}
			<Card title="Filters" subtitle="Filter tickets by status and priority">
				<div className="flex flex-wrap gap-4">
					<div className="flex-1 min-w-48">
						<label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
							Status
						</label>
						<select 
							className="block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
							value={filters.status} 
							onChange={(e)=>setFilters(f=>({...f, status:e.target.value}))}
						>
							<option value="">All Status</option>
							{['open','assigned','in_progress','resolved','closed'].map(s=> 
								<option key={s} value={s}>{s.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase())}</option>
							)}
						</select>
					</div>
					<div className="flex-1 min-w-48">
						<label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
							Priority
						</label>
						<select 
							className="block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
							value={filters.priority} 
							onChange={(e)=>setFilters(f=>({...f, priority:e.target.value}))}
						>
							<option value="">All Priority</option>
							{['low','medium','high'].map(p=> 
								<option key={p} value={p}>{p.charAt(0).toUpperCase() + p.slice(1)}</option>
							)}
						</select>
					</div>
					<div className="flex items-end">
						<Button onClick={load} loading={loading} variant="secondary">
							<svg className="w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
								<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
							</svg>
							Refresh
						</Button>
					</div>
				</div>
			</Card>

			{/* Error Alert */}
			{error && (
				<Alert variant="error" title="Error Loading Tickets">
					{error}
				</Alert>
			)}

			{/* Tickets Table */}
			<Card title="Tickets" subtitle={`${rows.length} ticket${rows.length !== 1 ? 's' : ''} found`}>
				<div className="overflow-x-auto">
					<table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
						<thead className="bg-gray-50 dark:bg-gray-700">
							<tr>
								<th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
									Ticket ID
								</th>
								<th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
									Description
								</th>
								<th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
									Status
								</th>
								<th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
									Priority
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
									<td colSpan={6} className="px-6 py-12 text-center">
										<div className="flex items-center justify-center">
											<svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-blue-600" fill="none" viewBox="0 0 24 24">
												<circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
												<path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
											</svg>
											Loading tickets...
										</div>
									</td>
								</tr>
							) : rows.length === 0 ? (
								<tr>
									<td colSpan={6} className="px-6 py-12 text-center">
										<div className="text-gray-500 dark:text-gray-400">
											<svg className="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
												<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
											</svg>
											<h3 className="mt-2 text-sm font-medium text-gray-900 dark:text-white">No tickets found</h3>
											<p className="mt-1 text-sm text-gray-500 dark:text-gray-400">Get started by creating a new ticket.</p>
										</div>
									</td>
								</tr>
							) : (
								rows.map(ticket => (
									<tr key={ticket.id} className="hover:bg-gray-50 dark:hover:bg-gray-700">
										<td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">
											#{ticket.id}
										</td>
										<td className="px-6 py-4 text-sm text-gray-900 dark:text-white">
											<div className="max-w-xs truncate">
												{ticket.description || ticket.title || 'No description'}
											</div>
										</td>
										<td className="px-6 py-4 whitespace-nowrap">
											<span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(ticket.status)}`}>
												{(ticket.status || 'open').replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase())}
											</span>
										</td>
										<td className="px-6 py-4 whitespace-nowrap">
											<span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPriorityColor(ticket.priority)}`}>
												{(ticket.priority || 'medium').charAt(0).toUpperCase() + (ticket.priority || 'medium').slice(1)}
											</span>
										</td>
										<td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
											{ticket.created_at ? new Date(ticket.created_at).toLocaleDateString() : 'N/A'}
										</td>
										<td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
											<Button variant="ghost" size="sm">
												<svg className="w-4 h-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
													<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
													<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
												</svg>
												View
											</Button>
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
