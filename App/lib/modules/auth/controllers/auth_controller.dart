import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/core/utils/constants.dart';
import 'package:jan_mitra/data/models/user_model.dart';
import 'package:jan_mitra/data/repository/auth_repository.dart';
import 'package:jan_mitra/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString selectedUserType = AppConstants.roleCitizen.obs;

  // Login form controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Register form controllers
  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPhoneController = TextEditingController();
  final TextEditingController registerPasswordController =
      TextEditingController();
  final TextEditingController registerConfirmPasswordController =
      TextEditingController();

  // Forgot password form controller
  final TextEditingController forgotPasswordEmailController =
      TextEditingController();

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPhoneController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    forgotPasswordEmailController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void setUserType(String userType) {
    selectedUserType.value = userType;
  }

  // Note: Email/password authentication is now handled directly in login_view.dart using FirebaseAuthService
  // These methods are kept for backward compatibility but may be removed in future versions

  // Note: Registration and password reset are now handled directly in respective views using FirebaseAuthService
  // These methods are kept for backward compatibility but may be removed in future versions

  Future<void> logout() async {
    try {
      await _authRepository.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }
}
