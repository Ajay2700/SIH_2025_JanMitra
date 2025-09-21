import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jan_mitra/data/models/user_model.dart';
import 'package:jan_mitra/data/services/firebase_auth_service.dart';
import 'package:jan_mitra/core/ui/app_card.dart';
import 'package:jan_mitra/core/ui/app_button.dart';

class UserProfileView extends StatelessWidget {
  final UserModel user;

  const UserProfileView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(context),
            SizedBox(height: 24),

            // User Details Card
            _buildUserDetailsCard(context),
            SizedBox(height: 16),

            // Contact Information Card
            _buildContactInfoCard(context),
            SizedBox(height: 16),

            // Account Information Card
            _buildAccountInfoCard(context),
            SizedBox(height: 16),

            // Actions Card
            _buildActionsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: user.profileImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: user.profileImageUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
          ),
          SizedBox(height: 16),

          // User Name
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),

          // User Type Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getUserTypeLabel(user.userType),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailsCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildDetailRow('Full Name', user.name, Icons.person),
          _buildDetailRow('Email', user.email, Icons.email),
          _buildDetailRow('Phone', user.phone ?? 'Not provided', Icons.phone),
          _buildDetailRow(
            'User Type',
            _getUserTypeLabel(user.userType),
            Icons.account_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildDetailRow('Email Address', user.email, Icons.email),
          _buildDetailRow(
            'Phone Number',
            user.phone ?? 'Not provided',
            Icons.phone,
          ),
          _buildDetailRow(
            'Contact Status',
            'Active',
            Icons.check_circle,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildDetailRow('User ID', user.id, Icons.fingerprint),
          _buildDetailRow(
            'Account Created',
            _formatDate(user.createdAt),
            Icons.calendar_today,
          ),
          _buildDetailRow(
            'Last Updated',
            _formatDate(user.updatedAt ?? user.createdAt),
            Icons.update,
          ),
          _buildDetailRow(
            'Account Status',
            'Verified',
            Icons.verified,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          AppButton(
            label: 'Edit Profile',
            onPressed: () {
              // TODO: Navigate to edit profile
              Get.snackbar('Info', 'Edit profile functionality coming soon!');
            },
            leadingIcon: Icons.edit,
          ),
          SizedBox(height: 12),
          AppButton(
            label: 'Change Password',
            onPressed: () {
              // TODO: Navigate to change password
              Get.snackbar(
                'Info',
                'Change password functionality coming soon!',
              );
            },
            leadingIcon: Icons.lock,
            type: AppButtonType.secondary,
          ),
          SizedBox(height: 12),
          AppButton(
            label: 'Sign Out',
            onPressed: () async {
              try {
                final authService = Get.find<FirebaseAuthService>();
                await authService.signOut();
                Get.offAllNamed('/auth');
                Get.snackbar('Success', 'Signed out successfully!');
              } catch (e) {
                Get.snackbar('Error', 'Failed to sign out: $e');
              }
            },
            leadingIcon: Icons.logout,
            type: AppButtonType.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, [
    Color? iconColor,
  ]) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getUserTypeLabel(String userType) {
    switch (userType.toLowerCase()) {
      case 'admin':
        return 'Government Official';
      case 'citizen':
        return 'Citizen';
      case 'worker':
        return 'Municipal Worker';
      default:
        return userType;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
