import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:jan_mitra/core/utils/constants.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/data/models/comment_model.dart';
import 'package:jan_mitra/data/models/location_model.dart';
import 'package:jan_mitra/data/services/supabase_service.dart';

class IssueService extends GetxService {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final RxBool isMockEnabled = false.obs;
  final uuid = Uuid();

  // Mock data for development
  final List<IssueModel> _mockIssues = [];
  final Map<String, List<CommentModel>> _mockComments = {};

  // Initialize with mock data for development
  Future<IssueService> init() async {
    // For production, set isMockEnabled to false
    if (kReleaseMode) {
      isMockEnabled.value = false;
    }

    if (isMockEnabled.value) {
      _generateMockData();
    }

    return this;
  }

  // Create issue with multiple attachments
  Future<IssueModel?> createIssueWithAttachments({
    required String title,
    required String description,
    required String userId,
    required String priority,
    required double latitude,
    required double longitude,
    required String address,
    List<String>? attachmentPaths,
    String? categoryId,
  }) async {
    try {
      List<String> attachmentUrls = [];

      // Upload attachments if provided
      if (attachmentPaths != null && attachmentPaths.isNotEmpty) {
        for (String attachmentPath in attachmentPaths) {
          final File file = File(attachmentPath);
          final fileBytes = await file.readAsBytes();
          final fileExt = attachmentPath.split('.').last;
          // final fileName = attachmentPath.split('/').last; // Currently unused

          final fileUrl = await _supabaseService.uploadFile(
            'issue-attachments',
            'issues/${DateTime.now().millisecondsSinceEpoch}',
            fileBytes,
            fileExt,
          );

          attachmentUrls.add(fileUrl);
        }
      }

      // Create issue in database
      final Map<String, dynamic> issueData = {
        'title': title,
        'description': description,
        'status': AppConstants.statusSubmitted,
        'priority': priority,
        'location': 'POINT($longitude $latitude)',
        'address': address,
        'created_by': userId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (categoryId != null) {
        issueData['category_id'] = categoryId;
      }

      if (attachmentUrls.isNotEmpty) {
        issueData['attachment_urls'] = attachmentUrls;
      }

      final response = await _supabaseService.insertData('issues', issueData);

      return IssueModel(
        id: response['id'],
        title: response['title'],
        description: response['description'],
        status: response['status'],
        priority: response['priority'],
        location: LocationModel(latitude: latitude, longitude: longitude),
        address: response['address'],
        imageUrl: attachmentUrls.isNotEmpty ? attachmentUrls.first : '',
        createdBy: response['created_by'],
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating issue with attachments: $e');
      }
      return null;
    }
  }

  void _generateMockData() {
    // Generate some mock issues
    final mockIssues = [
      IssueModel(
        id: 'issue-001',
        title: 'Pothole on Main Street',
        description: 'Large pothole causing traffic issues',
        status: AppConstants.statusSubmitted,
        priority: AppConstants.priorityHigh,
        location: LocationModel(latitude: 28.6139, longitude: 77.2090),
        address: 'Main Street, New Delhi',
        imageUrl: 'https://via.placeholder.com/300/FF5733/FFFFFF?text=Pothole',
        createdBy: 'user-123',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      IssueModel(
        id: 'issue-002',
        title: 'Street Light Not Working',
        description:
            'Street light at the corner of Park Avenue is not working for the past week',
        status: AppConstants.statusAcknowledged,
        priority: AppConstants.priorityMedium,
        location: LocationModel(latitude: 28.6129, longitude: 77.2295),
        address: 'Park Avenue, New Delhi',
        imageUrl:
            'https://via.placeholder.com/300/33A8FF/FFFFFF?text=Street+Light',
        createdBy: 'user-123',
        assignedTo: 'staff-456',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        updatedAt: DateTime.now().subtract(Duration(days: 4)),
      ),
      IssueModel(
        id: 'issue-003',
        title: 'Garbage Not Collected',
        description:
            'Garbage has not been collected from the community bin for over a week',
        status: AppConstants.statusInProgress,
        priority: AppConstants.priorityMedium,
        location: LocationModel(latitude: 28.5355, longitude: 77.2410),
        address: 'Green Park, New Delhi',
        imageUrl: 'https://via.placeholder.com/300/33FF57/FFFFFF?text=Garbage',
        createdBy: 'user-123',
        assignedTo: 'staff-789',
        createdAt: DateTime.now().subtract(Duration(days: 7)),
        updatedAt: DateTime.now().subtract(Duration(days: 3)),
      ),
      IssueModel(
        id: 'issue-004',
        title: 'Water Supply Disruption',
        description: 'No water supply in the area since yesterday morning',
        status: AppConstants.statusResolved,
        priority: AppConstants.priorityHigh,
        location: LocationModel(latitude: 28.7041, longitude: 77.1025),
        address: 'Rohini, New Delhi',
        imageUrl: 'https://via.placeholder.com/300/C133FF/FFFFFF?text=Water',
        createdBy: 'user-123',
        assignedTo: 'staff-456',
        createdAt: DateTime.now().subtract(Duration(days: 10)),
        updatedAt: DateTime.now().subtract(Duration(days: 1)),
        resolvedAt: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];

    _mockIssues.addAll(mockIssues);

    // Generate mock comments
    _mockComments['issue-001'] = [
      CommentModel(
        id: 'comment-001',
        issueId: 'issue-001',
        userId: 'user-123',
        message: 'I almost had an accident because of this pothole!',
        createdAt: DateTime.now().subtract(Duration(days: 2, hours: 2)),
        user: {'name': 'Test User'},
      ),
    ];

    _mockComments['issue-002'] = [
      CommentModel(
        id: 'comment-002',
        issueId: 'issue-002',
        userId: 'staff-456',
        message:
            'We have acknowledged this issue and will send a technician soon.',
        createdAt: DateTime.now().subtract(Duration(days: 4)),
        user: {'name': 'Staff Member'},
      ),
      CommentModel(
        id: 'comment-003',
        issueId: 'issue-002',
        userId: 'user-123',
        message: 'Thank you for the quick response!',
        createdAt: DateTime.now().subtract(Duration(days: 4, hours: 1)),
        user: {'name': 'Test User'},
      ),
    ];

    _mockComments['issue-003'] = [
      CommentModel(
        id: 'comment-004',
        issueId: 'issue-003',
        userId: 'staff-789',
        message: 'We have assigned a sanitation team to address this issue.',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        user: {'name': 'Sanitation Dept'},
      ),
      CommentModel(
        id: 'comment-005',
        issueId: 'issue-003',
        userId: 'staff-789',
        message: 'The team is currently working on clearing the garbage.',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        user: {'name': 'Sanitation Dept'},
      ),
    ];

    _mockComments['issue-004'] = [
      CommentModel(
        id: 'comment-006',
        issueId: 'issue-004',
        userId: 'staff-456',
        message:
            'We have identified a burst pipe as the cause of the disruption.',
        createdAt: DateTime.now().subtract(Duration(days: 9)),
        user: {'name': 'Water Dept'},
      ),
      CommentModel(
        id: 'comment-007',
        issueId: 'issue-004',
        userId: 'staff-456',
        message:
            'Repair work has started and should be completed within 24 hours.',
        createdAt: DateTime.now().subtract(Duration(days: 8)),
        user: {'name': 'Water Dept'},
      ),
      CommentModel(
        id: 'comment-008',
        issueId: 'issue-004',
        userId: 'staff-456',
        message:
            'The issue has been resolved and water supply has been restored.',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        user: {'name': 'Water Dept'},
      ),
    ];
  }

  // Create a new issue
  Future<IssueModel> createIssue({
    required String title,
    required String description,
    required String imagePath,
    required double latitude,
    required double longitude,
    required String address,
    required String priority,
    required String userId,
    String? categoryId,
  }) async {
    if (isMockEnabled.value) {
      await Future.delayed(Duration(seconds: 2)); // Simulate network delay

      final newIssue = IssueModel(
        id: 'issue-${uuid.v4()}',
        title: title,
        description: description,
        status: AppConstants.statusSubmitted,
        priority: priority,
        location: LocationModel(latitude: latitude, longitude: longitude),
        address: address,
        imageUrl:
            'https://via.placeholder.com/300/FF5733/FFFFFF?text=${title.replaceAll(' ', '+')}',
        createdBy: userId,
        createdAt: DateTime.now(),
      );

      _mockIssues.add(newIssue);
      return newIssue;
    } else {
      try {
        // Upload image to Supabase Storage
        final File imageFile = File(imagePath);
        final fileBytes = await imageFile.readAsBytes();
        final fileExt = imagePath.split('.').last;

        final imageUrl = await _supabaseService.uploadFile(
          'issue_images',
          'issues',
          fileBytes,
          fileExt,
        );

        // Create issue in database
        final Map<String, dynamic> issueData = {
          'title': title,
          'description': description,
          'status': AppConstants.statusSubmitted,
          'priority': priority,
          'location': 'POINT($longitude $latitude)',
          'address': address,
          'image_url': imageUrl,
          'created_by': userId,
          'created_at': DateTime.now().toIso8601String(),
        };

        if (categoryId != null) {
          issueData['category_id'] = categoryId;
        }

        final response = await _supabaseService.insertData('issues', issueData);

        return IssueModel(
          id: response['id'],
          title: response['title'],
          description: response['description'],
          status: response['status'],
          priority: response['priority'],
          location: LocationModel(
            latitude: double.parse(
              response['location'].toString().split(' ')[1].replaceAll(')', ''),
            ),
            longitude: double.parse(
              response['location']
                  .toString()
                  .split(' ')[0]
                  .replaceAll('POINT(', ''),
            ),
          ),
          address: response['address'],
          imageUrl: response['image_url'],
          createdBy: response['created_by'],
          assignedTo: response['assigned_to'],
          categoryId: response['category_id'],
          departmentId: response['department_id'],
          createdAt: DateTime.parse(response['created_at']),
          updatedAt: response['updated_at'] != null
              ? DateTime.parse(response['updated_at'])
              : null,
          resolvedAt: response['resolved_at'] != null
              ? DateTime.parse(response['resolved_at'])
              : null,
        );
      } catch (e) {
        throw Exception('Failed to create issue: $e');
      }
    }
  }

  // Get all issues
  Future<List<IssueModel>> getAllIssues({
    String? status,
    String? priority,
    String? categoryId,
    String? departmentId,
    String? userId,
    String? assignedTo,
    int? limit,
    int? offset,
  }) async {
    if (isMockEnabled.value) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      var filteredIssues = List<IssueModel>.from(_mockIssues);

      if (status != null) {
        filteredIssues = filteredIssues
            .where((issue) => issue.status == status)
            .toList();
      }

      if (priority != null) {
        filteredIssues = filteredIssues
            .where((issue) => issue.priority == priority)
            .toList();
      }

      if (userId != null) {
        filteredIssues = filteredIssues
            .where((issue) => issue.createdBy == userId)
            .toList();
      }

      if (assignedTo != null) {
        filteredIssues = filteredIssues
            .where((issue) => issue.assignedTo == assignedTo)
            .toList();
      }

      // Sort by created date (newest first)
      filteredIssues.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (limit != null && offset != null) {
        final end = offset + limit;
        if (end <= filteredIssues.length) {
          return filteredIssues.sublist(offset, end);
        } else if (offset < filteredIssues.length) {
          return filteredIssues.sublist(offset);
        } else {
          return [];
        }
      }

      return filteredIssues;
    } else {
      try {
        final Map<String, dynamic> filters = {};

        if (status != null) filters['status'] = status;
        if (priority != null) filters['priority'] = priority;
        if (categoryId != null) filters['category_id'] = categoryId;
        if (departmentId != null) filters['department_id'] = departmentId;
        if (userId != null) filters['created_by'] = userId;
        if (assignedTo != null) filters['assigned_to'] = assignedTo;

        final response = await _supabaseService.fetchData(
          'issues',
          filters: filters,
          orderBy: 'created_at.desc',
          limit: limit,
          offset: offset,
        );

        return response
            .map(
              (data) => IssueModel(
                id: data['id'],
                title: data['title'],
                description: data['description'],
                status: data['status'],
                priority: data['priority'],
                location: LocationModel(
                  latitude: double.parse(
                    data['location']
                        .toString()
                        .split(' ')[1]
                        .replaceAll(')', ''),
                  ),
                  longitude: double.parse(
                    data['location']
                        .toString()
                        .split(' ')[0]
                        .replaceAll('POINT(', ''),
                  ),
                ),
                address: data['address'],
                imageUrl: data['image_url'],
                createdBy: data['created_by'],
                assignedTo: data['assigned_to'],
                categoryId: data['category_id'],
                departmentId: data['department_id'],
                createdAt: DateTime.parse(data['created_at']),
                updatedAt: data['updated_at'] != null
                    ? DateTime.parse(data['updated_at'])
                    : null,
                resolvedAt: data['resolved_at'] != null
                    ? DateTime.parse(data['resolved_at'])
                    : null,
              ),
            )
            .toList();
      } catch (e) {
        throw Exception('Failed to get issues: $e');
      }
    }
  }

  // Get issue by ID
  Future<IssueModel> getIssueById(String issueId) async {
    if (isMockEnabled.value) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      final issue = _mockIssues.firstWhere(
        (issue) => issue.id == issueId,
        orElse: () => throw Exception('Issue not found'),
      );

      return issue;
    } else {
      try {
        final response = await _supabaseService.fetchData(
          'issues',
          filters: {'id': issueId},
        );

        if (response.isEmpty) {
          throw Exception('Issue not found');
        }

        final data = response.first;

        return IssueModel(
          id: data['id'],
          title: data['title'],
          description: data['description'],
          status: data['status'],
          priority: data['priority'],
          location: LocationModel(
            latitude: double.parse(
              data['location'].toString().split(' ')[1].replaceAll(')', ''),
            ),
            longitude: double.parse(
              data['location']
                  .toString()
                  .split(' ')[0]
                  .replaceAll('POINT(', ''),
            ),
          ),
          address: data['address'],
          imageUrl: data['image_url'],
          createdBy: data['created_by'],
          assignedTo: data['assigned_to'],
          categoryId: data['category_id'],
          departmentId: data['department_id'],
          createdAt: DateTime.parse(data['created_at']),
          updatedAt: data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null,
          resolvedAt: data['resolved_at'] != null
              ? DateTime.parse(data['resolved_at'])
              : null,
        );
      } catch (e) {
        throw Exception('Failed to get issue: $e');
      }
    }
  }

  // Update issue
  Future<IssueModel> updateIssue({
    required String issueId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assignedTo,
    String? departmentId,
    String? categoryId,
  }) async {
    if (isMockEnabled.value) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      final index = _mockIssues.indexWhere((issue) => issue.id == issueId);
      if (index == -1) {
        throw Exception('Issue not found');
      }

      final issue = _mockIssues[index];

      final updatedIssue = IssueModel(
        id: issue.id,
        title: title ?? issue.title,
        description: description ?? issue.description,
        status: status ?? issue.status,
        priority: priority ?? issue.priority,
        location: issue.location,
        address: issue.address,
        imageUrl: issue.imageUrl,
        createdBy: issue.createdBy,
        assignedTo: assignedTo ?? issue.assignedTo,
        departmentId: departmentId ?? issue.departmentId,
        categoryId: categoryId ?? issue.categoryId,
        createdAt: issue.createdAt,
        updatedAt: DateTime.now(),
        resolvedAt: status == AppConstants.statusResolved
            ? DateTime.now()
            : issue.resolvedAt,
      );

      _mockIssues[index] = updatedIssue;

      return updatedIssue;
    } else {
      try {
        final Map<String, dynamic> updateData = {};

        if (title != null) updateData['title'] = title;
        if (description != null) updateData['description'] = description;
        if (status != null) updateData['status'] = status;
        if (priority != null) updateData['priority'] = priority;
        if (assignedTo != null) updateData['assigned_to'] = assignedTo;
        if (departmentId != null) updateData['department_id'] = departmentId;
        if (categoryId != null) updateData['category_id'] = categoryId;

        updateData['updated_at'] = DateTime.now().toIso8601String();

        if (status == AppConstants.statusResolved) {
          updateData['resolved_at'] = DateTime.now().toIso8601String();
        }

        final response = await _supabaseService.updateData(
          'issues',
          issueId,
          updateData,
        );

        return IssueModel(
          id: response['id'],
          title: response['title'],
          description: response['description'],
          status: response['status'],
          priority: response['priority'],
          location: LocationModel(
            latitude: double.parse(
              response['location'].toString().split(' ')[1].replaceAll(')', ''),
            ),
            longitude: double.parse(
              response['location']
                  .toString()
                  .split(' ')[0]
                  .replaceAll('POINT(', ''),
            ),
          ),
          address: response['address'],
          imageUrl: response['image_url'],
          createdBy: response['created_by'],
          assignedTo: response['assigned_to'],
          categoryId: response['category_id'],
          departmentId: response['department_id'],
          createdAt: DateTime.parse(response['created_at']),
          updatedAt: response['updated_at'] != null
              ? DateTime.parse(response['updated_at'])
              : null,
          resolvedAt: response['resolved_at'] != null
              ? DateTime.parse(response['resolved_at'])
              : null,
        );
      } catch (e) {
        throw Exception('Failed to update issue: $e');
      }
    }
  }

  // Update issue status
  Future<IssueModel> updateIssueStatus({
    required String issueId,
    required String status,
    String? assignedTo,
  }) async {
    return updateIssue(
      issueId: issueId,
      status: status,
      assignedTo: assignedTo,
    );
  }

  // Delete issue
  Future<void> deleteIssue(String issueId) async {
    if (isMockEnabled.value) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      final index = _mockIssues.indexWhere((issue) => issue.id == issueId);
      if (index == -1) {
        throw Exception('Issue not found');
      }

      _mockIssues.removeAt(index);
      _mockComments.remove(issueId);
    } else {
      try {
        // Get issue to get image URL
        final issue = await getIssueById(issueId);

        // Delete issue from database
        await _supabaseService.deleteData('issues', issueId);

        // Delete image from storage
        final imageUrl = issue.imageUrl;
        final imagePath = imageUrl.split('/').last;
        await _supabaseService.deleteFile('issue_images', 'issues/$imagePath');
      } catch (e) {
        throw Exception('Failed to delete issue: $e');
      }
    }
  }

  // Get comments for an issue
  Future<List<CommentModel>> getCommentsByIssue(String issueId) async {
    if (isMockEnabled.value) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      return _mockComments[issueId] ?? [];
    } else {
      try {
        final response = await _supabaseService.client
            .from('comments')
            .select('*, user:users(name)')
            .eq('issue_id', issueId)
            .order('created_at', ascending: true);

        return (response as List)
            .map(
              (data) => CommentModel(
                id: data['id'],
                issueId: data['issue_id'],
                userId: data['user_id'],
                message: data['message'],
                createdAt: DateTime.parse(data['created_at']),
                user: data['user'],
              ),
            )
            .toList();
      } catch (e) {
        throw Exception('Failed to get comments: $e');
      }
    }
  }

  // Add a comment to an issue
  Future<CommentModel> addComment({
    required String issueId,
    required String userId,
    required String message,
  }) async {
    if (isMockEnabled.value) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      final newComment = CommentModel(
        id: 'comment-${uuid.v4()}',
        issueId: issueId,
        userId: userId,
        message: message,
        createdAt: DateTime.now(),
        user: {'name': userId == 'user-123' ? 'Test User' : 'Staff Member'},
      );

      if (_mockComments[issueId] == null) {
        _mockComments[issueId] = [];
      }

      _mockComments[issueId]!.add(newComment);

      return newComment;
    } else {
      try {
        final commentData = {
          'issue_id': issueId,
          'user_id': userId,
          'message': message,
          'created_at': DateTime.now().toIso8601String(),
        };

        final response = await _supabaseService.insertData(
          'comments',
          commentData,
        );

        // Get user info
        final userData = await _supabaseService.fetchData(
          'users',
          filters: {'id': userId},
        );

        return CommentModel(
          id: response['id'],
          issueId: response['issue_id'],
          userId: response['user_id'],
          message: response['message'],
          createdAt: DateTime.parse(response['created_at']),
          user: {'name': userData.first['name']},
        );
      } catch (e) {
        throw Exception('Failed to add comment: $e');
      }
    }
  }
}
