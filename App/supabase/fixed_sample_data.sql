-- Sample data for government ticketing system

-- Insert sample departments if they don't exist
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

-- Insert sample ticket categories
INSERT INTO ticket_categories (name, description, department_id, sla_hours)
SELECT 'Road Maintenance', 'Issues related to road conditions and maintenance', 
       (SELECT id FROM departments WHERE department_code = 'PWD'), 72
WHERE NOT EXISTS (SELECT 1 FROM ticket_categories WHERE name = 'Road Maintenance');

INSERT INTO ticket_categories (name, description, department_id, sla_hours)
SELECT 'Water Supply Issues', 'Problems with water supply or quality', 
       (SELECT id FROM departments WHERE department_code = 'WSD'), 24
WHERE NOT EXISTS (SELECT 1 FROM ticket_categories WHERE name = 'Water Supply Issues');

INSERT INTO ticket_categories (name, description, department_id, sla_hours)
SELECT 'Power Outages', 'Electricity supply interruptions', 
       (SELECT id FROM departments WHERE department_code = 'ELECT'), 12
WHERE NOT EXISTS (SELECT 1 FROM ticket_categories WHERE name = 'Power Outages');

INSERT INTO ticket_categories (name, description, department_id, sla_hours)
SELECT 'Waste Collection', 'Issues with garbage collection and disposal', 
       (SELECT id FROM departments WHERE department_code = 'SAN'), 48
WHERE NOT EXISTS (SELECT 1 FROM ticket_categories WHERE name = 'Waste Collection');

INSERT INTO ticket_categories (name, description, department_id, sla_hours)
SELECT 'Public Health Concerns', 'Health hazards and sanitation issues', 
       (SELECT id FROM departments WHERE department_code = 'HLTH'), 36
WHERE NOT EXISTS (SELECT 1 FROM ticket_categories WHERE name = 'Public Health Concerns');

-- Insert sample users if they don't exist
-- Citizen user
INSERT INTO users (id, email, name, phone, user_type, district, state, pin_code)
SELECT 
  '00000000-0000-0000-0000-000000000001', 
  'citizen@example.com', 
  'John Citizen', 
  '9876543210', 
  'citizen',
  'Central District',
  'State',
  '110001'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE id = '00000000-0000-0000-0000-000000000001');

-- Staff user
INSERT INTO users (id, email, name, phone, user_type, department_id, employee_id, designation, role)
SELECT 
  '00000000-0000-0000-0000-000000000002', 
  'staff@example.com', 
  'Jane Staff', 
  '8765432109', 
  'staff',
  (SELECT id FROM departments WHERE department_code = 'PWD'),
  'EMP001',
  'Officer',
  'support_staff'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE id = '00000000-0000-0000-0000-000000000002');

-- Admin user
INSERT INTO users (id, email, name, phone, user_type, department_id, employee_id, designation, role)
SELECT 
  '00000000-0000-0000-0000-000000000003', 
  'admin@example.com', 
  'Admin User', 
  '7654321098', 
  'admin',
  (SELECT id FROM departments WHERE department_code = 'PWD'),
  'EMP002',
  'Administrator',
  'admin'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE id = '00000000-0000-0000-0000-000000000003');

-- Insert sample tickets
-- Ticket 1
INSERT INTO tickets (
  ticket_number, title, description, status, priority, ticket_type,
  category_id, user_id, department_id, location_address, district, state, pin_code,
  latitude, longitude, ward_number
)
SELECT
  'PWD-2023-001',
  'Pothole on Main Street',
  'Large pothole causing traffic issues and damage to vehicles',
  'open',
  'high',
  'complaint',
  (SELECT id FROM ticket_categories WHERE name = 'Road Maintenance'),
  '00000000-0000-0000-0000-000000000001',
  (SELECT id FROM departments WHERE department_code = 'PWD'),
  '123 Main Street',
  'Central District',
  'State',
  '110001',
  28.6139,
  77.2090,
  'Ward-5'
WHERE NOT EXISTS (SELECT 1 FROM tickets WHERE ticket_number = 'PWD-2023-001');

-- Ticket 2
INSERT INTO tickets (
  ticket_number, title, description, status, priority, ticket_type,
  category_id, user_id, department_id, location_address, district, state, pin_code,
  latitude, longitude, ward_number
)
SELECT
  'WSD-2023-001',
  'No water supply for 2 days',
  'Our area has not received water supply for the past 2 days',
  'in_progress',
  'urgent',
  'complaint',
  (SELECT id FROM ticket_categories WHERE name = 'Water Supply Issues'),
  '00000000-0000-0000-0000-000000000001',
  (SELECT id FROM departments WHERE department_code = 'WSD'),
  '456 Park Avenue',
  'East District',
  'State',
  '110002',
  28.6292,
  77.2183,
  'Ward-8'
WHERE NOT EXISTS (SELECT 1 FROM tickets WHERE ticket_number = 'WSD-2023-001');

-- Ticket 3
INSERT INTO tickets (
  ticket_number, title, description, status, priority, ticket_type,
  category_id, user_id, department_id, location_address, district, state, pin_code,
  latitude, longitude, ward_number
)
SELECT
  'ELECT-2023-001',
  'Frequent power cuts in residential area',
  'We are experiencing power cuts multiple times a day for the past week',
  'open',
  'medium',
  'complaint',
  (SELECT id FROM ticket_categories WHERE name = 'Power Outages'),
  '00000000-0000-0000-0000-000000000001',
  (SELECT id FROM departments WHERE department_code = 'ELECT'),
  '789 Lake View',
  'West District',
  'State',
  '110003',
  28.6129,
  77.2295,
  'Ward-12'
WHERE NOT EXISTS (SELECT 1 FROM tickets WHERE ticket_number = 'ELECT-2023-001');

-- Ticket 4
INSERT INTO tickets (
  ticket_number, title, description, status, priority, ticket_type,
  category_id, user_id, department_id, location_address, district, state, pin_code,
  latitude, longitude, ward_number
)
SELECT
  'SAN-2023-001',
  'Garbage not collected for a week',
  'The garbage collection service has not visited our area for a week causing sanitation issues',
  'pending',
  'high',
  'complaint',
  (SELECT id FROM ticket_categories WHERE name = 'Waste Collection'),
  '00000000-0000-0000-0000-000000000001',
  (SELECT id FROM departments WHERE department_code = 'SAN'),
  '101 Green Park',
  'South District',
  'State',
  '110004',
  28.5621,
  77.2410,
  'Ward-15'
WHERE NOT EXISTS (SELECT 1 FROM tickets WHERE ticket_number = 'SAN-2023-001');

-- Ticket 5
INSERT INTO tickets (
  ticket_number, title, description, status, priority, ticket_type,
  category_id, user_id, department_id, location_address, district, state, pin_code,
  latitude, longitude, ward_number
)
SELECT
  'HLTH-2023-001',
  'Stagnant water causing mosquito breeding',
  'There is stagnant water in our area which is causing mosquito breeding and health concerns',
  'open',
  'critical',
  'complaint',
  (SELECT id FROM ticket_categories WHERE name = 'Public Health Concerns'),
  '00000000-0000-0000-0000-000000000001',
  (SELECT id FROM departments WHERE department_code = 'HLTH'),
  '202 River Road',
  'North District',
  'State',
  '110005',
  28.7041,
  77.1025,
  'Ward-20'
WHERE NOT EXISTS (SELECT 1 FROM tickets WHERE ticket_number = 'HLTH-2023-001');

-- Insert sample comments for the first ticket
INSERT INTO ticket_comments (
  ticket_id, user_id, content, user_name, user_role, created_at
)
SELECT
  (SELECT id FROM tickets WHERE ticket_number = 'PWD-2023-001'),
  '00000000-0000-0000-0000-000000000001',
  'The pothole is getting worse with the recent rain. Please fix it urgently.',
  'John Citizen',
  'citizen',
  NOW() - INTERVAL '2 days'
WHERE EXISTS (SELECT 1 FROM tickets WHERE ticket_number = 'PWD-2023-001')
AND NOT EXISTS (
  SELECT 1 FROM ticket_comments 
  WHERE ticket_id = (SELECT id FROM tickets WHERE ticket_number = 'PWD-2023-001')
  AND user_id = '00000000-0000-0000-0000-000000000001'
  AND content = 'The pothole is getting worse with the recent rain. Please fix it urgently.'
);

-- Official response from staff
INSERT INTO ticket_comments (
  ticket_id, user_id, content, comment_type, is_official_response,
  department_id, user_name, user_role, user_designation, created_at
)
SELECT
  (SELECT id FROM tickets WHERE ticket_number = 'PWD-2023-001'),
  '00000000-0000-0000-0000-000000000002',
  'We have scheduled a repair team to fix the pothole within the next 48 hours.',
  'public',
  TRUE,
  (SELECT id FROM departments WHERE department_code = 'PWD'),
  'Jane Staff',
  'staff',
  'Officer',
  NOW() - INTERVAL '1 day'
WHERE EXISTS (SELECT 1 FROM tickets WHERE ticket_number = 'PWD-2023-001')
AND NOT EXISTS (
  SELECT 1 FROM ticket_comments 
  WHERE ticket_id = (SELECT id FROM tickets WHERE ticket_number = 'PWD-2023-001')
  AND user_id = '00000000-0000-0000-0000-000000000002'
  AND content = 'We have scheduled a repair team to fix the pothole within the next 48 hours.'
);

-- Internal note from staff
INSERT INTO ticket_comments (
  ticket_id, user_id, content, comment_type, is_official_response,
  department_id, user_name, user_role, user_designation, created_at
)
SELECT
  (SELECT id FROM tickets WHERE ticket_number = 'PWD-2023-001'),
  '00000000-0000-0000-0000-000000000002',
  'Repair materials need to be ordered. Might take longer than initially estimated.',
  'internal',
  TRUE,
  (SELECT id FROM departments WHERE department_code = 'PWD'),
  'Jane Staff',
  'staff',
  'Officer',
  NOW() - INTERVAL '12 hours'
WHERE EXISTS (SELECT 1 FROM tickets WHERE ticket_number = 'PWD-2023-001')
AND NOT EXISTS (
  SELECT 1 FROM ticket_comments 
  WHERE ticket_id = (SELECT id FROM tickets WHERE ticket_number = 'PWD-2023-001')
  AND user_id = '00000000-0000-0000-0000-000000000002'
  AND content = 'Repair materials need to be ordered. Might take longer than initially estimated.'
);

-- Insert sample comments for the second ticket
INSERT INTO ticket_comments (
  ticket_id, user_id, content, user_name, user_role, created_at
)
SELECT
  (SELECT id FROM tickets WHERE ticket_number = 'WSD-2023-001'),
  '00000000-0000-0000-0000-000000000001',
  'This is causing severe inconvenience. We need water urgently.',
  'John Citizen',
  'citizen',
  NOW() - INTERVAL '3 days'
WHERE EXISTS (SELECT 1 FROM tickets WHERE ticket_number = 'WSD-2023-001')
AND NOT EXISTS (
  SELECT 1 FROM ticket_comments 
  WHERE ticket_id = (SELECT id FROM tickets WHERE ticket_number = 'WSD-2023-001')
  AND user_id = '00000000-0000-0000-0000-000000000001'
  AND content = 'This is causing severe inconvenience. We need water urgently.'
);

-- Insert sample escalation matrix entries
INSERT INTO escalation_matrix (
  department_id, category_id, level, escalation_hours, escalate_to_role, notification_emails
)
SELECT
  (SELECT id FROM departments WHERE department_code = 'PWD'),
  (SELECT id FROM ticket_categories WHERE name = 'Road Maintenance'),
  1,
  24,
  'supervisor',
  ARRAY['supervisor@example.com']
WHERE NOT EXISTS (
  SELECT 1 FROM escalation_matrix 
  WHERE department_id = (SELECT id FROM departments WHERE department_code = 'PWD')
  AND category_id = (SELECT id FROM ticket_categories WHERE name = 'Road Maintenance')
  AND level = 1
);

INSERT INTO escalation_matrix (
  department_id, category_id, level, escalation_hours, escalate_to_role, notification_emails
)
SELECT
  (SELECT id FROM departments WHERE department_code = 'PWD'),
  (SELECT id FROM ticket_categories WHERE name = 'Road Maintenance'),
  2,
  48,
  'manager',
  ARRAY['manager@example.com']
WHERE NOT EXISTS (
  SELECT 1 FROM escalation_matrix 
  WHERE department_id = (SELECT id FROM departments WHERE department_code = 'PWD')
  AND category_id = (SELECT id FROM ticket_categories WHERE name = 'Road Maintenance')
  AND level = 2
);

INSERT INTO escalation_matrix (
  department_id, category_id, level, escalation_hours, escalate_to_role, notification_emails
)
SELECT
  (SELECT id FROM departments WHERE department_code = 'PWD'),
  (SELECT id FROM ticket_categories WHERE name = 'Road Maintenance'),
  3,
  72,
  'director',
  ARRAY['director@example.com']
WHERE NOT EXISTS (
  SELECT 1 FROM escalation_matrix 
  WHERE department_id = (SELECT id FROM departments WHERE department_code = 'PWD')
  AND category_id = (SELECT id FROM ticket_categories WHERE name = 'Road Maintenance')
  AND level = 3
);
