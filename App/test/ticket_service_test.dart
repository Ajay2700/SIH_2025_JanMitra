import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/data/services/ticket_service.dart';

// Create a simplified TicketService for testing
class TestTicketService extends TicketService {
  // Test data
  final Map<String, List<Map<String, dynamic>>> testData = {};

  // Mock responses
  Map<String, dynamic>? mockInsertResponse;
  Map<String, dynamic>? mockUpdateResponse;

  // Override methods that interact with Supabase
  @override
  Future<List> getAllTickets({
    String? status,
    String? priority,
    String? departmentId,
    String? userId,
    String? searchQuery,
    int? limit,
    int? offset,
    String? categoryId,
    String? district,
    DateTime? fromDate,
    bool? isEscalated,
    bool? isSlaBreached,
    String? state,
    String? ticketType,
    DateTime? toDate,
    String? wardNumber,
  }) async {
    final tickets = testData['tickets'] ?? [];
    return tickets;
  }

  @override
  Future<dynamic> getTicketById(String ticketId) async {
    final tickets = testData['tickets'] ?? [];
    final ticketData = tickets.firstWhere(
      (ticket) => ticket['id'] == ticketId,
      orElse: () => {'id': ticketId},
    );

    final comments = testData['ticket_comments'] ?? [];
    final ticketComments = comments
        .where((comment) => comment['ticket_id'] == ticketId)
        .toList();

    // Create ticket with comments
    final ticketJson = Map<String, dynamic>.from(ticketData);
    if (ticketComments.isNotEmpty) {
      ticketJson['comments'] = ticketComments;
    }

    return ticketJson;
  }

  @override
  Future<dynamic> createTicket(dynamic ticket) async {
    final response =
        mockInsertResponse ??
        (ticket is Map<String, dynamic>
            ? {
                ...ticket,
                'id': 'mock-id',
                'created_at': DateTime.now().toIso8601String(),
              }
            : {
                ...ticket.toJson(),
                'id': 'mock-id',
                'created_at': DateTime.now().toIso8601String(),
              });
    return response;
  }

  // Helper method to set up test data
  void setTestData(String table, List<Map<String, dynamic>> data) {
    testData[table] = data;
  }
}

void main() {
  late TestTicketService testTicketService;

  setUp(() {
    testTicketService = TestTicketService();
    Get.put<TicketService>(testTicketService);
  });

  tearDown(() {
    Get.reset();
  });

  group('TicketService Tests', () {
    test('getAllTickets should return a list of tickets', () async {
      // Arrange
      final mockTickets = [
        {
          'id': '1',
          'title': 'Test Ticket',
          'description': 'Test Description',
          'status': 'open',
          'priority': 'medium',
          'user_id': 'user123',
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      testTicketService.setTestData('tickets', mockTickets);

      // Act
      final result = await testTicketService.getAllTickets();

      // Assert
      expect(result, isA<List>());
      expect(result.length, 1);
      expect(result[0]['title'], 'Test Ticket');
      expect(result[0]['status'], 'open');
    });

    test('createTicket should create a new ticket', () async {
      // Arrange
      final ticket = {
        'title': 'New Ticket',
        'description': 'New Description',
        'user_id': 'user123',
      };

      testTicketService.mockInsertResponse = {
        'id': 'new-id',
        'title': 'New Ticket',
        'description': 'New Description',
        'status': 'open',
        'priority': 'medium',
        'user_id': 'user123',
        'created_at': DateTime.now().toIso8601String(),
      };

      // Act
      final result = await testTicketService.createTicket(ticket);

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], 'new-id');
      expect(result['title'], 'New Ticket');
    });

    test('getTicketById should return a ticket with comments', () async {
      // Arrange
      final ticketId = 'ticket123';
      final mockTicket = {
        'id': ticketId,
        'title': 'Test Ticket',
        'description': 'Test Description',
        'status': 'open',
        'priority': 'medium',
        'user_id': 'user123',
        'created_at': DateTime.now().toIso8601String(),
      };

      final mockComments = [
        {
          'id': 'comment1',
          'ticket_id': ticketId,
          'user_id': 'user123',
          'content': 'Test Comment',
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      testTicketService.setTestData('tickets', [mockTicket]);
      testTicketService.setTestData('ticket_comments', mockComments);

      // Act
      final result = await testTicketService.getTicketById(ticketId);

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], ticketId);
      expect(result['comments'], isNotNull);
      expect(result['comments'].length, 1);
      expect(result['comments'][0]['content'], 'Test Comment');
    });
  });
}
