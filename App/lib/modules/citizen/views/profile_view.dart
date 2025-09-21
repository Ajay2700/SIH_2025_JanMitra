import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/modules/citizen/controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  final ProfileController _controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (_controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _controller.errorMessage.value,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _controller.getCurrentUser,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_controller.currentUser.value == null) {
          return Center(child: Text('User not found'));
        }

        final user = _controller.currentUser.value!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16),

              // Profile Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(fontSize: 48, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // User Information
              Obx(() {
                if (_controller.isEditing.value) {
                  return _buildEditProfileForm(context);
                } else {
                  return Column(
                    children: [
                      // User Name
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 8),

                      // User Email
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      SizedBox(height: 8),

                      // User Role
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          user.role.capitalize!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }),
              SizedBox(height: 32),

              // Profile Options
              _buildProfileOption(
                context,
                Icons.person_outline,
                'Edit Profile',
                () => _controller.startEditing(),
              ),
              Divider(),
              _buildProfileOption(
                context,
                Icons.notifications_outlined,
                'Notifications',
                () {
                  // TODO: Implement notifications settings
                  Get.snackbar(
                    'Coming Soon',
                    'This feature will be available in the next update.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              Divider(),
              _buildProfileOption(
                context,
                Icons.security_outlined,
                'Privacy & Security',
                () {
                  // TODO: Implement privacy settings
                  Get.snackbar(
                    'Coming Soon',
                    'This feature will be available in the next update.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              Divider(),
              _buildProfileOption(
                context,
                Icons.help_outline,
                'Help & Support',
                () {
                  // TODO: Implement help & support
                  Get.snackbar(
                    'Coming Soon',
                    'This feature will be available in the next update.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              Divider(),
              _buildProfileOption(context, Icons.info_outline, 'About', () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Jan Mitra',
                  applicationVersion: '1.0.0',
                  applicationIcon: Icon(
                    Icons.location_city,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  children: [
                    Text(
                      'A crowdsourced civic issue reporting and resolution system that empowers citizens to report and track civic issues in their community.',
                    ),
                  ],
                );
              }),
              Divider(),
              SizedBox(height: 16),

              // Sign Out Button
              ElevatedButton.icon(
                onPressed: _controller.signOut,
                icon: Icon(Icons.logout),
                label: Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEditProfileForm(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Name Field
          TextField(
            controller: _controller.nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),

          // Email Field
          TextField(
            controller: _controller.emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 24),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _controller.cancelEditing,
                child: Text('Cancel'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: _controller.saveProfile,
                child: Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
