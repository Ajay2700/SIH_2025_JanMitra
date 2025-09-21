import { createContext, useContext, useMemo, useState, useEffect } from 'react'
import { getApiUrl } from '../../config/api.js'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
	const [token, setToken] = useState(() => {
		const storedToken = localStorage.getItem('token') || ''
		// Basic JWT format validation
		if (storedToken && !storedToken.includes('.')) {
			console.warn('Invalid token format detected, clearing...')
			localStorage.removeItem('token')
			localStorage.removeItem('user')
			return ''
		}
		return storedToken
	})
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
	
	return fetch(getApiUrl(path), {
		method,
		headers,
		body: body ? JSON.stringify(body) : undefined,
            }).then(async (res) => {
                if (!res.ok) {
                    let err
                    try { 
                        err = await res.json() 
                    } catch { 
                        err = { error: res.statusText || `HTTP ${res.status}` } 
                    }
                    console.error('API Error:', path, err)
                    
                    // If token is invalid, clear it automatically
                    if (res.status === 401 && token) {
                        console.warn('Token invalid, clearing authentication...')
                        localStorage.removeItem('token')
                        localStorage.removeItem('user')
                        // Redirect to login if we're not already there
                        if (window.location.pathname !== '/login') {
                            window.location.href = '/login'
                        }
                    }
                    
                    throw new Error(err.error || err.message || `Request failed with status ${res.status}`)
                }
		try { 
			return await res.json() 
		} catch { 
			return null 
		}
	}).catch(error => {
		console.error('API Fetch Error:', path, error)
		throw error
	})
}


