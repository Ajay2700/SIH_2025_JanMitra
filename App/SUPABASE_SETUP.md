# Supabase Database Setup Guide

This guide will help you set up the Supabase database for the Jan Mitra civic issues app with real-time functionality.

## 1. Create Supabase Project

1. Go to [Supabase](https://supabase.com) and create an account
2. Create a new project
3. Note down your project URL and anon key

## 2. Database Schema

Run the following SQL commands in your Supabase SQL editor:

### Create Profiles Table
```sql
-- Create profiles table for user information
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  name TEXT NOT NULL,
  avatar_url TEXT,
  phone TEXT,
  role TEXT DEFAULT 'citizen',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view all profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
```

### Create Issues Table
```sql
-- Create issues table for civic issues
CREATE TABLE issues (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT DEFAULT 'submitted' CHECK (status IN ('submitted', 'acknowledged', 'in_progress', 'resolved', 'rejected')),
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  image_url TEXT,
  location JSONB NOT NULL,
  address TEXT NOT NULL,
  created_by UUID REFERENCES auth.users(id) NOT NULL,
  assigned_to UUID REFERENCES auth.users(id),
  category_id UUID,
  department_id UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  resolved_at TIMESTAMP WITH TIME ZONE
);

-- Enable RLS
ALTER TABLE issues ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Anyone can view issues" ON issues FOR SELECT USING (true);
CREATE POLICY "Users can create issues" ON issues FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Users can update own issues" ON issues FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Admins can update any issue" ON issues FOR UPDATE USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);
```

### Create Issue Likes Table
```sql
-- Create issue_likes table for like functionality
CREATE TABLE issue_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  issue_id UUID REFERENCES issues(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(issue_id, user_id)
);

-- Enable RLS
ALTER TABLE issue_likes ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Anyone can view likes" ON issue_likes FOR SELECT USING (true);
CREATE POLICY "Users can like issues" ON issue_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unlike their likes" ON issue_likes FOR DELETE USING (auth.uid() = user_id);
```

### Create Categories Table
```sql
-- Create categories table for issue categorization
CREATE TABLE categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  color TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default categories
INSERT INTO categories (name, description, icon, color) VALUES
('Garbage Collection', 'Waste management and garbage collection issues', 'local_shipping', '#4CAF50'),
('Road Maintenance', 'Road repairs, potholes, and infrastructure', 'road', '#FF9800'),
('Water Supply', 'Water supply and quality issues', 'water_drop', '#2196F3'),
('Electricity', 'Power supply and electrical issues', 'electrical_services', '#FFC107'),
('Animal Control', 'Stray animals and animal-related issues', 'pets', '#9C27B0'),
('Public Safety', 'Safety concerns and security issues', 'security', '#F44336'),
('Environment', 'Environmental concerns and pollution', 'eco', '#4CAF50'),
('General Complaint', 'General civic complaints', 'report_problem', '#607D8B');
```

### Create Departments Table
```sql
-- Create departments table for issue assignment
CREATE TABLE departments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  contact_email TEXT,
  contact_phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default departments
INSERT INTO departments (name, description, contact_email, contact_phone) VALUES
('Municipal Corporation', 'General municipal services', 'info@municipal.gov', '+91-XXX-XXXXXXX'),
('Public Works Department', 'Infrastructure and construction', 'pwd@municipal.gov', '+91-XXX-XXXXXXX'),
('Water Department', 'Water supply and quality', 'water@municipal.gov', '+91-XXX-XXXXXXX'),
('Electricity Department', 'Power supply and electrical services', 'electricity@municipal.gov', '+91-XXX-XXXXXXX'),
('Health Department', 'Public health and sanitation', 'health@municipal.gov', '+91-XXX-XXXXXXX'),
('Environment Department', 'Environmental protection', 'environment@municipal.gov', '+91-XXX-XXXXXXX');
```

### Create Functions and Triggers
```sql
-- Function to automatically create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, role)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'name', 'User'), 'citizen');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER handle_issues_updated_at
  BEFORE UPDATE ON issues
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
```

## 3. Storage Setup

### Create Storage Bucket for Images
```sql
-- Create storage bucket for issue images
INSERT INTO storage.buckets (id, name, public) VALUES ('issue-images', 'issue-images', true);

-- Create storage policies
CREATE POLICY "Anyone can view images" ON storage.objects FOR SELECT USING (bucket_id = 'issue-images');
CREATE POLICY "Authenticated users can upload images" ON storage.objects FOR INSERT WITH CHECK (
  bucket_id = 'issue-images' AND auth.role() = 'authenticated'
);
CREATE POLICY "Users can update own images" ON storage.objects FOR UPDATE USING (
  bucket_id = 'issue-images' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "Users can delete own images" ON storage.objects FOR DELETE USING (
  bucket_id = 'issue-images' AND auth.uid()::text = (storage.foldername(name))[1]
);
```

## 4. Real-time Setup

Enable real-time for the issues table:
```sql
-- Enable real-time for issues table
ALTER PUBLICATION supabase_realtime ADD TABLE issues;
ALTER PUBLICATION supabase_realtime ADD TABLE issue_likes;
```

## 5. Environment Variables

Add these to your Flutter app's environment:

```dart
// In your main.dart or config file
const supabaseUrl = 'YOUR_SUPABASE_URL';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

## 6. Authentication Setup

### Enable Email Authentication
1. Go to Authentication > Settings in Supabase dashboard
2. Enable email authentication
3. Configure email templates if needed

### Optional: Enable Google Sign-in
1. Go to Authentication > Providers
2. Enable Google provider
3. Add your Google OAuth credentials

## 7. Testing the Setup

You can test your setup by:

1. **Creating a test issue:**
```sql
INSERT INTO issues (title, description, location, address, created_by)
VALUES (
  'Test Issue',
  'This is a test issue',
  '{"latitude": 28.6139, "longitude": 77.2090}',
  'Test Location',
  'your-user-id-here'
);
```

2. **Checking real-time updates:**
   - Open two browser tabs
   - Create an issue in one tab
   - Watch it appear in real-time in the other tab

## 8. Security Considerations

1. **Row Level Security (RLS)** is enabled on all tables
2. **Policies** are configured to allow appropriate access
3. **File uploads** are restricted to authenticated users
4. **Real-time** is only enabled for necessary tables

## 9. Performance Optimization

1. **Indexes** - Add indexes for frequently queried columns:
```sql
CREATE INDEX idx_issues_status ON issues(status);
CREATE INDEX idx_issues_created_by ON issues(created_by);
CREATE INDEX idx_issues_created_at ON issues(created_at);
CREATE INDEX idx_issue_likes_issue_id ON issue_likes(issue_id);
```

2. **Pagination** - Use range queries for large datasets
3. **Image optimization** - Compress images before upload

## 10. Monitoring

Set up monitoring in Supabase:
1. Go to Settings > API
2. Monitor API usage and performance
3. Set up alerts for errors and high usage

This setup provides a complete, scalable foundation for your civic issues app with real-time functionality, user authentication, and proper security policies.
