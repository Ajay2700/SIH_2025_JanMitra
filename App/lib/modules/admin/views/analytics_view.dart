import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/modules/admin/controllers/analytics_controller.dart';
import 'package:intl/intl.dart';

class AnalyticsView extends StatelessWidget {
  final AnalyticsController _controller = Get.find<AnalyticsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics'),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _showDateRangePicker(context),
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _controller.refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (_controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _controller.errorMessage.value,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _controller.refreshData,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Date Range',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(_controller.startDate.value),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(' to '),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(_controller.endDate.value),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Summary Stats
              Text('Summary', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              _buildSummaryStats(context),
              SizedBox(height: 24),

              // Status Breakdown
              Text(
                'Status Breakdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              _buildStatusBreakdown(context),
              SizedBox(height: 24),

              // Priority Breakdown
              Text(
                'Priority Breakdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              _buildPriorityBreakdown(context),
              SizedBox(height: 24),

              // Performance Metrics
              Text(
                'Performance Metrics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              _buildPerformanceMetrics(context),
              SizedBox(height: 24),

              // Issues by Day (Chart placeholder)
              Text(
                'Issues by Day',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              Card(
                child: Container(
                  height: 200,
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Chart visualization would be implemented here',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryStats(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          context,
          'Total Issues',
          _controller.totalIssues.toString(),
          Icons.report_problem,
          Colors.blue,
        ),
        _buildStatCard(
          context,
          'Pending Issues',
          _controller.pendingIssues.toString(),
          Icons.pending_actions,
          Colors.orange,
        ),
        _buildStatCard(
          context,
          'Resolved Issues',
          _controller.resolvedIssues.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          context,
          'Rejected Issues',
          _controller.rejectedIssues.toString(),
          Icons.cancel,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatusBreakdown(BuildContext context) {
    final statusData = _controller.getIssuesByStatus();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: statusData.map((item) {
            final count = item['count'] as int;
            final percentage = _controller.totalIssues > 0
                ? (count / _controller.totalIssues * 100).toStringAsFixed(1)
                : '0.0';

            return Column(
              children: [
                Row(
                  children: [
                    Text(
                      item['status'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text('$count (${percentage}%)'),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _controller.totalIssues > 0
                      ? count / _controller.totalIssues
                      : 0.0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(item['status']),
                  ),
                ),
                SizedBox(height: 16),
              ],
            );
          }).toList()..removeLast(), // Remove the last SizedBox
        ),
      ),
    );
  }

  Widget _buildPriorityBreakdown(BuildContext context) {
    final priorityData = _controller.getIssuesByPriority();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: priorityData.map((item) {
            final count = item['count'] as int;
            final percentage = _controller.totalIssues > 0
                ? (count / _controller.totalIssues * 100).toStringAsFixed(1)
                : '0.0';

            return Column(
              children: [
                Row(
                  children: [
                    Text(
                      item['priority'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text('$count (${percentage}%)'),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _controller.totalIssues > 0
                      ? count / _controller.totalIssues
                      : 0.0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getPriorityColor(item['priority']),
                  ),
                ),
                SizedBox(height: 16),
              ],
            );
          }).toList()..removeLast(), // Remove the last SizedBox
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Resolution Rate'),
                Text(
                  '${_controller.resolutionRate.toStringAsFixed(1)}%',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Avg. Resolution Time'),
                Text(
                  '${_controller.averageResolutionTime.toStringAsFixed(1)} days',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Color(0xFFFFA000); // Amber
      case 'acknowledged':
        return Color(0xFF42A5F5); // Blue
      case 'in progress':
        return Color(0xFF7E57C2); // Purple
      case 'resolved':
        return Color(0xFF66BB6A); // Green
      case 'rejected':
        return Color(0xFFEF5350); // Red
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Color(0xFFEF5350); // Red
      case 'medium':
        return Color(0xFFFFA000); // Amber
      case 'low':
        return Color(0xFF66BB6A); // Green
      default:
        return Colors.grey;
    }
  }

  void _showDateRangePicker(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: _controller.startDate.value,
      end: _controller.endDate.value,
    );

    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      _controller.setDateRange(pickedDateRange.start, pickedDateRange.end);
    }
  }
}
