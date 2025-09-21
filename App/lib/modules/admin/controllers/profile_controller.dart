import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/data/models/user_model.dart';
import 'package:jan_mitra/data/repository/auth_repository.dart';
import 'package:jan_mitra/routes/app_routes.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      currentUser.value = await _authRepository.getCurrentUser();
    } catch (e) {
      errorMessage.value = 'Failed to get user: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

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
