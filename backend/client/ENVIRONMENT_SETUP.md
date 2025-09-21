# Environment Setup for JanMitra Client

## Required Environment Variables

Create a `.env` file in the `backend/client` directory with the following variables:

```env
# API Configuration
VITE_API_BASE=http://localhost:3000

# Development Configuration (optional)
VITE_DEBUG=false
```

## Environment Variable Details

### VITE_API_BASE
- **Description**: The base URL for your backend API
- **Default**: `http://localhost:3000`
- **Example Values**:
  - Local development: `http://localhost:3000`
  - Production: `https://your-api-domain.com`
  - Staging: `https://staging-api.your-domain.com`

### VITE_DEBUG (Optional)
- **Description**: Enable debug mode for additional logging
- **Default**: `false`
- **Values**: `true` or `false`

## Setup Instructions

1. Navigate to the client directory:
   ```bash
   cd backend/client
   ```

2. Create the `.env` file:
   ```bash
   touch .env
   ```

3. Add the environment variables to the `.env` file:
   ```bash
   echo "VITE_API_BASE=http://localhost:3000" >> .env
   echo "VITE_DEBUG=false" >> .env
   ```

4. Verify the file was created correctly:
   ```bash
   cat .env
   ```

5. Restart the development server:
   ```bash
   npm run dev
   ```

## Configuration Notes

- The `VITE_` prefix is required for Vite to expose these variables to the client-side code
- Environment variables are loaded at build time
- Changes to `.env` require restarting the development server
- The `.env` file should be added to `.gitignore` to avoid committing sensitive data

## API Configuration

The application now uses a centralized API configuration in `src/config/api.js` that:

- Reads the `VITE_API_BASE` environment variable
- Provides fallback to `http://localhost:3000` if not set
- Handles URL construction consistently across the application
- Includes helper functions for API requests

## Troubleshooting

### API Connection Issues
1. Verify the `VITE_API_BASE` URL is correct
2. Ensure the backend server is running on the specified port
3. Check for CORS configuration on the backend
4. Verify network connectivity

### Environment Variable Not Loading
1. Ensure the variable name starts with `VITE_`
2. Restart the development server after adding new variables
3. Check for typos in the variable name
4. Verify the `.env` file is in the correct directory

### Default Fallback
If `VITE_API_BASE` is not set, the application will default to `http://localhost:3000` for local development.
