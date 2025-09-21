import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/modules/admin/controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Profile'),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: controller.logout),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        }

        final user = controller.currentUser.value;
        if (user == null) {
          return Center(child: Text('User not found'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: 24),
              ProfileInfoCard(
                title: 'Personal Information',
                items: [
                  ProfileInfoItem(label: 'Name', value: user.name),
                  ProfileInfoItem(label: 'Email', value: user.email),
                  ProfileInfoItem(label: 'Role', value: user.role.capitalize!),
                ],
              ),
              SizedBox(height: 16),
              ProfileInfoCard(
                title: 'App Information',
                items: [ProfileInfoItem(label: 'Version', value: '1.0.0')],
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: controller.logout,
                  child: Text('Logout'),
                  style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final List<ProfileInfoItem> items;

  const ProfileInfoCard({Key? key, required this.title, required this.items})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '${item.label}:',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.value,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoItem {
  final String label;
  final String value;

  ProfileInfoItem({required this.label, required this.value});
}
