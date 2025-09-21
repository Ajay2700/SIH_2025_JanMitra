import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/modules/citizen/controllers/dynamic_issue_controller.dart';
import 'package:jan_mitra/core/ui/app_loading.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/routes/app_routes.dart';
import 'package:jan_mitra/data/services/firebase_auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyIssuesView extends StatelessWidget {
  const MyIssuesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Check authentication
    final authService = Get.find<FirebaseAuthService>();
    if (!authService.isAuthenticated.value ||
        authService.getCurrentUser() == null) {
      // Redirect to login if not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(Routes.LOGIN);
      });
      return const Scaffold(
        body: Center(child: AppLoading(message: 'Checking authentication...')),
      );
    }

    // Initialize controller if not already initialized
    DynamicIssueController controller;
    try {
      controller = Get.find<DynamicIssueController>();
    } catch (e) {
      // If controller is not found, initialize it
      controller = Get.put(DynamicIssueController());
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFF2C2C2E,
      ), // Dark gray background like in image
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoading(
            message: 'Loading your issues...',
            type: AppLoadingType.bounce,
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return AppErrorWidget(
            title: 'Error Loading Issues',
            message: controller.errorMessage.value,
            onRetry: controller.refreshData,
          );
        }

        return controller.userIssues.isEmpty
            ? _buildEmptyState(context)
            : RefreshIndicator(
                onRefresh: controller.refreshData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: controller.userIssues.map((issue) {
                      return _buildIssueCard(context, issue, controller);
                    }).toList(),
                  ),
                ),
              );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.REPORT_ISSUE),
        icon: const Icon(Icons.edit),
        label: const Text('Post Issue'),
        backgroundColor: const Color(0xFF007AFF),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AppEmptyWidget(
      title: 'No Issues Posted Yet',
      message:
          'Start by reporting your first civic issue. Your posts will appear here for others to see and support.',
      icon: Icons.assignment_outlined,
      actionText: 'Report Issue',
      onAction: () => Get.toNamed(Routes.REPORT_ISSUE),
    );
  }

  // Helper method to determine issue type based on title/description
  String _getIssueType(String title, String description) {
    final text = (title + ' ' + description).toLowerCase();

    if (text.contains('light') ||
        text.contains('electricity') ||
        text.contains('power')) {
      return 'Electrical';
    } else if (text.contains('road') ||
        text.contains('pothole') ||
        text.contains('highway')) {
      return 'Road';
    } else if (text.contains('garbage') ||
        text.contains('waste') ||
        text.contains('trash')) {
      return 'Sanitation';
    } else if (text.contains('water') ||
        text.contains('supply') ||
        text.contains('pipe')) {
      return 'Water';
    } else if (text.contains('sewage') ||
        text.contains('drainage') ||
        text.contains('drain')) {
      return 'Drainage';
    } else if (text.contains('park') ||
        text.contains('garden') ||
        text.contains('tree')) {
      return 'Environment';
    } else {
      return 'General';
    }
  }

  // Helper method to get color for issue type
  Color _getIssueTypeColor(String issueType) {
    switch (issueType) {
      case 'Electrical':
        return const Color(0xFFFF9800); // Orange
      case 'Road':
        return const Color(0xFF2196F3); // Blue
      case 'Sanitation':
        return const Color(0xFF4CAF50); // Green
      case 'Water':
        return const Color(0xFF00BCD4); // Cyan
      case 'Drainage':
        return const Color(0xFF9C27B0); // Purple
      case 'Environment':
        return const Color(0xFF8BC34A); // Light Green
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  Widget _buildIssueCard(
    BuildContext context,
    IssueModel issue,
    DynamicIssueController controller,
  ) {
    // Get status color and text - service maps ticket statuses to issue statuses
    Color statusColor;
    String statusText;

    switch (issue.status) {
      case 'submitted': // Maps to 'open' in tickets
        statusColor = const Color(0xFFE91E63); // Pink for Pending
        statusText = 'Pending';
        break;
      case 'acknowledged': // Maps to 'pending' in tickets
        statusColor = const Color(0xFFFFA726); // Orange for Confirmed
        statusText = 'Confirmed';
        break;
      case 'in_progress': // Maps to 'in_progress' in tickets
        statusColor = const Color(0xFF42A5F5); // Blue for In Progress
        statusText = 'In Progress';
        break;
      case 'resolved': // Maps to 'resolved'/'closed' in tickets
        statusColor = const Color(0xFF66BB6A); // Green for Resolved
        statusText = 'Resolved';
        break;
      case 'rejected': // Maps to 'rejected' in tickets
        statusColor = const Color(0xFFEF5350); // Red for Rejected
        statusText = 'Rejected';
        break;
      default:
        statusColor = Colors.grey;
        statusText = issue.status;
    }

    // Get issue type based on title/description
    String issueType = _getIssueType(issue.title, issue.description);
    Color typeColor = _getIssueTypeColor(issueType);

    // User data
    final userName = issue
        .createdBy; // This will be the user ID, you might want to fetch user name
    final location = issue.address.isNotEmpty
        ? issue.address
        : 'Unknown Location';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // User name and location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        location,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Three dots menu
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () {
                    // Show options menu
                  },
                ),
              ],
            ),
          ),

          // Issue Image
          if (issue.imageUrl.isNotEmpty)
            ClipRRect(
              child: CachedNetworkImage(
                imageUrl: issue.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),

          // Description
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              issue.description,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),

          // Actions and Status
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: () => controller.toggleLike(issue.id),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.hasUserLiked(issue.id)
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_up_outlined,
                        color: controller.hasUserLiked(issue.id)
                            ? Colors.red
                            : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.getLikeCount(issue.id)}',
                        style: TextStyle(
                          color: controller.hasUserLiked(issue.id)
                              ? Colors.red
                              : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Share button
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.grey, size: 20),
                  onPressed: () {
                    // Share functionality
                  },
                ),

                const Spacer(),

                // Issue type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    border: Border.all(color: typeColor, width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    issueType,
                    style: TextStyle(
                      color: typeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
