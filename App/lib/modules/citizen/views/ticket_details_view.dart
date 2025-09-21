import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/core/ui/loading_indicator.dart';
import 'package:jan_mitra/core/ui/status_badge.dart';
// import 'package:jan_mitra/data/models/ticket_model_local.dart';
import 'package:jan_mitra/modules/citizen/controllers/ticket_controller.dart';
import 'package:intl/intl.dart';

class TicketDetailsView extends GetView<TicketController> {
  const TicketDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get ticket ID from arguments
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String ticketId = args['ticketId'] ?? '';

    // Load ticket details
    if (ticketId.isNotEmpty) {
      controller.getTicketDetails(ticketId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (ticketId.isNotEmpty) {
                controller.getTicketDetails(ticketId);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
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
                  onPressed: () {
                    if (ticketId.isNotEmpty) {
                      controller.getTicketDetails(ticketId);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final ticket = controller.selectedTicket.value;
        if (ticket == null) {
          return const Center(child: Text('Ticket not found'));
        }

        return _buildTicketDetails(context, ticket);
      }),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTicketDetails(BuildContext context, dynamic ticket) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTicketHeader(ticket),
          const SizedBox(height: 24),
          _buildTicketInfo(ticket),
          const SizedBox(height: 24),
          _buildTicketDescription(ticket),
          if (ticket.attachments != null && ticket.attachments!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildAttachments(ticket),
          ],
          const SizedBox(height: 24),
          _buildCommentsSection(ticket),
        ],
      ),
    );
  }

  Widget _buildTicketHeader(dynamic ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                ticket.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            StatusBadge(status: ticket.status),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Ticket #${ticket.id.substring(0, 8)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
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
      ],
    );
  }

  Widget _buildTicketInfo(dynamic ticket) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              'Created',
              DateFormat('MMM dd, yyyy HH:mm').format(ticket.createdAt),
            ),
            if (ticket.updatedAt != null)
              _buildInfoRow(
                'Updated',
                DateFormat('MMM dd, yyyy HH:mm').format(ticket.updatedAt!),
              ),
            if (ticket.resolvedAt != null)
              _buildInfoRow(
                'Resolved',
                DateFormat('MMM dd, yyyy HH:mm').format(ticket.resolvedAt!),
              ),
            if (ticket.subCategory != null)
              _buildInfoRow('Category', ticket.subCategory!),
            if (ticket.departmentId != null)
              _buildInfoRow('Department', ticket.departmentId!),
            if (ticket.assignedTo != null)
              _buildInfoRow('Assigned To', ticket.assignedTo!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketDescription(dynamic ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              ticket.description,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachments(dynamic ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: ticket.attachments!.map((url) {
                return ListTile(
                  leading: const Icon(Icons.attachment),
                  title: Text(
                    url.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    // Open attachment
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(dynamic ticket) {
    final comments = ticket.comments ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Comments (${comments.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (comments.isEmpty)
          const Card(
            elevation: 1,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No comments yet',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return _buildCommentCard(comment);
            },
          ),
        const SizedBox(height: 16),
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildCommentCard(dynamic comment) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      child: Icon(Icons.person, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.userName ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (comment.userRole != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          comment.userRole!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  DateFormat('MMM dd, HH:mm').format(comment.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => controller.commentText.value = value,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
            ),
            Obx(() {
              return IconButton(
                icon: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.addComment(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Obx(() {
      final ticket = controller.selectedTicket.value;
      if (ticket == null) return const SizedBox.shrink();

      // Only show action buttons for open tickets
      if (ticket.status == 'closed' || ticket.status == 'resolved') {
        return const SizedBox.shrink();
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (ticket.status == 'open')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showStatusUpdateDialog(ticket),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Cancel Ticket'),
                  ),
                ),
              if (ticket.status == 'open') const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showStatusUpdateDialog(ticket),
                  child: const Text('Update Status'),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showStatusUpdateDialog(dynamic ticket) {
    final List<String> availableStatuses = [];

    // Determine which statuses are valid for the current ticket status
    if (ticket.status == 'open') {
      availableStatuses.addAll(['closed', 'pending']);
    } else if (ticket.status == 'in_progress') {
      availableStatuses.addAll(['pending', 'resolved']);
    } else if (ticket.status == 'pending') {
      availableStatuses.addAll(['open', 'in_progress']);
    } else if (ticket.status == 'resolved') {
      availableStatuses.addAll(['closed', 'open']);
    } else {
      availableStatuses.add('open');
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Update Ticket Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableStatuses.map((status) {
            return ListTile(
              title: Text(_getStatusLabel(status)),
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(status),
                radius: 12,
              ),
              onTap: () {
                Get.back();
                controller.updateTicketStatus(ticket.id, status);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'open') {
      return Colors.blue;
    } else if (status == 'in_progress') {
      return Colors.amber;
    } else if (status == 'pending') {
      return Colors.orange;
    } else if (status == 'resolved') {
      return Colors.green;
    } else if (status == 'closed') {
      return Colors.grey;
    } else if (status == 'rejected') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

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

  String _getStatusLabel(String status) {
    if (status == 'open') {
      return 'Open';
    } else if (status == 'in_progress') {
      return 'In Progress';
    } else if (status == 'pending') {
      return 'Pending';
    } else if (status == 'resolved') {
      return 'Resolved';
    } else if (status == 'closed') {
      return 'Closed';
    } else if (status == 'rejected') {
      return 'Rejected';
    } else {
      return 'Unknown';
    }
  }
}
