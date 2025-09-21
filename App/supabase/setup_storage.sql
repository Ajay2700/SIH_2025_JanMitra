-- Setup Supabase Storage for Jan Mitra App
-- This script creates storage buckets and sets up policies

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
('issue-attachments', 'issue-attachments', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'text/plain']),
('user-profiles', 'user-profiles', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/gif']),
('documents', 'documents', false, 20971520, ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'text/plain']);

-- Create storage policies for issue-attachments bucket
CREATE POLICY "Anyone can view issue attachments" ON storage.objects
FOR SELECT USING (bucket_id = 'issue-attachments');

CREATE POLICY "Authenticated users can upload issue attachments" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'issue-attachments' 
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Users can update their own attachments" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'issue-attachments' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own attachments" ON storage.objects
FOR DELETE USING (
  bucket_id = 'issue-attachments' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Create storage policies for user-profiles bucket
CREATE POLICY "Anyone can view user profiles" ON storage.objects
FOR SELECT USING (bucket_id = 'user-profiles');

CREATE POLICY "Users can upload their own profile pictures" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'user-profiles' 
  AND auth.role() = 'authenticated'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update their own profile pictures" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'user-profiles' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own profile pictures" ON storage.objects
FOR DELETE USING (
  bucket_id = 'user-profiles' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Create storage policies for documents bucket
CREATE POLICY "Authenticated users can view documents" ON storage.objects
FOR SELECT USING (
  bucket_id = 'documents' 
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Authenticated users can upload documents" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'documents' 
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Users can update their own documents" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'documents' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own documents" ON storage.objects
FOR DELETE USING (
  bucket_id = 'documents' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Print success message
SELECT 'Storage buckets and policies created successfully!' as message;

