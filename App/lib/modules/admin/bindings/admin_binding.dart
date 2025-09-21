import 'package:get/get.dart';
import 'package:jan_mitra/data/repository/issue_repository.dart';
import 'package:jan_mitra/modules/admin/controllers/admin_home_controller.dart';
import 'package:jan_mitra/modules/admin/controllers/analytics_controller.dart';
import 'package:jan_mitra/modules/admin/controllers/issue_list_controller.dart';
import 'package:jan_mitra/modules/admin/controllers/map_dashboard_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<IssueRepository>(() => IssueRepository());

    // Controllers
    Get.lazyPut<AdminHomeController>(() => AdminHomeController());
    Get.lazyPut<IssueListController>(() => IssueListController());
    Get.lazyPut<MapDashboardController>(() => MapDashboardController());
    Get.lazyPut<AnalyticsController>(() => AnalyticsController());
  }
}
