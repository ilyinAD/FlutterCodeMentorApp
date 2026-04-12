import 'package:equatable/equatable.dart';

class CodeReviewModel extends Equatable {
  final int id;
  final int submissionId;
  final String? aiModel;
  final String overallStatus;
  final double? aiConfidence;
  final int? executionTimeMs;
  final DateTime? createdAt;
  final List<ReviewFeedbackModel> feedbacks;

  const CodeReviewModel({
    required this.id,
    required this.submissionId,
    this.aiModel,
    required this.overallStatus,
    this.aiConfidence,
    this.executionTimeMs,
    this.createdAt,
    this.feedbacks = const [],
  });

  factory CodeReviewModel.fromJson(Map<String, dynamic> json) {
    return CodeReviewModel(
      id: json['id'] as int,
      submissionId: json['submission_id'] as int,
      aiModel: json['ai_model'] as String?,
      overallStatus: json['overall_status'] as String? ?? 'pending',
      aiConfidence: (json['ai_confidence'] as num?)?.toDouble(),
      executionTimeMs: json['execution_time_ms'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      feedbacks: (json['feedbacks'] as List<dynamic>?)
              ?.map((e) =>
                  ReviewFeedbackModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, submissionId, overallStatus];
}

class ReviewFeedbackModel extends Equatable {
  final int id;
  final int reviewId;
  final String feedbackType;
  final String? filePath;
  final int? lineStart;
  final int? lineEnd;
  final String? codeSnippet;
  final String? suggestedFix;
  final String description;
  final int severity;
  final bool isResolved;
  final String? teacherComment;
  final bool? teacherApproved;

  const ReviewFeedbackModel({
    required this.id,
    required this.reviewId,
    required this.feedbackType,
    this.filePath,
    this.lineStart,
    this.lineEnd,
    this.codeSnippet,
    this.suggestedFix,
    required this.description,
    required this.severity,
    this.isResolved = false,
    this.teacherComment,
    this.teacherApproved,
  });

  factory ReviewFeedbackModel.fromJson(Map<String, dynamic> json) {
    return ReviewFeedbackModel(
      id: json['id'] as int,
      reviewId: json['review_id'] as int,
      feedbackType: json['feedback_type'] as String,
      filePath: json['file_path'] as String?,
      lineStart: json['line_start'] as int?,
      lineEnd: json['line_end'] as int?,
      codeSnippet: json['code_snippet'] as String?,
      suggestedFix: json['suggested_fix'] as String?,
      description: json['description'] as String,
      severity: json['severity'] as int? ?? 1,
      isResolved: json['is_resolved'] as bool? ?? false,
      teacherComment: json['teacher_comment'] as String?,
      teacherApproved: json['teacher_approved'] as bool?,
    );
  }

  @override
  List<Object?> get props => [id, reviewId, feedbackType, severity, teacherApproved];
}
