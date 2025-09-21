import 'package:get/get.dart';
import 'package:jan_mitra/data/repository/issue_repository.dart';
import 'package:jan_mitra/modules/citizen/controllers/citizen_home_controller.dart';
import 'package:jan_mitra/modules/citizen/controllers/citizen_main_controller.dart';
import 'package:jan_mitra/modules/citizen/controllers/issue_tracker_controller.dart';
import 'package:jan_mitra/modules/citizen/controllers/my_issues_controller.dart';
import 'package:jan_mitra/modules/citizen/controllers/profile_controller.dart';
import 'package:jan_mitra/modules/citizen/controllers/report_issue_controller.dart';

class CitizenBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.put<IssueRepository>(IssueRepository());

    // Controllers
    Get.lazyPut<CitizenMainController>(() => CitizenMainController());
    Get.lazyPut<CitizenHomeController>(() => CitizenHomeController());
    Get.lazyPut<ReportIssueController>(() => ReportIssueController());
    Get.lazyPut<IssueTrackerController>(() => IssueTrackerController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<MyIssuesController>(() => MyIssuesController());
  }
}
