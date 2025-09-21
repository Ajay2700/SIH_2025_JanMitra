// Local ticket model for offline support and caching
import 'package:jan_mitra/data/models/ticket_model.dart';

/// Local version of TicketModel for offline storage and caching
class TicketModelLocal {
  final String id;
  final String? ticketNumber;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? ticketType;
  final String userId;
  final String? assignedTo;
  final String? departmentId;
  final String? categoryId;
  final String? subCategory;
  final String? locationAddress;
  final String? district;
  final String? state;
  final String? pinCode;
  final double? latitude;
  final double? longitude;
  final String? wardNumber;
  final String? constituency;
  final int? escalationLevel;
  final String? escalationReason;
  final String? forwardedFromDeptId;
  final String? forwardedReason;
  final bool isPublic;
  final int? satisfactionRating;
  final String? feedbackText;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final List<String>? attachments;
  final List<dynamic>? comments;
  final List<dynamic>? history;
  final Map<String, dynamic>? slaInfo;

  // Local-specific fields
  final bool isOffline;
  final bool isPendingSync;
  final DateTime? lastSyncedAt;

  TicketModelLocal({
    required this.id,
    this.ticketNumber,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.ticketType,
    required this.userId,
    this.assignedTo,
    this.departmentId,
    this.categoryId,
    this.subCategory,
    this.locationAddress,
    this.district,
    this.state,
    this.pinCode,
    this.latitude,
    this.longitude,
    this.wardNumber,
    this.constituency,
    this.escalationLevel,
    this.escalationReason,
    this.forwardedFromDeptId,
    this.forwardedReason,
    this.isPublic = false,
    this.satisfactionRating,
    this.feedbackText,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.closedAt,
    this.attachments,
    this.comments,
    this.history,
    this.slaInfo,
    this.isOffline = false,
    this.isPendingSync = false,
    this.lastSyncedAt,
  });

  // Convert from TicketModel
  factory TicketModelLocal.fromTicketModel(dynamic ticket) {
    return TicketModelLocal(
      id: ticket.id,
      ticketNumber: ticket.ticketNumber,
      title: ticket.title,
      description: ticket.description,
      status: ticket.status,
      priority: ticket.priority,
      ticketType: ticket.ticketType,
      userId: ticket.userId,
      assignedTo: ticket.assignedTo,
      departmentId: ticket.departmentId,
      categoryId: ticket.categoryId,
      subCategory: ticket.subCategory,
      locationAddress: ticket.locationAddress,
      district: ticket.district,
      state: ticket.state,
      pinCode: ticket.pinCode,
      latitude: ticket.latitude,
      longitude: ticket.longitude,
      wardNumber: ticket.wardNumber,
      constituency: ticket.constituency,
      escalationLevel: ticket.escalationLevel,
      escalationReason: ticket.escalationReason,
      forwardedFromDeptId: ticket.forwardedFromDeptId,
      forwardedReason: ticket.forwardedReason,
      isPublic: ticket.isPublic,
      satisfactionRating: ticket.satisfactionRating,
      feedbackText: ticket.feedbackText,
      dueDate: ticket.dueDate,
      createdAt: ticket.createdAt,
      updatedAt: ticket.updatedAt,
      resolvedAt: ticket.resolvedAt,
      closedAt: ticket.closedAt,
      attachments: ticket.attachments,
      comments: ticket.comments,
      history: ticket.history,
      slaInfo: ticket.slaInfo,
    );
  }

  // Convert to TicketModel
  Map<String, dynamic> toTicketModel() {
    return {
      id: id,
      title: title,
      description: description,
      status: status,
      priority: priority,
      userId: userId,
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketNumber': ticketNumber,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'ticketType': ticketType,
      'userId': userId,
      'assignedTo': assignedTo,
      'departmentId': departmentId,
      'categoryId': categoryId,
      'subCategory': subCategory,
      'locationAddress': locationAddress,
      'district': district,
      'state': state,
      'pinCode': pinCode,
      'latitude': latitude,
      'longitude': longitude,
      'wardNumber': wardNumber,
      'constituency': constituency,
      'escalationLevel': escalationLevel,
      'escalationReason': escalationReason,
      'forwardedFromDeptId': forwardedFromDeptId,
      'forwardedReason': forwardedReason,
      'isPublic': isPublic,
      'satisfactionRating': satisfactionRating,
      'feedbackText': feedbackText,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'attachments': attachments,
      'comments': comments,
      'history': history,
      'slaInfo': slaInfo,
      'isOffline': isOffline,
      'isPendingSync': isPendingSync,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory TicketModelLocal.fromJson(Map<String, dynamic> json) {
    return TicketModelLocal(
      id: json['id'],
      ticketNumber: json['ticketNumber'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      priority: json['priority'],
      ticketType: json['ticketType'],
      userId: json['userId'],
      assignedTo: json['assignedTo'],
      departmentId: json['departmentId'],
      categoryId: json['categoryId'],
      subCategory: json['subCategory'],
      locationAddress: json['locationAddress'],
      district: json['district'],
      state: json['state'],
      pinCode: json['pinCode'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      wardNumber: json['wardNumber'],
      constituency: json['constituency'],
      escalationLevel: json['escalationLevel'],
      escalationReason: json['escalationReason'],
      forwardedFromDeptId: json['forwardedFromDeptId'],
      forwardedReason: json['forwardedReason'],
      isPublic: json['isPublic'] ?? false,
      satisfactionRating: json['satisfactionRating'],
      feedbackText: json['feedbackText'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      closedAt: json['closedAt'] != null
          ? DateTime.parse(json['closedAt'])
          : null,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      comments: json['comments'],
      history: json['history'],
      slaInfo: json['slaInfo'],
      isOffline: json['isOffline'] ?? false,
      isPendingSync: json['isPendingSync'] ?? false,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'])
          : null,
    );
  }
}
