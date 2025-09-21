# Troubleshooting Database Issues

## "relation departments does not exist" Error

If you encounter the error `ERROR: 42P01: relation "departments" does not exist`, follow these steps:

### Option 1: Run the Fix Script

1. Connect to your Supabase database using the SQL Editor or psql
2. Run the `fix_departments.sql` script:
   ```
   psql YOUR_SUPABASE_URL -U postgres -f fix_departments.sql
   ```

This script will:
- Drop any foreign key constraints that reference the departments table
- Drop the departments table if it exists
- Create a new departments table
- Add self-reference constraint
- Insert sample departments

### Option 2: Manual Fix

If the script doesn't work, follow these manual steps:

1. Connect to your Supabase database using the SQL Editor
2. Run these commands:

```sql
-- Create the departments table first
CREATE TABLE IF NOT EXISTS departments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  department_code TEXT UNIQUE,
  jurisdiction TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert at least one department
INSERT INTO departments (name, department_code)
SELECT 'Public Works', 'PWD'
WHERE NOT EXISTS (SELECT 1 FROM departments WHERE department_code = 'PWD');
```

### Option 3: Check for Schema Issues

If you're still having issues, the problem might be related to schema namespaces:

1. Check which schema your tables are in:
```sql
SELECT table_schema, table_name 
FROM information_schema.tables 
WHERE table_name = 'departments';
```

2. If the table exists in a different schema than 'public', qualify all references:
```sql
CREATE TABLE public.departments (...);
```

### Option 4: Check PostgreSQL Version

Some features might not be available in older PostgreSQL versions. Supabase uses PostgreSQL 14+, so make sure your local development environment matches this version if you're testing locally.

## After Fixing

After fixing the departments table issue, try running the full schema script again. If you encounter more errors, address them one by one, making sure each referenced table exists before it's referenced by another table.
