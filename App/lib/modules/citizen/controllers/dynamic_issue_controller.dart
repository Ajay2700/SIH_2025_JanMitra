import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jan_mitra/data/services/issue_service_supabase.dart';
import 'package:jan_mitra/data/services/firebase_auth_service.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/data/models/location_model.dart';

class DynamicIssueController extends GetxController {
  late IssueServiceSupabase _issueService;

  // Observable lists and states
  final RxList<IssueModel> allIssues = <IssueModel>[].obs;
  final RxList<IssueModel> userIssues = <IssueModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isPosting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, bool> userLikes = <String, bool>{}.obs;
  final RxMap<String, int> likeCounts = <String, int>{}.obs;

  // Real-time subscription
  RealtimeChannel? _realtimeChannel;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    _initializeRealtimeSubscription();
    loadAllIssues();
    loadUserIssues(); // Load user issues on init
  }

  void _initializeService() {
    try {
      _issueService = Get.find<IssueServiceSupabase>();
    } catch (e) {
      // If service is not found, initialize it
      _issueService = Get.put(IssueServiceSupabase());
    }
  }

  @override
  void onClose() {
    _realtimeChannel?.unsubscribe();
    super.onClose();
  }

  // Initialize real-time subscription
  void _initializeRealtimeSubscription() {
    _realtimeChannel = _issueService.subscribeToIssues(_handleRealtimeUpdate);
    print('DEBUG: Real-time subscription initialized');
  }

  // Handle real-time updates
  void _handleRealtimeUpdate(dynamic payload) {
    print('DEBUG: Handling real-time update in controller: $payload');
    // Refresh both all issues and user issues when there's an update
    loadAllIssues();
    loadUserIssues();
  }

  // Helper method to map data to IssueModel
  IssueModel _mapToIssueModel(Map<String, dynamic> data) {
    final locationData = data['location'] as Map<String, dynamic>? ?? {};

    return IssueModel(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      status: data['status'] as String? ?? 'submitted',
      priority: data['priority'] as String? ?? 'medium',
      location: LocationModel(
        latitude: (locationData['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (locationData['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      address: data['address'] as String? ?? '',
      imageUrl: data['image_url'] as String? ?? '',
      createdBy: data['created_by'] as String? ?? 'anonymous',
      assignedTo: null,
      categoryId: null,
      departmentId: null,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : null,
      resolvedAt: null,
    );
  }

  // Load all issues for the feed
  Future<void> loadAllIssues() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final issues = await _issueService.getAllIssues();
      allIssues.value = issues;

      // Load like counts and user likes for each issue
      await _loadLikeData(issues);
    } catch (e) {
      errorMessage.value = 'Failed to load issues: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Load user's own issues
  Future<void> loadUserIssues() async {
    print('DEBUG: loadUserIssues called');
    try {
      final authService = Get.find<FirebaseAuthService>();
      final currentUser = authService.getCurrentUser();
      if (currentUser != null) {
        print('DEBUG: Loading issues for user: ${currentUser.id}');
        final issues = await _issueService.getIssuesByUser(currentUser.id);
        print('DEBUG: Loaded ${issues.length} user issues');
        userIssues.value = issues;
      } else {
        print('DEBUG: No current user found');
        userIssues.value = [];
      }
    } catch (e) {
      print('DEBUG: loadUserIssues failed: $e');
      errorMessage.value = 'Failed to load user issues: $e';
    }
  }

  // Post a new issue
  Future<bool> postIssue({
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required String address,
    required String priority,
    String? imageUrl,
    String? categoryId,
  }) async {
    isPosting.value = true;
    errorMessage.value = '';

    try {
      final authService = Get.find<FirebaseAuthService>();
      final currentUser = authService.getCurrentUser();
      if (currentUser == null) {
        errorMessage.value = 'User not authenticated';
        return false;
      }
      final userId = currentUser.id;

      await _issueService.createIssue(
        title: title,
        description: description,
        latitude: latitude,
        longitude: longitude,
        address: address,
        priority: priority,
        imageUrl: imageUrl,
        userId: userId,
        categoryId: categoryId,
      );

      // Refresh the issues list
      await loadAllIssues();
      await loadUserIssues();

      Get.snackbar(
        'Success',
        'Your issue has been posted successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to post issue: $e';
      Get.snackbar(
        'Error',
        'Failed to post issue: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isPosting.value = false;
    }
  }

  // Toggle like on an issue
  Future<void> toggleLike(String issueId) async {
    try {
      final authService = Get.find<FirebaseAuthService>();
      final currentUser = authService.getCurrentUser();
      if (currentUser == null) {
        Get.snackbar(
          'Error',
          'Please login to like issues',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      final userId = currentUser.id;

      await _issueService.toggleLike(issueId, userId);

      // Update local state
      final currentLikeStatus = userLikes[issueId] ?? false;
      userLikes[issueId] = !currentLikeStatus;

      // Update like count
      final currentCount = likeCounts[issueId] ?? 0;
      likeCounts[issueId] = currentCount + (currentLikeStatus ? -1 : 1);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update like: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Update issue status
  Future<void> updateIssueStatus(String issueId, String status) async {
    try {
      await _issueService.updateIssueStatus(issueId, status);

      // Update local state
      final issueIndex = allIssues.indexWhere((issue) => issue.id == issueId);
      if (issueIndex != -1) {
        final updatedIssue = IssueModel(
          id: allIssues[issueIndex].id,
          title: allIssues[issueIndex].title,
          description: allIssues[issueIndex].description,
          status: status,
          priority: allIssues[issueIndex].priority,
          location: allIssues[issueIndex].location,
          address: allIssues[issueIndex].address,
          imageUrl: allIssues[issueIndex].imageUrl,
          createdBy: allIssues[issueIndex].createdBy,
          assignedTo: allIssues[issueIndex].assignedTo,
          categoryId: allIssues[issueIndex].categoryId,
          departmentId: allIssues[issueIndex].departmentId,
          createdAt: allIssues[issueIndex].createdAt,
          updatedAt: DateTime.now(),
          resolvedAt: status == 'resolved'
              ? DateTime.now()
              : allIssues[issueIndex].resolvedAt,
        );
        allIssues[issueIndex] = updatedIssue;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Load like data for issues
  Future<void> _loadLikeData(List<IssueModel> issues) async {
    final authService = Get.find<FirebaseAuthService>();
    final currentUser = authService.getCurrentUser();

    for (final issue in issues) {
      // Load like count
      final likeCount = await _issueService.getLikeCount(issue.id);
      likeCounts[issue.id] = likeCount;

      // Load user like status if user is logged in
      if (currentUser != null) {
        final hasLiked = await _issueService.hasUserLiked(
          issue.id,
          currentUser.id,
        );
        userLikes[issue.id] = hasLiked;
      }
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadAllIssues();
    await loadUserIssues();
  }

  // Get like count for an issue
  int getLikeCount(String issueId) {
    return likeCounts[issueId] ?? 0;
  }

  // Check if user liked an issue
  bool hasUserLiked(String issueId) {
    return userLikes[issueId] ?? false;
  }
}
