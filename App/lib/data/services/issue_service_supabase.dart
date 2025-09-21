import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jan_mitra/data/services/supabase_service.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/data/models/location_model.dart';

class IssueServiceSupabase {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  // Create a new issue/post
  Future<String> createIssue({
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required String address,
    required String priority,
    String? imageUrl,
    String? userId,
    String? categoryId,
  }) async {
    try {
      final issueData = {
        'title': title,
        'description': description,
        'status': 'open', // Use 'open' instead of 'submitted' to match enum
        'priority': priority,
        'user_id': userId, // Use 'user_id' instead of 'created_by'
        'category_id': categoryId,
        'location_address': address, // Use separate fields
        'latitude': latitude,
        'longitude': longitude,
        'ticket_type': 'complaint', // Required field
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add image_url if provided
      if (imageUrl != null && imageUrl.isNotEmpty) {
        issueData['attachments'] = [imageUrl];
      }

      final response = await _supabaseService.insertData('tickets', issueData);
      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create issue: $e');
    }
  }

  // Get all issues (for the feed)
  Future<List<IssueModel>> getAllIssues({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabaseService.fetchData(
        'tickets',
        orderBy: 'created_at.desc',
        limit: limit,
        offset: offset,
      );

      return response.map((data) => _mapToIssueModel(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch issues: $e');
    }
  }

  // Get issues by user
  Future<List<IssueModel>> getIssuesByUser(String userId) async {
    try {
      print('DEBUG: getIssuesByUser called with userId: $userId');
      final response = await _supabaseService.fetchData(
        'tickets',
        filters: {'user_id': userId},
        orderBy: 'created_at.desc',
      );
      print('DEBUG: getIssuesByUser found ${response.length} issues');

      return response.map((data) => _mapToIssueModel(data)).toList();
    } catch (e) {
      print('DEBUG: getIssuesByUser failed: $e');
      throw Exception('Failed to fetch user issues: $e');
    }
  }

  // Update issue status
  Future<void> updateIssueStatus(String issueId, String status) async {
    try {
      await _supabaseService.updateData('tickets', issueId, {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update issue status: $e');
    }
  }

  // Like/Unlike an issue (disabled for now - table doesn't exist)
  Future<void> toggleLike(String issueId, String userId) async {
    // Like functionality disabled - issue_likes table not in schema
    // This is a placeholder for future implementation
    print('Like functionality not implemented - issue_likes table missing');
  }

  // Get like count for an issue (disabled for now)
  Future<int> getLikeCount(String issueId) async {
    // Return 0 for now since likes table doesn't exist
    return 0;
  }

  // Check if user liked an issue (disabled for now)
  Future<bool> hasUserLiked(String issueId, String userId) async {
    // Return false for now since likes table doesn't exist
    return false;
  }

  // Subscribe to real-time updates
  RealtimeChannel subscribeToIssues([Function? onUpdate]) {
    return _supabaseService
        .createSubscription('tickets')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tickets',
          callback: (payload) {
            print('DEBUG: Real-time ticket update: $payload');
            if (onUpdate != null) {
              onUpdate(payload);
            }
          },
        )
        .subscribe();
  }

  // Helper method to map database data to IssueModel
  IssueModel _mapToIssueModel(Map<String, dynamic> data) {
    // Handle image URL from attachments array or direct field
    String imageUrl = '';
    if (data['attachments'] != null &&
        (data['attachments'] as List).isNotEmpty) {
      imageUrl = (data['attachments'] as List).first.toString();
    } else if (data['image_url'] != null) {
      imageUrl = data['image_url'] as String;
    }

    return IssueModel(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      status: _mapStatus(data['status'] as String? ?? 'open'),
      priority: data['priority'] as String? ?? 'medium',
      location: LocationModel(
        latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      address: data['location_address'] as String? ?? '',
      imageUrl: imageUrl,
      createdBy:
          data['user_id'] as String? ??
          'anonymous', // Use 'user_id' instead of 'created_by'
      assignedTo: data['assigned_to'] as String?,
      categoryId: data['category_id'] as String?,
      departmentId: data['department_id'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : null,
      resolvedAt: data['resolved_at'] != null
          ? DateTime.parse(data['resolved_at'] as String)
          : null,
    );
  }

  // Helper method to map ticket status to issue status
  String _mapStatus(String ticketStatus) {
    switch (ticketStatus) {
      case 'open':
        return 'submitted';
      case 'in_progress':
        return 'in_progress';
      case 'pending':
        return 'acknowledged';
      case 'resolved':
        return 'resolved';
      case 'closed':
        return 'resolved';
      case 'rejected':
        return 'rejected';
      case 'escalated':
        return 'in_progress';
      case 'forwarded':
        return 'in_progress';
      default:
        return 'submitted';
    }
  }
}
