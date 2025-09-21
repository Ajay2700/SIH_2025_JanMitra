import 'package:get/get.dart';
import 'package:jan_mitra/data/repository/issue_repository.dart';
import 'package:jan_mitra/modules/citizen/controllers/my_issues_controller.dart';

class MyIssuesBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    if (!Get.isRegistered<IssueRepository>()) {
      Get.put<IssueRepository>(IssueRepository());
    }

    // Controllers
    Get.lazyPut<MyIssuesController>(() => MyIssuesController());
  }
}
