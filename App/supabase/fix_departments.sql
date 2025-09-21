-- Script to fix the "relation departments does not exist" error

-- Drop any existing foreign keys that reference departments
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT tc.table_name, tc.constraint_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.constraint_column_usage ccu 
        ON tc.constraint_name = ccu.constraint_name
        WHERE tc.constraint_type = 'FOREIGN KEY' 
        AND ccu.table_name = 'departments'
    ) LOOP
        EXECUTE 'ALTER TABLE ' || r.table_name || ' DROP CONSTRAINT ' || r.constraint_name;
        RAISE NOTICE 'Dropped foreign key constraint % on table %', r.constraint_name, r.table_name;
    END LOOP;
END $$;

-- Drop the departments table if it exists
DROP TABLE IF EXISTS departments CASCADE;

-- Create the departments table
CREATE TABLE departments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  department_code TEXT UNIQUE,
  jurisdiction TEXT,
  parent_department_id UUID, -- Self-reference will be added later
  head_official_name TEXT,
  head_official_title TEXT,
  contact_email TEXT,
  contact_phone TEXT,
  address TEXT,
  district TEXT,
  state TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add the self-reference constraint
ALTER TABLE departments 
ADD CONSTRAINT fk_departments_parent 
FOREIGN KEY (parent_department_id) 
REFERENCES departments(id);

-- Insert sample departments
INSERT INTO departments (name, description, department_code, jurisdiction) VALUES
('Public Works', 'Responsible for infrastructure and public facilities', 'PWD', 'State'),
('Water Supply', 'Manages water resources and distribution', 'WSD', 'State'),
('Electricity', 'Manages power distribution and related issues', 'ELECT', 'State'),
('Sanitation', 'Responsible for waste management and cleanliness', 'SAN', 'Municipal'),
('Health', 'Manages healthcare facilities and public health', 'HLTH', 'State');

-- Verify the departments table exists and has data
SELECT COUNT(*) FROM departments;
