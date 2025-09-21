import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/data/models/comment_model.dart';
import 'package:jan_mitra/data/models/notification_model.dart';
import 'package:jan_mitra/data/services/supabase_service.dart';

class RealtimeService extends GetxService {
  final SupabaseService? _supabaseService = Get.isRegistered<SupabaseService>()
      ? Get.find<SupabaseService>()
      : null;
  final RxBool isMockEnabled = true.obs;

  // Stream controllers for mock mode
  final _issueStreamController = StreamController<IssueModel>.broadcast();
  final _commentStreamController = StreamController<CommentModel>.broadcast();
  final _notificationStreamController =
      StreamController<NotificationModel>.broadcast();

  // Supabase realtime channels
  RealtimeChannel? _issueChannel;
  RealtimeChannel? _commentChannel;
  RealtimeChannel? _notificationChannel;

  // Stream getters
  Stream<IssueModel> get issueUpdates => _issueStreamController.stream;
  Stream<CommentModel> get commentUpdates => _commentStreamController.stream;
  Stream<NotificationModel> get notificationUpdates =>
      _notificationStreamController.stream;

  Future<RealtimeService> init() async {
    // For production, set isMockEnabled to false
    if (kReleaseMode) {
      isMockEnabled.value = false;
    }

    if (!isMockEnabled.value && _supabaseService != null) {
      _setupRealtimeSubscriptions();
    }

    print("***** RealtimeService init completed *****");
    return this;
  }

  void _setupRealtimeSubscriptions() {
    try {
      // For now, we'll just initialize the channels but not subscribe
      // This is a simplified version for development
      _issueChannel = _supabaseService?.createSubscription('issues');
      _commentChannel = _supabaseService?.createSubscription('comments');
      _notificationChannel = _supabaseService?.createSubscription(
        'notifications',
      );

      if (kDebugMode) {
        print('Realtime channels initialized but not subscribed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up realtime subscriptions: $e');
      }
    }
  }

  // Handler methods will be implemented in the future when
  // Supabase realtime subscriptions are fully set up

  // Example implementation of how handlers will work:
  //
  // void _processRealtimeUpdate(String channel, Map<String, dynamic> data) {
  //   try {
  //     switch(channel) {
  //       case 'issues':
  //         final issue = IssueModel.fromJson(data);
  //         _issueStreamController.add(issue);
  //         break;
  //       case 'comments':
  //         final comment = CommentModel.fromJson(data);
  //         _commentStreamController.add(comment);
  //         break;
  //       case 'notifications':
  //         final notification = NotificationModel.fromJson(data);
  //         _notificationStreamController.add(notification);
  //         break;
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error handling realtime update: $e');
  //     }
  //   }
  // }

  // For mock mode: notify about issue updates
  void notifyIssueUpdate(IssueModel issue) {
    if (isMockEnabled.value) {
      _issueStreamController.add(issue);
    }
  }

  // For mock mode: notify about comment updates
  void notifyCommentUpdate(CommentModel comment) {
    if (isMockEnabled.value) {
      _commentStreamController.add(comment);
    }
  }

  // For mock mode: notify about notification updates
  void notifyNotificationUpdate(NotificationModel notification) {
    if (isMockEnabled.value) {
      _notificationStreamController.add(notification);
    }
  }

  @override
  void onClose() {
    _issueStreamController.close();
    _commentStreamController.close();
    _notificationStreamController.close();

    _issueChannel?.unsubscribe();
    _commentChannel?.unsubscribe();
    _notificationChannel?.unsubscribe();

    super.onClose();
  }
}
