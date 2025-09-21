import 'package:jan_mitra/data/models/location_model.dart';

class IssueModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final LocationModel location;
  final String address;
  final String imageUrl;
  final String createdBy;
  final String? assignedTo;
  final String? categoryId;
  final String? departmentId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;

  IssueModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.location,
    required this.address,
    required this.imageUrl,
    required this.createdBy,
    this.assignedTo,
    this.categoryId,
    this.departmentId,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
  });

  @override
  String toString() {
    return 'IssueModel(id: $id, title: $title, status: $status, priority: $priority)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'location': location.toJson(),
      'address': address,
      'image_url': imageUrl,
      'created_by': createdBy,
      'assigned_to': assignedTo,
      'category_id': categoryId,
      'department_id': departmentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      location: LocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      address: json['address'] as String,
      imageUrl: json['image_url'] as String,
      createdBy: json['created_by'] as String,
      assignedTo: json['assigned_to'] as String?,
      categoryId: json['category_id'] as String?,
      departmentId: json['department_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }
}
