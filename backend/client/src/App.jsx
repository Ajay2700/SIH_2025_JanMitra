import { AuthProvider } from './modules/auth/useAuth.jsx'
import App from './modules/app/App.jsx'

export default function Root() {
	return (
		<AuthProvider>
			<App />
		</AuthProvider>
	)
}
