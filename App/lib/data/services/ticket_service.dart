import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jan_mitra/data/services/supabase_service.dart';
import 'package:jan_mitra/core/config/env_config.dart';

class TicketService extends GetxService {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  // Table names
  final String _ticketsTable = 'tickets';
  final String _commentsTable = 'ticket_comments';
  final String _ticketHistoryTable = 'ticket_history';
  final String _ticketCategoriesTable = 'ticket_categories';
  final String _slaTrackingTable = 'sla_tracking';
  final String _escalationMatrixTable = 'escalation_matrix';

  // Reactive data streams
  final RxList tickets = <dynamic>[].obs;
  final RxMap<String, List> ticketComments = <String, List>{}.obs;
  final RxMap<String, List<Map<String, dynamic>>> ticketHistory =
      <String, List<Map<String, dynamic>>>{}.obs;

  // Constants for ticket status
  static const String STATUS_OPEN = 'open';
  static const String STATUS_IN_PROGRESS = 'in_progress';
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_RESOLVED = 'resolved';
  static const String STATUS_CLOSED = 'closed';
  static const String STATUS_REJECTED = 'rejected';
  static const String STATUS_ESCALATED = 'escalated';
  static const String STATUS_FORWARDED = 'forwarded';

  static final List<String> STATUS_VALUES = [
    STATUS_OPEN,
    STATUS_IN_PROGRESS,
    STATUS_PENDING,
    STATUS_RESOLVED,
    STATUS_CLOSED,
    STATUS_REJECTED,
    STATUS_ESCALATED,
    STATUS_FORWARDED,
  ];

  // Subscription channels
  RealtimeChannel? _ticketsChannel;
  RealtimeChannel? _commentsChannel;
  final Map<String, RealtimeChannel> _ticketSpecificChannels = {};

  // Status streams for notifications
  final RxBool ticketsUpdated = false.obs;
  final RxMap<String, bool> commentsUpdated = <String, bool>{}.obs;
  final RxString lastUpdatedTicketId = ''.obs;

  // Initialize service
  Future<TicketService> init() async {
    if (EnvConfig.enableRealtime) {
      _setupRealtimeSubscriptions();
    }

    if (kDebugMode) {
      print('TicketService initialized');
    }

    return this;
  }

  // Set up realtime subscriptions
  void _setupRealtimeSubscriptions() {
    try {
      // Subscribe to all ticket changes
      _ticketsChannel = _supabaseService.subscribeToTableChanges(
        _ticketsTable,
        (newRecord) {
          if (kDebugMode) {
            print('Ticket updated: ${newRecord['id']}');
          }

          // Find and update the ticket in the local cache
          final ticketId = newRecord['id'] as String;
          final index = tickets.indexWhere((t) => t['id'] == ticketId);

          if (index >= 0) {
            // Update existing ticket
            tickets[index] = newRecord;
          } else {
            // Add new ticket
            tickets.add(newRecord);
          }

          // Notify listeners
          ticketsUpdated.value = !ticketsUpdated.value;
          lastUpdatedTicketId.value = ticketId;
        },
        eventTypes: ['INSERT', 'UPDATE'],
      );

      // Subscribe to all comment changes
      _commentsChannel = _supabaseService.subscribeToTableChanges(
        _commentsTable,
        (newRecord) {
          if (kDebugMode) {
            print('Comment updated for ticket: ${newRecord['ticket_id']}');
          }

          // Get the ticket ID
          final ticketId = newRecord['ticket_id'] as String;
          final comment = newRecord;

          // Update comments for this ticket
          if (ticketComments.containsKey(ticketId)) {
            final comments = ticketComments[ticketId]!;
            final index = comments.indexWhere((c) => c['id'] == comment['id']);

            if (index >= 0) {
              // Update existing comment
              comments[index] = comment;
            } else {
              // Add new comment
              comments.add(comment);
            }

            ticketComments[ticketId] = comments;
          } else {
            // Create new entry
            ticketComments[ticketId] = [comment];
          }

          // Notify listeners
          _notifyCommentUpdate(ticketId);
          lastUpdatedTicketId.value = ticketId;
        },
        eventTypes: ['INSERT', 'UPDATE'],
      );

      if (kDebugMode) {
        print('Realtime subscriptions set up for tickets and comments');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up realtime subscriptions: $e');
      }
    }
  }

  // Fetch all tickets with advanced filtering for government use
  Future<List> getAllTickets({
    String? status,
    String? priority,
    String? ticketType,
    String? departmentId,
    String? categoryId,
    String? userId,
    String? district,
    String? state,
    String? wardNumber,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
    bool? isEscalated,
    bool? isSlaBreached,
    int? limit,
    int? offset,
  }) async {
    try {
      // Start building the query
      dynamic query = _supabaseService.client.from(_ticketsTable).select();

      // Apply filters
      if (status != null) query = query.eq('status', status);
      if (priority != null) query = query.eq('priority', priority);
      if (ticketType != null) query = query.eq('ticket_type', ticketType);
      if (departmentId != null) query = query.eq('department_id', departmentId);
      if (categoryId != null) query = query.eq('category_id', categoryId);
      if (userId != null) query = query.eq('user_id', userId);
      if (district != null) query = query.eq('district', district);
      if (state != null) query = query.eq('state', state);
      if (wardNumber != null) query = query.eq('ward_number', wardNumber);

      // Date range filters
      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      // Escalation filter
      if (isEscalated == true) {
        query = query.gt('escalation_level', 0);
      }

      // Apply sorting and pagination
      query = query.order('created_at', ascending: false);
      if (limit != null) query = query.limit(limit);
      if (offset != null)
        query = query.range(offset, offset + (limit ?? 20) - 1);

      // Execute the query
      final List<dynamic> response = await query;
      List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
        response,
      );

      // Apply text search filter manually if needed
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        data = data.where((ticket) {
          final title = (ticket['title'] as String?)?.toLowerCase() ?? '';
          final description =
              (ticket['description'] as String?)?.toLowerCase() ?? '';
          return title.contains(searchLower) ||
              description.contains(searchLower);
        }).toList();
      }

      // If SLA breach filter is applied, we need to fetch SLA info and filter manually
      if (isSlaBreached != null) {
        final List tickets = data;

        // For each ticket, fetch SLA info
        List filteredTickets = [];
        for (var ticket in tickets) {
          final slaInfo = await getSlaInfo(ticket['id']);
          if (slaInfo != null && slaInfo['sla_breached'] == isSlaBreached) {
            filteredTickets.add({...ticket, 'slaInfo': slaInfo});
          }
        }
        return filteredTickets;
      }

      return data;
    } catch (e) {
      throw Exception('Failed to fetch tickets: $e');
    }
  }

  // Get SLA information for a ticket
  Future<dynamic> getSlaInfo(String ticketId) async {
    try {
      final response = await _supabaseService.client
          .from(_slaTrackingTable)
          .select()
          .eq('ticket_id', ticketId)
          .maybeSingle();

      if (response != null) {
        return response;
      }
      return null;
    } catch (e) {
      print('Error fetching SLA info: $e');
      return null;
    }
  }

  // Fetch a single ticket by ID with comments, history, and SLA info
  Future<dynamic> getTicketById(String ticketId) async {
    try {
      // Fetch ticket data
      final ticketData = await _supabaseService.client
          .from(_ticketsTable)
          .select()
          .eq('id', ticketId)
          .single();

      // Fetch comments for this ticket
      final List<dynamic> commentsResponse = await _supabaseService.client
          .from(_commentsTable)
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      final List<Map<String, dynamic>> commentsData =
          List<Map<String, dynamic>>.from(commentsResponse);

      // Convert comments to dynamic objects
      final comments = commentsData;

      // Fetch ticket history
      final List<dynamic> historyResponse = await _supabaseService.client
          .from(_ticketHistoryTable)
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      final List<Map<String, dynamic>> historyData =
          List<Map<String, dynamic>>.from(historyResponse);

      // Convert history to dynamic objects
      final history = historyData;

      // Fetch SLA info
      final slaInfo = await getSlaInfo(ticketId);

      // Create ticket model with all related data
      // Create a new map with all the original data plus the additional fields
      return {
        ...ticketData,
        'comments': comments,
        'history': history,
        'slaInfo': slaInfo,
      };
    } catch (e) {
      throw Exception('Failed to fetch ticket details: $e');
    }
  }

  // Fetch ticket history
  Future<List> getTicketHistory(String ticketId) async {
    try {
      final List<dynamic> response = await _supabaseService.client
          .from(_ticketHistoryTable)
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      final List<Map<String, dynamic>> historyData =
          List<Map<String, dynamic>>.from(response);

      return historyData;
    } catch (e) {
      throw Exception('Failed to fetch ticket history: $e');
    }
  }

  // Get ticket categories
  Future<List<Map<String, dynamic>>> getTicketCategories({
    String? departmentId,
    bool activeOnly = true,
  }) async {
    try {
      dynamic query = _supabaseService.client
          .from(_ticketCategoriesTable)
          .select();

      // Apply filters using PostgrestFilterBuilder methods
      if (departmentId != null) {
        query = query.eq('department_id', departmentId);
      }

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      // Apply ordering
      query = query.order('name');

      final List<dynamic> response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch ticket categories: $e');
    }
  }

  // Get ticket category by ID
  Future<Map<String, dynamic>?> getTicketCategoryById(String categoryId) async {
    try {
      final response = await _supabaseService.client
          .from(_ticketCategoriesTable)
          .select()
          .eq('id', categoryId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch ticket category: $e');
    }
  }

  // Create a new ticket with government-specific fields
  Future<dynamic> createTicket(dynamic ticket) async {
    try {
      // Generate ticket number if not provided
      Map<String, dynamic> ticketJson = ticket is Map<String, dynamic>
          ? Map<String, dynamic>.from(ticket)
          : ticket.toJson();

      if ((ticket is Map<String, dynamic>
                  ? ticket['ticket_number']
                  : ticket.ticketNumber) ==
              null &&
          (ticket is Map<String, dynamic>
                  ? ticket['department_id']
                  : ticket.departmentId) !=
              null) {
        // Get department code
        final deptResponse = await _supabaseService.client
            .from('departments')
            .select('department_code')
            .eq(
              'id',
              (ticket is Map<String, dynamic>
                      ? ticket['department_id']
                      : ticket.departmentId)
                  .toString(),
            )
            .maybeSingle();

        if (deptResponse != null) {
          final deptCode = deptResponse['department_code'] as String? ?? 'DEPT';
          final year = DateTime.now().year;
          final randomNum = DateTime.now().millisecondsSinceEpoch % 10000;
          ticketJson['ticket_number'] = '$deptCode-$year-$randomNum';
        }
      }

      // Insert the ticket
      final Map<String, dynamic> ticketData = await _supabaseService.insertData(
        _ticketsTable,
        ticketJson,
      );

      return ticketData;
    } catch (e) {
      throw Exception('Failed to create ticket: $e');
    }
  }

  // Get escalation matrix for a department and category
  Future<List<Map<String, dynamic>>> getEscalationMatrix({
    required String departmentId,
    String? categoryId,
  }) async {
    try {
      // Start with basic query
      dynamic query = _supabaseService.client
          .from(_escalationMatrixTable)
          .select();

      // Apply department filter
      query = query.eq('department_id', departmentId);

      // Apply category filter if provided
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      // Apply ordering
      query = query.order('level');

      final List<dynamic> response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch escalation matrix: $e');
    }
  }

  // Escalate a ticket
  Future<dynamic> escalateTicket({
    required String ticketId,
    required int escalationLevel,
    String? escalationReason,
    String? escalateToUserId,
  }) async {
    try {
      // Prepare update data
      Map<String, dynamic> updateData = {
        'escalation_level': escalationLevel,
        'status': 'escalated',
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (escalationReason != null) {
        updateData['escalation_reason'] = escalationReason;
      }

      if (escalateToUserId != null) {
        updateData['assigned_to'] = escalateToUserId;
      }

      // Update the ticket
      final Map<String, dynamic> updatedTicket = await _supabaseService
          .updateData(_ticketsTable, ticketId, updateData);

      return updatedTicket;
    } catch (e) {
      throw Exception('Failed to escalate ticket: $e');
    }
  }

  // Forward a ticket to another department
  Future<dynamic> forwardTicket({
    required String ticketId,
    required String newDepartmentId,
    String? forwardingReason,
  }) async {
    try {
      // Get current ticket data to preserve the current department as forwarded_from
      final ticketData = await _supabaseService.client
          .from(_ticketsTable)
          .select()
          .eq('id', ticketId)
          .single();

      final ticket = ticketData;

      // Prepare update data
      Map<String, dynamic> updateData = {
        'department_id': newDepartmentId,
        'forwarded_from_dept_id': ticket['department_id'],
        'status': 'forwarded',
        'updated_at': DateTime.now().toIso8601String(),
        'assigned_to': null, // Clear assignment when forwarding
      };

      if (forwardingReason != null) {
        updateData['forwarded_reason'] = forwardingReason;
      }

      // Update the ticket
      final Map<String, dynamic> updatedTicket = await _supabaseService
          .updateData(_ticketsTable, ticketId, updateData);

      return updatedTicket;
    } catch (e) {
      throw Exception('Failed to forward ticket: $e');
    }
  }

  // Update ticket status and other details
  Future<dynamic> updateTicket(
    String ticketId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Handle special status updates
      if (data['status'] != null) {
        switch (data['status']) {
          case 'resolved':
            if (!data.containsKey('resolved_at')) {
              data['resolved_at'] = DateTime.now().toIso8601String();
            }
            break;
          case 'closed':
            if (!data.containsKey('closed_at')) {
              data['closed_at'] = DateTime.now().toIso8601String();
            }
            break;
        }
      }

      // Always add updatedAt timestamp
      data['updated_at'] = DateTime.now().toIso8601String();

      final Map<String, dynamic> updatedTicket = await _supabaseService
          .updateData(_ticketsTable, ticketId, data);

      return updatedTicket;
    } catch (e) {
      throw Exception('Failed to update ticket: $e');
    }
  }

  // Delete a ticket
  Future<void> deleteTicket(String ticketId) async {
    try {
      // First delete all comments associated with this ticket
      await _supabaseService.client
          .from(_commentsTable)
          .delete()
          .eq('ticket_id', ticketId);

      // Then delete the ticket
      await _supabaseService.deleteData(_ticketsTable, ticketId);
    } catch (e) {
      throw Exception('Failed to delete ticket: $e');
    }
  }

  // Add a comment to a ticket
  Future<dynamic> addComment(dynamic comment) async {
    try {
      final Map<String, dynamic> commentData = await _supabaseService
          .insertData(_commentsTable, comment.toJson());

      return commentData;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Delete a comment
  Future<void> deleteComment(String commentId) async {
    try {
      await _supabaseService.deleteData(_commentsTable, commentId);
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  // Subscribe to tickets for a specific user
  RealtimeChannel subscribeToTickets({String? userId}) {
    // Create a unique channel name for this user's tickets
    final channelKey = userId != null ? 'user_tickets:$userId' : 'all_tickets';

    // Check if we already have a subscription for this user
    if (_ticketSpecificChannels.containsKey(channelKey)) {
      return _ticketSpecificChannels[channelKey]!;
    }

    // Create a new subscription
    RealtimeChannel channel;

    if (userId != null) {
      channel = _supabaseService.client
          .channel('tickets_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: _ticketsTable,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              if (kDebugMode) {
                print('Received user ticket update: ${payload.newRecord}');
              }

              try {
                // Process the ticket update
                {
                  final ticket = payload.newRecord;

                  // Update the local cache
                  final index = tickets.indexWhere(
                    (t) => t['id'] == ticket['id'],
                  );
                  if (index >= 0) {
                    tickets[index] = ticket;
                  } else {
                    tickets.add(ticket);
                  }
                }
              } catch (e) {
                if (kDebugMode) {
                  print('Error processing ticket update: $e');
                }
              }

              // Notify listeners that data has changed
              _notifyTicketUpdate();
              lastUpdatedTicketId.value =
                  (payload.newRecord as Map<String, dynamic>?)?['id'] ?? '';
            },
          )
          .subscribe();
    } else {
      channel = _supabaseService.client
          .channel('tickets_all')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: _ticketsTable,
            callback: (payload) {
              if (kDebugMode) {
                print('Received all tickets update: ${payload.newRecord}');
              }

              try {
                // Process the ticket update
                {
                  final ticket = payload.newRecord;

                  // Update the local cache
                  final index = tickets.indexWhere(
                    (t) => t['id'] == ticket['id'],
                  );
                  if (index >= 0) {
                    tickets[index] = ticket;
                  } else {
                    tickets.add(ticket);
                  }
                }
              } catch (e) {
                if (kDebugMode) {
                  print('Error processing ticket update: $e');
                }
              }

              // Notify listeners that data has changed
              _notifyTicketUpdate();
              lastUpdatedTicketId.value =
                  (payload.newRecord as Map<String, dynamic>?)?['id'] ?? '';
            },
          )
          .subscribe();
    }

    // Store the channel for later reference
    _ticketSpecificChannels[channelKey] = channel;

    return channel;
  }

  // Subscribe to comments for a specific ticket
  RealtimeChannel subscribeToComments(String ticketId) {
    // Create a unique channel name for this ticket's comments
    final channelKey = 'ticket_comments:$ticketId';

    // Check if we already have a subscription for this ticket
    if (_ticketSpecificChannels.containsKey(channelKey)) {
      return _ticketSpecificChannels[channelKey]!;
    }

    // Create a new subscription
    final channel = _supabaseService.client
        .channel('comments_$ticketId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _commentsTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'ticket_id',
            value: ticketId,
          ),
          callback: (payload) {
            if (kDebugMode) {
              print('Received comment update: ${payload.newRecord}');
            }

            try {
              // Process the comment update if we have a new record
              final comment = payload.newRecord;

              // Update the local cache
              if (ticketComments.containsKey(ticketId)) {
                final comments = ticketComments[ticketId]!;
                final index = comments.indexWhere(
                  (c) => c['id'] == comment['id'],
                );

                if (index >= 0) {
                  comments[index] = comment;
                } else {
                  comments.add(comment);
                }

                ticketComments[ticketId] = comments;
              } else {
                ticketComments[ticketId] = [comment];
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error processing comment update: $e');
              }
            }

            // Notify listeners that data has changed
            _notifyCommentUpdate(ticketId);
          },
        )
        .subscribe();

    // Store the channel for later reference
    _ticketSpecificChannels[channelKey] = channel;

    return channel;
  }

  // This RxMap is used for per-ticket comment updates

  // Method to notify listeners that tickets have been updated
  void _notifyTicketUpdate() {
    ticketsUpdated.toggle();
  }

  // Method to notify listeners that comments for a specific ticket have been updated
  void _notifyCommentUpdate(String ticketId) {
    // Use a Map getter/setter approach instead of direct indexing on RxBool
    final current = commentsUpdated.containsKey(ticketId)
        ? commentsUpdated[ticketId]!
        : false;
    final updated = Map<String, bool>.from(commentsUpdated);
    updated[ticketId] = !current;
    commentsUpdated.value = updated;
  }

  // Clean up subscriptions
  void disposeSubscriptions() {
    _ticketsChannel?.unsubscribe();
    _commentsChannel?.unsubscribe();

    // Clean up ticket-specific subscriptions
    _ticketSpecificChannels.forEach((_, channel) {
      channel.unsubscribe();
    });
    _ticketSpecificChannels.clear();

    if (kDebugMode) {
      print('Disposed all ticket subscriptions');
    }
  }

  @override
  void onClose() {
    disposeSubscriptions();
    super.onClose();
  }

  // Subscribe to SLA tracking updates
  RealtimeChannel subscribeToSlaTracking(String ticketId) {
    return _supabaseService.client
        .channel('sla_$ticketId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _slaTrackingTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'ticket_id',
            value: ticketId,
          ),
          callback: (payload) {
            print('Received SLA update: $payload');
            // Notify listeners that data has changed
            Get.find<TicketService>()._notifyTicketUpdate();
          },
        )
        .subscribe();
  }

  // Subscribe to ticket history updates
  RealtimeChannel subscribeToTicketHistory(String ticketId) {
    return _supabaseService.client
        .channel('history_$ticketId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _ticketHistoryTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'ticket_id',
            value: ticketId,
          ),
          callback: (payload) {
            print('Received history update: $payload');
            // Notify listeners that data has changed
            Get.find<TicketService>()._notifyTicketUpdate();
          },
        )
        .subscribe();
  }

  // Get ticket counts by status with department and category filters
  Future<Map<String, int>> getTicketCountsByStatus({
    String? userId,
    String? departmentId,
    String? categoryId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      // Initialize counts with all possible statuses
      final Map<String, int> counts = {
        STATUS_OPEN: 0,
        STATUS_IN_PROGRESS: 0,
        STATUS_PENDING: 0,
        STATUS_RESOLVED: 0,
        STATUS_CLOSED: 0,
        STATUS_REJECTED: 0,
        STATUS_ESCALATED: 0,
        STATUS_FORWARDED: 0,
      };

      // Use Supabase to get counts by status
      for (String status in STATUS_VALUES) {
        // First, build a query to count tickets with this status
        var query = _supabaseService.client
            .from(_ticketsTable)
            .select('id')
            .eq('status', status);

        // Apply filters
        if (userId != null) {
          query = query.eq('user_id', userId);
        }

        if (departmentId != null) {
          query = query.eq('department_id', departmentId);
        }

        if (categoryId != null) {
          query = query.eq('category_id', categoryId);
        }

        // Date range filters
        if (fromDate != null) {
          query = query.gte('created_at', fromDate.toIso8601String());
        }

        if (toDate != null) {
          query = query.lte('created_at', toDate.toIso8601String());
        }

        // Execute the query and count the results
        final response = await query;
        counts[status] = response.length;
      }

      return counts;
    } catch (e) {
      print('Error getting ticket counts: $e');
      // Return empty counts on error
      return {
        STATUS_OPEN: 0,
        STATUS_IN_PROGRESS: 0,
        STATUS_PENDING: 0,
        STATUS_RESOLVED: 0,
        STATUS_CLOSED: 0,
        STATUS_REJECTED: 0,
        STATUS_ESCALATED: 0,
        STATUS_FORWARDED: 0,
      };
    }
  }

  // Get tickets with breached SLA
  Future<List> getBreachedSlaTickets({
    String? departmentId,
    String? categoryId,
    int limit = 10,
  }) async {
    try {
      // First get SLA breached records
      var slaQuery = _supabaseService.client
          .from(_slaTrackingTable)
          .select('ticket_id')
          .eq('sla_breached', true)
          .limit(limit);

      final List<dynamic> slaResponse = await slaQuery;
      final List<String> breachedTicketIds = slaResponse
          .map((item) => item['ticket_id'] as String)
          .toList();

      if (breachedTicketIds.isEmpty) {
        return [];
      }

      // Then fetch the actual tickets - we'll need to use multiple queries
      // since Supabase doesn't support direct 'IN' operator
      List tickets = [];

      for (String ticketId in breachedTicketIds) {
        var ticketQuery = _supabaseService.client
            .from(_ticketsTable)
            .select()
            .eq('id', ticketId);

        if (departmentId != null) {
          ticketQuery = ticketQuery.eq('department_id', departmentId);
        }

        if (categoryId != null) {
          ticketQuery = ticketQuery.eq('category_id', categoryId);
        }

        final List<dynamic> ticketResponse = await ticketQuery;
        if (ticketResponse.isNotEmpty) {
          final Map<String, dynamic> ticketData = ticketResponse.first;
          tickets.add(ticketData);
        }
      }

      // Sort by created_at descending
      tickets.sort(
        (a, b) =>
            (b['created_at'] as String).compareTo(a['created_at'] as String),
      );

      return tickets;
    } catch (e) {
      print('Error getting breached SLA tickets: $e');
      return [];
    }
  }
}
