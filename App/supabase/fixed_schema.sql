-- Create schema for Jan Mitra - Civic Issue Reporting System

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Create enum types
CREATE TYPE user_type AS ENUM ('citizen', 'staff', 'admin');
CREATE TYPE issue_status AS ENUM ('submitted', 'acknowledged', 'in_progress', 'resolved', 'rejected');
CREATE TYPE issue_priority AS ENUM ('low', 'medium', 'high');
CREATE TYPE ticket_status AS ENUM ('open', 'in_progress', 'pending', 'resolved', 'closed', 'rejected', 'escalated', 'forwarded');
CREATE TYPE ticket_priority AS ENUM ('low', 'medium', 'high', 'urgent', 'critical');
CREATE TYPE ticket_type AS ENUM ('complaint', 'suggestion', 'inquiry', 'service_request', 'feedback', 'grievance');

-- Departments table (create first, no circular dependency)
CREATE TABLE IF NOT EXISTS departments (
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

-- Insert some common government departments if table is empty
INSERT INTO departments (name, description, department_code, jurisdiction)
SELECT 'Public Works', 'Responsible for infrastructure and public facilities', 'PWD', 'State'
WHERE NOT EXISTS (SELECT 1 FROM departments WHERE department_code = 'PWD');

INSERT INTO departments (name, description, department_code, jurisdiction)
SELECT 'Water Supply', 'Manages water resources and distribution', 'WSD', 'State'
WHERE NOT EXISTS (SELECT 1 FROM departments WHERE department_code = 'WSD');

INSERT INTO departments (name, description, department_code, jurisdiction)
SELECT 'Electricity', 'Manages power distribution and related issues', 'ELECT', 'State'
WHERE NOT EXISTS (SELECT 1 FROM departments WHERE department_code = 'ELECT');

INSERT INTO departments (name, description, department_code, jurisdiction)
SELECT 'Sanitation', 'Responsible for waste management and cleanliness', 'SAN', 'Municipal'
WHERE NOT EXISTS (SELECT 1 FROM departments WHERE department_code = 'SAN');

INSERT INTO departments (name, description, department_code, jurisdiction)
SELECT 'Health', 'Manages healthcare facilities and public health', 'HLTH', 'State'
WHERE NOT EXISTS (SELECT 1 FROM departments WHERE department_code = 'HLTH');

-- Users table (create after departments)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  user_type user_type NOT NULL DEFAULT 'citizen',
  department_id UUID REFERENCES departments(id),
  aadhaar_number TEXT,
  address TEXT,
  district TEXT,
  state TEXT,
  pin_code TEXT,
  date_of_birth DATE,
  gender TEXT,
  id_proof_type TEXT,
  id_proof_number TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  employee_id TEXT,
  designation TEXT,
  role TEXT,
  jurisdiction TEXT,
  profile_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Now update departments to reference head_id (after users table exists)
ALTER TABLE departments ADD COLUMN IF NOT EXISTS head_id UUID REFERENCES users(id);

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  department_id UUID REFERENCES departments(id),
  icon TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ticket categories table
CREATE TABLE IF NOT EXISTS ticket_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  department_id UUID REFERENCES departments(id),
  parent_category_id UUID REFERENCES ticket_categories(id),
  is_active BOOLEAN DEFAULT TRUE,
  sla_hours INTEGER DEFAULT 48,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Issues table
CREATE TABLE IF NOT EXISTS issues (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status issue_status NOT NULL DEFAULT 'submitted',
  priority issue_priority NOT NULL DEFAULT 'medium',
  category_id UUID REFERENCES categories(id),
  location POINT,
  address TEXT,
  image_url TEXT,
  created_by UUID NOT NULL REFERENCES users(id),
  assigned_to UUID REFERENCES users(id),
  department_id UUID REFERENCES departments(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  resolved_at TIMESTAMP WITH TIME ZONE
);

-- Tickets table
CREATE TABLE IF NOT EXISTS tickets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_number TEXT UNIQUE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status ticket_status NOT NULL DEFAULT 'open',
  priority ticket_priority NOT NULL DEFAULT 'medium',
  ticket_type ticket_type NOT NULL DEFAULT 'complaint',
  category_id UUID REFERENCES ticket_categories(id),
  sub_category TEXT,
  user_id UUID NOT NULL REFERENCES users(id),
  assigned_to UUID REFERENCES users(id),
  department_id UUID REFERENCES departments(id),
  location_address TEXT,
  district TEXT,
  state TEXT,
  pin_code TEXT,
  latitude FLOAT,
  longitude FLOAT,
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
  closed_at TIMESTAMP WITH TIME ZONE
);

-- Comments table
CREATE TABLE IF NOT EXISTS comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  message TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ticket comments table
CREATE TABLE IF NOT EXISTS ticket_comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  content TEXT NOT NULL,
  comment_type TEXT DEFAULT 'public',
  is_official_response BOOLEAN DEFAULT FALSE,
  department_id UUID REFERENCES departments(id),
  user_name TEXT,
  user_role TEXT,
  user_designation TEXT,
  attachments JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Issue history table
CREATE TABLE IF NOT EXISTS issue_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
  status issue_status NOT NULL,
  updated_by UUID REFERENCES users(id),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ticket history table
CREATE TABLE IF NOT EXISTS ticket_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  action_type TEXT NOT NULL,
  old_value TEXT,
  new_value TEXT,
  changed_by UUID REFERENCES users(id),
  department_id UUID REFERENCES departments(id),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ticket attachments table
CREATE TABLE IF NOT EXISTS ticket_attachments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_type TEXT,
  file_size INTEGER,
  file_url TEXT NOT NULL,
  uploaded_by UUID REFERENCES users(id),
  is_public BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Escalation matrix table
CREATE TABLE IF NOT EXISTS escalation_matrix (
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

-- SLA tracking table
CREATE TABLE IF NOT EXISTS sla_tracking (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  target_resolution_time TIMESTAMP WITH TIME ZONE NOT NULL,
  actual_resolution_time TIMESTAMP WITH TIME ZONE,
  sla_breached BOOLEAN DEFAULT FALSE,
  breach_reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  related_to UUID,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Feedback table
CREATE TABLE IF NOT EXISTS feedback (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
  ticket_id UUID REFERENCES tickets(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Analytics table (for aggregated data)
CREATE TABLE IF NOT EXISTS analytics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  date DATE NOT NULL,
  department_id UUID REFERENCES departments(id),
  category_id UUID REFERENCES categories(id),
  total_issues INTEGER NOT NULL DEFAULT 0,
  resolved_issues INTEGER NOT NULL DEFAULT 0,
  avg_resolution_time INTERVAL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Settings table
CREATE TABLE IF NOT EXISTS settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key TEXT NOT NULL UNIQUE,
  value JSONB NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS issues_status_idx ON issues(status);
CREATE INDEX IF NOT EXISTS issues_department_idx ON issues(department_id);
CREATE INDEX IF NOT EXISTS issues_created_by_idx ON issues(created_by);
CREATE INDEX IF NOT EXISTS issues_assigned_to_idx ON issues(assigned_to);
CREATE INDEX IF NOT EXISTS comments_issue_id_idx ON comments(issue_id);
CREATE INDEX IF NOT EXISTS notifications_user_id_idx ON notifications(user_id);
CREATE INDEX IF NOT EXISTS notifications_read_idx ON notifications(is_read);
CREATE INDEX IF NOT EXISTS tickets_status_idx ON tickets(status);
CREATE INDEX IF NOT EXISTS tickets_department_idx ON tickets(department_id);
CREATE INDEX IF NOT EXISTS tickets_user_id_idx ON tickets(user_id);
CREATE INDEX IF NOT EXISTS tickets_assigned_to_idx ON tickets(assigned_to);
CREATE INDEX IF NOT EXISTS ticket_comments_ticket_id_idx ON ticket_comments(ticket_id);
CREATE INDEX IF NOT EXISTS ticket_history_ticket_id_idx ON ticket_history(ticket_id);
CREATE INDEX IF NOT EXISTS sla_tracking_ticket_id_idx ON sla_tracking(ticket_id);
CREATE INDEX IF NOT EXISTS sla_tracking_breached_idx ON sla_tracking(sla_breached);

-- Create a function to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to update updated_at column
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_users_updated_at') THEN
    CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_departments_updated_at') THEN
    CREATE TRIGGER update_departments_updated_at
    BEFORE UPDATE ON departments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_categories_updated_at') THEN
    CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_issues_updated_at') THEN
    CREATE TRIGGER update_issues_updated_at
    BEFORE UPDATE ON issues
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_tickets_updated_at') THEN
    CREATE TRIGGER update_tickets_updated_at
    BEFORE UPDATE ON tickets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_ticket_comments_updated_at') THEN
    CREATE TRIGGER update_ticket_comments_updated_at
    BEFORE UPDATE ON ticket_comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_sla_tracking_updated_at') THEN
    CREATE TRIGGER update_sla_tracking_updated_at
    BEFORE UPDATE ON sla_tracking
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_analytics_updated_at') THEN
    CREATE TRIGGER update_analytics_updated_at
    BEFORE UPDATE ON analytics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_settings_updated_at') THEN
    CREATE TRIGGER update_settings_updated_at
    BEFORE UPDATE ON settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END
$$;

-- Create a function to track issue history
CREATE OR REPLACE FUNCTION track_issue_status_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO issue_history (issue_id, status, updated_by, comment)
    VALUES (NEW.id, NEW.status, NEW.assigned_to, 'Status updated to ' || NEW.status);
  END IF;
  
  IF NEW.status = 'resolved' AND OLD.status != 'resolved' THEN
    NEW.resolved_at = NOW();
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to track issue history
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'track_issue_status_change') THEN
    CREATE TRIGGER track_issue_status_change
    BEFORE UPDATE ON issues
    FOR EACH ROW EXECUTE FUNCTION track_issue_status_change();
  END IF;
END
$$;

-- Create a function to track ticket status changes
CREATE OR REPLACE FUNCTION track_ticket_status_change()
RETURNS TRIGGER AS $$
DECLARE
  category_sla_hours INTEGER;
  dept_name TEXT;
BEGIN
  -- Track status changes in history
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    -- Get department name
    SELECT name INTO dept_name FROM departments WHERE id = NEW.department_id;
    
    -- Record history
    INSERT INTO ticket_history (
      ticket_id, action_type, old_value, new_value, 
      changed_by, department_id, notes
    )
    VALUES (
      NEW.id, 'status_change', OLD.status, NEW.status,
      NEW.assigned_to, NEW.department_id, 
      'Status updated from ' || OLD.status || ' to ' || NEW.status
    );
    
    -- Add system comment
    INSERT INTO ticket_comments (
      ticket_id, user_id, content, comment_type, is_official_response,
      department_id, user_name, user_role
    )
    VALUES (
      NEW.id, 
      COALESCE(NEW.assigned_to, NEW.user_id), 
      'Ticket status changed from ' || OLD.status || ' to ' || NEW.status,
      'system', TRUE,
      NEW.department_id,
      COALESCE(dept_name, 'System'),
      'system'
    );
    
    -- Set resolved_at timestamp if status is now 'resolved'
    IF NEW.status = 'resolved' AND OLD.status != 'resolved' THEN
      NEW.resolved_at = NOW();
    END IF;
    
    -- Set closed_at timestamp if status is now 'closed'
    IF NEW.status = 'closed' AND OLD.status != 'closed' THEN
      NEW.closed_at = NOW();
    END IF;
  END IF;
  
  -- Track assignment changes
  IF OLD.assigned_to IS DISTINCT FROM NEW.assigned_to THEN
    INSERT INTO ticket_history (
      ticket_id, action_type, old_value, new_value, 
      changed_by, department_id, notes
    )
    VALUES (
      NEW.id, 'assignment_change', 
      COALESCE(OLD.assigned_to::text, 'unassigned'), 
      COALESCE(NEW.assigned_to::text, 'unassigned'),
      NEW.assigned_to, NEW.department_id, 
      'Ticket assignment updated'
    );
  END IF;
  
  -- Track department changes
  IF OLD.department_id IS DISTINCT FROM NEW.department_id THEN
    INSERT INTO ticket_history (
      ticket_id, action_type, old_value, new_value, 
      changed_by, department_id, notes
    )
    VALUES (
      NEW.id, 'department_change', 
      COALESCE(OLD.department_id::text, 'none'), 
      COALESCE(NEW.department_id::text, 'none'),
      NEW.assigned_to, NEW.department_id, 
      'Ticket department updated'
    );
  END IF;
  
  -- Create or update SLA tracking
  IF TG_OP = 'INSERT' OR OLD.category_id IS DISTINCT FROM NEW.category_id THEN
    -- Get SLA hours from category
    SELECT sla_hours INTO category_sla_hours 
    FROM ticket_categories 
    WHERE id = NEW.category_id;
    
    -- Set default SLA hours if not found
    IF category_sla_hours IS NULL THEN
      category_sla_hours := 48;
    END IF;
    
    -- Calculate due date
    NEW.due_date := NEW.created_at + (category_sla_hours * INTERVAL '1 hour');
    
    -- Create SLA tracking record
    INSERT INTO sla_tracking (
      ticket_id, 
      target_resolution_time,
      created_at
    )
    VALUES (
      NEW.id,
      NEW.due_date,
      NOW()
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to track ticket status changes
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'track_ticket_status_change') THEN
    CREATE TRIGGER track_ticket_status_change
    BEFORE INSERT OR UPDATE ON tickets
    FOR EACH ROW EXECUTE FUNCTION track_ticket_status_change();
  END IF;
END
$$;

-- Enable Row Level Security
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE issue_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE escalation_matrix ENABLE ROW LEVEL SECURITY;
ALTER TABLE sla_tracking ENABLE ROW LEVEL SECURITY;

-- Create policies (for development, allow all operations)
-- These should be replaced with proper policies in production
CREATE POLICY departments_allow_all ON departments FOR ALL USING (true);
CREATE POLICY users_allow_all ON users FOR ALL USING (true);
CREATE POLICY categories_allow_all ON categories FOR ALL USING (true);
CREATE POLICY issues_allow_all ON issues FOR ALL USING (true);
CREATE POLICY comments_allow_all ON comments FOR ALL USING (true);
CREATE POLICY issue_history_allow_all ON issue_history FOR ALL USING (true);
CREATE POLICY notifications_allow_all ON notifications FOR ALL USING (true);
CREATE POLICY feedback_allow_all ON feedback FOR ALL USING (true);
CREATE POLICY analytics_allow_all ON analytics FOR ALL USING (true);
CREATE POLICY settings_allow_all ON settings FOR ALL USING (true);
CREATE POLICY tickets_allow_all ON tickets FOR ALL USING (true);
CREATE POLICY ticket_comments_allow_all ON ticket_comments FOR ALL USING (true);
CREATE POLICY ticket_history_allow_all ON ticket_history FOR ALL USING (true);
CREATE POLICY ticket_attachments_allow_all ON ticket_attachments FOR ALL USING (true);
CREATE POLICY ticket_categories_allow_all ON ticket_categories FOR ALL USING (true);
CREATE POLICY escalation_matrix_allow_all ON escalation_matrix FOR ALL USING (true);
CREATE POLICY sla_tracking_allow_all ON sla_tracking FOR ALL USING (true);
