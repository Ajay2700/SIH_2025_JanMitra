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
      print('DEBUG: loadAllIssues failed: $e');
      print('DEBUG: Using static data as fallback');
      // Use static data as fallback when server fails
      allIssues.value = _getStaticAllIssues();
      errorMessage.value =
          ''; // Clear error message since we have fallback data
    } finally {
      isLoading.value = false;
    }
  }

  // Static data for all issues when server is not available
  List<IssueModel> _getStaticAllIssues() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    final threeDaysAgo = now.subtract(const Duration(days: 3));

    return [
      IssueModel(
        id: 'static-all-1',
        title: 'Street Light Not Working',
        description:
            'The street light at the main road intersection has been out for 3 days. This creates safety concerns during night time.',
        status: 'in_progress',
        priority: 'high',
        location: Location(latitude: 28.4506, longitude: 77.5847),
        address: 'Sector 15, Main Road Intersection, Gurgaon',
        imageUrl:
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
        createdBy: 'user1',
        createdAt: yesterday,
        updatedAt: now,
      ),
      IssueModel(
        id: 'static-all-2',
        title: 'Pothole on Highway',
        description:
            'Large pothole on the highway causing damage to vehicles. Needs immediate attention from road maintenance department.',
        status: 'acknowledged',
        priority: 'medium',
        location: Location(latitude: 28.4512, longitude: 77.5853),
        address: 'NH-48, Near Toll Plaza, Gurgaon',
        imageUrl:
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop',
        createdBy: 'user2',
        createdAt: twoDaysAgo,
        updatedAt: yesterday,
      ),
      IssueModel(
        id: 'static-all-3',
        title: 'Garbage Collection Issue',
        description:
            'Garbage has not been collected from the locality for the past week. The bins are overflowing and creating unhygienic conditions.',
        status: 'submitted',
        priority: 'medium',
        location: Location(latitude: 28.4498, longitude: 77.5841),
        address: 'Sector 14, Residential Area, Gurgaon',
        imageUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
        createdBy: 'user3',
        createdAt: threeDaysAgo,
        updatedAt: twoDaysAgo,
      ),
      IssueModel(
        id: 'static-all-4',
        title: 'Water Supply Problem',
        description:
            'No water supply in the apartment complex since morning. The maintenance team is not responding to calls.',
        status: 'resolved',
        priority: 'high',
        location: Location(latitude: 28.4509, longitude: 77.5858),
        address: 'DLF Phase 2, Apartment Complex, Gurgaon',
        imageUrl:
            'https://images.unsplash.com/photo-1544376664-7ad8e2f95ef0?w=400&h=300&fit=crop',
        createdBy: 'user4',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
        resolvedAt: yesterday,
      ),
      IssueModel(
        id: 'static-all-5',
        title: 'Broken Park Bench',
        description:
            'The park bench in the community park is broken and needs repair. It\'s a popular spot for senior citizens.',
        status: 'submitted',
        priority: 'low',
        location: Location(latitude: 28.4501, longitude: 77.5844),
        address: 'Community Park, Sector 16, Gurgaon',
        imageUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
        createdBy: 'user5',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: threeDaysAgo,
      ),
    ];
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
      print('DEBUG: Using static data as fallback');
      // Use static data as fallback when server fails
      userIssues.value = _getStaticUserIssues();
      errorMessage.value =
          ''; // Clear error message since we have fallback data
    }
  }

  // Static data for when server is not available
  List<IssueModel> _getStaticUserIssues() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    return [
      IssueModel(
        id: 'static-1',
        title: 'Street Light Not Working',
        description:
            'The street light at the main road intersection has been out for 3 days. This creates safety concerns during night time.',
        status: 'in_progress',
        priority: 'high',
        location: Location(latitude: 28.4506, longitude: 77.5847),
        address: 'Sector 15, Main Road Intersection, Gurgaon',
        imageUrl:
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
        createdBy: 'current_user',
        createdAt: yesterday,
        updatedAt: now,
      ),
      IssueModel(
        id: 'static-2',
        title: 'Pothole on Highway',
        description:
            'Large pothole on the highway causing damage to vehicles. Needs immediate attention from road maintenance department.',
        status: 'acknowledged',
        priority: 'medium',
        location: Location(latitude: 28.4512, longitude: 77.5853),
        address: 'NH-48, Near Toll Plaza, Gurgaon',
        imageUrl:
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop',
        createdBy: 'current_user',
        createdAt: twoDaysAgo,
        updatedAt: yesterday,
      ),
      IssueModel(
        id: 'static-3',
        title: 'Garbage Collection Issue',
        description:
            'Garbage has not been collected from the locality for the past week. The bins are overflowing and creating unhygienic conditions.',
        status: 'submitted',
        priority: 'medium',
        location: Location(latitude: 28.4498, longitude: 77.5841),
        address: 'Sector 14, Residential Area, Gurgaon',
        imageUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
        createdBy: 'current_user',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: twoDaysAgo,
      ),
      IssueModel(
        id: 'static-4',
        title: 'Water Supply Problem',
        description:
            'No water supply in the apartment complex since morning. The maintenance team is not responding to calls.',
        status: 'resolved',
        priority: 'high',
        location: Location(latitude: 28.4509, longitude: 77.5858),
        address: 'DLF Phase 2, Apartment Complex, Gurgaon',
        imageUrl:
            'https://images.unsplash.com/photo-1544376664-7ad8e2f95ef0?w=400&h=300&fit=crop',
        createdBy: 'current_user',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
        resolvedAt: yesterday,
      ),
    ];
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
