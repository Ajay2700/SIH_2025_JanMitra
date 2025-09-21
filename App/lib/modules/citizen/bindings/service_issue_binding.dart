import 'package:get/get.dart';
import 'package:jan_mitra/data/services/issue_service.dart';
import 'package:jan_mitra/modules/citizen/views/service_issue_form_view.dart';

class ServiceIssueBinding extends Bindings {
  @override
  void dependencies() {
    // Register services
    Get.lazyPut<IssueService>(() => IssueService());

    // Register controllers
    Get.lazyPut<ServiceIssueFormController>(() => ServiceIssueFormController());
  }
}
