import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/core/utils/constants.dart';
import 'package:jan_mitra/modules/admin/controllers/issue_list_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class IssueListView extends StatelessWidget {
  final IssueListController _controller = Get.find<IssueListController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Issue Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Filter Issues',
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

        if (_controller.filteredIssues.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No issues found',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Try changing the filters',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _controller.setStatusFilter('all');
                    _controller.setPriorityFilter('all');
                  },
                  icon: Icon(Icons.clear_all),
                  label: Text('Clear Filters'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.refreshData,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _controller.filteredIssues.length,
            itemBuilder: (context, index) {
              final issue = _controller.filteredIssues[index];
              return _buildIssueCard(context, issue);
            },
          ),
        );
      }),
    );
  }

  Widget _buildIssueCard(BuildContext context, issue) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Issue Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: issue.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 150,
                color: Colors.grey[300],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 150,
                color: Colors.grey[300],
                child: Icon(Icons.error, size: 50, color: Colors.grey[600]),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Priority
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        issue.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildPriorityChip(issue.priority),
                  ],
                ),
                SizedBox(height: 8),

                // Description
                Text(
                  issue.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),

                // Date and Reported By
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(issue.createdAt),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      issue.creator?.name ?? 'Unknown',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Status and Actions
                Row(
                  children: [
                    Expanded(child: _buildStatusDropdown(context, issue)),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.visibility),
                      onPressed: () => Get.toNamed(
                        '/admin/issue-details',
                        arguments: {'issueId': issue.id},
                      ),
                      tooltip: 'View Details',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, issue) {
    final statusOptions = [
      AppConstants.statusSubmitted,
      AppConstants.statusAcknowledged,
      AppConstants.statusInProgress,
      AppConstants.statusResolved,
      AppConstants.statusRejected,
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _controller.getStatusColor(issue.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _controller.getStatusColor(issue.status)),
      ),
      child: DropdownButton<String>(
        value: issue.status,
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        isDense: true,
        underline: SizedBox(),
        style: TextStyle(
          color: _controller.getStatusColor(issue.status),
          fontWeight: FontWeight.bold,
        ),
        onChanged: (String? newValue) {
          if (newValue != null && newValue != issue.status) {
            _controller.updateIssueStatus(issue.id, newValue);
          }
        },
        items: statusOptions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value.capitalize!),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color = _controller.getPriorityColor(priority);
    IconData icon;

    switch (priority) {
      case AppConstants.priorityLow:
        icon = Icons.arrow_downward;
        break;
      case AppConstants.priorityMedium:
        icon = Icons.remove;
        break;
      case AppConstants.priorityHigh:
        icon = Icons.arrow_upward;
        break;
      default:
        icon = Icons.remove;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            priority.capitalize!,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Filter Issues',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),

              // Status Filter
              Text('Status', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8),
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip(
                      context,
                      'All',
                      _controller.statusFilter.value == 'all',
                      () => _controller.setStatusFilter('all'),
                    ),
                    _buildFilterChip(
                      context,
                      'Submitted',
                      _controller.statusFilter.value ==
                          AppConstants.statusSubmitted,
                      () => _controller.setStatusFilter(
                        AppConstants.statusSubmitted,
                      ),
                    ),
                    _buildFilterChip(
                      context,
                      'Acknowledged',
                      _controller.statusFilter.value ==
                          AppConstants.statusAcknowledged,
                      () => _controller.setStatusFilter(
                        AppConstants.statusAcknowledged,
                      ),
                    ),
                    _buildFilterChip(
                      context,
                      'In Progress',
                      _controller.statusFilter.value ==
                          AppConstants.statusInProgress,
                      () => _controller.setStatusFilter(
                        AppConstants.statusInProgress,
                      ),
                    ),
                    _buildFilterChip(
                      context,
                      'Resolved',
                      _controller.statusFilter.value ==
                          AppConstants.statusResolved,
                      () => _controller.setStatusFilter(
                        AppConstants.statusResolved,
                      ),
                    ),
                    _buildFilterChip(
                      context,
                      'Rejected',
                      _controller.statusFilter.value ==
                          AppConstants.statusRejected,
                      () => _controller.setStatusFilter(
                        AppConstants.statusRejected,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Priority Filter
              Text('Priority', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8),
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip(
                      context,
                      'All',
                      _controller.priorityFilter.value == 'all',
                      () => _controller.setPriorityFilter('all'),
                    ),
                    _buildFilterChip(
                      context,
                      'Low',
                      _controller.priorityFilter.value ==
                          AppConstants.priorityLow,
                      () => _controller.setPriorityFilter(
                        AppConstants.priorityLow,
                      ),
                    ),
                    _buildFilterChip(
                      context,
                      'Medium',
                      _controller.priorityFilter.value ==
                          AppConstants.priorityMedium,
                      () => _controller.setPriorityFilter(
                        AppConstants.priorityMedium,
                      ),
                    ),
                    _buildFilterChip(
                      context,
                      'High',
                      _controller.priorityFilter.value ==
                          AppConstants.priorityHigh,
                      () => _controller.setPriorityFilter(
                        AppConstants.priorityHigh,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onTap(),
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
