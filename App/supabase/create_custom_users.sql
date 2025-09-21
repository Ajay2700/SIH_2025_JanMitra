-- Create Custom Users for Jan Mitra App
-- This script creates multiple users with different roles and profiles

-- First, create users in auth.users (this would normally be done through signup)
-- For demo purposes, we'll insert directly into the users table

-- Insert custom users with realistic Indian names and details
INSERT INTO users (id, email, name, phone, user_type, created_at, updated_at) VALUES
-- Government Officials
('11111111-1111-1111-1111-111111111111', 'rajesh.kumar@gov.in', 'Rajesh Kumar', '+91-9876543210', 'admin', NOW(), NOW()),
('22222222-2222-2222-2222-222222222222', 'priya.sharma@gov.in', 'Priya Sharma', '+91-9876543211', 'admin', NOW(), NOW()),
('33333333-3333-3333-3333-333333333333', 'amit.singh@gov.in', 'Amit Singh', '+91-9876543212', 'admin', NOW(), NOW()),

-- Citizens
('44444444-4444-4444-4444-444444444444', 'ajjukumar1012@gmail.com', 'Ajjukumar Patel', '+91-9876543213', 'citizen', NOW(), NOW()),
('55555555-5555-5555-5555-555555555555', 'sneha.gupta@gmail.com', 'Sneha Gupta', '+91-9876543214', 'citizen', NOW(), NOW()),
('66666666-6666-6666-6666-666666666666', 'vikram.reddy@gmail.com', 'Vikram Reddy', '+91-9876543215', 'citizen', NOW(), NOW()),
('77777777-7777-7777-7777-777777777777', 'kavya.nair@gmail.com', 'Kavya Nair', '+91-9876543216', 'citizen', NOW(), NOW()),
('88888888-8888-8888-8888-888888888888', 'arjun.sharma@gmail.com', 'Arjun Sharma', '+91-9876543217', 'citizen', NOW(), NOW()),
('99999999-9999-9999-9999-999999999999', 'priya.patel@gmail.com', 'Priya Patel', '+91-9876543218', 'citizen', NOW(), NOW()),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'rohit.kumar@gmail.com', 'Rohit Kumar', '+91-9876543219', 'citizen', NOW(), NOW()),

-- Municipal Workers
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'ramesh.worker@municipal.gov.in', 'Ramesh Kumar', '+91-9876543220', 'worker', NOW(), NOW()),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'sunita.worker@municipal.gov.in', 'Sunita Devi', '+91-9876543221', 'worker', NOW(), NOW()),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'mohammed.worker@municipal.gov.in', 'Mohammed Ali', '+91-9876543222', 'worker', NOW(), NOW());

-- Create some sample issues for these users
INSERT INTO issues (id, user_id, title, description, status, priority, location, created_at, updated_at) VALUES
('issue-001', '44444444-4444-4444-4444-444444444444', 'Broken Street Light', 'Street light at Sector 15, Block A is not working for the past 3 days. It gets very dark in the evening.', 'open', 'high', 'Sector 15, Block A, Delhi', NOW(), NOW()),
('issue-002', '55555555-5555-5555-5555-555555555555', 'Pothole on Main Road', 'Large pothole on the main road near Central Market causing traffic congestion and vehicle damage.', 'in_progress', 'high', 'Central Market, Main Road, Delhi', NOW(), NOW()),
('issue-003', '66666666-6666-6666-6666-666666666666', 'Garbage Not Collected', 'Garbage has not been collected from our area for 5 days. It is causing health issues.', 'open', 'medium', 'Residential Area, Sector 22, Delhi', NOW(), NOW()),
('issue-004', '77777777-7777-7777-7777-777777777777', 'Water Supply Issue', 'No water supply in our building for 2 days. Please resolve urgently.', 'open', 'high', 'Building Complex, Sector 18, Delhi', NOW(), NOW()),
('issue-005', '88888888-8888-8888-8888-888888888888', 'Damaged Footpath', 'Footpath near the school is damaged and dangerous for children.', 'resolved', 'medium', 'Near School, Sector 12, Delhi', NOW(), NOW()),
('issue-006', '99999999-9999-9999-9999-999999999999', 'Traffic Signal Not Working', 'Traffic signal at the busy intersection is not working properly.', 'in_progress', 'high', 'Busy Intersection, Sector 8, Delhi', NOW(), NOW()),
('issue-007', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Street Vendor Issue', 'Unauthorized street vendors blocking the footpath near metro station.', 'open', 'low', 'Metro Station, Sector 5, Delhi', NOW(), NOW());

-- Create sample comments on issues
INSERT INTO comments (id, issue_id, user_id, content, created_at) VALUES
('comment-001', 'issue-001', '11111111-1111-1111-1111-111111111111', 'Issue has been assigned to the electrical department. Will be resolved within 24 hours.', NOW()),
('comment-002', 'issue-002', '55555555-5555-5555-5555-555555555555', 'Thank you for reporting. We will update the status soon.', NOW()),
('comment-003', 'issue-003', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Garbage collection truck was under maintenance. Service will resume tomorrow.', NOW()),
('comment-004', 'issue-004', '22222222-2222-2222-2222-222222222222', 'Water supply issue has been escalated to the water department.', NOW()),
('comment-005', 'issue-005', '88888888-8888-8888-8888-888888888888', 'Thank you for fixing the footpath. It looks much better now!', NOW());

-- Print success message
SELECT 'Custom users and sample data created successfully!' as message;

