import { createContext, useContext, useMemo, useState, useEffect } from 'react'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
	const [token, setToken] = useState(() => localStorage.getItem('token') || '')
	const [user, setUser] = useState(() => {
		try { return JSON.parse(localStorage.getItem('user') || 'null') } catch { return null }
	})

	useEffect(() => {
		if (token) localStorage.setItem('token', token); else localStorage.removeItem('token')
	}, [token])

	useEffect(() => {
		if (user) localStorage.setItem('user', JSON.stringify(user)); else localStorage.removeItem('user')
	}, [user])

	const value = useMemo(() => ({ token, setToken, user, setUser }), [token, user])
	return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
	const ctx = useContext(AuthContext)
	if (!ctx) throw new Error('useAuth must be used within AuthProvider')
	return ctx
}

export function apiFetch(path, { method = 'GET', body, token } = {}) {
	const headers = { 'Content-Type': 'application/json' }
	if (token) headers['Authorization'] = `Bearer ${token}`
	return fetch(import.meta.env.VITE_API_BASE + path, {
		method,
		headers,
		body: body ? JSON.stringify(body) : undefined,
	}).then(async (res) => {
		if (!res.ok) {
			let err
			try { err = await res.json() } catch { err = { error: res.statusText } }
			throw new Error(err.error || 'Request failed')
		}
		try { return await res.json() } catch { return null }
	})
}


