-- Sample data for government ticketing system

-- First, ensure departments table exists and has data
DO $$
BEGIN
    -- Check if departments table exists, if not create it
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'departments') THEN
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
        ('Education', 'Handles educational institutions and policies', 'EDU', 'State'),
        ('Health', 'Manages healthcare facilities and public health', 'HLTH', 'State'),
        ('Transport', 'Manages public transportation and related infrastructure', 'TRANS', 'State'),
        ('Revenue', 'Handles taxation and revenue collection', 'REV', 'State'),
        ('Agriculture', 'Supports farmers and agricultural development', 'AGRI', 'State'),
        ('Social Welfare', 'Manages social security and welfare programs', 'SW', 'State');
    END IF;
END $$;

-- Ensure ticket_categories table exists and has data
DO $$
BEGIN
    -- Check if ticket_categories table exists, if not create it
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'ticket_categories') THEN
        CREATE TABLE ticket_categories (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          name TEXT NOT NULL,
          description TEXT,
          department_id UUID REFERENCES departments(id),
          parent_category_id UUID REFERENCES ticket_categories(id),
          is_active BOOLEAN DEFAULT TRUE,
          sla_hours INTEGER,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );

        -- Insert some common government ticket categories
        INSERT INTO ticket_categories (name, description, sla_hours) VALUES
        ('Road Maintenance', 'Issues related to road conditions and maintenance', 72),
        ('Water Supply', 'Issues related to water supply and quality', 48),
        ('Electricity', 'Issues related to power supply and electrical infrastructure', 24),
        ('Sanitation', 'Issues related to waste management and cleanliness', 48),
        ('Public Transport', 'Issues related to public transportation services', 72),
        ('Public Safety', 'Issues related to safety concerns in public areas', 24),
        ('Property Tax', 'Queries and issues related to property taxation', 96),
        ('Birth/Death Certificate', 'Requests for birth or death certificates', 120),
        ('School Related', 'Issues related to government schools', 96),
        ('Healthcare', 'Issues related to government healthcare facilities', 48);
    END IF;
END $$;

-- Ensure users table exists
DO $$
BEGIN
    -- Check if users table exists, if not create it
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'users') THEN
        CREATE TABLE users (
          id UUID PRIMARY KEY,
          email TEXT UNIQUE NOT NULL,
          name TEXT NOT NULL,
          user_type TEXT NOT NULL DEFAULT 'citizen',
          department_id UUID REFERENCES departments(id),
          aadhaar_number TEXT,
          phone_number TEXT,
          address TEXT,
          district TEXT,
          state TEXT,
          pin_code TEXT,
          date_of_birth DATE,
          gender TEXT,
          id_proof_type TEXT,
          id_proof_number TEXT,
          is_verified BOOLEAN DEFAULT FALSE,
          verification_date TIMESTAMP WITH TIME ZONE,
          employee_id TEXT,
          designation TEXT,
          role TEXT,
          jurisdiction TEXT,
          profile_image_url TEXT,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
    END IF;
END $$;

-- Now create test users
DO $$
DECLARE
    citizen_id UUID;
    staff_id UUID;
    admin_id UUID;
    pwd_dept_id UUID;
    water_dept_id UUID;
    road_cat_id UUID;
    water_cat_id UUID;
    first_ticket_id UUID;
    second_ticket_id UUID;
BEGIN
    -- For testing, we'll use hardcoded UUIDs
    citizen_id := '00000000-0000-0000-0000-000000000001'::UUID;
    staff_id := '00000000-0000-0000-0000-000000000002'::UUID;
    admin_id := '00000000-0000-0000-0000-000000000003'::UUID;
    
    -- Get department IDs
    SELECT id INTO pwd_dept_id FROM departments WHERE department_code = 'PWD';
    SELECT id INTO water_dept_id FROM departments WHERE department_code = 'WSD';
    
    -- Get category IDs
    SELECT id INTO road_cat_id FROM ticket_categories WHERE name = 'Road Maintenance';
    SELECT id INTO water_cat_id FROM ticket_categories WHERE name = 'Water Supply';
    
    -- Insert citizen user
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = citizen_id) THEN
        INSERT INTO users (
            id, email, name, user_type, phone_number, address, district, 
            state, pin_code, aadhaar_number, is_verified
        )
        VALUES (
            citizen_id, 'citizen@example.com', 'Rahul Sharma', 'citizen',
            '9876543210', '123 Main Street, Sector 10', 'Central District',
            'Karnataka', '560001', '123456789012', TRUE
        );
    END IF;
    
    -- Insert staff user
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = staff_id) THEN
        INSERT INTO users (
            id, email, name, user_type, department_id, phone_number,
            employee_id, designation, role, is_verified
        )
        VALUES (
            staff_id, 'staff@example.com', 'Priya Patel', 'staff',
            pwd_dept_id, '8765432109', 'EMP001', 'Junior Engineer',
            'ticket_handler', TRUE
        );
    END IF;
    
    -- Insert admin user
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = admin_id) THEN
        INSERT INTO users (
            id, email, name, user_type, department_id, phone_number,
            employee_id, designation, role, is_verified
        )
        VALUES (
            admin_id, 'admin@example.com', 'Amit Kumar', 'admin',
            water_dept_id, '7654321098', 'EMP002', 'Department Head',
            'admin', TRUE
        );
    END IF;

    -- Ensure we have the necessary tables for tickets
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'tickets') THEN
        -- Create enum types for ticket status and priority
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ticket_status') THEN
            CREATE TYPE ticket_status AS ENUM ('open', 'in_progress', 'pending', 'resolved', 'closed', 'rejected', 'escalated', 'forwarded');
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ticket_priority') THEN
            CREATE TYPE ticket_priority AS ENUM ('low', 'medium', 'high', 'urgent', 'critical');
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ticket_type') THEN
            CREATE TYPE ticket_type AS ENUM ('complaint', 'suggestion', 'inquiry', 'service_request', 'feedback', 'grievance');
        END IF;
        
        -- Create tickets table
        CREATE TABLE tickets (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          ticket_number TEXT UNIQUE,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          status ticket_status NOT NULL DEFAULT 'open',
          priority ticket_priority NOT NULL DEFAULT 'medium',
          ticket_type ticket_type NOT NULL DEFAULT 'complaint',
          user_id UUID NOT NULL,
          assigned_to UUID REFERENCES users(id),
          department_id UUID REFERENCES departments(id),
          category_id UUID REFERENCES ticket_categories(id),
          sub_category TEXT,
          location_address TEXT,
          district TEXT,
          state TEXT,
          pin_code TEXT,
          latitude NUMERIC,
          longitude NUMERIC,
          ward_number TEXT,
          constituency TEXT,
          escalation_level INTEGER DEFAULT 0,
          escalation_reason TEXT,
          forwarded_from_dept_id UUID REFERENCES departments(id),
          forwarded_reason TEXT,
          is_public BOOLEAN DEFAULT TRUE,
          satisfaction_rating INTEGER,
          feedback_text TEXT,
          due_date TIMESTAMP WITH TIME ZONE,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          resolved_at TIMESTAMP WITH TIME ZONE,
          closed_at TIMESTAMP WITH TIME ZONE,
          attachments TEXT[]
        );
        
        -- Create comments table
        CREATE TABLE ticket_comments (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
          user_id UUID NOT NULL,
          content TEXT NOT NULL,
          comment_type TEXT DEFAULT 'public',
          is_official_response BOOLEAN DEFAULT FALSE,
          department_id UUID REFERENCES departments(id),
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          user_role TEXT,
          user_name TEXT,
          user_designation TEXT,
          attachments TEXT[]
        );
    END IF;
    
    -- Insert sample tickets
    INSERT INTO tickets (
        ticket_number, title, description, status, priority, ticket_type,
        user_id, department_id, category_id, location_address, district,
        state, pin_code, latitude, longitude, ward_number, is_public, attachments
    ) 
    VALUES 
    (
        'PWD-2023-001', 
        'Pothole on Main Road', 
        'There is a large pothole on Main Road near City Hospital that is causing traffic issues and is dangerous for two-wheelers.',
        'open', 
        'high', 
        'complaint',
        citizen_id, 
        pwd_dept_id, 
        road_cat_id,
        'Main Road near City Hospital', 
        'Central District', 
        'Karnataka', 
        '560001',
        12.9716, 
        77.5946, 
        'Ward-12',
        TRUE,
        ARRAY['https://example.com/pothole1.jpg', 'https://example.com/pothole2.jpg']
    ),
    (
        'WSD-2023-001', 
        'No Water Supply in Sector 5', 
        'We have not received water supply in Sector 5 for the last 3 days. This is causing severe inconvenience to all residents.',
        'in_progress', 
        'urgent', 
        'complaint',
        citizen_id, 
        water_dept_id, 
        water_cat_id,
        'Sector 5, Residential Area', 
        'North District', 
        'Karnataka', 
        '560002',
        12.9815, 
        77.6087, 
        'Ward-5',
        TRUE,
        ARRAY['https://example.com/watertank.jpg']
    ),
    (
        'PWD-2023-002', 
        'Streetlight not working', 
        'The streetlight at the corner of Park Street and Lake Road has not been working for a week, making the area unsafe at night.',
        'pending', 
        'medium', 
        'service_request',
        citizen_id, 
        pwd_dept_id, 
        road_cat_id,
        'Corner of Park Street and Lake Road', 
        'South District', 
        'Karnataka', 
        '560003',
        12.9542, 
        77.6192, 
        'Ward-8',
        TRUE,
        NULL
    ),
    (
        'WSD-2023-002', 
        'Water Quality Issue', 
        'The water supply in our area has a strange smell and color. We suspect contamination and request immediate testing.',
        'open', 
        'critical', 
        'complaint',
        citizen_id, 
        water_dept_id, 
        water_cat_id,
        'Green Valley Apartments, Block C', 
        'East District', 
        'Karnataka', 
        '560004',
        12.9975, 
        77.6536, 
        'Ward-15',
        TRUE,
        ARRAY['https://example.com/water_sample.jpg']
    ),
    (
        'PWD-2023-003', 
        'Suggestion for New Bus Stop', 
        'I would like to suggest adding a bus stop near the new Tech Park in Sector 10. Many employees would benefit from this.',
        'open', 
        'low', 
        'suggestion',
        citizen_id, 
        pwd_dept_id, 
        road_cat_id,
        'Tech Park, Sector 10', 
        'West District', 
        'Karnataka', 
        '560005',
        12.9716, 
        77.5746, 
        'Ward-20',
        TRUE,
        NULL
    );

    -- Get the first two ticket IDs for comments
    SELECT id INTO first_ticket_id FROM tickets WHERE ticket_number = 'PWD-2023-001';
    SELECT id INTO second_ticket_id FROM tickets WHERE ticket_number = 'WSD-2023-001';
    -- Insert sample ticket comments for first ticket
    IF first_ticket_id IS NOT NULL THEN
        INSERT INTO ticket_comments (
            ticket_id, user_id, content, comment_type, is_official_response,
            department_id, user_role, user_name, user_designation
        )
        VALUES
        (
            first_ticket_id, 
            citizen_id, 
            'I noticed this pothole has grown larger after the recent rains. It is now about 2 feet wide and 6 inches deep.',
            'public', 
            FALSE,
            NULL, 
            'citizen', 
            'Rahul Sharma', 
            NULL
        ),
        (
            first_ticket_id, 
            staff_id, 
            'Thank you for reporting this issue. We have dispatched a team to inspect the pothole and assess the repairs needed.',
            'public', 
            TRUE,
            pwd_dept_id, 
            'staff', 
            'Priya Patel', 
            'Junior Engineer'
        ),
        (
            first_ticket_id, 
            staff_id, 
            'Need to check if this requires full resurfacing or just patching.',
            'internal', 
            TRUE,
            pwd_dept_id, 
            'staff', 
            'Priya Patel', 
            'Junior Engineer'
        ),
        (
            first_ticket_id, 
            citizen_id, 
            'Thank you for the quick response. When can we expect the repairs to be completed?',
            'public', 
            FALSE,
            NULL, 
            'citizen', 
            'Rahul Sharma', 
            NULL
        );
    END IF;
    -- Insert sample ticket comments for second ticket
    IF second_ticket_id IS NOT NULL THEN
        INSERT INTO ticket_comments (
            ticket_id, user_id, content, comment_type, is_official_response,
            department_id, user_role, user_name, user_designation
        )
        VALUES
        (
            second_ticket_id, 
            citizen_id, 
            'This is causing severe problems for elderly residents in our area who cannot store large quantities of water.',
            'public', 
            FALSE,
            NULL, 
            'citizen', 
            'Rahul Sharma', 
            NULL
        ),
        (
            second_ticket_id, 
            admin_id, 
            'We are aware of the issue and have identified a burst pipeline as the cause. Repair work has started and water supply should be restored within 24 hours.',
            'public', 
            TRUE,
            water_dept_id, 
            'admin', 
            'Amit Kumar', 
            'Department Head'
        ),
        (
            second_ticket_id, 
            admin_id, 
            'Arrange for water tankers to be sent to the affected area immediately.',
            'internal', 
            TRUE,
            water_dept_id, 
            'admin', 
            'Amit Kumar', 
            'Department Head'
        ),
        (
            second_ticket_id, 
            citizen_id, 
            'Thank you for the update. Will water tankers be provided in the meantime?',
            'public', 
            FALSE,
            NULL, 
            'citizen', 
            'Rahul Sharma', 
            NULL
        ),
        (
            second_ticket_id, 
            admin_id, 
            'Yes, we are dispatching water tankers that should arrive in your area within the next 2 hours.',
            'public', 
            TRUE,
            water_dept_id, 
            'admin', 
            'Amit Kumar', 
            'Department Head'
        );
        
        -- Update the status to in_progress
        UPDATE tickets SET status = 'in_progress' WHERE id = second_ticket_id;
    END IF;
    -- Create escalation matrix table if it doesn't exist
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'escalation_matrix') THEN
        CREATE TABLE escalation_matrix (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          department_id UUID NOT NULL REFERENCES departments(id),
          category_id UUID REFERENCES ticket_categories(id),
          level INTEGER NOT NULL,
          escalation_hours INTEGER NOT NULL,
          escalate_to UUID REFERENCES users(id),
          escalate_to_role TEXT,
          notification_emails TEXT[],
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
    END IF;
    
    -- Create escalation matrix entries
    INSERT INTO escalation_matrix (
        department_id, category_id, level, escalation_hours, 
        escalate_to_role, notification_emails
    )
    VALUES
    (
        pwd_dept_id, road_cat_id, 1, 24, 
        'supervisor', ARRAY['supervisor@pwd.gov.in']
    ),
    (
        pwd_dept_id, road_cat_id, 2, 48, 
        'department_head', ARRAY['head@pwd.gov.in']
    ),
    (
        water_dept_id, water_cat_id, 1, 12, 
        'supervisor', ARRAY['supervisor@wsd.gov.in']
    ),
    (
        water_dept_id, water_cat_id, 2, 24, 
        'department_head', ARRAY['head@wsd.gov.in']
    );
END
$$;
