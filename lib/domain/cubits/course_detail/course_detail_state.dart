import 'package:equatable/equatable.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/task_model.dart';

sealed class CourseDetailState extends Equatable {
  const CourseDetailState();

  @override
  List<Object?> get props => [];
}

class CourseDetailInitial extends CourseDetailState {
  const CourseDetailInitial();
}

class CourseDetailLoading extends CourseDetailState {
  const CourseDetailLoading();
}

class CourseDetailLoaded extends CourseDetailState {
  final CourseModel course;
  final List<TaskModel> tasks;

  const CourseDetailLoaded({required this.course, required this.tasks});

  @override
  List<Object?> get props => [course, tasks];
}

class CourseDetailError extends CourseDetailState {
  final String message;

  const CourseDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
