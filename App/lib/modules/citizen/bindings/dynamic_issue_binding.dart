import 'package:get/get.dart';
import 'package:jan_mitra/data/services/issue_service_supabase.dart';
import 'package:jan_mitra/modules/citizen/controllers/dynamic_issue_controller.dart';

class DynamicIssueBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<IssueServiceSupabase>(IssueServiceSupabase());
    Get.put<DynamicIssueController>(DynamicIssueController());
  }
}
