import 'package:get/get.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/data/models/user_model.dart';
import 'package:jan_mitra/data/repository/auth_repository.dart';
import 'package:jan_mitra/data/repository/issue_repository.dart';

class CitizenHomeController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final IssueRepository _issueRepository = Get.find<IssueRepository>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<IssueModel> userIssues = <IssueModel>[].obs;
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

      if (currentUser.value != null) {
        // Get user issues if we have a user
        await getUserIssues();
      } else {
        // Handle case where user is not logged in or not found
        errorMessage.value = 'User not found. Please sign in again.';
        print('No current user found');
      }
    } catch (e) {
      errorMessage.value = 'Failed to get user: ${e.toString()}';
      print('Error getting current user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserIssues() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (currentUser.value != null) {
        print('Getting issues for user: ${currentUser.value!.id}');
        userIssues.value = await _issueRepository.getIssuesByUser(
          currentUser.value!.id,
        );
      } else {
        // If no user is found, get all issues as a fallback
        print('No user found, getting all issues');
        userIssues.value = await _issueRepository.getAllIssues();
      }

      print('Loaded ${userIssues.length} issues');

      // If no issues found, try getting all issues
      if (userIssues.isEmpty) {
        print('No issues found for user, getting all issues');
        userIssues.value = await _issueRepository.getAllIssues();
        print('Loaded ${userIssues.length} issues from all issues');
      }
    } catch (e) {
      print('Error getting issues: $e');
      errorMessage.value = 'Failed to get issues: ${e.toString()}';

      // Try to get all issues as a fallback
      try {
        print('Trying to get all issues as fallback');
        userIssues.value = await _issueRepository.getAllIssues();
        if (userIssues.isNotEmpty) {
          errorMessage.value = '';
        }
      } catch (e) {
        print('Error getting all issues: $e');
        userIssues.value = [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await getCurrentUser();
  }

  Future<void> signOutAndRedirect() async {
    try {
      await _authRepository.signOut();
      Get.offAllNamed('/auth');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
