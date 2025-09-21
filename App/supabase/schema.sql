-- Create schema for Jan Mitra - Civic Issue Reporting System

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enum types
CREATE TYPE user_type AS ENUM ('citizen', 'staff', 'admin');
CREATE TYPE issue_status AS ENUM ('submitted', 'acknowledged', 'in_progress', 'resolved', 'rejected');
CREATE TYPE issue_priority AS ENUM ('low', 'medium', 'high');

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  user_type user_type NOT NULL DEFAULT 'citizen',
  department_id UUID REFERENCES departments(id),
  profile_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Departments table
CREATE TABLE departments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  head_id UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Categories table
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  department_id UUID REFERENCES departments(id),
  icon TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Issues table
CREATE TABLE issues (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status issue_status NOT NULL DEFAULT 'submitted',
  priority issue_priority NOT NULL DEFAULT 'medium',
  category_id UUID REFERENCES categories(id),
  location GEOGRAPHY(POINT) NOT NULL,
  address TEXT,
  image_url TEXT NOT NULL,
  created_by UUID NOT NULL REFERENCES users(id),
  assigned_to UUID REFERENCES users(id),
  department_id UUID REFERENCES departments(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  resolved_at TIMESTAMP WITH TIME ZONE
);

-- Comments table
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  message TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Issue history table
CREATE TABLE issue_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
  status issue_status NOT NULL,
  updated_by UUID REFERENCES users(id),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notifications table
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  related_to UUID REFERENCES issues(id) ON DELETE CASCADE,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Feedback table
CREATE TABLE feedback (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Analytics table (for aggregated data)
CREATE TABLE analytics (
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
CREATE TABLE settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key TEXT NOT NULL UNIQUE,
  value JSONB NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX issues_status_idx ON issues(status);
CREATE INDEX issues_department_idx ON issues(department_id);
CREATE INDEX issues_created_by_idx ON issues(created_by);
CREATE INDEX issues_assigned_to_idx ON issues(assigned_to);
CREATE INDEX comments_issue_id_idx ON comments(issue_id);
CREATE INDEX notifications_user_id_idx ON notifications(user_id);
CREATE INDEX notifications_read_idx ON notifications(is_read);

-- Create a function to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to update updated_at column
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_departments_updated_at
BEFORE UPDATE ON departments
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at
BEFORE UPDATE ON categories
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_issues_updated_at
BEFORE UPDATE ON issues
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_analytics_updated_at
BEFORE UPDATE ON analytics
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_settings_updated_at
BEFORE UPDATE ON settings
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

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
CREATE TRIGGER track_issue_status_change
BEFORE UPDATE ON issues
FOR EACH ROW EXECUTE FUNCTION track_issue_status_change();

-- Create a function to create notification on issue status change
CREATE OR REPLACE FUNCTION create_notification_on_status_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Notify the issue creator about status change
  INSERT INTO notifications (user_id, title, message, related_to)
  VALUES (
    NEW.created_by, 
    'Issue Status Updated', 
    'Your issue "' || (SELECT title FROM issues WHERE id = NEW.issue_id) || '" has been updated to ' || NEW.status,
    NEW.issue_id
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to create notification on issue status change
CREATE TRIGGER create_notification_on_status_change
AFTER INSERT ON issue_history
FOR EACH ROW EXECUTE FUNCTION create_notification_on_status_change();

-- Create a function to create notification on new comment
CREATE OR REPLACE FUNCTION create_notification_on_new_comment()
RETURNS TRIGGER AS $$
DECLARE
  issue_title TEXT;
  issue_creator UUID;
  commenter_name TEXT;
BEGIN
  -- Get issue details
  SELECT title, created_by INTO issue_title, issue_creator
  FROM issues
  WHERE id = NEW.issue_id;
  
  -- Get commenter name
  SELECT name INTO commenter_name
  FROM users
  WHERE id = NEW.user_id;
  
  -- Notify the issue creator if the comment is from someone else
  IF issue_creator != NEW.user_id THEN
    INSERT INTO notifications (user_id, title, message, related_to)
    VALUES (
      issue_creator, 
      'New Comment on Your Issue', 
      commenter_name || ' commented on your issue "' || issue_title || '"',
      NEW.issue_id
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to create notification on new comment
CREATE TRIGGER create_notification_on_new_comment
AFTER INSERT ON comments
FOR EACH ROW EXECUTE FUNCTION create_notification_on_new_comment();
