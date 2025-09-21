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

  // Edit profile functionality
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final RxBool isEditing = false.obs;

  void startEditing() {
    if (currentUser.value != null) {
      nameController.text = currentUser.value!.name;
      emailController.text = currentUser.value!.email;
      phoneController.text = currentUser.value!.phone ?? '';
      isEditing.value = true;
    }
  }

  void cancelEditing() {
    isEditing.value = false;
  }

  Future<void> saveProfile() async {
    if (currentUser.value == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // In a real app, this would call a repository method to update the user profile
      // For now, we'll just update the local user object
      currentUser.value = UserModel(
        id: currentUser.value!.id,
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        role: currentUser.value!.role,
        createdAt: currentUser.value!.createdAt,
      );

      isEditing.value = false;

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to update profile: ${e.toString()}';

      Get.snackbar(
        'Error',
        'Failed to update profile',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _authRepository.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      errorMessage.value = 'Failed to sign out: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
