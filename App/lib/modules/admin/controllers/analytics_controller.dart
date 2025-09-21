import 'package:get/get.dart';
import 'package:jan_mitra/core/utils/constants.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/data/repository/issue_repository.dart';
import 'package:intl/intl.dart';

class AnalyticsController extends GetxController {
  final IssueRepository _issueRepository = Get.find<IssueRepository>();

  final RxList<IssueModel> allIssues = <IssueModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Date range filter
  final Rx<DateTime> startDate = DateTime.now()
      .subtract(Duration(days: 30))
      .obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    getAllIssues();
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

  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
  }

  List<IssueModel> get filteredIssues {
    return allIssues.where((issue) {
      return issue.createdAt.isAfter(startDate.value) &&
          issue.createdAt.isBefore(endDate.value.add(Duration(days: 1)));
    }).toList();
  }

  // Analytics data
  int get totalIssues => filteredIssues.length;

  int get pendingIssues => filteredIssues
      .where(
        (issue) =>
            issue.status == AppConstants.statusSubmitted ||
            issue.status == AppConstants.statusAcknowledged ||
            issue.status == AppConstants.statusInProgress,
      )
      .length;

  int get resolvedIssues => filteredIssues
      .where((issue) => issue.status == AppConstants.statusResolved)
      .length;

  int get rejectedIssues => filteredIssues
      .where((issue) => issue.status == AppConstants.statusRejected)
      .length;

  // Priority breakdown
  int get highPriorityIssues => filteredIssues
      .where((issue) => issue.priority == AppConstants.priorityHigh)
      .length;

  int get mediumPriorityIssues => filteredIssues
      .where((issue) => issue.priority == AppConstants.priorityMedium)
      .length;

  int get lowPriorityIssues => filteredIssues
      .where((issue) => issue.priority == AppConstants.priorityLow)
      .length;

  // Resolution rate
  double get resolutionRate {
    if (totalIssues == 0) return 0.0;
    return resolvedIssues / totalIssues * 100;
  }

  // Average resolution time (in days)
  double get averageResolutionTime {
    final resolvedIssuesList = filteredIssues
        .where(
          (issue) =>
              issue.status == AppConstants.statusResolved &&
              issue.updatedAt != null,
        )
        .toList();

    if (resolvedIssuesList.isEmpty) return 0.0;

    double totalDays = 0;
    for (var issue in resolvedIssuesList) {
      final difference = issue.updatedAt!.difference(issue.createdAt).inHours;
      totalDays += difference / 24.0;
    }

    return totalDays / resolvedIssuesList.length;
  }

  // Issues by day for chart
  List<Map<String, dynamic>> getIssuesByDay() {
    final Map<String, int> issueCountByDay = {};
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Initialize all days in range with 0 count
    for (
      var i = 0;
      i <= endDate.value.difference(startDate.value).inDays;
      i++
    ) {
      final date = startDate.value.add(Duration(days: i));
      issueCountByDay[dateFormat.format(date)] = 0;
    }

    // Count issues by day
    for (var issue in filteredIssues) {
      final dateString = dateFormat.format(issue.createdAt);
      issueCountByDay[dateString] = (issueCountByDay[dateString] ?? 0) + 1;
    }

    // Convert to list for chart
    List<Map<String, dynamic>> result = issueCountByDay.entries.map((entry) {
      return {'date': entry.key, 'count': entry.value};
    }).toList();

    result.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    return result;
  }

  // Issues by status for chart
  List<Map<String, dynamic>> getIssuesByStatus() {
    return [
      {
        'status': 'Submitted',
        'count': filteredIssues
            .where((issue) => issue.status == AppConstants.statusSubmitted)
            .length,
      },
      {
        'status': 'Acknowledged',
        'count': filteredIssues
            .where((issue) => issue.status == AppConstants.statusAcknowledged)
            .length,
      },
      {
        'status': 'In Progress',
        'count': filteredIssues
            .where((issue) => issue.status == AppConstants.statusInProgress)
            .length,
      },
      {'status': 'Resolved', 'count': resolvedIssues},
      {'status': 'Rejected', 'count': rejectedIssues},
    ];
  }

  // Issues by priority for chart
  List<Map<String, dynamic>> getIssuesByPriority() {
    return [
      {'priority': 'High', 'count': highPriorityIssues},
      {'priority': 'Medium', 'count': mediumPriorityIssues},
      {'priority': 'Low', 'count': lowPriorityIssues},
    ];
  }
}
