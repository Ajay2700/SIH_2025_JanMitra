# Jan Mitra - Enhanced Setup Instructions

## 🚀 Quick Setup Guide

### **Step 1: Run SQL Scripts in Supabase**

Execute these SQL scripts in your **Supabase SQL Editor** in the following order:

1. **Setup Storage Buckets:**
   ```sql
   -- Run the content of supabase/setup_storage.sql
   ```

2. **Create Custom Users:**
   ```sql
   -- Run the content of supabase/create_custom_users.sql
   ```

### **Step 2: Update Supabase Auth Settings**

Go to **Supabase Dashboard** → **Authentication** → **URL Configuration**:

- **Site URL:** `https://tfktqtczpskctezdrxoh.supabase.co`
- **Redirect URLs:** `https://tfktqtczpskctezdrxoh.supabase.co`

### **Step 3: Run the Enhanced App**

```bash
flutter run
```

## 🎯 New Features Implemented

### **✅ Custom Users Created**
- **Government Officials:** Rajesh Kumar, Priya Sharma, Amit Singh
- **Citizens:** Ajjukumar Patel, Sneha Gupta, Vikram Reddy, Kavya Nair, Arjun Sharma, Priya Patel, Rohit Kumar
- **Municipal Workers:** Ramesh Kumar, Sunita Devi, Mohammed Ali

### **✅ Enhanced Home Screen**
- **Welcome Section:** Personalized greeting with user info
- **Quick Actions:** Report Issue and My Issues buttons
- **All Users Display:** Shows all users with profile pictures and types
- **Recent Issues:** Displays latest reported issues
- **Floating Action Button:** Quick access to report issues

### **✅ User Profile System**
- **Comprehensive Profiles:** Shows all user details including contact info, account info
- **User Types:** Government Officials, Citizens, Municipal Workers
- **Profile Actions:** Edit profile, change password, sign out
- **Visual Design:** Beautiful cards with gradients and icons

### **✅ File Upload & Storage**
- **Supabase Storage:** 3 buckets created (issue-attachments, user-profiles, documents)
- **Multiple File Support:** Upload multiple images/documents per issue
- **File Types:** Images (JPEG, PNG, GIF), PDFs, text files
- **Size Limits:** 10MB for attachments, 5MB for profiles, 20MB for documents

### **✅ Issue Posting with Attachments**
- **Multiple Attachments:** Upload photos, documents with each issue
- **Real-time Upload:** Progress tracking and error handling
- **Organized Storage:** Files stored in organized folder structure
- **Public Access:** Attachments viewable by all users

## 🎨 UI/UX Improvements

### **Modern Design Elements**
- **Gradient Headers:** Beautiful gradient backgrounds
- **Card-based Layout:** Clean, organized information display
- **Status Badges:** Color-coded status indicators
- **User Avatars:** Circular profile pictures with initials
- **Responsive Design:** Works on all screen sizes

### **User Experience**
- **Pull to Refresh:** Refresh data by pulling down
- **Loading States:** Proper loading indicators
- **Error Handling:** User-friendly error messages
- **Quick Navigation:** Easy access to all features

## 🔧 Technical Features

### **Storage Service**
- **File Upload:** Single and multiple file uploads
- **Progress Tracking:** Real-time upload progress
- **Error Handling:** Comprehensive error management
- **File Management:** Upload, view, delete files

### **Issue Service**
- **Enhanced Creation:** Issues with multiple attachments
- **Real-time Data:** Live updates from Supabase
- **User Integration:** Links issues to user profiles
- **Location Support:** GPS coordinates and addresses

### **Authentication**
- **JWT Tokens:** Secure authentication
- **Profile Management:** Auto-create user profiles
- **Session Handling:** Persistent login sessions
- **Deep Linking:** Email confirmation support

## 📱 How to Use

### **For Citizens:**
1. **Sign In** with your email and password
2. **View All Users** - See government officials and other citizens
3. **Report Issues** - Take photos and report problems
4. **Track Progress** - Monitor your reported issues
5. **View Profiles** - Click on any user to see their details

### **For Government Officials:**
1. **Access Dashboard** - View all reported issues
2. **Update Status** - Mark issues as in-progress or resolved
3. **Add Comments** - Provide updates to citizens
4. **Manage Users** - View citizen and worker profiles

### **For Municipal Workers:**
1. **View Assigned Issues** - See issues assigned to you
2. **Update Progress** - Report on work completion
3. **Upload Evidence** - Add photos of completed work
4. **Communicate** - Add comments and updates

## 🚨 Troubleshooting

### **Common Issues:**

1. **"User not found" error:**
   - Run the custom users SQL script
   - Check if user exists in both auth.users and users tables

2. **File upload fails:**
   - Verify storage buckets are created
   - Check file size limits
   - Ensure proper permissions

3. **Email confirmation not working:**
   - Update Supabase auth settings
   - Check redirect URLs
   - Verify Android manifest deep links

### **Need Help?**
- Check console logs for detailed error messages
- Verify Supabase connection and permissions
- Ensure all SQL scripts are executed successfully

## 🎉 Success!

Your Jan Mitra app now has:
- ✅ Multiple custom users with different roles
- ✅ Enhanced home screen with user profiles
- ✅ File upload and storage capabilities
- ✅ Beautiful, modern UI design
- ✅ Real-time data from Supabase
- ✅ Comprehensive issue reporting system

**Enjoy using your enhanced Jan Mitra app! 🚀**

