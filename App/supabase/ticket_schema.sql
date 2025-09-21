-- Create schema for Ticketing System

-- Create enum types for ticket status and priority
CREATE TYPE ticket_status AS ENUM ('open', 'in_progress', 'pending', 'resolved', 'closed', 'rejected', 'escalated', 'forwarded');
CREATE TYPE ticket_priority AS ENUM ('low', 'medium', 'high', 'urgent', 'critical');

-- Create enum for ticket type (government specific)
CREATE TYPE ticket_type AS ENUM ('complaint', 'suggestion', 'inquiry', 'service_request', 'feedback', 'grievance');

-- Check if departments table exists, if not create a government-specific version
DO $$
BEGIN
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
END
$$;

-- Check if users table exists, if not create a government-specific version
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'users') THEN
        CREATE TABLE users (
          id UUID PRIMARY KEY REFERENCES auth.users(id),
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
END
$$;

-- Ticket categories table (government specific)
CREATE TABLE ticket_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  department_id UUID REFERENCES departments(id),
  parent_category_id UUID REFERENCES ticket_categories(id),
  is_active BOOLEAN DEFAULT TRUE,
  sla_hours INTEGER, -- Service Level Agreement in hours
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

-- Tickets table (government specific)
CREATE TABLE tickets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_number TEXT UNIQUE, -- Government reference number
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status ticket_status NOT NULL DEFAULT 'open',
  priority ticket_priority NOT NULL DEFAULT 'medium',
  ticket_type ticket_type NOT NULL DEFAULT 'complaint',
  user_id UUID NOT NULL REFERENCES auth.users(id),
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

-- Ticket Comments table (government specific)
CREATE TABLE ticket_comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  content TEXT NOT NULL,
  comment_type TEXT DEFAULT 'public', -- public, internal, status_update, etc.
  is_official_response BOOLEAN DEFAULT FALSE,
  department_id UUID REFERENCES departments(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_role TEXT,
  user_name TEXT,
  user_designation TEXT,
  attachments TEXT[]
);

-- Ticket History table (for audit trail)
CREATE TABLE ticket_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  action_type TEXT NOT NULL, -- created, updated, status_changed, assigned, escalated, etc.
  old_value JSONB,
  new_value JSONB,
  changed_by UUID REFERENCES auth.users(id),
  department_id UUID REFERENCES departments(id),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ticket Attachments table
CREATE TABLE ticket_attachments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  comment_id UUID REFERENCES ticket_comments(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  file_url TEXT NOT NULL,
  uploaded_by UUID REFERENCES auth.users(id),
  is_public BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ticket Escalation Matrix
CREATE TABLE escalation_matrix (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  department_id UUID NOT NULL REFERENCES departments(id),
  category_id UUID REFERENCES ticket_categories(id),
  level INTEGER NOT NULL,
  escalation_hours INTEGER NOT NULL, -- Hours after which to escalate
  escalate_to UUID REFERENCES users(id),
  escalate_to_role TEXT,
  notification_emails TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- SLA (Service Level Agreement) Tracking
CREATE TABLE sla_tracking (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  target_resolution_time TIMESTAMP WITH TIME ZONE NOT NULL,
  actual_resolution_time TIMESTAMP WITH TIME ZONE,
  sla_breached BOOLEAN DEFAULT FALSE,
  breach_reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for government ticketing system
CREATE INDEX tickets_status_idx ON tickets(status);
CREATE INDEX tickets_user_id_idx ON tickets(user_id);
CREATE INDEX tickets_assigned_to_idx ON tickets(assigned_to);
CREATE INDEX tickets_department_id_idx ON tickets(department_id);
CREATE INDEX tickets_category_id_idx ON tickets(category_id);
CREATE INDEX tickets_district_idx ON tickets(district);
CREATE INDEX tickets_ticket_number_idx ON tickets(ticket_number);
CREATE INDEX tickets_ticket_type_idx ON tickets(ticket_type);
CREATE INDEX tickets_due_date_idx ON tickets(due_date);
CREATE INDEX tickets_escalation_level_idx ON tickets(escalation_level);

CREATE INDEX ticket_comments_ticket_id_idx ON ticket_comments(ticket_id);
CREATE INDEX ticket_comments_user_id_idx ON ticket_comments(user_id);
CREATE INDEX ticket_comments_is_official_idx ON ticket_comments(is_official_response);

CREATE INDEX ticket_history_ticket_id_idx ON ticket_history(ticket_id);
CREATE INDEX ticket_history_action_type_idx ON ticket_history(action_type);

CREATE INDEX ticket_attachments_ticket_id_idx ON ticket_attachments(ticket_id);
CREATE INDEX ticket_attachments_comment_id_idx ON ticket_attachments(comment_id);

CREATE INDEX escalation_matrix_department_id_idx ON escalation_matrix(department_id);
CREATE INDEX escalation_matrix_category_id_idx ON escalation_matrix(category_id);

CREATE INDEX sla_tracking_ticket_id_idx ON sla_tracking(ticket_id);
CREATE INDEX sla_tracking_breached_idx ON sla_tracking(sla_breached);

-- Create a trigger to update updated_at column
CREATE TRIGGER update_tickets_updated_at
BEFORE UPDATE ON tickets
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create a function to track ticket status changes and maintain audit trail
CREATE OR REPLACE FUNCTION track_ticket_status_change()
RETURNS TRIGGER AS $$
DECLARE
    user_info RECORD;
    dept_id UUID;
    ticket_cat_id UUID;
    sla_hours INTEGER;
BEGIN
    -- Get user info
    SELECT user_type, name, department_id, designation INTO user_info 
    FROM users 
    WHERE id = COALESCE(NEW.assigned_to, NEW.user_id);
    
    -- Track status change in history table
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO ticket_history (
            ticket_id, 
            action_type, 
            old_value, 
            new_value, 
            changed_by,
            department_id,
            notes
        )
        VALUES (
            NEW.id, 
            'status_changed',
            jsonb_build_object('status', OLD.status),
            jsonb_build_object('status', NEW.status),
            COALESCE(NEW.assigned_to, NEW.user_id),
            user_info.department_id,
            'Status updated from ' || OLD.status || ' to ' || NEW.status
        );
        
        -- Add a system comment for the status change
        INSERT INTO ticket_comments (
            ticket_id, 
            user_id, 
            content, 
            comment_type,
            is_official_response,
            department_id,
            user_role, 
            user_name,
            user_designation
        )
        VALUES (
            NEW.id, 
            COALESCE(NEW.assigned_to, NEW.user_id), 
            'Status updated from ' || OLD.status || ' to ' || NEW.status,
            'status_update',
            TRUE,
            user_info.department_id,
            user_info.user_type,
            user_info.name,
            user_info.designation
        );
    END IF;
    
    -- Set timestamps based on status changes
    IF NEW.status = 'resolved' AND OLD.status != 'resolved' THEN
        NEW.resolved_at = NOW();
        
        -- Update SLA tracking
        UPDATE sla_tracking
        SET actual_resolution_time = NOW(),
            sla_breached = (NOW() > target_resolution_time),
            updated_at = NOW()
        WHERE ticket_id = NEW.id;
        
    ELSIF NEW.status = 'closed' AND OLD.status != 'closed' THEN
        NEW.closed_at = NOW();
    END IF;
    
    -- Handle assignment changes
    IF OLD.assigned_to IS DISTINCT FROM NEW.assigned_to THEN
        INSERT INTO ticket_history (
            ticket_id, 
            action_type, 
            old_value, 
            new_value, 
            changed_by,
            department_id,
            notes
        )
        VALUES (
            NEW.id, 
            'assignment_changed',
            jsonb_build_object('assigned_to', OLD.assigned_to),
            jsonb_build_object('assigned_to', NEW.assigned_to),
            COALESCE(NEW.assigned_to, NEW.user_id),
            user_info.department_id,
            'Ticket assignment updated'
        );
    END IF;
    
    -- Handle department changes (forwarding)
    IF OLD.department_id IS DISTINCT FROM NEW.department_id AND OLD.department_id IS NOT NULL THEN
        NEW.forwarded_from_dept_id = OLD.department_id;
        
        INSERT INTO ticket_history (
            ticket_id, 
            action_type, 
            old_value, 
            new_value, 
            changed_by,
            department_id,
            notes
        )
        VALUES (
            NEW.id, 
            'forwarded',
            jsonb_build_object('department_id', OLD.department_id),
            jsonb_build_object('department_id', NEW.department_id),
            COALESCE(NEW.assigned_to, NEW.user_id),
            NEW.department_id,
            COALESCE(NEW.forwarded_reason, 'Ticket forwarded to another department')
        );
    END IF;
    
    -- Create or update SLA tracking when a new ticket is created or category changes
    IF TG_OP = 'INSERT' OR OLD.category_id IS DISTINCT FROM NEW.category_id THEN
        -- Get SLA hours for the category
        SELECT sla_hours INTO sla_hours FROM ticket_categories WHERE id = NEW.category_id;
        
        IF sla_hours IS NOT NULL THEN
            -- Calculate target resolution time
            IF TG_OP = 'INSERT' THEN
                INSERT INTO sla_tracking (
                    ticket_id,
                    target_resolution_time,
                    created_at
                )
                VALUES (
                    NEW.id,
                    NEW.created_at + (sla_hours || ' hours')::interval,
                    NOW()
                );
            ELSE
                -- Update existing SLA tracking
                UPDATE sla_tracking
                SET target_resolution_time = NOW() + (sla_hours || ' hours')::interval,
                    updated_at = NOW()
                WHERE ticket_id = NEW.id;
            END IF;
            
            -- Set due date on ticket
            NEW.due_date = NEW.created_at + (sla_hours || ' hours')::interval;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to track ticket status changes
CREATE TRIGGER track_ticket_status_change
BEFORE UPDATE ON tickets
FOR EACH ROW EXECUTE FUNCTION track_ticket_status_change();

-- Enable RLS on all ticket tables
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE escalation_matrix ENABLE ROW LEVEL SECURITY;
ALTER TABLE sla_tracking ENABLE ROW LEVEL SECURITY;

-- For development/testing, create a policy that allows all operations for now
-- In production, you would replace these with proper policies
CREATE POLICY tickets_allow_all ON tickets
  FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE POLICY ticket_comments_allow_all ON ticket_comments
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Add policies for new tables
CREATE POLICY ticket_categories_allow_all ON ticket_categories
  FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE POLICY ticket_history_allow_all ON ticket_history
  FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE POLICY ticket_attachments_allow_all ON ticket_attachments
  FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE POLICY escalation_matrix_allow_all ON escalation_matrix
  FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE POLICY sla_tracking_allow_all ON sla_tracking
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- The commented policies below can be enabled in production
/*
-- Create policies for tickets table
-- Users can read their own tickets
CREATE POLICY tickets_read_own ON tickets
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can create tickets
CREATE POLICY tickets_insert_own ON tickets
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own tickets
CREATE POLICY tickets_update_own ON tickets
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Staff can read all tickets
CREATE POLICY tickets_read_staff ON tickets
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND (users.user_type = 'staff' OR users.user_type = 'admin')
    )
  );

-- Staff can update tickets assigned to them
CREATE POLICY tickets_update_staff ON tickets
  FOR UPDATE
  USING (
    assigned_to = auth.uid() OR
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.user_type = 'admin'
    )
  );

-- Create policies for ticket_comments table
-- Users can read comments on their tickets
CREATE POLICY ticket_comments_read_own ON ticket_comments
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM tickets
      WHERE tickets.id = ticket_id AND tickets.user_id = auth.uid()
    )
  );

-- Users can add comments to their tickets
CREATE POLICY ticket_comments_insert_own ON ticket_comments
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (
      SELECT 1 FROM tickets
      WHERE tickets.id = ticket_id AND tickets.user_id = auth.uid()
    )
  );

-- Staff can read all ticket comments
CREATE POLICY ticket_comments_read_staff ON ticket_comments
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND (users.user_type = 'staff' OR users.user_type = 'admin')
    )
  );

-- Staff can add comments to tickets assigned to them
CREATE POLICY ticket_comments_insert_staff ON ticket_comments
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (
      SELECT 1 FROM tickets
      WHERE tickets.id = ticket_id AND 
      (tickets.assigned_to = auth.uid() OR
       EXISTS (
         SELECT 1 FROM users
         WHERE users.id = auth.uid() AND users.user_type = 'admin'
       ))
    )
  );
*/
