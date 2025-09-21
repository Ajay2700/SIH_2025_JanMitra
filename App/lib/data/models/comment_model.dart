class CommentModel {
  final String id;
  final String issueId;
  final String userId;
  final String message;
  final DateTime createdAt;
  final Map<String, dynamic>? user;

  CommentModel({
    required this.id,
    required this.issueId,
    required this.userId,
    required this.message,
    required this.createdAt,
    this.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'issue_id': issueId,
      'user_id': userId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'user': user,
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      issueId: json['issue_id'] as String,
      userId: json['user_id'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: json['user'] as Map<String, dynamic>?,
    );
  }
}
