class DepartmentModel {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  DepartmentModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
