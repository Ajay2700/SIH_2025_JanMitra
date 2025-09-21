import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/modules/citizen/controllers/dynamic_issue_controller.dart';
import 'package:jan_mitra/core/ui/app_loading.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/routes/app_routes.dart';
import 'package:jan_mitra/data/services/firebase_auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: AppLoading(
              message: 'Loading your issues...',
              type: AppLoadingType.bounce,
            ),
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
            : _buildIssuesList(context, controller);
      }),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildIssuesList(
    BuildContext context,
    DynamicIssueController controller,
  ) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      color: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header with title and refresh button
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: Text(
              'My Issues',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.refreshData();
                },
                tooltip: 'Refresh',
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final issue = controller.userIssues[index];
                return _buildIssueCard(context, issue, controller);
              }, childCount: controller.userIssues.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Get.toNamed(Routes.REPORT_ISSUE);
        },
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Report Issue',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
  Color _getIssueTypeColor(String issueType, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (issueType) {
      case 'Electrical':
        return isDark
            ? const Color(0xFFFFB74D)
            : const Color(0xFFFF9800); // Orange
      case 'Road':
        return isDark
            ? const Color(0xFF64B5F6)
            : const Color(0xFF2196F3); // Blue
      case 'Sanitation':
        return isDark
            ? const Color(0xFF81C784)
            : const Color(0xFF4CAF50); // Green
      case 'Water':
        return isDark
            ? const Color(0xFF4DD0E1)
            : const Color(0xFF00BCD4); // Cyan
      case 'Drainage':
        return isDark
            ? const Color(0xFFBA68C8)
            : const Color(0xFF9C27B0); // Purple
      case 'Environment':
        return isDark
            ? const Color(0xFFAED581)
            : const Color(0xFF8BC34A); // Light Green
      default:
        return isDark
            ? const Color(0xFFB0BEC5)
            : const Color(0xFF757575); // Grey
    }
  }

  Widget _buildIssueCard(
    BuildContext context,
    IssueModel issue,
    DynamicIssueController controller,
  ) {
    // Get status color and text
    final statusData = _getStatusData(issue.status);
    final issueType = _getIssueType(issue.title, issue.description);
    final typeColor = _getIssueTypeColor(issueType, context);
    final userName = issue.createdBy.isNotEmpty ? issue.createdBy : 'Anonymous';
    final location = issue.address.isNotEmpty
        ? issue.address
        : 'Unknown Location';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        elevation: 8,
        shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).cardColor,
                Theme.of(context).cardColor.withValues(alpha: 0.9),
              ],
            ),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildCardHeader(context, userName, location, issue.createdAt),

              // Image Section
              if (issue.imageUrl.isNotEmpty)
                _buildImageSection(context, issue.imageUrl),

              // Content Section
              _buildContentSection(context, issue),

              // Actions Section
              _buildActionsSection(
                context,
                issue,
                controller,
                statusData,
                typeColor,
                issueType,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusData(String status) {
    switch (status) {
      case 'submitted':
        return {
          'color': const Color(0xFFF59E0B),
          'text': 'Pending',
          'icon': Icons.schedule_rounded,
        };
      case 'acknowledged':
        return {
          'color': const Color(0xFF3B82F6),
          'text': 'Confirmed',
          'icon': Icons.check_circle_outline_rounded,
        };
      case 'in_progress':
        return {
          'color': const Color(0xFF8B5CF6),
          'text': 'In Progress',
          'icon': Icons.work_outline_rounded,
        };
      case 'resolved':
        return {
          'color': const Color(0xFF10B981),
          'text': 'Resolved',
          'icon': Icons.check_circle_rounded,
        };
      case 'rejected':
        return {
          'color': const Color(0xFFEF4444),
          'text': 'Rejected',
          'icon': Icons.cancel_rounded,
        };
      default:
        return {
          'color': Colors.grey,
          'text': status,
          'icon': Icons.help_outline_rounded,
        };
    }
  }

  Widget _buildCardHeader(
    BuildContext context,
    String userName,
    String location,
    DateTime createdAt,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
            Theme.of(context).primaryColor.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.1),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Time ago
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getTimeAgo(createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, String imageUrl) {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_rounded,
                  size: 48,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  'Image not available',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, IssueModel issue) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            issue.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleLarge?.color,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            issue.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    IssueModel issue,
    DynamicIssueController controller,
    Map<String, dynamic> statusData,
    Color typeColor,
    String issueType,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          // Action buttons row
          Row(
            children: [
              // Like button
              _buildActionButton(
                context,
                icon: controller.hasUserLiked(issue.id)
                    ? Icons.thumb_up_rounded
                    : Icons.thumb_up_outlined,
                label: '${controller.getLikeCount(issue.id)}',
                isActive: controller.hasUserLiked(issue.id),
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.toggleLike(issue.id);
                },
              ),
              const SizedBox(width: 12),

              // Share button
              _buildActionButton(
                context,
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () {
                  HapticFeedback.lightImpact();
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
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  border: Border.all(color: typeColor, width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  issueType.toUpperCase(),
                  style: TextStyle(
                    color: typeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusData['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: statusData['color'].withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(statusData['icon'], color: statusData['color'], size: 20),
                const SizedBox(width: 8),
                Text(
                  statusData['text'],
                  style: TextStyle(
                    color: statusData['color'],
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Theme.of(context).dividerColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
