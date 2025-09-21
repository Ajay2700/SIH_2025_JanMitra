import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/core/utils/constants.dart';
import 'package:jan_mitra/data/models/comment_model.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/data/models/user_model.dart';
import 'package:jan_mitra/data/repository/auth_repository.dart';
import 'package:jan_mitra/data/repository/issue_repository.dart';
import 'package:jan_mitra/data/services/realtime_service.dart';
import 'package:jan_mitra/routes/app_routes.dart';

// Status update model
class StatusUpdate {
  final String status;
  final DateTime timestamp;
  final String? updatedBy;
  final String? comment;

  StatusUpdate({
    required this.status,
    required this.timestamp,
    this.updatedBy,
    this.comment,
  });
}

class IssueTrackerController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final IssueRepository _issueRepository = Get.find<IssueRepository>();
  final RealtimeService _realtimeService = Get.find<RealtimeService>();

  // Subscription for real-time updates
  StreamSubscription? _issueSubscription;
  StreamSubscription? _commentSubscription;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<IssueModel?> issue = Rx<IssueModel?>(null);
  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSubmittingComment = false.obs;

  // Status tracking
  final RxList<StatusUpdate> statusUpdates = <StatusUpdate>[].obs;
  final RxBool showStatusHistory = false.obs;

  final commentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getCurrentUser();

    // Get issue ID from parameters
    if (Get.arguments != null && Get.arguments['issueId'] != null) {
      loadIssueDetails(Get.arguments['issueId']);

      // Subscribe to real-time updates
      _issueSubscription = _realtimeService.issueUpdates.listen(_onIssueUpdate);
      _commentSubscription = _realtimeService.commentUpdates.listen(
        _onCommentUpdate,
      );
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    // Cancel subscriptions when controller is closed
    _issueSubscription?.cancel();
    _commentSubscription?.cancel();
    super.onClose();
  }

  Future<void> getCurrentUser() async {
    try {
      currentUser.value = await _authRepository.getCurrentUser();
    } catch (e) {
      errorMessage.value = 'Failed to get user: ${e.toString()}';
    }
  }

  Future<void> loadIssueDetails(String issueId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final issues = await _issueRepository.getAllIssues();
      issue.value = issues.firstWhere((i) => i.id == issueId);
      await loadComments(issueId);
      _generateStatusUpdates();
    } catch (e) {
      errorMessage.value = 'Failed to load issue details: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Generate status updates from issue data and comments
  void _generateStatusUpdates() {
    if (issue.value == null) return;

    final List<StatusUpdate> updates = [];

    // Add initial submission status
    updates.add(
      StatusUpdate(
        status: AppConstants.statusSubmitted,
        timestamp: issue.value!.createdAt,
        updatedBy: issue.value!.createdBy,
        comment: 'Issue reported',
      ),
    );

    // Add status updates based on comments that mention status changes
    for (var comment in comments) {
      if (_isStatusUpdateComment(comment.message)) {
        updates.add(
          StatusUpdate(
            status: _extractStatusFromComment(comment.message),
            timestamp: comment.createdAt,
            updatedBy: comment.userId,
            comment: comment.message,
          ),
        );
      }
    }

    // Add current status if it's different from the last update
    final currentStatus = issue.value!.status;
    if (updates.isEmpty || updates.last.status != currentStatus) {
      updates.add(
        StatusUpdate(
          status: currentStatus,
          timestamp: issue.value!.updatedAt ?? issue.value!.createdAt,
          updatedBy: issue.value!.assignedTo,
          comment: 'Status updated to $currentStatus',
        ),
      );
    }

    // Sort updates by timestamp
    updates.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    statusUpdates.value = updates;
  }

  // Check if a comment indicates a status update
  bool _isStatusUpdateComment(String comment) {
    final lowerComment = comment.toLowerCase();
    return lowerComment.contains('status') ||
        lowerComment.contains('updated to') ||
        lowerComment.contains('changed to') ||
        lowerComment.contains('marked as');
  }

  // Extract status from comment text
  String _extractStatusFromComment(String comment) {
    final lowerComment = comment.toLowerCase();

    if (lowerComment.contains(AppConstants.statusAcknowledged.toLowerCase())) {
      return AppConstants.statusAcknowledged;
    } else if (lowerComment.contains(
      AppConstants.statusInProgress.toLowerCase(),
    )) {
      return AppConstants.statusInProgress;
    } else if (lowerComment.contains(
      AppConstants.statusResolved.toLowerCase(),
    )) {
      return AppConstants.statusResolved;
    } else if (lowerComment.contains(
      AppConstants.statusRejected.toLowerCase(),
    )) {
      return AppConstants.statusRejected;
    } else {
      return AppConstants.statusSubmitted;
    }
  }

  Future<void> loadComments(String issueId) async {
    try {
      comments.value = await _issueRepository.getCommentsByIssue(issueId);
    } catch (e) {
      errorMessage.value = 'Failed to load comments: ${e.toString()}';
    }
  }

  Future<void> addComment() async {
    if (currentUser.value == null || issue.value == null) {
      errorMessage.value = 'User or issue not available.';
      return;
    }

    if (commentController.text.isEmpty) {
      errorMessage.value = 'Please enter a comment.';
      return;
    }

    isSubmittingComment.value = true;

    try {
      final newComment = await _issueRepository.addComment(
        issueId: issue.value!.id,
        userId: currentUser.value!.id,
        message: commentController.text,
      );

      comments.add(newComment);
      commentController.clear();

      // Notify realtime service about the new comment
      _realtimeService.notifyCommentUpdate(newComment);

      // If this is a status update comment, update the issue status
      if (_isStatusUpdateComment(newComment.message)) {
        final status = _extractStatusFromComment(newComment.message);
        if (status != issue.value!.status) {
          await _issueRepository.updateIssueStatus(
            issueId: issue.value!.id,
            status: status,
            assignedTo: issue.value!.assignedTo,
          );
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to add comment: ${e.toString()}';
    } finally {
      isSubmittingComment.value = false;
    }
  }

  Future<void> refreshData() async {
    if (issue.value != null) {
      await loadIssueDetails(issue.value!.id);
    }
  }

  String getStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return '#FFA000';
      case 'acknowledged':
        return '#42A5F5';
      case 'in_progress':
        return '#7E57C2';
      case 'resolved':
        return '#66BB6A';
      case 'rejected':
        return '#EF5350';
      default:
        return '#9E9E9E';
    }
  }

  // Toggle status history visibility
  void toggleStatusHistory() {
    showStatusHistory.value = !showStatusHistory.value;
  }

  // Check if issue can be edited or deleted (only if status is 'submitted')
  bool canEditIssue() {
    return issue.value?.status == AppConstants.statusSubmitted;
  }

  // Edit issue
  Future<void> editIssue({
    required String title,
    required String description,
    required String priority,
  }) async {
    if (!canEditIssue()) {
      errorMessage.value = 'Only submitted issues can be edited.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final updatedIssue = await _issueRepository.updateIssue(
        issueId: issue.value!.id,
        title: title,
        description: description,
        priority: priority,
      );

      issue.value = updatedIssue;

      // Notify realtime service about the update
      _realtimeService.notifyIssueUpdate(updatedIssue);

      Get.snackbar(
        'Success',
        'Issue updated successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
    } catch (e) {
      errorMessage.value = 'Failed to update issue: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Failed to update issue',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete issue
  Future<void> deleteIssue() async {
    if (!canEditIssue()) {
      errorMessage.value = 'Only submitted issues can be deleted.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _issueRepository.deleteIssue(issue.value!.id);

      Get.snackbar(
        'Success',
        'Issue deleted successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );

      // Navigate back to home
      Get.offAllNamed(Routes.CITIZEN_HOME);
    } catch (e) {
      errorMessage.value = 'Failed to delete issue: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Failed to delete issue',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      isLoading.value = false;
    }
  }

  // Get formatted timestamp for status update
  String getFormattedTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  // Realtime update handlers
  void _onIssueUpdate(IssueModel updatedIssue) {
    if (issue.value?.id == updatedIssue.id) {
      issue.value = updatedIssue;
      _generateStatusUpdates();
    }
  }

  void _onCommentUpdate(CommentModel newComment) {
    if (issue.value?.id == newComment.issueId) {
      if (!comments.any((comment) => comment.id == newComment.id)) {
        comments.add(newComment);
        _generateStatusUpdates();
      }
    }
  }
}
