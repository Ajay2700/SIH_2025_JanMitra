import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/data/models/comment_model.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/data/services/issue_service.dart';

class IssueRepository extends GetxService {
  final IssueService _issueService = Get.find<IssueService>();

  Future<List<IssueModel>> getIssuesByUser(String userId) async {
    try {
      return await _issueService.getAllIssues(userId: userId);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting issues by user: ${e.toString()}');
      }
      throw Exception('Failed to get issues: ${e.toString()}');
    }
  }

  Future<List<IssueModel>> getAllIssues({
    String? status,
    String? priority,
    String? categoryId,
    String? departmentId,
    String? userId,
    String? assignedTo,
    int? limit,
    int? offset,
  }) async {
    try {
      return await _issueService.getAllIssues(
        status: status,
        priority: priority,
        categoryId: categoryId,
        departmentId: departmentId,
        userId: userId,
        assignedTo: assignedTo,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all issues: ${e.toString()}');
      }
      throw Exception('Failed to get issues: ${e.toString()}');
    }
  }

  Future<IssueModel> createIssue({
    required String title,
    required String description,
    required String imagePath,
    required double latitude,
    required double longitude,
    required String address,
    required String priority,
    required String userId,
    String? categoryId,
  }) async {
    try {
      return await _issueService.createIssue(
        title: title,
        description: description,
        imagePath: imagePath,
        latitude: latitude,
        longitude: longitude,
        address: address,
        priority: priority,
        userId: userId,
        categoryId: categoryId,
      );
    } catch (e) {
      throw Exception('Failed to create issue: ${e.toString()}');
    }
  }

  Future<IssueModel> updateIssueStatus({
    required String issueId,
    required String status,
    String? assignedTo,
  }) async {
    try {
      return await _issueService.updateIssueStatus(
        issueId: issueId,
        status: status,
        assignedTo: assignedTo,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating issue status: ${e.toString()}');
      }
      throw Exception('Failed to update issue status: ${e.toString()}');
    }
  }

  Future<List<CommentModel>> getCommentsByIssue(String issueId) async {
    try {
      return await _issueService.getCommentsByIssue(issueId);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting comments: ${e.toString()}');
      }
      throw Exception('Failed to get comments: ${e.toString()}');
    }
  }

  Future<CommentModel> addComment({
    required String issueId,
    required String userId,
    required String message,
  }) async {
    try {
      return await _issueService.addComment(
        issueId: issueId,
        userId: userId,
        message: message,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error adding comment: ${e.toString()}');
      }
      throw Exception('Failed to add comment: ${e.toString()}');
    }
  }

  Future<IssueModel> updateIssue({
    required String issueId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assignedTo,
    String? departmentId,
    String? categoryId,
  }) async {
    try {
      return await _issueService.updateIssue(
        issueId: issueId,
        title: title,
        description: description,
        status: status,
        priority: priority,
        assignedTo: assignedTo,
        departmentId: departmentId,
        categoryId: categoryId,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating issue: ${e.toString()}');
      }
      throw Exception('Failed to update issue: ${e.toString()}');
    }
  }

  Future<void> deleteIssue(String issueId) async {
    try {
      await _issueService.deleteIssue(issueId);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting issue: ${e.toString()}');
      }
      throw Exception('Failed to delete issue: ${e.toString()}');
    }
  }
}
