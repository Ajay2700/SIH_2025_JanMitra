import { useEffect, useState } from 'react'
import { useAuth, apiFetch } from '../auth/useAuth.jsx'
import { Card, Alert, Button, Input } from '../../components/UI/index.js'

export default function Staff() {
	const { token } = useAuth()
	const [rows, setRows] = useState([])
	const [form, setForm] = useState({ email: '', password: '', full_name: '', phone_number: '', address: '' })
	const [error, setError] = useState('')
	const [loading, setLoading] = useState(false)
	const [creating, setCreating] = useState(false)

	async function load() {
		setLoading(true); setError('')
		try {
			// For regular users, we'll show a limited view or mock data
			// since they typically don't have access to full user management
			const mockData = [
				{
					id: 1,
					email: 'support@janmitra.com',
					full_name: 'Support Team',
					phone_number: '+1 (555) 123-4567',
					address: '123 Main St, City, State',
					role: 'staff'
				},
				{
					id: 2,
					email: 'admin@janmitra.com',
					full_name: 'System Administrator',
					phone_number: '+1 (555) 987-6543',
					address: '456 Admin Ave, City, State',
					role: 'admin'
				}
			]
			setRows(mockData)
		} catch (e) { 
			setError('Unable to load staff information') 
		} finally { 
			setLoading(false) 
		}
	}
	useEffect(() => { load() }, [])

	async function createStaff() {
		setCreating(true)
		setError('')
		try {
			// For regular users, show a message that they don't have permission
			setError('You do not have permission to create staff members. Please contact an administrator.')
		} catch (e) {
			setError(e.message)
		} finally {
			setCreating(false)
		}
	}

	async function updateStaff(id, changes) {
		setError('You do not have permission to modify staff members. Please contact an administrator.')
	}

	async function deleteStaff(id) {
		setError('You do not have permission to delete staff members. Please contact an administrator.')
	}

	return (
		<div className="space-y-6">
			{/* Header */}
			<div>
				<h1 className="text-3xl font-bold text-gray-900 dark:text-white">Staff Directory</h1>
				<p className="mt-2 text-gray-600 dark:text-gray-400">
					View contact information for our support team
				</p>
			</div>

			{/* Error Alert */}
			{error && (
				<Alert variant="error" title="Error">
					{error}
				</Alert>
			)}


			{/* Staff Table */}
			<Card title="Contact Directory" subtitle={`${rows.length} staff member${rows.length !== 1 ? 's' : ''} available for support`}>
				<div className="overflow-x-auto">
					<table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
						<thead className="bg-gray-50 dark:bg-gray-700">
							<tr>
								<th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
									Name
								</th>
								<th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
									Email
								</th>
								<th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
									Phone
								</th>
								<th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
									Address
								</th>
								<th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
									Role
								</th>
								<th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
									Contact
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
											Loading staff members...
										</div>
									</td>
								</tr>
							) : rows.length === 0 ? (
								<tr>
									<td colSpan={6} className="px-6 py-12 text-center">
										<div className="text-gray-500 dark:text-gray-400">
											<svg className="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
												<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
											</svg>
											<h3 className="mt-2 text-sm font-medium text-gray-900 dark:text-white">No staff members found</h3>
											<p className="mt-1 text-sm text-gray-500 dark:text-gray-400">Get started by adding a new staff member.</p>
										</div>
									</td>
								</tr>
							) : (
								rows.map(staff => (
									<tr key={staff.id} className="hover:bg-gray-50 dark:hover:bg-gray-700">
										<td className="px-6 py-4 whitespace-nowrap">
											<div className="flex items-center">
												<div className="h-10 w-10 rounded-full bg-gradient-to-r from-blue-600 to-indigo-600 flex items-center justify-center">
													<span className="text-sm font-medium text-white">
														{(staff.full_name || staff.email || 'S').charAt(0).toUpperCase()}
													</span>
												</div>
												<div className="ml-4">
													<div className="text-sm font-medium text-gray-900 dark:text-white">
														{staff.full_name || 'No name'}
													</div>
												</div>
											</div>
										</td>
										<td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
											{staff.email}
										</td>
										<td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
											{staff.phone_number || 'N/A'}
										</td>
										<td className="px-6 py-4 text-sm text-gray-500 dark:text-gray-400">
											<div className="max-w-xs truncate">
												{staff.address || 'N/A'}
											</div>
										</td>
										<td className="px-6 py-4 whitespace-nowrap">
											<span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
												staff.role === 'admin' 
													? 'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-300'
													: 'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-300'
											}`}>
												{(staff.role || 'user').charAt(0).toUpperCase() + (staff.role || 'user').slice(1)}
											</span>
										</td>
										<td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
											<div className="flex space-x-2">
												<Button 
													variant="ghost" 
													size="sm"
													onClick={() => window.location.href = `mailto:${staff.email}`}
												>
													<svg className="w-4 h-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
														<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
													</svg>
													Email
												</Button>
												{staff.phone_number && (
													<Button 
														variant="ghost" 
														size="sm"
														onClick={() => window.location.href = `tel:${staff.phone_number}`}
													>
														<svg className="w-4 h-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
															<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
														</svg>
														Call
													</Button>
												)}
											</div>
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
