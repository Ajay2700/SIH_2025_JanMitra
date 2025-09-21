import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/core/utils/constants.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/modules/citizen/controllers/citizen_home_controller.dart';
// import 'package:jan_mitra/modules/citizen/controllers/citizen_main_controller.dart';
import 'package:jan_mitra/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class CitizenHomeView extends StatelessWidget {
  final CitizenHomeController _controller = Get.find<CitizenHomeController>();
  // final CitizenMainController _mainController =
  //     Get.find<CitizenMainController>(); // Currently unused

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Jan Mitra'),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.notifications),
      //       onPressed: () {
      //         Get.snackbar(
      //           'Notifications',
      //           'No new notifications',
      //           backgroundColor: Colors.blue[100],
      //           colorText: Colors.blue[800],
      //         );
      //       },
      //     ),
      //     IconButton(
      //       icon: Icon(Icons.person),
      //       onPressed: () => Get.toNamed(Routes.CITIZEN_PROFILE),
      //     ),
      //   ],
      // ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (_controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  _controller.errorMessage.value,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _controller.refreshData,
                      child: Text('Retry'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => Get.offAllNamed(Routes.AUTH),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (_controller.userIssues.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No issues reported yet',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Report your first civic issue',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.REPORT_ISSUE),
                  icon: Icon(Icons.add),
                  label: Text('Report Issue'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.refreshData,
          child: ListView(
            padding: EdgeInsets.all(16),
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

              // Service Cards
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildServiceCard(
                        context,
                        'Report Issue',
                        Icons.report_problem,
                        Colors.orange,
                        () => Get.toNamed(Routes.REPORT_ISSUE),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildServiceCard(
                        context,
                        'Support Tickets',
                        Icons.confirmation_number,
                        Colors.blue,
                        () => Get.toNamed(Routes.MY_ISSUES),
                      ),
                    ),
                  ],
                ),
              ),

              // Recent Issues Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Recent Issues',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    onPressed: () => Get.toNamed(Routes.MY_ISSUES),
                    icon: Icon(Icons.list),
                    label: Text('View All'),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Issue List
              ..._controller.userIssues
                  .map((issue) => _buildIssueCard(context, issue))
                  .toList(),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.REPORT_ISSUE),
        child: Icon(Icons.add),
        tooltip: 'Report Issue',
      ),
    );
  }

  Widget _buildIssueCard(BuildContext context, IssueModel issue) {
    Color statusColor;
    switch (issue.status) {
      case AppConstants.statusSubmitted:
        statusColor = Color(0xFFFFA000); // Amber
        break;
      case AppConstants.statusAcknowledged:
        statusColor = Color(0xFF42A5F5); // Blue
        break;
      case AppConstants.statusInProgress:
        statusColor = Color(0xFF7E57C2); // Purple
        break;
      case AppConstants.statusResolved:
        statusColor = Color(0xFF66BB6A); // Green
        break;
      case AppConstants.statusRejected:
        statusColor = Color(0xFFEF5350); // Red
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () =>
            Get.toNamed(Routes.ISSUE_DETAILS, arguments: {'issueId': issue.id}),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Issue Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: issue.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: Icon(Icons.error, size: 50, color: Colors.grey[600]),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          issue.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          issue.status.capitalize!,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Description
                  Text(
                    issue.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),

                  // Date and Priority
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(issue.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      _buildPriorityChip(issue.priority),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    IconData icon;

    switch (priority) {
      case AppConstants.priorityLow:
        color = Color(0xFF66BB6A); // Green
        icon = Icons.arrow_downward;
        break;
      case AppConstants.priorityMedium:
        color = Color(0xFFFFA000); // Amber
        icon = Icons.remove;
        break;
      case AppConstants.priorityHigh:
        color = Color(0xFFEF5350); // Red
        icon = Icons.arrow_upward;
        break;
      default:
        color = Colors.grey;
        icon = Icons.remove;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            priority.capitalize!,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
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
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
