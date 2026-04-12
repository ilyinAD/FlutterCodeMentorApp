import 'package:equatable/equatable.dart';

class CourseModel extends Equatable {
  final int courseId;
  final int teacherId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime? createdAt;

  const CourseModel({
    required this.courseId,
    required this.teacherId,
    required this.title,
    this.description,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseId: json['course_id'] as int,
      teacherId: json['teacher_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [courseId, teacherId, title, description, startDate, endDate, isActive];
}
