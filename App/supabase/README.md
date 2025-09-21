# Jan Mitra Supabase Setup

This directory contains the SQL schema and sample data for the Jan Mitra application's Supabase backend.

## Setup Instructions

### Option 1: Using the Setup Scripts (Recommended)

#### For Windows:
1. Open Command Prompt
2. Navigate to this directory
3. Run `setup.bat`
4. Enter your Supabase URL and Anon Key when prompted

#### For macOS/Linux:
1. Open Terminal
2. Navigate to this directory
3. Make the script executable: `chmod +x setup.sh`
4. Run `./setup.sh`
5. Enter your Supabase URL and Anon Key when prompted

### Option 2: Manual Setup

1. Create a new Supabase project
2. Get your Supabase URL and Anon Key from the project settings
3. Run the following SQL files in order:
   - `run_this_first.sql` - Creates the departments table (fixes the common error)
   - `fixed_schema.sql` - Creates the complete database schema
   - `fixed_sample_data.sql` - Inserts sample data

You can run these files using the Supabase SQL Editor or using the PostgreSQL client:

```bash
psql YOUR_SUPABASE_URL -U postgres -f run_this_first.sql
psql YOUR_SUPABASE_URL -U postgres -f fixed_schema.sql
psql YOUR_SUPABASE_URL -U postgres -f fixed_sample_data.sql
```

If you encounter any errors, see the troubleshoot.md file for solutions.

## Schema Overview

The Jan Mitra application uses the following main tables:

- `departments` - Government departments
- `users` - User accounts (citizens, staff, admins)
- `tickets` - Citizen complaints and service requests
- `ticket_categories` - Categories for tickets
- `ticket_comments` - Comments on tickets
- `ticket_history` - Audit trail of ticket changes
- `ticket_attachments` - Files attached to tickets
- `escalation_matrix` - Rules for ticket escalation
- `sla_tracking` - Service Level Agreement tracking

## Important Notes

- The schema requires the PostGIS extension to be enabled on your Supabase project for geospatial functionality.
- The schema includes Row Level Security (RLS) policies that allow all operations for development purposes. These should be replaced with proper policies in production.
- The sample data includes test users with hardcoded UUIDs for testing purposes.
- The schema is designed to work with Supabase's authentication system.

## Enabling PostGIS Extension

If you encounter an error about the "postgis" extension not being available, you'll need to enable it in your Supabase project:

1. Go to your Supabase dashboard
2. Navigate to the SQL Editor
3. Run the following SQL command:
   ```sql
   CREATE EXTENSION IF NOT EXISTS postgis;
   ```
4. Then run the setup scripts again