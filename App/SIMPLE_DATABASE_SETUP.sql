-- Simple Database Setup for Jan Mitra App
-- Run this in your Supabase SQL Editor

-- 1. Create issues table (simplified)
CREATE TABLE IF NOT EXISTS issues (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT DEFAULT 'submitted',
  priority TEXT DEFAULT 'medium',
  image_url TEXT,
  location JSONB DEFAULT '{"latitude": 0.0, "longitude": 0.0, "address": ""}',
  address TEXT DEFAULT '',
  created_by UUID DEFAULT gen_random_uuid(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create issue_likes table
CREATE TABLE IF NOT EXISTS issue_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
  user_id UUID DEFAULT gen_random_uuid(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Enable Row Level Security
ALTER TABLE issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE issue_likes ENABLE ROW LEVEL SECURITY;

-- 4. Create simple policies
CREATE POLICY "Anyone can view issues" ON issues FOR SELECT USING (true);
CREATE POLICY "Anyone can insert issues" ON issues FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can update issues" ON issues FOR UPDATE USING (true);

CREATE POLICY "Anyone can view likes" ON issue_likes FOR SELECT USING (true);
CREATE POLICY "Anyone can insert likes" ON issue_likes FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can delete likes" ON issue_likes FOR DELETE USING (true);

-- 5. Insert some sample data
INSERT INTO issues (title, description, address, priority) VALUES
('Road Pothole', 'Large pothole on Main Street causing traffic issues', 'Main Street, Delhi', 'high'),
('Garbage Collection', 'Garbage not collected for 3 days', 'Residential Area, Mumbai', 'medium'),
('Water Supply Issue', 'No water supply in the morning', 'Apartment Complex, Bangalore', 'high'),
('Street Light Problem', 'Street light not working at night', 'Park Road, Chennai', 'low');

-- 6. Enable real-time
ALTER PUBLICATION supabase_realtime ADD TABLE issues;
ALTER PUBLICATION supabase_realtime ADD TABLE issue_likes;
