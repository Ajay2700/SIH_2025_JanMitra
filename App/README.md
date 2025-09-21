# Jan Mitra - Crowdsourced Civic Issue Reporting and Resolution System

Jan Mitra is a comprehensive civic issue reporting and resolution platform built with Flutter and Supabase. It enables citizens to report civic issues while providing government officials with tools to manage and resolve these issues efficiently.

## Features

### Citizen App
- **Issue Reporting**: Report civic issues with photos, location tagging, and descriptions
- **Voice Input**: Add descriptions using speech-to-text (temporarily disabled)
- **Issue Tracking**: Track the status of reported issues
- **Notifications**: Receive updates when issue status changes
- **Authentication**: Secure login and registration system

### Admin Portal
- **Interactive Dashboard**: View issues on a map with filtering options
- **Task Assignment**: Assign issues to staff members
- **Status Updates**: Update issue status and add comments
- **Analytics**: View statistics on issue resolution
- **User Management**: Manage staff accounts and permissions

## Tech Stack

- **Frontend**: Flutter (Cross-platform for Android, iOS, Web)
- **State Management**: GetX
- **Backend**: Supabase (PostgreSQL, Authentication, Storage, Realtime)
- **Maps**: Google Maps API
- **Location Services**: Geolocator
- **Image Handling**: Image Picker, Cached Network Image

## Project Structure

```
lib/
├── core/
│   ├── bindings/
│   ├── config/
│   ├── theme/
│   ├── ui/
│   └── utils/
├── data/
│   ├── models/
│   ├── repository/
│   └── services/
├── modules/
│   ├── admin/
│   ├── auth/
│   └── citizen/
└── routes/
```

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Supabase account
- Google Maps API key

### Setup

1. Clone the repository
```bash
git clone https://github.com/yourusername/jan_mitra.git
cd jan_mitra
```

2. Install dependencies
```bash
flutter pub get
```

3. Create a Supabase project and set up the database using the SQL scripts in the `supabase` directory.

4. Create a `.env` file in the project root with your Supabase and Google Maps API keys:
```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
```

5. Run the app
```bash
flutter run
```

## Deployment for Government Use

### Supabase Configuration

1. Set up a dedicated Supabase project for production use
2. Apply the database schema from `supabase/schema.sql`
3. Configure Row Level Security policies from `supabase/rls_policies.sql`
4. Set up storage buckets for issue images with appropriate permissions

### Environment Configuration

For production deployment, configure the following environment variables:

```
SUPABASE_URL=https://your-production-project.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key
GOOGLE_MAPS_API_KEY=your-restricted-api-key
GOVERNMENT_NAME=Your Government Name
DEPARTMENT_NAME=Your Department Name
SUPPORT_EMAIL=support@yourdomain.gov
SUPPORT_PHONE=Your Support Phone
```

### Security Considerations

1. **API Keys**: Use restricted API keys with domain limitations
2. **Authentication**: Implement two-factor authentication for admin users
3. **Data Protection**: Apply Row Level Security policies to protect sensitive data
4. **Encryption**: Enable encryption at rest for the database
5. **Auditing**: Set up audit logs for all administrative actions

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- Flutter Team for the amazing framework
- Supabase Team for the powerful backend platform
- GetX Team for the state management solution