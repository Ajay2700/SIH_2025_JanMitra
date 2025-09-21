# JanMitra Admin Dashboard

A comprehensive admin dashboard for the JanMitra citizen grievance management system built with React.js and integrated with the backend API.

## Features

### 🏠 Dashboard Overview
- **Analytics Summary**: Key metrics and statistics at a glance
- **Quick Actions**: Fast access to common admin tasks
- **Recent Activity**: System activity feed
- **System Health**: Server status and performance indicators

### 👥 User Management
- **User CRUD Operations**: Create, read, update, and delete users
- **Role Management**: Assign admin, staff, or user roles
- **Department Assignment**: Assign users to departments
- **User Status**: Activate/deactivate user accounts
- **User Statistics**: View user counts and activity

### 🏢 Department Management
- **Department Hierarchy**: Create parent-child department relationships
- **Department CRUD**: Full department lifecycle management
- **Department Statistics**: Performance metrics per department
- **Status Management**: Enable/disable departments

### 📁 Category Management
- **Category Hierarchy**: Organize categories with parent-child relationships
- **Department Linking**: Associate categories with departments
- **Category CRUD**: Complete category management
- **Category Statistics**: Track issues and performance by category

### 🎫 Ticket Management
- **Advanced Filtering**: Filter by status, priority, department, and assignee
- **Status Updates**: Change ticket status with dropdown selectors
- **Priority Management**: Update ticket priority levels
- **Assignment**: Assign tickets to staff members
- **Bulk Operations**: Manage multiple tickets efficiently

### ⚠️ Issue Management
- **Issue Tracking**: Monitor citizen-reported issues
- **Status Management**: Update issue resolution status
- **Priority Handling**: Set and modify issue priorities
- **Category Filtering**: Filter issues by category and department
- **Resolution Tracking**: Track issue resolution progress

### 📈 Analytics Dashboard
- **Performance Metrics**: Department and category performance analytics
- **Summary Statistics**: Key performance indicators
- **Trend Analysis**: Historical data and trends
- **System Health**: Real-time system status monitoring

### 🔔 Notification Management
- **Notification Center**: View all system notifications
- **Send Notifications**: Create and send notifications to users
- **Bulk Messaging**: Send notifications to all users or specific groups
- **Read Status**: Track notification read/unread status
- **Notification Types**: Support for different notification types (info, success, warning, error)

### 💬 Feedback Management
- **Feedback Review**: Review citizen feedback and ratings
- **Rating System**: 5-star rating display and management
- **Status Control**: Publish, reject, or keep feedback pending
- **Feedback Statistics**: Average ratings and feedback counts
- **Ticket Integration**: Link feedback to specific tickets

### ⏰ SLA Management
- **SLA Configuration**: Set response and resolution time limits
- **Category-based SLAs**: Different SLAs for different categories
- **Breach Monitoring**: Check for SLA violations
- **Time Tracking**: Visual representation of time limits
- **Escalation Rules**: Configure escalation timeframes

### ⚙️ Settings Management
- **System Configuration**: Manage application settings
- **Setting Types**: Support for string, number, boolean, and JSON settings
- **Default Reset**: Reset settings to default values
- **Setting Categories**: Organize settings by type and purpose

## Technical Implementation

### Architecture
- **Frontend**: React.js with functional components and hooks
- **Routing**: React Router DOM with protected admin routes
- **State Management**: React Context for authentication
- **Styling**: Tailwind CSS for responsive design
- **API Integration**: Axios-based API service layer

### Security
- **Role-based Access**: Admin-only access to dashboard features
- **Authentication**: JWT token-based authentication
- **Route Protection**: Protected routes for admin functions
- **User Session**: Persistent login state management

### API Integration
The dashboard integrates with all backend endpoints:

#### Authentication
- `POST /api/auth/login` - User authentication
- `GET /api/auth/profile` - Get user profile
- `POST /api/auth/logout` - User logout

#### User Management
- `GET /api/users` - Get all users
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user
- `GET /api/users/stats` - User statistics

#### Department Management
- `GET /api/departments` - Get all departments
- `POST /api/departments` - Create department
- `PUT /api/departments/:id` - Update department
- `DELETE /api/departments/:id` - Delete department

#### Category Management
- `GET /api/categories` - Get all categories
- `POST /api/categories` - Create category
- `PUT /api/categories/:id` - Update category
- `DELETE /api/categories/:id` - Delete category

#### Ticket Management
- `GET /api/tickets` - Get all tickets
- `PUT /api/tickets/:id` - Update ticket
- `DELETE /api/tickets/:id` - Delete ticket

#### Issue Management
- `GET /api/issues` - Get all issues
- `PUT /api/issues/:id` - Update issue
- `DELETE /api/issues/:id` - Delete issue

#### Analytics
- `GET /api/analytics/dashboard` - Dashboard analytics
- `GET /api/analytics/department-performance` - Department performance
- `GET /api/analytics/category-analytics` - Category analytics

#### Notifications
- `GET /api/notifications/my` - Get notifications
- `POST /api/notifications` - Send notification
- `PUT /api/notifications/:id/read` - Mark as read

#### Feedback
- `GET /api/feedback` - Get all feedback
- `PUT /api/feedback/:id` - Update feedback status
- `DELETE /api/feedback/:id` - Delete feedback

#### SLA
- `GET /api/sla` - Get all SLA configurations
- `POST /api/sla` - Create SLA
- `PUT /api/sla/:id` - Update SLA
- `DELETE /api/sla/:id` - Delete SLA
- `POST /api/sla/check-breaches` - Check SLA breaches

#### Settings
- `GET /api/settings` - Get all settings
- `POST /api/settings` - Create setting
- `PUT /api/settings/:key` - Update setting
- `DELETE /api/settings/:key` - Delete setting

## Getting Started

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn
- Backend API running and accessible

### Installation
1. Navigate to the client directory:
   ```bash
   cd backend/client
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   Create a `.env` file in the client directory:
   ```env
   VITE_API_BASE=http://localhost:3000
   VITE_DEBUG=false
   ```
   
   **Note**: See `ENVIRONMENT_SETUP.md` for detailed environment configuration instructions.

4. Start the development server:
   ```bash
   npm run dev
   ```

### Admin Access
To access the admin dashboard:
1. Login with an admin account
2. Navigate to `/admin` route
3. Use the sidebar navigation to access different admin features

### Default Admin Credentials
- Email: `admin@example.com`
- Password: `ChangeMe123!`

## Usage Guide

### Dashboard Overview
The main dashboard provides:
- **Statistics Cards**: Quick view of key metrics
- **Quick Actions**: Fast access to common tasks
- **Recent Activity**: Latest system events
- **System Health**: Real-time status monitoring

### Managing Users
1. Navigate to **Users** in the sidebar
2. Click **Add User** to create new users
3. Edit user details by clicking **Edit** on any user row
4. Assign roles (admin, staff, user) and departments
5. Activate/deactivate user accounts

### Managing Departments
1. Go to **Departments** section
2. Create department hierarchy with parent departments
3. Assign departments to users and categories
4. Track department performance in analytics

### Managing Categories
1. Access **Categories** management
2. Link categories to specific departments
3. Create category hierarchies
4. Monitor category performance and issue counts

### Ticket Management
1. Use **Tickets** section for ticket oversight
2. Apply filters to find specific tickets
3. Update ticket status and priority
4. Assign tickets to staff members
5. Track ticket resolution progress

### Analytics and Reporting
1. Visit **Analytics** for performance insights
2. View department performance metrics
3. Analyze category statistics
4. Monitor system health and trends

### System Configuration
1. Access **Settings** for system configuration
2. Manage application settings
3. Configure system parameters
4. Reset settings to defaults when needed

## Customization

### Adding New Features
1. Create new components in `src/modules/admin/`
2. Add routes in `src/modules/app/App.jsx`
3. Update navigation in `AdminLayout.jsx`
4. Add API services in `src/services/api.js`

### Styling
- Uses Tailwind CSS for styling
- Responsive design for mobile and desktop
- Consistent color scheme and typography
- Customizable component styles

### API Integration
- Centralized API service layer
- Error handling and loading states
- Token-based authentication
- Consistent request/response patterns

## Troubleshooting

### Common Issues

#### Authentication Errors
- Ensure backend API is running
- Check JWT token validity
- Verify admin role assignment

#### API Connection Issues
- Verify `VITE_API_BASE` environment variable
- Check CORS configuration on backend
- Ensure network connectivity

#### Permission Errors
- Confirm user has admin role
- Check route protection logic
- Verify token permissions

### Debug Mode
Enable debug logging by adding to `.env`:
```env
VITE_DEBUG=true
```

## Contributing

1. Follow React.js best practices
2. Use functional components with hooks
3. Implement proper error handling
4. Add loading states for async operations
5. Write responsive CSS with Tailwind
6. Test all admin functionality

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review API documentation
3. Verify backend connectivity
4. Check browser console for errors

## Future Enhancements

- Real-time notifications with WebSocket
- Advanced analytics with charts
- Bulk operations for data management
- Export functionality for reports
- Advanced user permission system
- Audit logging for admin actions
- Mobile-responsive optimizations
- Dark mode theme support
