import { Routes, Route, Navigate } from 'react-router-dom'
import Dashboard from '../dashboard/Dashboard.jsx'
import Tickets from '../tickets/Tickets.jsx'
import Staff from '../staff/Staff.jsx'
import Login from '../auth/Login.jsx'
import { useAuth } from '../auth/useAuth.jsx'

// Layout Components
import AdminLayout from '../../components/Layout/AdminLayout.jsx'
import UserLayout from '../../components/Layout/UserLayout.jsx'

// Admin Components
import AdminDashboard from '../admin/AdminDashboard.jsx'
import UserManagement from '../admin/UserManagement.jsx'
import DepartmentManagement from '../admin/DepartmentManagement.jsx'
import CategoryManagement from '../admin/CategoryManagement.jsx'
import TicketManagement from '../admin/TicketManagement.jsx'
import IssueManagement from '../admin/IssueManagement.jsx'
import AnalyticsDashboard from '../admin/AnalyticsDashboard.jsx'
import NotificationManagement from '../admin/NotificationManagement.jsx'
import FeedbackManagement from '../admin/FeedbackManagement.jsx'
import SLAManagement from '../admin/SLAManagement.jsx'
import SettingsManagement from '../admin/SettingsManagement.jsx'

function ProtectedRoute({ children }) {
	const { token } = useAuth()
	if (!token) return <Navigate to="/login" replace />
	return children
}

function UserRoute({ children }) {
	const { token, user } = useAuth()
	if (!token) return <Navigate to="/login" replace />
	if (user?.role === 'admin') return <Navigate to="/admin" replace />
	return <UserLayout>{children}</UserLayout>
}

function AdminRoute({ children }) {
	const { token, user } = useAuth()
	if (!token) return <Navigate to="/login" replace />
	if (user?.role !== 'admin') return <Navigate to="/" replace />
	return <AdminLayout>{children}</AdminLayout>
}

export default function App() {
	return (
		<div className="min-h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-white">
			<Routes>
				<Route path="/login" element={<Login />} />
				
				{/* Regular User Routes */}
				<Route path="/" element={<UserRoute><Dashboard /></UserRoute>} />
				<Route path="/tickets" element={<UserRoute><Tickets /></UserRoute>} />
				<Route path="/staff" element={<UserRoute><Staff /></UserRoute>} />
				<Route path="/issues" element={<UserRoute><div>Issues Page</div></UserRoute>} />
				<Route path="/support" element={<UserRoute><div>Support Page</div></UserRoute>} />
				
				{/* Admin Routes */}
				<Route path="/admin" element={<AdminRoute><AdminDashboard /></AdminRoute>} />
				<Route path="/admin/users" element={<AdminRoute><UserManagement /></AdminRoute>} />
				<Route path="/admin/departments" element={<AdminRoute><DepartmentManagement /></AdminRoute>} />
				<Route path="/admin/categories" element={<AdminRoute><CategoryManagement /></AdminRoute>} />
				<Route path="/admin/tickets" element={<AdminRoute><TicketManagement /></AdminRoute>} />
				<Route path="/admin/issues" element={<AdminRoute><IssueManagement /></AdminRoute>} />
				<Route path="/admin/analytics" element={<AdminRoute><AnalyticsDashboard /></AdminRoute>} />
				<Route path="/admin/notifications" element={<AdminRoute><NotificationManagement /></AdminRoute>} />
				<Route path="/admin/feedback" element={<AdminRoute><FeedbackManagement /></AdminRoute>} />
				<Route path="/admin/sla" element={<AdminRoute><SLAManagement /></AdminRoute>} />
				<Route path="/admin/settings" element={<AdminRoute><SettingsManagement /></AdminRoute>} />
				
				{/* Fallback */}
				<Route path="*" element={<Navigate to="/" replace />} />
			</Routes>
		</div>
	)
}
