import { useEffect, useState, useMemo } from 'react'
import { useAuth, apiFetch } from '../auth/useAuth.jsx'

export default function Tickets() {
	const { token } = useAuth()
	const [rows, setRows] = useState([])
	const [loading, setLoading] = useState(false)
	const [error, setError] = useState('')
	const [filters, setFilters] = useState({ status: '', priority: '' })

	async function load() {
		setLoading(true); setError('')
		try {
			const data = await apiFetch('/admin/tickets' + toQuery(filters), { token })
			setRows(data || [])
		} catch (e) {
			setError(e.message)
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

	async function updateStatus(id, status) {
		await apiFetch(`/admin/tickets/${id}/status`, { method: 'PATCH', token, body: { status } })
		load()
	}
	async function updatePriority(id, priority) {
		await apiFetch(`/admin/tickets/${id}/priority`, { method: 'PATCH', token, body: { priority } })
		load()
	}

	return (
		<div className="p-6 space-y-4">
			<h1 className="text-2xl font-semibold">Tickets</h1>
			<div className="flex gap-2">
				<select className="border rounded px-2 py-1" value={filters.status} onChange={(e)=>setFilters(f=>({...f, status:e.target.value}))}>
					<option value="">All Status</option>
					{['open','assigned','in_progress','resolved','closed'].map(s=> <option key={s} value={s}>{s}</option>)}
				</select>
				<select className="border rounded px-2 py-1" value={filters.priority} onChange={(e)=>setFilters(f=>({...f, priority:e.target.value}))}>
					<option value="">All Priority</option>
					{['low','medium','high'].map(p=> <option key={p} value={p}>{p}</option>)}
				</select>
				<button className="border rounded px-3" onClick={load}>Refresh</button>
			</div>
			{error ? <div className="text-red-600 text-sm">{error}</div> : null}
			<div className="overflow-auto">
				<table className="min-w-full bg-white">
					<thead>
						<tr className="text-left bg-gray-100">
							<th className="p-2">Description</th>
							<th className="p-2">Status</th>
							<th className="p-2">Priority</th>
							<th className="p-2">Actions</th>
						</tr>
					</thead>
					<tbody>
						{loading ? <tr><td className="p-2" colSpan={4}>Loading...</td></tr> :
						rows.map(t => (
							<tr key={t.id} className="border-t">
								<td className="p-2">{t.description}</td>
								<td className="p-2">
									<select className="border rounded px-2 py-1" value={t.status} onChange={(e)=>updateStatus(t.id, e.target.value)}>
										{['open','assigned','in_progress','resolved','closed'].map(s=> <option key={s} value={s}>{s}</option>)}
									</select>
								</td>
								<td className="p-2">
									<select className="border rounded px-2 py-1" value={t.priority} onChange={(e)=>updatePriority(t.id, e.target.value)}>
										{['low','medium','high'].map(p=> <option key={p} value={p}>{p}</option>)}
									</select>
								</td>
								<td className="p-2">
									<button className="border rounded px-3">Details</button>
								</td>
							</tr>
						))}
					</tbody>
				</table>
			</div>
		</div>
	)
}
