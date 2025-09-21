class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String role;
  final String? departmentId;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    this.departmentId,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get user type based on role for UI compatibility
  String get userType => role;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'department_id': departmentId,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      departmentId: json['department_id'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
