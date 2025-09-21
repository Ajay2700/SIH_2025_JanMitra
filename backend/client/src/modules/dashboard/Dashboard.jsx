import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { useAuth } from '../auth/useAuth.jsx'
import { Card, Alert, Button, Input } from '../../components/UI/index.js'
import { usersAPI } from '../../services/api.js'

export default function Dashboard() {
	const [dashboardData, setDashboardData] = useState(null)
	const [loading, setLoading] = useState(true)
	const [error, setError] = useState('')
	const [showCreateUserModal, setShowCreateUserModal] = useState(false)
	const [creatingUser, setCreatingUser] = useState(false)
	const [createUserError, setCreateUserError] = useState('')
	const [createUserSuccess, setCreateUserSuccess] = useState('')
	const [userForm, setUserForm] = useState({
		email: '',
		password: '',
		full_name: '',
		phone_number: '',
		role: 'user'
	})
	const { user, token } = useAuth()

	useEffect(() => {
		// Load dashboard data with proper error handling
		const loadDashboardData = async () => {
			try {
				// Simulate API call delay
				await new Promise(resolve => setTimeout(resolve, 1000))
				
				// Mock dashboard data - in real implementation, this would come from API
				setDashboardData({
					tickets: {
						total: 12,
						pending: 3,
						inProgress: 5,
						resolved: 4
					},
					issues: {
						total: 8,
						open: 2,
						investigating: 3,
						resolved: 3
					},
					recentActivity: [
						{
							id: 1,
							title: 'New ticket created',
							description: 'Issue with login functionality',
							timestamp: '2 hours ago',
							type: 'ticket'
						},
						{
							id: 2,
							title: 'Issue resolved',
							description: 'Database connection issue fixed',
							timestamp: '4 hours ago',
							type: 'issue'
						},
						{
							id: 3,
							title: 'Status update',
							description: 'Ticket #123 marked as in progress',
							timestamp: '6 hours ago',
							type: 'update'
						}
					]
				})
			} catch (err) {
				console.error('Dashboard data loading error:', err)
				setError('Failed to load dashboard data. Please try again later.')
			} finally {
				setLoading(false)
			}
		}

		loadDashboardData()
	}, [])

	const handleCreateUser = async (e) => {
		e.preventDefault()
		setCreatingUser(true)
		setCreateUserError('')
		setCreateUserSuccess('')

		try {
			const result = await usersAPI.create(userForm, token)
			setCreateUserSuccess('User created successfully!')
			setUserForm({
				email: '',
				password: '',
				full_name: '',
				phone_number: '',
				role: 'user'
			})
			setTimeout(() => {
				setShowCreateUserModal(false)
				setCreateUserSuccess('')
			}, 2000)
		} catch (err) {
			setCreateUserError(err.message || 'Failed to create user')
		} finally {
			setCreatingUser(false)
		}
	}

	if (loading) {
		return (
			<div className="flex items-center justify-center min-h-96">
				<div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
			</div>
		)
	}

	// Debug logging (can be removed later)
	console.log('Current user:', user)
	console.log('User role:', user?.role)
	console.log('Is admin:', user?.role === 'admin')

	const quickActions = [
		// Admin-only action
		...(user?.role === 'admin' ? [{
			title: 'Create User',
			description: 'Quickly add a new user to the system',
			onClick: () => setShowCreateUserModal(true),
			icon: (
				<svg className="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
					<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
				</svg>
			),
			color: 'from-indigo-500 to-indigo-600',
			textColor: 'text-indigo-600 dark:text-indigo-400'
		}] : []),
		{
			title: 'Create New Ticket',
			description: 'Report an issue or request support',
			href: '/tickets',
			icon: (
				<svg className="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
					<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
				</svg>
			),
			color: 'from-blue-500 to-blue-600',
			textColor: 'text-blue-600 dark:text-blue-400'
		},
		{
			title: 'View My Issues',
			description: 'Check status of reported issues',
			href: '/issues',
			icon: (
				<svg className="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
					<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
				</svg>
			),
			color: 'from-green-500 to-green-600',
			textColor: 'text-green-600 dark:text-green-400'
		},
		{
			title: 'Contact Support',
			description: 'Get help from our support team',
			href: '/support',
			icon: (
				<svg className="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
					<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18.364 5.636l-3.536 3.536m0 5.656l3.536 3.536M9.172 9.172L5.636 5.636m3.536 9.192L5.636 18.364M12 2.25a9.75 9.75 0 100 19.5 9.75 9.75 0 000-19.5z" />
				</svg>
			),
			color: 'from-purple-500 to-purple-600',
			textColor: 'text-purple-600 dark:text-purple-400'
		},
		{
			title: 'API Documentation',
			description: 'Access API documentation',
			href: import.meta.env.VITE_API_BASE + '/docs',
			external: true,
			icon: (
				<svg className="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
					<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
				</svg>
			),
			color: 'from-orange-500 to-orange-600',
			textColor: 'text-orange-600 dark:text-orange-400'
		}
	]

	return (
		<div className="space-y-6">
			{/* Header */}
			<div>
				<h1 className="text-3xl font-bold text-gray-900 dark:text-white">
					Welcome back, {user?.full_name || user?.email?.split('@')[0]}!
				</h1>
				<p className="mt-2 text-gray-600 dark:text-gray-400">
					Here's what's happening with your tickets and issues today.
				</p>
				
				{/* Debug info and test button */}
				<div className="mt-4 p-4 bg-yellow-100 dark:bg-yellow-900 rounded-lg">
					<p className="text-sm text-gray-700 dark:text-gray-300">
						Debug: User role = {user?.role || 'undefined'} | Is admin = {user?.role === 'admin' ? 'Yes' : 'No'}
					</p>
					<Button 
						onClick={() => setShowCreateUserModal(true)}
						className="mt-2"
					>
						Test Open Modal
					</Button>
				</div>
			</div>

			{/* Error Alert */}
			{error && (
				<Alert variant="error" title="Error Loading Dashboard">
					{error}
				</Alert>
			)}

			{/* Stats Cards */}
			<div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
				<Card className="bg-white dark:bg-gray-800">
					<div className="flex items-center">
						<div className="flex-shrink-0">
							<div className="w-8 h-8 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center">
								<svg className="w-5 h-5 text-blue-600 dark:text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
									<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
								</svg>
							</div>
						</div>
						<div className="ml-5 w-0 flex-1">
							<dl>
								<dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">Total Tickets</dt>
								<dd className="text-lg font-medium text-gray-900 dark:text-white">{dashboardData?.tickets.total || 0}</dd>
							</dl>
						</div>
					</div>
				</Card>

				<Card className="bg-white dark:bg-gray-800">
					<div className="flex items-center">
						<div className="flex-shrink-0">
							<div className="w-8 h-8 bg-yellow-100 dark:bg-yellow-900 rounded-lg flex items-center justify-center">
								<svg className="w-5 h-5 text-yellow-600 dark:text-yellow-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
									<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
								</svg>
							</div>
						</div>
						<div className="ml-5 w-0 flex-1">
							<dl>
								<dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">Pending</dt>
								<dd className="text-lg font-medium text-gray-900 dark:text-white">{dashboardData?.tickets.pending || 0}</dd>
							</dl>
						</div>
					</div>
				</Card>

				<Card className="bg-white dark:bg-gray-800">
					<div className="flex items-center">
						<div className="flex-shrink-0">
							<div className="w-8 h-8 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center">
								<svg className="w-5 h-5 text-blue-600 dark:text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
									<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
								</svg>
							</div>
						</div>
						<div className="ml-5 w-0 flex-1">
							<dl>
								<dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">In Progress</dt>
								<dd className="text-lg font-medium text-gray-900 dark:text-white">{dashboardData?.tickets.inProgress || 0}</dd>
							</dl>
						</div>
					</div>
				</Card>

				<Card className="bg-white dark:bg-gray-800">
					<div className="flex items-center">
						<div className="flex-shrink-0">
							<div className="w-8 h-8 bg-green-100 dark:bg-green-900 rounded-lg flex items-center justify-center">
								<svg className="w-5 h-5 text-green-600 dark:text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
									<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
								</svg>
							</div>
						</div>
						<div className="ml-5 w-0 flex-1">
							<dl>
								<dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">Resolved</dt>
								<dd className="text-lg font-medium text-gray-900 dark:text-white">{dashboardData?.tickets.resolved || 0}</dd>
							</dl>
						</div>
					</div>
				</Card>
			</div>

			{/* Quick Actions */}
			<Card title="Quick Actions" subtitle="Get things done faster">
				<div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
					{quickActions.map((action, index) => {
						if (action.onClick) {
							// Render as button for onClick actions
							return (
								<button
									key={index}
									onClick={action.onClick}
									className="group relative bg-white dark:bg-gray-700 p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-blue-500 rounded-lg border border-gray-200 dark:border-gray-600 hover:border-gray-300 dark:hover:border-gray-500 transition-all duration-200 hover:shadow-lg w-full text-left"
								>
									<div>
										<span className={`rounded-lg inline-flex p-3 bg-gradient-to-r ${action.color} text-white ring-4 ring-white dark:ring-gray-700`}>
											{action.icon}
										</span>
									</div>
									<div className="mt-4">
										<h3 className="text-lg font-medium text-gray-900 dark:text-white group-hover:text-blue-600 dark:group-hover:text-blue-400">
											<span className="absolute inset-0" aria-hidden="true" />
											{action.title}
										</h3>
										<p className="mt-2 text-sm text-gray-500 dark:text-gray-400">
											{action.description}
										</p>
									</div>
									<span className="pointer-events-none absolute top-6 right-6 text-gray-300 dark:text-gray-600 group-hover:text-gray-400 dark:group-hover:text-gray-500" aria-hidden="true">
										<svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
											<path d="M20 4h1a1 1 0 00-1-1v1zm-1 12a1 1 0 102 0h-2zM8 3a1 1 0 000 2V3zM3.293 19.293a1 1 0 101.414 1.414l-1.414-1.414zM19 4v12h2V4h-2zm1-1H8v2h12V3zm-.707.293l-16 16 1.414 1.414 16-16-1.414-1.414z" />
										</svg>
									</span>
								</button>
							)
						} else {
							// Render as Link for href actions
							return (
								<Link
									key={index}
									to={action.href}
									{...(action.external ? { target: '_blank', rel: 'noreferrer' } : {})}
									className="group relative bg-white dark:bg-gray-700 p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-blue-500 rounded-lg border border-gray-200 dark:border-gray-600 hover:border-gray-300 dark:hover:border-gray-500 transition-all duration-200 hover:shadow-lg"
								>
									<div>
										<span className={`rounded-lg inline-flex p-3 bg-gradient-to-r ${action.color} text-white ring-4 ring-white dark:ring-gray-700`}>
											{action.icon}
										</span>
									</div>
									<div className="mt-4">
										<h3 className="text-lg font-medium text-gray-900 dark:text-white group-hover:text-blue-600 dark:group-hover:text-blue-400">
											<span className="absolute inset-0" aria-hidden="true" />
											{action.title}
										</h3>
										<p className="mt-2 text-sm text-gray-500 dark:text-gray-400">
											{action.description}
										</p>
									</div>
									<span className="pointer-events-none absolute top-6 right-6 text-gray-300 dark:text-gray-600 group-hover:text-gray-400 dark:group-hover:text-gray-500" aria-hidden="true">
										<svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
											<path d="M20 4h1a1 1 0 00-1-1v1zm-1 12a1 1 0 102 0h-2zM8 3a1 1 0 000 2V3zM3.293 19.293a1 1 0 101.414 1.414l-1.414-1.414zM19 4v12h2V4h-2zm1-1H8v2h12V3zm-.707.293l-16 16 1.414 1.414 16-16-1.414-1.414z" />
										</svg>
									</span>
								</Link>
							)
						}
					})}
				</div>
			</Card>

			{/* Recent Activity */}
			<Card title="Recent Activity" subtitle="Your latest updates and notifications">
				<div className="flow-root">
					<ul className="-mb-8">
						{dashboardData?.recentActivity?.map((activity, activityIdx) => (
							<li key={activity.id}>
								<div className="relative pb-8">
									{activityIdx !== dashboardData.recentActivity.length - 1 ? (
										<span className="absolute top-4 left-4 -ml-px h-full w-0.5 bg-gray-200 dark:bg-gray-600" aria-hidden="true" />
									) : null}
									<div className="relative flex space-x-3">
										<div>
											<span className={`h-8 w-8 rounded-full flex items-center justify-center ring-8 ring-white dark:ring-gray-800 ${
												activity.type === 'ticket' ? 'bg-blue-500' :
												activity.type === 'issue' ? 'bg-green-500' :
												'bg-purple-500'
											}`}>
												{activity.type === 'ticket' ? (
													<svg className="h-5 w-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
														<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
													</svg>
												) : activity.type === 'issue' ? (
													<svg className="h-5 w-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
														<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
													</svg>
												) : (
													<svg className="h-5 w-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
														<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
													</svg>
												)}
											</span>
										</div>
										<div className="min-w-0 flex-1 pt-1.5 flex justify-between space-x-4">
											<div>
												<p className="text-sm text-gray-900 dark:text-white font-medium">{activity.title}</p>
												<p className="text-sm text-gray-500 dark:text-gray-400">{activity.description}</p>
											</div>
											<div className="text-right text-sm whitespace-nowrap text-gray-500 dark:text-gray-400">
												<time dateTime={new Date().toISOString()}>{activity.timestamp}</time>
											</div>
										</div>
									</div>
								</div>
							</li>
						))}
					</ul>
				</div>
			</Card>

			{/* Create User Modal */}
			{showCreateUserModal && (
				<div className="fixed inset-0 z-50 overflow-y-auto">
					<div className="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
						<div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" onClick={() => setShowCreateUserModal(false)}></div>
						
						<div className="inline-block align-bottom bg-white dark:bg-gray-800 rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
							<form onSubmit={handleCreateUser}>
								<div className="bg-white dark:bg-gray-800 px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
									<div className="sm:flex sm:items-start">
										<div className="mt-3 text-center sm:mt-0 sm:text-left w-full">
											<h3 className="text-lg leading-6 font-medium text-gray-900 dark:text-white mb-4">
												Create New User
											</h3>
											
											{createUserError && (
												<Alert variant="error" title="Error">
													{createUserError}
												</Alert>
											)}
											
											{createUserSuccess && (
												<Alert variant="success" title="Success">
													{createUserSuccess}
												</Alert>
											)}

											<div className="space-y-4">
												<div>
													<label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
														Email Address
													</label>
													<Input
														type="email"
														value={userForm.email}
														onChange={(e) => setUserForm({...userForm, email: e.target.value})}
														required
														className="mt-1"
													/>
												</div>

												<div>
													<label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
														Password
													</label>
													<Input
														type="password"
														value={userForm.password}
														onChange={(e) => setUserForm({...userForm, password: e.target.value})}
														required
														className="mt-1"
													/>
												</div>

												<div>
													<label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
														Full Name
													</label>
													<Input
														type="text"
														value={userForm.full_name}
														onChange={(e) => setUserForm({...userForm, full_name: e.target.value})}
														required
														className="mt-1"
													/>
												</div>

												<div>
													<label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
														Phone Number
													</label>
													<Input
														type="tel"
														value={userForm.phone_number}
														onChange={(e) => setUserForm({...userForm, phone_number: e.target.value})}
														className="mt-1"
													/>
												</div>

												<div>
													<label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
														Role
													</label>
													<select
														value={userForm.role}
														onChange={(e) => setUserForm({...userForm, role: e.target.value})}
														className="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
													>
														<option value="user">User</option>
														<option value="admin">Admin</option>
													</select>
												</div>
											</div>
										</div>
									</div>
								</div>
								<div className="bg-gray-50 dark:bg-gray-700 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
									<Button
										type="submit"
										loading={creatingUser}
										className="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-indigo-600 text-base font-medium text-white hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:ml-3 sm:w-auto sm:text-sm"
									>
										{creatingUser ? 'Creating...' : 'Create User'}
									</Button>
									<Button
										type="button"
										variant="secondary"
										onClick={() => setShowCreateUserModal(false)}
										className="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-600 text-base font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
									>
										Cancel
									</Button>
								</div>
							</form>
						</div>
					</div>
				</div>
			)}
		</div>
	)
}
