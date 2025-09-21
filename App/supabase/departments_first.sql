-- Create departments table first to resolve dependency issues

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Check if departments table exists, if not create it
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'departments') THEN
        CREATE TABLE departments (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          name TEXT NOT NULL,
          description TEXT,
          department_code TEXT UNIQUE,
          jurisdiction TEXT,
          parent_department_id UUID REFERENCES departments(id),
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
        
        -- Insert some common government departments
        INSERT INTO departments (name, description, department_code, jurisdiction) VALUES
        ('Public Works', 'Responsible for infrastructure and public facilities', 'PWD', 'State'),
        ('Water Supply', 'Manages water resources and distribution', 'WSD', 'State'),
        ('Electricity', 'Manages power distribution and related issues', 'ELECT', 'State'),
        ('Sanitation', 'Responsible for waste management and cleanliness', 'SAN', 'Municipal'),
        ('Health', 'Manages healthcare facilities and public health', 'HLTH', 'State');
        
        RAISE NOTICE 'Departments table created successfully';
    ELSE
        RAISE NOTICE 'Departments table already exists';
    END IF;
END
$$;
