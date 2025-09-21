import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationBadge extends StatelessWidget {
  // This service will be used in the future to get real notification counts
  // For now we're using a placeholder value

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // For now, use a placeholder count
      // In the future, this will use: _notificationService.unreadNotificationCount.value
      final notificationCount = 0;

      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.notifications),
          if (notificationCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  notificationCount > 9 ? '9+' : '$notificationCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
  }
}
