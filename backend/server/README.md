# JanMitra Server

A comprehensive ticket management system built with Node.js, Express, and Supabase for the Smart India Hackathon 2025.

## Features

- **User Management**: Complete user registration, authentication, and role-based access control
- **Department Management**: Hierarchical department structure with statistics
- **Ticket Categories**: Organized categorization system for issues and tickets
- **Issue Tracking**: Citizens can report issues with location data and attachments
- **Ticket Management**: Staff can create, assign, and manage tickets
- **Comments & Attachments**: Rich communication and file sharing capabilities
- **Notifications**: Real-time notifications for all stakeholders
- **Feedback System**: Citizen feedback collection and analytics
- **SLA Management**: Service Level Agreement tracking and breach detection
- **Analytics Dashboard**: Comprehensive reporting and analytics
- **System Settings**: Configurable application settings

## Tech Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **File Upload**: Multer
- **Validation**: Joi
- **Security**: Helmet, CORS, Rate Limiting
- **Documentation**: Built-in API documentation

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd backend/server
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment Setup**
   ```bash
   cp env.example .env
   ```
   
   Update the `.env` file with your Supabase credentials:
   ```env
   SUPABASE_URL=your_supabase_url_here
   SUPABASE_ANON_KEY=your_supabase_anon_key_here
   SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key_here
   PORT=3001
   NODE_ENV=development
   JWT_SECRET=your_jwt_secret_here
   JWT_EXPIRES_IN=7d
   MAX_FILE_SIZE=10485760
   UPLOAD_PATH=./uploads
   RATE_LIMIT_WINDOW_MS=900000
   RATE_LIMIT_MAX_REQUESTS=100
   ```

4. **Create uploads directory**
   ```bash
   mkdir uploads
   ```

## Running the Application

### Development
```bash
npm run dev
```

### Production
```bash
npm start
```

The server will start on `http://localhost:3001` (or the port specified in your environment variables).

## API Documentation

Once the server is running, you can access:

- **API Documentation**: `http://localhost:3001/api/docs`
- **Health Check**: `http://localhost:3001/api/health`
- **Root Endpoint**: `http://localhost:3001/`

## API Endpoints

### Authentication (`/api/auth`)
- `POST /register` - Register new user
- `POST /login` - User login
- `POST /logout` - User logout
- `POST /refresh` - Refresh token
- `GET /profile` - Get user profile
- `PUT /profile` - Update user profile
- `PUT /change-password` - Change password
- `POST /forgot-password` - Forgot password
- `POST /reset-password` - Reset password

### Users (`/api/users`)
- `GET /` - Get all users (admin)
- `POST /` - Create user (admin)
- `GET /:id` - Get user by ID
- `PUT /:id` - Update user
- `DELETE /:id` - Delete user (admin)
- `GET /stats` - Get user statistics (admin)
- `GET /department/:department_id` - Get users by department (admin)

### Departments (`/api/departments`)
- `GET /` - Get all departments
- `GET /hierarchy` - Get department hierarchy
- `GET /:id` - Get department by ID
- `GET /:id/stats` - Get department statistics
- `POST /` - Create department (admin)
- `PUT /:id` - Update department (admin)
- `DELETE /:id` - Delete department (admin)

### Categories (`/api/categories`)
- `GET /` - Get all categories
- `GET /hierarchy` - Get category hierarchy
- `GET /department/:department_id` - Get categories by department
- `GET /:id` - Get category by ID
- `GET /:id/stats` - Get category statistics
- `POST /` - Create category (admin)
- `PUT /:id` - Update category (admin)
- `DELETE /:id` - Delete category (admin)

### Issues (`/api/issues`)
- `GET /` - Get all issues
- `GET /stats` - Get issue statistics
- `GET /citizen/:citizen_id` - Get issues by citizen
- `GET /:id` - Get issue by ID
- `GET /:id/history` - Get issue history
- `POST /` - Create issue
- `PUT /:id` - Update issue
- `DELETE /:id` - Delete issue

### Tickets (`/api/tickets`)
- `GET /` - Get all tickets
- `GET /stats` - Get ticket statistics
- `GET /department/:department_id` - Get tickets by department
- `GET /assigned/:user_id` - Get tickets by assigned user
- `GET /:id` - Get ticket by ID
- `GET /:id/history` - Get ticket history
- `POST /` - Create ticket
- `PUT /:id` - Update ticket
- `DELETE /:id` - Delete ticket (admin)

### Comments (`/api/comments`)
- `GET /ticket/:ticket_id` - Get comments by ticket
- `GET /user/:user_id` - Get comments by user
- `GET /ticket/:ticket_id/stats` - Get comment statistics
- `GET /:id` - Get comment by ID
- `POST /` - Create comment
- `PUT /:id` - Update comment
- `DELETE /:id` - Delete comment

### Attachments (`/api/attachments`)
- `GET /ticket/:ticket_id` - Get attachments by ticket
- `GET /issue/:issue_id` - Get attachments by issue
- `GET /:id` - Get attachment by ID
- `GET /:id/download` - Download attachment
- `POST /ticket/:ticket_id` - Upload ticket attachment
- `POST /issue/:issue_id` - Upload issue attachment
- `DELETE /:id` - Delete attachment

### Notifications (`/api/notifications`)
- `GET /my` - Get my notifications
- `GET /unread-count` - Get unread count
- `GET /user/:user_id` - Get notifications by user
- `GET /:id` - Get notification by ID
- `PUT /:id/read` - Mark as read
- `PUT /mark-all-read` - Mark all as read
- `DELETE /:id` - Delete notification
- `POST /` - Create notification (admin)
- `POST /bulk` - Send bulk notification (admin)

### Feedback (`/api/feedback`)
- `GET /` - Get all feedback (admin)
- `GET /stats` - Get feedback statistics (admin)
- `GET /ticket/:ticket_id` - Get feedback by ticket
- `GET /citizen/:citizen_id` - Get feedback by citizen
- `GET /:id` - Get feedback by ID
- `POST /` - Create feedback
- `PUT /:id` - Update feedback
- `DELETE /:id` - Delete feedback

### Analytics (`/api/analytics`)
- `GET /dashboard` - Get dashboard analytics
- `GET /department-performance` - Get department performance
- `GET /category-analytics` - Get category analytics
- `GET /summary` - Get analytics summary
- `GET /` - Get analytics metrics
- `POST /metric` - Record analytics metric (admin)

### SLA (`/api/sla`)
- `GET /` - Get all SLA configurations
- `GET /category/:category_id` - Get SLAs by category
- `GET /stats` - Get SLA statistics
- `GET /:id` - Get SLA by ID
- `POST /` - Create SLA (admin)
- `PUT /:id` - Update SLA (admin)
- `DELETE /:id` - Delete SLA (admin)
- `POST /ticket/:ticket_id/apply` - Apply SLA to ticket (admin)
- `POST /check-breaches` - Check SLA breaches (admin)

### Settings (`/api/settings`)
- `GET /config` - Get app configuration
- `GET /health` - Get system health
- `GET /stats` - Get system statistics (admin)
- `GET /keys` - Get settings by keys
- `GET /:key` - Get setting by key
- `GET /` - Get all settings
- `POST /` - Create setting (admin)
- `PUT /:key` - Update setting (admin)
- `PUT /` - Update multiple settings (admin)
- `DELETE /:key` - Delete setting (admin)
- `POST /reset-defaults` - Reset to defaults (admin)

## Database Schema

The application uses the following main tables:

- **users** - User accounts and profiles
- **departments** - Department hierarchy
- **ticket_categories** - Issue and ticket categories
- **issues** - Citizen-reported issues
- **tickets** - Staff-managed tickets
- **comments** - Communication on tickets
- **attachments** - File attachments
- **notifications** - System notifications
- **feedback** - Citizen feedback
- **analytics** - System metrics
- **sla** - Service Level Agreements
- **ticket_sla** - SLA tracking for tickets
- **escalation_matrix** - Escalation rules
- **issue_history** - Issue change history
- **ticket_history** - Ticket change history
- **system_settings** - Application configuration

## User Roles

- **citizen** - Can report issues, view their tickets, provide feedback
- **staff** - Can manage tickets, view department data
- **admin** - Can manage users, departments, categories, system settings
- **super_admin** - Full system access

## Security Features

- JWT-based authentication
- Role-based access control
- Rate limiting
- Input validation
- File upload restrictions
- CORS protection
- Helmet security headers

## Error Handling

The API uses consistent error responses:

```json
{
  "success": false,
  "message": "Error description",
  "errors": "Detailed error information (development only)"
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions, please contact the development team or create an issue in the repository.
