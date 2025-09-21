import 'package:jan_mitra/data/models/notification_model.dart';

/// Mock notification service for development and testing
class MockNotificationService {
  static final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      userId: 'user1',
      title: 'Welcome to Jan Mitra',
      message: 'Thank you for joining our civic issue reporting platform.',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: '2',
      userId: 'user1',
      title: 'Ticket Created',
      message: 'Your ticket #TKT-2024-001 has been successfully created.',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  /// Get all notifications for a user
  Future<List<NotificationModel>> getNotifications(String userId) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay
    return _notifications.where((n) => n.userId == userId).toList();
  }

  /// Get unread notifications count
  Future<int> getUnreadCount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _notifications.where((n) => n.userId == userId && !n.isRead).length;
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }

  /// Add a new notification
  Future<void> addNotification(NotificationModel notification) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _notifications.add(notification);
  }

  /// Clear all notifications for a user
  Future<void> clearNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _notifications.removeWhere((n) => n.userId == userId);
  }

  /// Show a notification (mock implementation)
  Future<void> showNotification(String title, String body) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('Mock notification: $title - $body');
  }

  /// Subscribe to topic (mock implementation)
  Future<void> subscribeToTopic(String topic) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('Mock: Subscribed to topic $topic');
  }

  /// Unsubscribe from topic (mock implementation)
  Future<void> unsubscribeFromTopic(String topic) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('Mock: Unsubscribed from topic $topic');
  }

  /// Subscribe to issue updates (mock implementation)
  Future<void> subscribeToIssueUpdates(String issueId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('Mock: Subscribed to issue updates for $issueId');
  }

  /// Get notifications stream (mock implementation)
  List<NotificationModel> get notifications => _notifications;
}
