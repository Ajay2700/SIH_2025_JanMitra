import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/core/ui/empty_state.dart';
import 'package:jan_mitra/core/ui/loading_indicator.dart';
import 'package:jan_mitra/core/ui/status_badge.dart';
// import 'package:jan_mitra/data/models/ticket_model_local.dart';
import 'package:jan_mitra/modules/citizen/controllers/ticket_controller.dart';
import 'package:jan_mitra/routes/app_routes.dart';
import 'package:intl/intl.dart';

class TicketsListView extends GetView<TicketController> {
  const TicketsListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchTickets(forceRefresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilters(),
          Expanded(child: _buildTicketsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.CREATE_TICKET),
        child: const Icon(Icons.add),
        tooltip: 'Create New Ticket',
      ),
    );
  }

  Widget _buildStatusFilters() {
    return Obx(() {
      final counts = controller.ticketCounts;

      // Calculate total count
      final totalCount =
          (counts['open'] ?? 0) +
          (counts['in_progress'] ?? 0) +
          (counts['pending'] ?? 0) +
          (counts['resolved'] ?? 0) +
          (counts['closed'] ?? 0) +
          (counts['rejected'] ?? 0);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Filter by Status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Get.theme.primaryColor,
              ),
            ),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', 'all', totalCount),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Open',
                  'open',
                  counts['open'] ?? 0,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'In Progress',
                  'in_progress',
                  counts['in_progress'] ?? 0,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Pending',
                  'pending',
                  counts['pending'] ?? 0,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Resolved',
                  'resolved',
                  counts['resolved'] ?? 0,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Closed',
                  'closed',
                  counts['closed'] ?? 0,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFilterChip(
    String label,
    String filter,
    int count, {
    Color? color,
  }) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == filter;
      final effectiveColor = color ?? Get.theme.primaryColor;

      return FilterChip(
        selected: isSelected,
        label: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? effectiveColor : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onSelected: (_) => controller.applyFilter(filter),
        backgroundColor: Colors.grey[200],
        selectedColor: effectiveColor.withOpacity(0.15),
        checkmarkColor: effectiveColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? effectiveColor : Colors.transparent,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      );
    });
  }

  Widget _buildTicketsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: LoadingIndicator());
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: ${controller.errorMessage.value}',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.fetchTickets(forceRefresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (controller.tickets.isEmpty) {
        return EmptyState(
          icon: Icons.confirmation_number_outlined,
          title: 'No Tickets Found',
          message: 'You haven\'t created any tickets yet.',
          buttonText: 'Create Ticket',
          onButtonPressed: () => Get.toNamed(Routes.CREATE_TICKET),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchTickets(forceRefresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.tickets.length,
          itemBuilder: (context, index) {
            final ticket = controller.tickets[index];
            return _buildTicketCard(ticket);
          },
        ),
      );
    });
  }

  Widget _buildTicketCard(dynamic ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => Get.toNamed(
          Routes.TICKET_DETAILS,
          arguments: {'ticketId': ticket.id},
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ticket.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: ticket.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ticket.description,
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getPriorityIcon(ticket.priority),
                        size: 16,
                        color: _getPriorityColor(ticket.priority),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getPriorityLabel(ticket.priority),
                        style: TextStyle(
                          color: _getPriorityColor(ticket.priority),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(ticket.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              if (ticket.subCategory != null) ...[
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    ticket.subCategory!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.grey[200],
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Removed unused method

  IconData _getPriorityIcon(String priority) {
    if (priority == 'low') {
      return Icons.arrow_downward;
    } else if (priority == 'medium') {
      return Icons.remove;
    } else if (priority == 'high') {
      return Icons.arrow_upward;
    } else if (priority == 'urgent') {
      return Icons.priority_high;
    } else {
      return Icons.remove;
    }
  }

  Color _getPriorityColor(String priority) {
    if (priority == 'low') {
      return Colors.green;
    } else if (priority == 'medium') {
      return Colors.blue;
    } else if (priority == 'high') {
      return Colors.orange;
    } else if (priority == 'urgent') {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  String _getPriorityLabel(String priority) {
    if (priority == 'low') {
      return 'Low';
    } else if (priority == 'medium') {
      return 'Medium';
    } else if (priority == 'high') {
      return 'High';
    } else if (priority == 'urgent') {
      return 'Urgent';
    } else {
      return 'Unknown';
    }
  }
}
