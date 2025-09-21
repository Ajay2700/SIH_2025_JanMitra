import 'package:get/get.dart';
import 'package:jan_mitra/core/utils/constants.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/data/models/user_model.dart';
import 'package:jan_mitra/data/repository/auth_repository.dart';
import 'package:jan_mitra/data/repository/issue_repository.dart';

class MyIssuesController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final IssueRepository _issueRepository = Get.find<IssueRepository>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<IssueModel> userIssues = <IssueModel>[].obs;
  final RxList<IssueModel> filteredIssues = <IssueModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Filters
  final RxString statusFilter = 'all'.obs;
  final RxString priorityFilter = 'all'.obs;
  final RxString sortBy = 'newest'.obs;
  final RxString searchQuery = ''.obs;

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
        await getUserIssues();
      }
    } catch (e) {
      errorMessage.value = 'Failed to get user: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserIssues() async {
    if (currentUser.value == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      try {
        userIssues.value = await _issueRepository.getIssuesByUser(
          currentUser.value!.id,
        );
        applyFilters();
      } catch (e) {
        print('Repository call failed: $e');
        userIssues.value = [];
        filteredIssues.value = [];
      }
    } catch (e) {
      errorMessage.value = 'Failed to get issues: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await getUserIssues();
  }

  // Set status filter
  void setStatusFilter(String status) {
    statusFilter.value = status;
    applyFilters();
  }

  // Set priority filter
  void setPriorityFilter(String priority) {
    priorityFilter.value = priority;
    applyFilters();
  }

  // Set sort option
  void setSortBy(String sort) {
    sortBy.value = sort;
    applyFilters();
  }

  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // Apply all filters
  void applyFilters() {
    List<IssueModel> result = List.from(userIssues);

    // Apply status filter
    if (statusFilter.value != 'all') {
      result = result
          .where((issue) => issue.status == statusFilter.value)
          .toList();
    }

    // Apply priority filter
    if (priorityFilter.value != 'all') {
      result = result
          .where((issue) => issue.priority == priorityFilter.value)
          .toList();
    }

    // Apply search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result
          .where(
            (issue) =>
                issue.title.toLowerCase().contains(query) ||
                issue.description.toLowerCase().contains(query),
          )
          .toList();
    }

    // Apply sorting
    switch (sortBy.value) {
      case 'newest':
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'priority_high':
        result.sort((a, b) {
          final priorityOrder = {
            AppConstants.priorityHigh: 0,
            AppConstants.priorityMedium: 1,
            AppConstants.priorityLow: 2,
          };
          return priorityOrder[a.priority]!.compareTo(
            priorityOrder[b.priority]!,
          );
        });
        break;
      case 'priority_low':
        result.sort((a, b) {
          final priorityOrder = {
            AppConstants.priorityHigh: 0,
            AppConstants.priorityMedium: 1,
            AppConstants.priorityLow: 2,
          };
          return priorityOrder[b.priority]!.compareTo(
            priorityOrder[a.priority]!,
          );
        });
        break;
    }

    filteredIssues.value = result;
  }

  // Get issue count by status
  int getIssueCountByStatus(String status) {
    if (status == 'all') {
      return userIssues.length;
    }
    return userIssues.where((issue) => issue.status == status).length;
  }
}
