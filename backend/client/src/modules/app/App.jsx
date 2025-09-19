import { Routes, Route, Navigate } from 'react-router-dom'
import Dashboard from '../dashboard/Dashboard.jsx'
import Tickets from '../tickets/Tickets.jsx'
import Staff from '../staff/Staff.jsx'
import Login from '../auth/Login.jsx'
import { useAuth } from '../auth/useAuth.jsx'

function ProtectedRoute({ children }) {
	const { token } = useAuth()
	if (!token) return <Navigate to="/login" replace />
	return children
}

export default function App() {
	return (
		<div className="min-h-screen bg-gray-50 text-gray-900">
			<Routes>
				<Route path="/login" element={<Login />} />
				<Route path="/" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
				<Route path="/tickets" element={<ProtectedRoute><Tickets /></ProtectedRoute>} />
				<Route path="/staff" element={<ProtectedRoute><Staff /></ProtectedRoute>} />
				<Route path="*" element={<Navigate to="/" replace />} />
			</Routes>
		</div>
	)
}
