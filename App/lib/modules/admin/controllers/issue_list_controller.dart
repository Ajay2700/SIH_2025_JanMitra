import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/core/utils/constants.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/data/models/user_model.dart';
import 'package:jan_mitra/data/repository/auth_repository.dart';
import 'package:jan_mitra/data/repository/issue_repository.dart';

class IssueListController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final IssueRepository _issueRepository = Get.find<IssueRepository>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<IssueModel> allIssues = <IssueModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Filter options
  final RxString statusFilter = 'all'.obs;
  final RxString priorityFilter = 'all'.obs;
  final RxBool isUpdatingStatus = false.obs;

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
      if (currentUser.value != null) {
        await getAllIssues();
      }
    } catch (e) {
      errorMessage.value = 'Failed to get user: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAllIssues() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      allIssues.value = await _issueRepository.getAllIssues();
    } catch (e) {
      errorMessage.value = 'Failed to get issues: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await getAllIssues();
  }

  void setStatusFilter(String status) {
    statusFilter.value = status;
  }

  void setPriorityFilter(String priority) {
    priorityFilter.value = priority;
  }

  List<IssueModel> get filteredIssues {
    return allIssues.where((issue) {
      bool statusMatch =
          statusFilter.value == 'all' || issue.status == statusFilter.value;
      bool priorityMatch =
          priorityFilter.value == 'all' ||
          issue.priority == priorityFilter.value;
      return statusMatch && priorityMatch;
    }).toList();
  }

  Future<void> updateIssueStatus(String issueId, String newStatus) async {
    if (currentUser.value == null) return;

    isUpdatingStatus.value = true;
    errorMessage.value = '';

    try {
      final updatedIssue = await _issueRepository.updateIssueStatus(
        issueId: issueId,
        status: newStatus,
        assignedTo: currentUser.value!.id,
      );

      // Update the issue in the list
      final index = allIssues.indexWhere((issue) => issue.id == issueId);
      if (index != -1) {
        allIssues[index] = updatedIssue;
      }

      Get.snackbar(
        'Success',
        'Issue status updated to ${newStatus.capitalize}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to update issue status: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusSubmitted:
        return Color(0xFFFFA000); // Amber
      case AppConstants.statusAcknowledged:
        return Color(0xFF42A5F5); // Blue
      case AppConstants.statusInProgress:
        return Color(0xFF7E57C2); // Purple
      case AppConstants.statusResolved:
        return Color(0xFF66BB6A); // Green
      case AppConstants.statusRejected:
        return Color(0xFFEF5350); // Red
      default:
        return Colors.grey;
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case AppConstants.priorityLow:
        return Color(0xFF66BB6A); // Green
      case AppConstants.priorityMedium:
        return Color(0xFFFFA000); // Amber
      case AppConstants.priorityHigh:
        return Color(0xFFEF5350); // Red
      default:
        return Colors.grey;
    }
  }
}
