import 'package:get/get.dart';
import 'package:jan_mitra/data/services/mock_notification_service.dart';

class NotificationRepository {
  // Get the appropriate notification service
  final _notificationService = Get.find<MockNotificationService>();

  // Show a notification
  Future<void> showNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    await _notificationService.showNotification(title, body);
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _notificationService.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _notificationService.unsubscribeFromTopic(topic);
  }

  // Subscribe to issue updates
  Future<void> subscribeToIssueUpdates(String issueId) async {
    await _notificationService.subscribeToIssueUpdates(issueId);
  }

  // Clear notifications
  Future<void> clearNotifications(String userId) async {
    await _notificationService.clearNotifications(userId);
  }

  // Get notification count
  int getNotificationCount() {
    return _notificationService.notifications.length;
  }
}
