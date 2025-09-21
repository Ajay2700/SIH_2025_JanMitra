-- IMPORTANT: Run this script first to create the departments table
-- This will fix the "relation departments does not exist" error

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create departments table with minimal fields
CREATE TABLE IF NOT EXISTS departments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  department_code TEXT UNIQUE,
  jurisdiction TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert basic department data
INSERT INTO departments (name, department_code, jurisdiction)
SELECT 'Public Works', 'PWD', 'State'
WHERE NOT EXISTS (SELECT 1 FROM departments WHERE department_code = 'PWD');

INSERT INTO departments (name, department_code, jurisdiction)
SELECT 'Water Supply', 'WSD', 'State'
WHERE NOT EXISTS (SELECT 1 FROM departments WHERE department_code = 'WSD');

INSERT INTO departments (name, department_code, jurisdiction)
SELECT 'Electricity', 'ELECT', 'State'
WHERE NOT EXISTS (SELECT 1 FROM departments WHERE department_code = 'ELECT');

INSERT INTO departments (name, department_code, jurisdiction)
SELECT 'Sanitation', 'SAN', 'Municipal'
WHERE NOT EXISTS (SELECT 1 FROM departments WHERE department_code = 'SAN');

INSERT INTO departments (name, department_code, jurisdiction)
SELECT 'Health', 'HLTH', 'State'
WHERE NOT EXISTS (SELECT 1 FROM departments WHERE department_code = 'HLTH');

-- Verify the departments table exists and has data
SELECT COUNT(*) FROM departments;
