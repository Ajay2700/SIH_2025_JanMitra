-- Sample data for issues table

-- Insert sample users if they don't exist
INSERT INTO users (id, email, name, user_type, district, state, pin_code)
SELECT '00000000-0000-0000-0000-000000000001', 'citizen@example.com', 'John Citizen', 'citizen', 'Central District', 'State', '110001'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE id = '00000000-0000-0000-0000-000000000001');

INSERT INTO users (id, email, name, user_type, district, state, pin_code)
SELECT '00000000-0000-0000-0000-000000000002', 'citizen2@example.com', 'Jane Citizen', 'citizen', 'North District', 'State', '110002'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE id = '00000000-0000-0000-0000-000000000002');

-- Insert sample departments
INSERT INTO departments (name, description, department_code, jurisdiction)
SELECT 'Public Works', 'Responsible for infrastructure and public facilities', 'PWD', 'State'
WHERE NOT EXISTS (SELECT 1 FROM departments WHERE department_code = 'PWD');

INSERT INTO departments (name, description, department_code, jurisdiction)
SELECT 'Sanitation', 'Responsible for waste management and cleanliness', 'SAN', 'Municipal'
WHERE NOT EXISTS (SELECT 1 FROM departments WHERE department_code = 'SAN');

-- Insert sample categories
INSERT INTO categories (name, description, department_id)
SELECT 'Road Maintenance', 'Issues related to road conditions', (SELECT id FROM departments WHERE department_code = 'PWD')
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Road Maintenance');

INSERT INTO categories (name, description, department_id)
SELECT 'Waste Collection', 'Issues with garbage collection', (SELECT id FROM departments WHERE department_code = 'SAN')
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Waste Collection');

-- Insert sample issues
INSERT INTO issues (title, description, status, priority, location, address, created_by, department_id, category_id)
SELECT
  'Pothole on Main Street',
  'Large pothole causing traffic issues and damage to vehicles',
  'submitted',
  'high',
  'POINT(77.2090 28.6139)',
  '123 Main Street, Central District',
  '00000000-0000-0000-0000-000000000001',
  (SELECT id FROM departments WHERE department_code = 'PWD'),
  (SELECT id FROM categories WHERE name = 'Road Maintenance')
WHERE NOT EXISTS (SELECT 1 FROM issues WHERE title = 'Pothole on Main Street');

INSERT INTO issues (title, description, status, priority, location, address, created_by, department_id, category_id)
SELECT
  'Garbage not collected',
  'Garbage has not been collected for 3 days in our area',
  'acknowledged',
  'medium',
  'POINT(77.2183 28.6292)',
  '456 Park Avenue, North District',
  '00000000-0000-0000-0000-000000000002',
  (SELECT id FROM departments WHERE department_code = 'SAN'),
  (SELECT id FROM categories WHERE name = 'Waste Collection')
WHERE NOT EXISTS (SELECT 1 FROM issues WHERE title = 'Garbage not collected');

INSERT INTO issues (title, description, status, priority, location, address, created_by, department_id, category_id)
SELECT
  'Street light not working',
  'Street light has been out for a week, safety concern at night',
  'in_progress',
  'medium',
  'POINT(77.2295 28.6129)',
  '789 Lake Road, West District',
  '00000000-0000-0000-0000-000000000001',
  (SELECT id FROM departments WHERE department_code = 'PWD'),
  (SELECT id FROM categories WHERE name = 'Road Maintenance')
WHERE NOT EXISTS (SELECT 1 FROM issues WHERE title = 'Street light not working');