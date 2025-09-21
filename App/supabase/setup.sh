#!/bin/bash

# Setup script for Jan Mitra Supabase database
echo "Jan Mitra Supabase Setup Script"
echo "==============================="

# Get Supabase URL and Anon Key
read -p "Enter your Supabase URL: " SUPABASE_URL
read -p "Enter your Supabase Anon Key: " SUPABASE_ANON_KEY

# Check if psql is installed
if ! command -v psql &> /dev/null; then
    echo "Error: PostgreSQL client (psql) is not installed or not in PATH"
    echo "Please install PostgreSQL client tools and try again"
    exit 1
fi

# Enable required extensions
echo "Enabling required extensions..."
psql "$SUPABASE_URL" -U postgres -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
psql "$SUPABASE_URL" -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"

# Create departments table first (to avoid the common error)
echo "Creating departments table first..."
psql "$SUPABASE_URL" -U postgres -f run_this_first.sql

# Execute main schema files
echo "Creating database schema..."
psql "$SUPABASE_URL" -U postgres -f fixed_schema.sql

echo "Inserting sample data..."
psql "$SUPABASE_URL" -U postgres -f fixed_sample_data.sql

echo "Setup complete!"
echo "You can now run the application with the Supabase backend."