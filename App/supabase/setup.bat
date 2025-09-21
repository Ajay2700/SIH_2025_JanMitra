@echo off
REM Setup script for Jan Mitra Supabase database

echo Jan Mitra Supabase Setup Script
echo ===============================

REM Get Supabase URL and Anon Key
set /p SUPABASE_URL=Enter your Supabase URL: 
set /p SUPABASE_ANON_KEY=Enter your Supabase Anon Key: 

REM Check if psql is installed
where psql >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: PostgreSQL client (psql) is not installed or not in PATH
    echo Please install PostgreSQL client tools and try again
    exit /b 1
)

REM Enable required extensions
echo Enabling required extensions...
psql "%SUPABASE_URL%" -U postgres -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
psql "%SUPABASE_URL%" -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"

REM Create departments table first (to avoid the common error)
echo Creating departments table first...
psql "%SUPABASE_URL%" -U postgres -f run_this_first.sql

REM Execute main schema files
echo Creating database schema...
psql "%SUPABASE_URL%" -U postgres -f fixed_schema.sql

echo Inserting sample data...
psql "%SUPABASE_URL%" -U postgres -f fixed_sample_data.sql

echo Setup complete!
echo You can now run the application with the Supabase backend.