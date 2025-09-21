import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/core/utils/constants.dart';
import 'package:jan_mitra/core/utils/platform_utils.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/modules/citizen/controllers/issue_tracker_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class IssueTrackerView extends StatelessWidget {
  final IssueTrackerController _controller = Get.find<IssueTrackerController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

        if (_controller.issue.value == null) {
          return Center(child: Text('Issue not found'));
        }

        final issue = _controller.issue.value!;

        return RefreshIndicator(
          onRefresh: _controller.refreshData,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Issue Image
                CachedNetworkImage(
                  imageUrl: issue.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: Icon(Icons.error, size: 50, color: Colors.grey[600]),
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
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          _buildStatusChip(issue.status),
                        ],
                      ),

                      // Edit/Delete buttons for submitted issues
                      Obx(() {
                        if (_controller.canEditIssue()) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _showEditDialog(context),
                                  icon: Icon(Icons.edit, size: 16),
                                  label: Text('Edit'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                    side: BorderSide(color: Colors.blue),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _showDeleteConfirmation(context),
                                  icon: Icon(Icons.delete, size: 16),
                                  label: Text('Delete'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: BorderSide(color: Colors.red),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      }),
                      SizedBox(height: 8),

                      // Date and Priority
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(issue.createdAt),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(width: 16),
                          _buildPriorityChip(issue.priority),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text(issue.description),
                      SizedBox(height: 24),

                      // Location
                      Text(
                        'Location',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildLocationMap(issue),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Status Timeline
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status Updates',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton.icon(
                            onPressed: _controller.toggleStatusHistory,
                            icon: Obx(
                              () => Icon(
                                _controller.showStatusHistory.value
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                            ),
                            label: Obx(
                              () => Text(
                                _controller.showStatusHistory.value
                                    ? 'Hide History'
                                    : 'Show History',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildStatusTimeline(context),

                      // Status History
                      Obx(
                        () => _controller.showStatusHistory.value
                            ? _buildStatusHistory(context)
                            : SizedBox.shrink(),
                      ),

                      SizedBox(height: 24),

                      // Comments Section
                      Text(
                        'Comments',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),

                      // Comment Input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller.commentController,
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Obx(
                            () => IconButton(
                              onPressed: _controller.isSubmittingComment.value
                                  ? null
                                  : _controller.addComment,
                              icon: _controller.isSubmittingComment.value
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(Icons.send),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Comments List
                      Obx(() {
                        if (_controller.comments.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'No comments yet',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: _controller.comments.map((comment) {
                            final isCurrentUser =
                                _controller.currentUser.value?.id ==
                                comment.userId;

                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Colors.blue[50]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCurrentUser
                                      ? Colors.blue[200]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        comment.user != null
                                            ? comment.user!['name'] ??
                                                  'Unknown User'
                                            : 'Unknown User',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isCurrentUser
                                              ? Colors.blue[700]
                                              : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'MMM dd, h:mm a',
                                        ).format(comment.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(comment.message),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case AppConstants.statusSubmitted:
        color = Color(0xFFFFA000); // Amber
        break;
      case AppConstants.statusAcknowledged:
        color = Color(0xFF42A5F5); // Blue
        break;
      case AppConstants.statusInProgress:
        color = Color(0xFF7E57C2); // Purple
        break;
      case AppConstants.statusResolved:
        color = Color(0xFF66BB6A); // Green
        break;
      case AppConstants.statusRejected:
        color = Color(0xFFEF5350); // Red
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status.capitalize!,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
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

  Widget _buildStatusTimeline(BuildContext context) {
    final allStatuses = [
      AppConstants.statusSubmitted,
      AppConstants.statusAcknowledged,
      AppConstants.statusInProgress,
      AppConstants.statusResolved,
    ];

    final currentStatusIndex = allStatuses.indexOf(
      _controller.issue.value!.status,
    );

    return Column(
      children:
          List.generate(allStatuses.length, (index) {
              final status = allStatuses[index];
              final isActive = index <= currentStatusIndex;
              final isRejected =
                  _controller.issue.value!.status ==
                  AppConstants.statusRejected;

              // If the issue is rejected, only the submitted status should be active
              final isActiveWithRejection = isRejected ? index == 0 : isActive;

              return Row(
                children: [
                  // Status Circle
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isActiveWithRejection
                          ? _getStatusColor(status)
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActiveWithRejection
                            ? _getStatusColor(status)
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: isActiveWithRejection
                        ? Icon(
                            getStatusIcon(status),
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),

                  // Status Line (except for the last item)
                  if (index < allStatuses.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color:
                            isActiveWithRejection && index < currentStatusIndex
                            ? _getStatusColor(status)
                            : Colors.grey[300],
                      ),
                    ),

                  // For the last item, add empty space to align with other items
                  if (index == allStatuses.length - 1)
                    Expanded(child: SizedBox()),
                ],
              );
            }).expand((element) => [element, SizedBox(height: 8)]).toList()
            ..removeLast(), // Remove the last SizedBox
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusSubmitted:
        return Color(0xFFFFA000); // Amber
      case AppConstants.statusAcknowledged:
        return Color(0xFF42A5F5); // Blue
      case AppConstants.statusInProgress:
        return Color(0xFF7E57C2); // Purple
      case AppConstants.statusResolved:
        return Color(0xFF66BB6A); // Green
      case AppConstants.statusRejected:
        return Color(0xFFEF5350); // Red
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case AppConstants.statusSubmitted:
        return Icons.send;
      case AppConstants.statusAcknowledged:
        return Icons.visibility;
      case AppConstants.statusInProgress:
        return Icons.engineering;
      case AppConstants.statusResolved:
        return Icons.check;
      case AppConstants.statusRejected:
        return Icons.close;
      default:
        return Icons.circle;
    }
  }

  // Show edit dialog
  void _showEditDialog(BuildContext context) {
    final issue = _controller.issue.value!;
    final titleController = TextEditingController(text: issue.title);
    final descriptionController = TextEditingController(
      text: issue.description,
    );
    final selectedPriority = issue.priority.obs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Issue'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Issue Title',
                  hintText: 'e.g., Pothole on Main Street',
                  prefixIcon: Icon(Icons.title),
                ),
                maxLength: 100,
              ),
              SizedBox(height: 16),

              // Description Field
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the issue in detail',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                maxLength: 500,
              ),
              SizedBox(height: 16),

              // Priority Selection
              Text('Priority', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityButton(
                    context,
                    AppConstants.priorityLow,
                    'Low',
                    Color(0xFF66BB6A),
                    selectedPriority,
                  ),
                  SizedBox(width: 8),
                  _buildPriorityButton(
                    context,
                    AppConstants.priorityMedium,
                    'Medium',
                    Color(0xFFFFA000),
                    selectedPriority,
                  ),
                  SizedBox(width: 8),
                  _buildPriorityButton(
                    context,
                    AppConstants.priorityHigh,
                    'High',
                    Color(0xFFEF5350),
                    selectedPriority,
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter a title',
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[800],
                );
                return;
              }

              if (descriptionController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter a description',
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[800],
                );
                return;
              }

              _controller.editIssue(
                title: titleController.text,
                description: descriptionController.text,
                priority: selectedPriority.value,
              );

              Navigator.of(context).pop();
            },
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Issue'),
        content: Text(
          'Are you sure you want to delete this issue? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.deleteIssue();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Build priority button for edit dialog
  Widget _buildPriorityButton(
    BuildContext context,
    String value,
    String label,
    Color color,
    Rx<String> selectedPriority,
  ) {
    return Expanded(
      child: Obx(() {
        final isSelected = selectedPriority.value == value;

        return OutlinedButton(
          onPressed: () => selectedPriority.value = value,
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? color.withOpacity(0.2) : null,
            side: BorderSide(
              color: isSelected ? color : Colors.grey,
              width: isSelected ? 2 : 1,
            ),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }),
    );
  }

  // Build location map with fallback
  Widget _buildLocationMap(IssueModel issue) {
    // Check if Google Maps is supported on this platform
    if (PlatformUtils.isGoogleMapsSupported) {
      try {
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(issue.location.latitude, issue.location.longitude),
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: MarkerId('issue_location'),
              position: LatLng(
                issue.location.latitude,
                issue.location.longitude,
              ),
            ),
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        );
      } catch (e) {
        print("Google Maps error in issue tracker: $e");
        return _buildLocationFallback(issue);
      }
    } else {
      // Use fallback on platforms where Maps isn't supported
      return _buildLocationFallback(issue);
    }
  }

  // Fallback widget when Google Maps isn't available
  Widget _buildLocationFallback(IssueModel issue) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 48, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              'Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Lat: ${issue.location.latitude.toStringAsFixed(6)}',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              'Long: ${issue.location.longitude.toStringAsFixed(6)}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHistory(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: _controller.statusUpdates.map((update) {
          final Color statusColor = _getStatusColor(update.status);

          return Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    getStatusIcon(update.status),
                    color: statusColor,
                    size: 16,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            update.status.capitalize!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          Text(
                            _controller.getFormattedTimestamp(update.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      if (update.comment != null)
                        Text(update.comment!, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
