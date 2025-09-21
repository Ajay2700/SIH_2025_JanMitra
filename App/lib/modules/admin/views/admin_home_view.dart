import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/modules/admin/controllers/admin_home_controller.dart';
import 'package:jan_mitra/routes/app_routes.dart';

class AdminHomeView extends StatelessWidget {
  final AdminHomeController _controller = Get.find<AdminHomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _controller.signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
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
                  onPressed: _controller.refreshData,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.refreshData,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                Obx(() {
                  if (_controller.currentUser.value != null) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Welcome, ${_controller.currentUser.value!.name}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    );
                  }
                  return SizedBox.shrink();
                }),

                // Stats Cards
                _buildStatsCards(context),
                SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16),

                // Action Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        Icons.list_alt,
                        'Issue List',
                        'View and manage all reported issues',
                        () => Get.toNamed(Routes.ISSUE_LIST),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        Icons.map,
                        'Map Dashboard',
                        'View issues on interactive map',
                        () => Get.toNamed(Routes.MAP_DASHBOARD),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        Icons.analytics,
                        'Analytics',
                        'View issue statistics and trends',
                        () => Get.toNamed(Routes.ANALYTICS),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        Icons.person,
                        'Profile',
                        'Manage your account settings',
                        () => Get.toNamed(Routes.ADMIN_PROFILE),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Recent Issues
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Issues',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.ISSUE_LIST),
                      child: Text('View All'),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Recent Issues List
                _controller.allIssues.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No issues reported yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _controller.allIssues.length > 5
                            ? 5
                            : _controller.allIssues.length,
                        itemBuilder: (context, index) {
                          final issue = _controller.allIssues[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(issue.title),
                              subtitle: Text(
                                'Status: ${issue.status.capitalize}, Priority: ${issue.priority.capitalize}',
                              ),
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(issue.status),
                                child: Icon(
                                  _getStatusIcon(issue.status),
                                  color: Colors.white,
                                ),
                              ),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () => Get.toNamed(
                                '/admin/issue-details',
                                arguments: {'issueId': issue.id},
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          context,
          'Total Issues',
          _controller.totalIssues.toString(),
          Icons.report_problem,
          Colors.blue,
        ),
        _buildStatCard(
          context,
          'Pending Issues',
          _controller.pendingIssues.toString(),
          Icons.pending_actions,
          Colors.orange,
        ),
        _buildStatCard(
          context,
          'Resolved Issues',
          _controller.resolvedIssues.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          context,
          'High Priority',
          _controller.highPriorityIssues.toString(),
          Icons.priority_high,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return Color(0xFFFFA000); // Amber
      case 'acknowledged':
        return Color(0xFF42A5F5); // Blue
      case 'in_progress':
        return Color(0xFF7E57C2); // Purple
      case 'resolved':
        return Color(0xFF66BB6A); // Green
      case 'rejected':
        return Color(0xFFEF5350); // Red
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'submitted':
        return Icons.send;
      case 'acknowledged':
        return Icons.visibility;
      case 'in_progress':
        return Icons.engineering;
      case 'resolved':
        return Icons.check;
      case 'rejected':
        return Icons.close;
      default:
        return Icons.circle;
    }
  }
}
