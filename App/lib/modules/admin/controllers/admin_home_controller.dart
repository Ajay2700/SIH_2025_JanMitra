import 'package:get/get.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/data/models/user_model.dart';
import 'package:jan_mitra/data/repository/auth_repository.dart';
import 'package:jan_mitra/data/repository/issue_repository.dart';
import 'package:jan_mitra/routes/app_routes.dart';

class AdminHomeController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final IssueRepository _issueRepository = Get.find<IssueRepository>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<IssueModel> allIssues = <IssueModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Filter options
  final RxString statusFilter = 'all'.obs;
  final RxString priorityFilter = 'all'.obs;

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

  void signOut() async {
    try {
      await _authRepository.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      errorMessage.value = 'Failed to sign out: ${e.toString()}';
    }
  }

  // Analytics data
  int get totalIssues => allIssues.length;

  int get pendingIssues => allIssues
      .where(
        (issue) =>
            issue.status == 'submitted' ||
            issue.status == 'acknowledged' ||
            issue.status == 'in_progress',
      )
      .length;

  int get resolvedIssues =>
      allIssues.where((issue) => issue.status == 'resolved').length;

  int get rejectedIssues =>
      allIssues.where((issue) => issue.status == 'rejected').length;

  int get highPriorityIssues =>
      allIssues.where((issue) => issue.priority == 'high').length;
}
