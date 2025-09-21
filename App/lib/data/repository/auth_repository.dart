import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/data/models/user_model.dart';
import 'package:jan_mitra/data/services/firebase_auth_service.dart';

class AuthRepository extends GetxService {
  final FirebaseAuthService _authService = Get.find<FirebaseAuthService>();

  Future<UserModel?> getCurrentUser() async {
    try {
      // Check if user is authenticated
      final isAuthenticated = _authService.isAuthenticated.value;
      if (!isAuthenticated) {
        if (kDebugMode) {
          print('User not authenticated');
        }
        return null;
      }

      // Get current user from FirebaseAuthService
      final user = _authService.getCurrentUser();
      return user;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user: ${e.toString()}');
      }
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: ${e.toString()}');
      }
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }
}
