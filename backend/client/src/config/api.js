// API Configuration
export const API_CONFIG = {
  BASE_URL: import.meta.env.VITE_API_BASE || 'http://localhost:3001',
  TIMEOUT: 10000, // 10 seconds
  RETRY_ATTEMPTS: 3
}

// Helper function to get full API URL
export const getApiUrl = (path) => {
  const baseUrl = API_CONFIG.BASE_URL.replace(/\/$/, '') // Remove trailing slash
  const cleanPath = path.replace(/^\//, '') // Remove leading slash
  return `${baseUrl}/${cleanPath}`
}

// Helper function for fetch with consistent configuration
export const apiRequest = async (path, options = {}) => {
  const url = getApiUrl(path)
  const config = {
    timeout: API_CONFIG.TIMEOUT,
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options.headers
    }
  }

  try {
    const response = await fetch(url, config)
    
    if (!response.ok) {
      let error
      try {
        error = await response.json()
      } catch {
        error = { error: response.statusText }
      }
      throw new Error(error.error || 'Request failed')
    }

    try {
      return await response.json()
    } catch {
      return null
    }
  } catch (error) {
    throw error
  }
}

// Authenticated API request helper
export const authenticatedRequest = (token) => (path, options = {}) => {
  return apiRequest(path, {
    ...options,
    headers: {
      ...options.headers,
      Authorization: token ? `Bearer ${token}` : undefined
    }
  })
}
