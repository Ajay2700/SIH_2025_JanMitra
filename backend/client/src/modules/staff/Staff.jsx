import { useEffect, useState } from 'react'
import { useAuth, apiFetch } from '../auth/useAuth.jsx'

export default function Staff() {
	const { token } = useAuth()
	const [rows, setRows] = useState([])
	const [form, setForm] = useState({ email: '', password: '', full_name: '', phone_number: '', address: '' })
	const [error, setError] = useState('')
	const [loading, setLoading] = useState(false)

	async function load() {
		setLoading(true); setError('')
		try {
			const data = await apiFetch('/admin/staff', { token })
			setRows(data || [])
		} catch (e) { setError(e.message) } finally { setLoading(false) }
	}
	useEffect(() => { load() }, [])

	async function createStaff() {
		await apiFetch('/admin/staff', { method: 'POST', token, body: form })
		setForm({ email: '', password: '', full_name: '', phone_number: '', address: '' })
		load()
	}
	async function updateStaff(id, changes) {
		await apiFetch(`/admin/staff/${id}`, { method: 'PATCH', token, body: changes })
		load()
	}
	async function deleteStaff(id) {
		await apiFetch(`/admin/staff/${id}`, { method: 'DELETE', token })
		load()
	}

	return (
		<div className="p-6 space-y-6">
			<h1 className="text-2xl font-semibold">Staff</h1>
			{error ? <div className="text-red-600 text-sm">{error}</div> : null}
			<div className="grid grid-cols-1 md:grid-cols-5 gap-2">
				<input className="border rounded px-2 py-1" placeholder="Email" value={form.email} onChange={e=>setForm(f=>({...f, email:e.target.value}))} />
				<input className="border rounded px-2 py-1" placeholder="Password" type="password" value={form.password} onChange={e=>setForm(f=>({...f, password:e.target.value}))} />
				<input className="border rounded px-2 py-1" placeholder="Full name" value={form.full_name} onChange={e=>setForm(f=>({...f, full_name:e.target.value}))} />
				<input className="border rounded px-2 py-1" placeholder="Phone" value={form.phone_number} onChange={e=>setForm(f=>({...f, phone_number:e.target.value}))} />
				<input className="border rounded px-2 py-1" placeholder="Address" value={form.address} onChange={e=>setForm(f=>({...f, address:e.target.value}))} />
				<button className="border rounded px-3 md:col-span-5" onClick={createStaff}>Create</button>
			</div>

			<div className="overflow-auto">
				<table className="min-w-full bg-white">
					<thead>
						<tr className="text-left bg-gray-100">
							<th className="p-2">Email</th>
							<th className="p-2">Name</th>
							<th className="p-2">Phone</th>
							<th className="p-2">Address</th>
							<th className="p-2">Actions</th>
						</tr>
					</thead>
					<tbody>
						{loading ? <tr><td className="p-2" colSpan={5}>Loading...</td></tr> : rows.map(s => (
							<tr key={s.id} className="border-t">
								<td className="p-2">{s.email}</td>
								<td className="p-2">
									<input className="border rounded px-2 py-1" defaultValue={s.full_name} onBlur={(e)=>updateStaff(s.id, { full_name: e.target.value })} />
								</td>
								<td className="p-2">
									<input className="border rounded px-2 py-1" defaultValue={s.phone_number} onBlur={(e)=>updateStaff(s.id, { phone_number: e.target.value })} />
								</td>
								<td className="p-2">
									<input className="border rounded px-2 py-1" defaultValue={s.address} onBlur={(e)=>updateStaff(s.id, { address: e.target.value })} />
								</td>
								<td className="p-2">
									<button className="border rounded px-3" onClick={()=>deleteStaff(s.id)}>Delete</button>
								</td>
							</tr>
						))}
					</tbody>
				</table>
			</div>
		</div>
	)
}
