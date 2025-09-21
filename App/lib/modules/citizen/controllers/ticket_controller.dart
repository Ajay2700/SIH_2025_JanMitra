import 'package:get/get.dart';
import 'package:jan_mitra/data/repository/ticket_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TicketController extends GetxController {
  final TicketRepository _repository = Get.find<TicketRepository>();

  // Observable variables
  final RxList tickets = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedFilter = 'all'.obs;
  final Rx<dynamic> selectedTicket = Rx<dynamic>(null);
  final RxMap<String, int> ticketCounts = <String, int>{}.obs;

  // Form fields
  final RxString title = ''.obs;
  final RxString description = ''.obs;
  final RxString priority = 'medium'.obs;
  final RxString category = ''.obs;
  final RxString departmentId = ''.obs;
  final RxList<String> attachments = <String>[].obs;

  // Comment field
  final RxString commentText = ''.obs;

  // Realtime subscriptions
  RealtimeChannel? _ticketsSubscription;
  RealtimeChannel? _commentsSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchTickets();
    subscribeToTicketUpdates();

    // Listen for ticket updates
    ever(_repository.ticketService.ticketsUpdated, (_) {
      fetchTickets(forceRefresh: true);
    });

    // Listen for comment updates
    ever(_repository.ticketService.commentsUpdated, (updates) {
      if (selectedTicket.value != null &&
          updates.containsKey(selectedTicket.value!['id'])) {
        getTicketDetails(selectedTicket.value!['id']);
      }
    });
  }

  @override
  void onClose() {
    _ticketsSubscription?.unsubscribe();
    _commentsSubscription?.unsubscribe();
    super.onClose();
  }

  // Fetch tickets with optional filter
  Future<void> fetchTickets({bool forceRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      String? statusFilter;
      if (selectedFilter.value != 'all') {
        statusFilter = selectedFilter.value;
      }

      final fetchedTickets = await _repository.getMyTickets(
        status: statusFilter,
        forceRefresh: forceRefresh,
      );

      tickets.assignAll(fetchedTickets);
      await refreshTicketCounts();
    } catch (e) {
      errorMessage.value = 'Failed to load tickets: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Apply filter
  void applyFilter(String filter) {
    selectedFilter.value = filter;
    fetchTickets(forceRefresh: true);
  }

  // Get ticket details
  Future<void> getTicketDetails(String ticketId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final ticket = await _repository.getTicketById(ticketId);
      selectedTicket.value = ticket;

      // Subscribe to comments for this ticket
      subscribeToComments(ticketId);
    } catch (e) {
      errorMessage.value = 'Failed to load ticket details: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Create new ticket
  Future<bool> createTicket() async {
    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      if (title.value.isEmpty) {
        errorMessage.value = 'Title cannot be empty';
        return false;
      }

      if (description.value.isEmpty) {
        errorMessage.value = 'Description cannot be empty';
        return false;
      }

      final newTicket = await _repository.createTicket(
        title: title.value,
        description: description.value,
        priority: priority.value,
        departmentId: departmentId.value.isNotEmpty ? departmentId.value : null,
        category: category.value.isNotEmpty ? category.value : null,
        attachments: attachments.isNotEmpty ? attachments : null,
      );

      // Clear form fields
      clearForm();

      // Add to tickets list
      tickets.insert(0, newTicket);

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to create ticket: ${e.toString()}';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Update ticket status
  Future<bool> updateTicketStatus(String ticketId, String newStatus) async {
    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      final updatedTicket = await _repository.updateTicketStatus(
        ticketId,
        newStatus,
      );

      // Update in local list
      final index = tickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (index != -1) {
        tickets[index] = updatedTicket;
      }

      // Update selected ticket if it's the same one
      if (selectedTicket.value != null &&
          selectedTicket.value['id'] == ticketId) {
        selectedTicket.value = updatedTicket;
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to update ticket status: ${e.toString()}';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Add comment to ticket
  Future<bool> addComment() async {
    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      if (commentText.value.isEmpty) {
        errorMessage.value = 'Comment cannot be empty';
        return false;
      }

      if (selectedTicket.value == null) {
        errorMessage.value = 'No ticket selected';
        return false;
      }

      await _repository.addComment(
        selectedTicket.value!['id'],
        commentText.value,
      );

      // Clear comment field
      commentText.value = '';

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to add comment: ${e.toString()}';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Delete comment
  Future<bool> deleteComment(String commentId) async {
    if (selectedTicket.value == null) return false;

    try {
      await _repository.deleteComment(commentId, selectedTicket.value!['id']);
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to delete comment: ${e.toString()}';
      return false;
    }
  }

  // Subscribe to ticket updates
  void subscribeToTicketUpdates() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _ticketsSubscription = _repository.subscribeToTickets(userId: userId);

    // The callback in the Supabase channel will handle the updates
    // We just need to make sure we're subscribed
  }

  // Subscribe to comments for a specific ticket
  void subscribeToComments(String ticketId) {
    // Unsubscribe from previous subscription if any
    _commentsSubscription?.unsubscribe();

    _commentsSubscription = _repository.subscribeToComments(ticketId);

    // The callback in the Supabase channel will handle the updates
    // We just need to make sure we're subscribed
  }

  // Refresh ticket counts
  Future<void> refreshTicketCounts() async {
    try {
      final counts = await _repository.refreshTicketCounts();
      ticketCounts.assignAll(counts);
    } catch (e) {
      print('Failed to refresh ticket counts: $e');
    }
  }

  // Clear form fields
  void clearForm() {
    title.value = '';
    description.value = '';
    priority.value = 'medium';
    category.value = '';
    departmentId.value = '';
    attachments.clear();
  }

  // Add attachment
  void addAttachment(String url) {
    attachments.add(url);
  }

  // Remove attachment
  void removeAttachment(String url) {
    attachments.remove(url);
  }
}
