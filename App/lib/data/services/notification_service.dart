import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:jan_mitra/data/models/notification_model.dart';
import 'package:jan_mitra/data/services/supabase_service.dart';

class NotificationService extends GetxService {
  final SupabaseService? _supabaseService = Get.isRegistered<SupabaseService>()
      ? Get.find<SupabaseService>()
      : null;
  final RxBool isMockEnabled = true.obs;
  final uuid = Uuid();

  // Mock data for development
  final List<NotificationModel> _mockNotifications = [];

  // Initialize with mock data for development
  Future<NotificationService> init() async {
    // For production, set isMockEnabled to false
    if (kReleaseMode) {
      isMockEnabled.value = false;
    }

    if (isMockEnabled.value) {
      _generateMockNotifications();
    }

    print("***** MockNotificationService init completed *****");
    return this;
  }

  void _generateMockNotifications() {
    // Generate some mock notifications
    final mockNotifications = [
      NotificationModel(
        id: 'notification-001',
        userId: 'user-123',
        title: 'Issue Acknowledged',
        message: 'Your issue "Street Light Not Working" has been acknowledged.',
        relatedTo: 'issue-002',
        isRead: false,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      NotificationModel(
        id: 'notification-002',
        userId: 'user-123',
        title: 'Issue In Progress',
        message: 'Your issue "Garbage Not Collected" is now in progress.',
        relatedTo: 'issue-003',
        isRead: true,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      NotificationModel(
        id: 'notification-003',
        userId: 'user-123',
        title: 'Issue Resolved',
        message: 'Your issue "Water Supply Disruption" has been resolved.',
        relatedTo: 'issue-004',
        isRead: false,
        createdAt: DateTime.now().subtract(Duration(hours: 5)),
      ),
      NotificationModel(
        id: 'notification-004',
        userId: 'user-123',
        title: 'New Comment',
        message:
            'Staff Member commented on your issue "Street Light Not Working".',
        relatedTo: 'issue-002',
        isRead: false,
        createdAt: DateTime.now().subtract(Duration(days: 4)),
      ),
    ];

    _mockNotifications.addAll(mockNotifications);
  }

  // Get notifications for a user
  Future<List<NotificationModel>> getNotifications(
    String userId, {
    bool? isRead,
  }) async {
    if (isMockEnabled.value) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      var filteredNotifications = _mockNotifications
          .where((n) => n.userId == userId)
          .toList();

      if (isRead != null) {
        filteredNotifications = filteredNotifications
            .where((n) => n.isRead == isRead)
            .toList();
      }

      // Sort by created date (newest first)
      filteredNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return filteredNotifications;
    } else {
      try {
        final Map<String, dynamic> filters = {'user_id': userId};

        if (isRead != null) {
          filters['is_read'] = isRead;
        }

        final response = await _supabaseService!.fetchData(
          'notifications',
          filters: filters,
          orderBy: 'created_at.desc',
        );

        return response
            .map(
              (data) => NotificationModel(
                id: data['id'],
                userId: data['user_id'],
                title: data['title'],
                message: data['message'],
                relatedTo: data['related_to'],
                isRead: data['is_read'],
                createdAt: DateTime.parse(data['created_at']),
              ),
            )
            .toList();
      } catch (e) {
        throw Exception('Failed to get notifications: $e');
      }
    }
  }

  // Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    if (isMockEnabled.value) {
      return _mockNotifications
          .where((n) => n.userId == userId && !n.isRead)
          .length;
    } else {
      try {
        final response = await _supabaseService!.client
            .from('notifications')
            .select('*')
            .eq('user_id', userId)
            .eq('is_read', false);

        return response.length;
      } catch (e) {
        throw Exception('Failed to get unread count: $e');
      }
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    if (isMockEnabled.value) {
      await Future.delayed(
        Duration(milliseconds: 500),
      ); // Simulate network delay

      final index = _mockNotifications.indexWhere(
        (n) => n.id == notificationId,
      );
      if (index != -1) {
        _mockNotifications[index] = _mockNotifications[index].copyWith(
          isRead: true,
        );
      }
    } else {
      try {
        await _supabaseService!.updateData('notifications', notificationId, {
          'is_read': true,
        });
      } catch (e) {
        throw Exception('Failed to mark notification as read: $e');
      }
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    if (isMockEnabled.value) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      for (int i = 0; i < _mockNotifications.length; i++) {
        if (_mockNotifications[i].userId == userId) {
          _mockNotifications[i] = _mockNotifications[i].copyWith(isRead: true);
        }
      }
    } else {
      try {
        await _supabaseService!.client
            .from('notifications')
            .update({'is_read': true})
            .eq('user_id', userId)
            .eq('is_read', false);
      } catch (e) {
        throw Exception('Failed to mark all notifications as read: $e');
      }
    }
  }

  // Create a notification
  Future<NotificationModel> createNotification({
    required String userId,
    required String title,
    required String message,
    String? relatedTo,
  }) async {
    if (isMockEnabled.value) {
      await Future.delayed(
        Duration(milliseconds: 500),
      ); // Simulate network delay

      final newNotification = NotificationModel(
        id: 'notification-${uuid.v4()}',
        userId: userId,
        title: title,
        message: message,
        relatedTo: relatedTo,
        isRead: false,
        createdAt: DateTime.now(),
      );

      _mockNotifications.add(newNotification);

      return newNotification;
    } else {
      try {
        final notificationData = {
          'user_id': userId,
          'title': title,
          'message': message,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        };

        if (relatedTo != null) {
          notificationData['related_to'] = relatedTo;
        }

        final response = await _supabaseService!.insertData(
          'notifications',
          notificationData,
        );

        return NotificationModel(
          id: response['id'],
          userId: response['user_id'],
          title: response['title'],
          message: response['message'],
          relatedTo: response['related_to'],
          isRead: response['is_read'],
          createdAt: DateTime.parse(response['created_at']),
        );
      } catch (e) {
        throw Exception('Failed to create notification: $e');
      }
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    if (isMockEnabled.value) {
      await Future.delayed(
        Duration(milliseconds: 500),
      ); // Simulate network delay

      _mockNotifications.removeWhere((n) => n.id == notificationId);
    } else {
      try {
        await _supabaseService!.deleteData('notifications', notificationId);
      } catch (e) {
        throw Exception('Failed to delete notification: $e');
      }
    }
  }
}
