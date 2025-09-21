import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/core/ui/app_button.dart';
import 'package:jan_mitra/core/ui/app_text_field.dart';
// import 'package:jan_mitra/data/models/ticket_model_local.dart';
import 'package:jan_mitra/data/models/ticket_priority.dart';
import 'package:jan_mitra/modules/citizen/controllers/ticket_controller.dart';

class CreateTicketView extends GetView<TicketController> {
  const CreateTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Ticket')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildPrioritySelector(),
            const SizedBox(height: 16),
            _buildCategoryField(),
            const SizedBox(height: 16),
            _buildDepartmentField(),
            const SizedBox(height: 16),
            _buildAttachmentSection(),
            const SizedBox(height: 24),
            _buildErrorMessage(),
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        AppTextField(
          hintText: 'Enter ticket title',
          onChanged: (value) => controller.title.value = value,
          errorText:
              controller.title.value.isEmpty && controller.isSubmitting.value
              ? 'Title is required'
              : null,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        AppTextField(
          hintText: 'Describe your issue in detail',
          maxLines: 5,
          onChanged: (value) => controller.description.value = value,
          errorText:
              controller.description.value.isEmpty &&
                  controller.isSubmitting.value
              ? 'Description is required'
              : null,
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Obx(() {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildPriorityOption(TicketPriority.low, 'Low', Colors.green),
                const Divider(height: 1),
                _buildPriorityOption(
                  TicketPriority.medium,
                  'Medium',
                  Colors.blue,
                ),
                const Divider(height: 1),
                _buildPriorityOption(
                  TicketPriority.high,
                  'High',
                  Colors.orange,
                ),
                const Divider(height: 1),
                _buildPriorityOption(
                  TicketPriority.urgent,
                  'Urgent',
                  Colors.red,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPriorityOption(
    TicketPriority priority,
    String label,
    Color color,
  ) {
    return Obx(() {
      final isSelected = controller.priority.value == priority.value;

      return InkWell(
        onTap: () => controller.priority.value = priority.value,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? color : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category (Optional)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        AppTextField(
          hintText: 'e.g., Technical Issue, Billing, General Inquiry',
          onChanged: (value) => controller.category.value = value,
        ),
      ],
    );
  }

  Widget _buildDepartmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Department (Optional)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        AppTextField(
          hintText: 'e.g., IT, Finance, Customer Support',
          onChanged: (value) => controller.departmentId.value = value,
        ),
      ],
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments (Optional)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Obx(() {
          return Column(
            children: [
              if (controller.attachments.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.attachments.length,
                  itemBuilder: (context, index) {
                    final attachment = controller.attachments[index];
                    return ListTile(
                      leading: const Icon(Icons.attachment),
                      title: Text(
                        attachment.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          final attachments = controller.attachments.toList();
                          attachments.remove(attachment);
                          controller.attachments.assignAll(attachments);
                        },
                      ),
                    );
                  },
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  // Implement file picking logic
                  // For now, we'll add a dummy attachment for demonstration
                  controller.attachments.add(
                    'https://example.com/dummy-attachment-${DateTime.now().millisecondsSinceEpoch}.pdf',
                  );
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Add Attachment'),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Obx(() {
      if (controller.errorMessage.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return AppButton(
        label: 'Submit Ticket',
        isLoading: controller.isSubmitting.value,
        onPressed: () async {
          final result = await controller.createTicket();
          if (result) {
            Get.back();
            Get.snackbar(
              'Success',
              'Ticket created successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        },
      );
    });
  }
}
