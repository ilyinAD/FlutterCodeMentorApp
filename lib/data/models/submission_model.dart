import 'package:equatable/equatable.dart';

class SubmissionModel extends Equatable {
  final int submissionId;
  final int taskId;
  final int userId;
  final String submissionType;
  final String? code;
  final String? githubUrl;
  final String status;
  final double? score;
  final DateTime? createdAt;
  final String? studentName;

  const SubmissionModel({
    required this.submissionId,
    required this.taskId,
    required this.userId,
    required this.submissionType,
    this.code,
    this.githubUrl,
    required this.status,
    this.score,
    this.createdAt,
    this.studentName,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      submissionId: json['submission_id'] as int,
      taskId: json['task_id'] as int,
      userId: json['user_id'] as int,
      submissionType: json['submission_type'] as String? ?? 'code',
      code: json['code'] as String?,
      githubUrl: json['github_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      score: (json['score'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      studentName: json['student_name'] as String?,
    );
  }

  @override
  List<Object?> get props => [submissionId, taskId, userId, status, score];
}
