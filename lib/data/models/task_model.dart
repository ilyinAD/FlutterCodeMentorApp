import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  final int taskId;
  final int courseId;
  final String title;
  final String? description;
  final DateTime deadline;
  final int maxScore;
  final String status;
  final DateTime? createdAt;
  final List<TaskCriteriaModel>? criteria;

  const TaskModel({
    required this.taskId,
    required this.courseId,
    required this.title,
    this.description,
    required this.deadline,
    required this.maxScore,
    required this.status,
    this.createdAt,
    this.criteria,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: json['task_id'] as int,
      courseId: json['course_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      deadline: DateTime.parse(json['deadline'] as String),
      maxScore: json['max_score'] as int,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      criteria: (json['criteria'] as List<dynamic>?)
          ?.map((e) => TaskCriteriaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props =>
      [taskId, courseId, title, deadline, maxScore, status];
}

class TaskCriteriaModel extends Equatable {
  final int? id;
  final String criterionName;
  final String criterionDescription;
  final bool isMandatory;
  final int weight;

  const TaskCriteriaModel({
    this.id,
    required this.criterionName,
    required this.criterionDescription,
    this.isMandatory = true,
    this.weight = 10,
  });

  factory TaskCriteriaModel.fromJson(Map<String, dynamic> json) {
    return TaskCriteriaModel(
      id: json['id'] as int?,
      criterionName: json['criterion_name'] as String,
      criterionDescription: json['criterion_description'] as String,
      isMandatory: json['is_mandatory'] as bool? ?? true,
      weight: json['weight'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'criterion_name': criterionName,
        'criterion_description': criterionDescription,
        'is_mandatory': isMandatory,
        'weight': weight,
      };

  @override
  List<Object?> get props =>
      [id, criterionName, criterionDescription, isMandatory, weight];
}
