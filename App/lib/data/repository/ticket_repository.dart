import 'package:get/get.dart';
import 'package:jan_mitra/data/services/ticket_service.dart';
import 'package:jan_mitra/data/services/firebase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TicketRepository {
  final TicketService _ticketService = Get.find<TicketService>();

  // Getter for the ticket service
  TicketService get ticketService => _ticketService;

  // Cache for tickets
  final RxList _tickets = <dynamic>[].obs;
  final Rx<dynamic> _currentTicket = Rx<dynamic>(null);
  final RxMap<String, int> _ticketCounts = <String, int>{}.obs;

  // Getters
  List get tickets => _tickets;
  dynamic get currentTicket => _currentTicket.value;
  Map<String, int> get ticketCounts => _ticketCounts;

  // Fetch all tickets with optional filters
  Future<List> getAllTickets({
    String? status,
    String? priority,
    String? departmentId,
    String? userId,
    int? limit,
    int? offset,
    bool forceRefresh = false,
  }) async {
    if (_tickets.isEmpty || forceRefresh) {
      final fetchedTickets = await _ticketService.getAllTickets(
        status: status,
        priority: priority,
        departmentId: departmentId,
        userId: userId,
        limit: limit,
        offset: offset,
      );

      _tickets.assignAll(fetchedTickets);
    }

    return _tickets;
  }

  // Fetch tickets for current user
  Future<List> getMyTickets({String? status, bool forceRefresh = false}) async {
    final authService = Get.find<FirebaseAuthService>();

    if (!authService.isAuthenticated.value) {
      throw Exception(
        'User not authenticated. Please sign in to view tickets.',
      );
    }

    final user = authService.getCurrentUser();
    final userId = user?.id;
    if (userId == null) {
      throw Exception(
        'User not authenticated. Please sign in to view tickets.',
      );
    }

    return getAllTickets(
      userId: userId,
      status: status,
      forceRefresh: forceRefresh,
    );
  }

  // Get ticket by ID
  Future<dynamic> getTicketById(
    String ticketId, {
    bool forceRefresh = false,
  }) async {
    if (_currentTicket.value?.id != ticketId || forceRefresh) {
      final ticket = await _ticketService.getTicketById(ticketId);
      _currentTicket.value = ticket;
    }

    return _currentTicket.value!;
  }

  // Create a new ticket
  Future<dynamic> createTicket({
    required String title,
    required String description,
    required String priority,
    String? departmentId,
    String? category,
    List<String>? attachments,
  }) async {
    final authService = Get.find<FirebaseAuthService>();

    if (!authService.isAuthenticated.value) {
      throw Exception(
        'User not authenticated. Please sign in to create tickets.',
      );
    }

    final user = authService.getCurrentUser();
    final userId = user?.id;
    if (userId == null) {
      throw Exception(
        'User not authenticated. Please sign in to create tickets.',
      );
    }

    try {
      final newTicket = {
        'title': title,
        'description': description,
        'user_id': userId,
        'priority': priority,
        'department_id': departmentId,
        'sub_category': category,
        'attachments': attachments,
        'status': 'open',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final createdTicket = await _ticketService.createTicket(newTicket);
      _tickets.insert(0, createdTicket); // Add to the beginning of the list

      // Update counts
      await refreshTicketCounts();

      return createdTicket;
    } catch (e) {
      print('Error creating ticket: $e');
      rethrow;
    }
  }

  // Update ticket status
  Future<dynamic> updatedynamic(String ticketId, String newStatus) async {
    final data = {'status': newStatus};

    final updatedTicket = await _ticketService.updateTicket(ticketId, data);

    // Update in local cache
    final index = _tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index != -1) {
      _tickets[index] = updatedTicket;
    }

    if (_currentTicket.value?.id == ticketId) {
      _currentTicket.value = updatedTicket;
    }

    // Update counts
    await refreshTicketCounts();

    return updatedTicket;
  }

  // Update ticket details
  Future<dynamic> updateTicket(
    String ticketId,
    Map<String, dynamic> data,
  ) async {
    final updatedTicket = await _ticketService.updateTicket(ticketId, data);

    // Update in local cache
    final index = _tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index != -1) {
      _tickets[index] = updatedTicket;
    }

    if (_currentTicket.value?.id == ticketId) {
      _currentTicket.value = updatedTicket;
    }

    return updatedTicket;
  }

  // Delete a ticket
  Future<void> deleteTicket(String ticketId) async {
    await _ticketService.deleteTicket(ticketId);

    // Remove from local cache
    _tickets.removeWhere((ticket) => ticket.id == ticketId);

    if (_currentTicket.value?.id == ticketId) {
      _currentTicket.value = null;
    }

    // Update counts
    await refreshTicketCounts();
  }

  // Add comment to ticket
  Future<dynamic> addComment(String ticketId, String content) async {
    final authService = Get.find<FirebaseAuthService>();

    if (!authService.isAuthenticated.value) {
      throw Exception(
        'User not authenticated. Please sign in to add comments.',
      );
    }

    final user = authService.getCurrentUser();
    final userId = user?.id;
    if (userId == null) {
      throw Exception(
        'User not authenticated. Please sign in to add comments.',
      );
    }

    String userName = 'Anonymous User';
    String userRole = 'citizen';

    try {
      // Get user information
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('name, user_type')
          .eq('id', userId)
          .single();

      userName = userResponse['name'] as String? ?? userName;
      userRole = userResponse['user_type'] as String? ?? userRole;

      final comment = {
        'ticket_id': ticketId,
        'user_id': userId,
        'content': content,
        'user_name': userName,
        'user_role': userRole,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final createdComment = await _ticketService.addComment(comment);

      // Update current ticket if it's the one being commented on
      if (_currentTicket.value?['id'] == ticketId) {
        final currentComments = _currentTicket.value!['comments'] ?? [];
        final updatedComments = [...currentComments, createdComment];
        _currentTicket.value = {
          ..._currentTicket.value!,
          'comments': updatedComments,
        };
      }

      return createdComment;
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  // Update ticket status
  Future<dynamic> updateTicketStatus(String ticketId, String newStatus) async {
    final authService = Get.find<FirebaseAuthService>();

    if (!authService.isAuthenticated.value) {
      throw Exception(
        'User not authenticated. Please sign in to update ticket status.',
      );
    }

    final data = {
      'status': newStatus,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final updatedTicket = await _ticketService.updateTicket(ticketId, data);
    return updatedTicket;
  }

  // Delete comment
  Future<void> deleteComment(String commentId, String ticketId) async {
    await _ticketService.deleteComment(commentId);

    // Update current ticket if it's the one with the deleted comment
    if (_currentTicket.value?.id == ticketId) {
      final currentComments = _currentTicket.value!.comments ?? [];
      final updatedComments = currentComments
          .where((c) => c.id != commentId)
          .toList();
      _currentTicket.value = _currentTicket.value!.copyWith(
        comments: updatedComments,
      );
    }
  }

  // Subscribe to ticket updates
  RealtimeChannel subscribeToTickets({String? userId}) {
    return _ticketService.subscribeToTickets(userId: userId);
  }

  // Subscribe to comments for a specific ticket
  RealtimeChannel subscribeToComments(String ticketId) {
    return _ticketService.subscribeToComments(ticketId);
  }

  // Refresh ticket counts
  Future<Map<String, int>> refreshTicketCounts() async {
    final authService = Get.find<FirebaseAuthService>();
    final user = authService.getCurrentUser();
    final userId = user?.id;
    final counts = await _ticketService.getTicketCountsByStatus(userId: userId);
    _ticketCounts.assignAll(counts);
    return counts;
  }

  // Clear cache
  void clearCache() {
    _tickets.clear();
    _currentTicket.value = null;
    _ticketCounts.clear();
  }
}
