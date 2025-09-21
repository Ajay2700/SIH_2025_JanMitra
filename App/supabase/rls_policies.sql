-- Row Level Security (RLS) Policies for Jan Mitra

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE issue_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
-- Users can read their own profile
CREATE POLICY users_read_own ON users
  FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY users_update_own ON users
  FOR UPDATE
  USING (auth.uid() = id);

-- Admins can read all users
CREATE POLICY users_read_admin ON users
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.user_type = 'admin'
    )
  );

-- Admins can update all users
CREATE POLICY users_update_admin ON users
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.user_type = 'admin'
    )
  );

-- Staff can read all users
CREATE POLICY users_read_staff ON users
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.user_type = 'staff'
    )
  );

-- Create policies for departments table
-- Anyone can read departments
CREATE POLICY departments_read_all ON departments
  FOR SELECT
  USING (true);

-- Only admins can create, update, or delete departments
CREATE POLICY departments_write_admin ON departments
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.user_type = 'admin'
    )
  );

-- Create policies for categories table
-- Anyone can read categories
CREATE POLICY categories_read_all ON categories
  FOR SELECT
  USING (true);

-- Only admins can create, update, or delete categories
CREATE POLICY categories_write_admin ON categories
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.user_type = 'admin'
    )
  );

-- Create policies for issues table
-- Citizens can create issues
CREATE POLICY issues_insert_citizen ON issues
  FOR INSERT
  WITH CHECK (
    auth.uid() = created_by AND
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.user_type = 'citizen'
    )
  );

-- Citizens can read their own issues
CREATE POLICY issues_read_own ON issues
  FOR SELECT
  USING (
    created_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND (users.user_type = 'staff' OR users.user_type = 'admin')
    )
  );

-- Citizens can update their own issues only if status is 'submitted'
CREATE POLICY issues_update_own ON issues
  FOR UPDATE
  USING (
    created_by = auth.uid() AND status = 'submitted' AND
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.user_type = 'citizen'
    )
  );

-- Citizens can delete their own issues only if status is 'submitted'
CREATE POLICY issues_delete_own ON issues
  FOR DELETE
  USING (
    created_by = auth.uid() AND status = 'submitted' AND
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.user_type = 'citizen'
    )
  );

-- Staff can read all issues
CREATE POLICY issues_read_staff ON issues
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND (users.user_type = 'staff' OR users.user_type = 'admin')
    )
  );

-- Staff can update issues assigned to them or their department
CREATE POLICY issues_update_staff ON issues
  FOR UPDATE
  USING (
    (assigned_to = auth.uid() OR
    department_id = (SELECT department_id FROM users WHERE id = auth.uid())) AND
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.user_type = 'staff'
    )
  );

-- Admins can do anything with issues
CREATE POLICY issues_admin_all ON issues
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.user_type = 'admin'
    )
  );

-- Create policies for comments table
-- Anyone can read comments
CREATE POLICY comments_read_all ON comments
  FOR SELECT
  USING (true);

-- Users can create comments on issues they can see
CREATE POLICY comments_insert ON comments
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (
      SELECT 1 FROM issues
      WHERE issues.id = issue_id AND (
        issues.created_by = auth.uid() OR
        issues.assigned_to = auth.uid() OR
        EXISTS (
          SELECT 1 FROM users
          WHERE users.id = auth.uid() AND (users.user_type = 'staff' OR users.user_type = 'admin')
        )
      )
    )
  );

-- Users can update their own comments
CREATE POLICY comments_update_own ON comments
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can delete their own comments
CREATE POLICY comments_delete_own ON comments
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create policies for issue_history table
-- Anyone can read issue history
CREATE POLICY issue_history_read_all ON issue_history
  FOR SELECT
  USING (true);

-- Only system can write to issue history (via triggers)
-- This table is managed by triggers, not direct user input

-- Create policies for notifications table
-- Users can read their own notifications
CREATE POLICY notifications_read_own ON notifications
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can update their own notifications (mark as read)
CREATE POLICY notifications_update_own ON notifications
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Create policies for feedback table
-- Citizens can create feedback for their own issues
CREATE POLICY feedback_insert_own ON feedback
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (
      SELECT 1 FROM issues
      WHERE issues.id = issue_id AND issues.created_by = auth.uid() AND issues.status = 'resolved'
    )
  );

-- Citizens can read their own feedback
CREATE POLICY feedback_read_own ON feedback
  FOR SELECT
  USING (auth.uid() = user_id);

-- Staff and admins can read all feedback
CREATE POLICY feedback_read_staff ON feedback
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND (users.user_type = 'staff' OR users.user_type = 'admin')
    )
  );

-- Create policies for analytics table
-- Only admins and staff can read analytics
CREATE POLICY analytics_read_staff ON analytics
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND (users.user_type = 'staff' OR users.user_type = 'admin')
    )
  );

-- Only admins can write to analytics
CREATE POLICY analytics_write_admin ON analytics
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.user_type = 'admin'
    )
  );

-- Create policies for settings table
-- Only admins can read and write settings
CREATE POLICY settings_admin_all ON settings
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.user_type = 'admin'
    )
  );
