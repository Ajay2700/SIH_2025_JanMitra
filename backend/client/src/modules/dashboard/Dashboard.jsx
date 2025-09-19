import { Link } from 'react-router-dom'

export default function Dashboard() {
	return (
		<div className="p-6 space-y-4">
			<h1 className="text-2xl font-semibold">Dashboard</h1>
			<div className="grid grid-cols-1 md:grid-cols-3 gap-4">
				<Link className="block border rounded p-4 hover:bg-gray-50" to="/tickets">Manage Tickets</Link>
				<Link className="block border rounded p-4 hover:bg-gray-50" to="/staff">Manage Staff</Link>
				<a className="block border rounded p-4 hover:bg-gray-50" href={import.meta.env.VITE_API_BASE + '/docs'} target="_blank" rel="noreferrer">API Docs</a>
			</div>
		</div>
	)
}
