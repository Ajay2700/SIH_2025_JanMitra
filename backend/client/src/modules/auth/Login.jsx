import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth, apiFetch } from './useAuth.jsx'

export default function Login() {
	const [email, setEmail] = useState('admin@example.com')
	const [password, setPassword] = useState('ChangeMe123!')
	const [error, setError] = useState('')
	const navigate = useNavigate()
	const { setToken, setUser } = useAuth()

	async function handleSubmit(e) {
		e.preventDefault()
		setError('')
		try {
			const res = await apiFetch('/auth', { method: 'POST', body: { email, password } })
			setToken(res.token)
			setUser(res.user)
			navigate('/')
		} catch (err) {
			setError(err.message)
		}
	}

	return (
		<div className="grid place-items-center min-h-screen">
			<form onSubmit={handleSubmit} className="w-full max-w-sm bg-white shadow rounded p-6 space-y-4">
				<h1 className="text-xl font-semibold">Admin Login</h1>
				{error ? <div className="text-red-600 text-sm">{error}</div> : null}
				<div>
					<label className="block text-sm mb-1">Email</label>
					<input className="w-full border rounded px-3 py-2" type="email" value={email} onChange={(e)=>setEmail(e.target.value)} />
				</div>
				<div>
					<label className="block text-sm mb-1">Password</label>
					<input className="w-full border rounded px-3 py-2" type="password" value={password} onChange={(e)=>setPassword(e.target.value)} />
				</div>
				<button className="w-full bg-black text-white py-2 rounded">Login</button>
			</form>
		</div>
	)
}
