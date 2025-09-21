import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jan_mitra/core/utils/constants.dart';
import 'package:jan_mitra/modules/admin/controllers/map_dashboard_controller.dart';

class MapDashboardView extends StatelessWidget {
  final MapDashboardController _controller = Get.find<MapDashboardController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Filter Issues',
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

        return Stack(
          children: [
            // Google Map
            GoogleMap(
              initialCameraPosition: _controller.initialCameraPosition.value,
              onMapCreated: _controller.onMapCreated,
              markers: Set<Marker>.of(_controller.markers.values),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
            ),

            // Issue Count Card
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Issues on Map',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        _controller.filteredIssues.length.toString(),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      SizedBox(height: 8),
                      _buildStatusLegend(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatusLegend() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem('Submitted', Colors.orange),
        _buildLegendItem('Acknowledged', Colors.blue),
        _buildLegendItem('In Progress', Colors.purple),
        _buildLegendItem('Resolved', Colors.green),
        _buildLegendItem('Rejected', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
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
                'Filter Map Issues',
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
