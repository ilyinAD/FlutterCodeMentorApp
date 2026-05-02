import 'package:equatable/equatable.dart';
import '../../../data/models/course_model.dart';

sealed class StudentCoursesState extends Equatable {
  const StudentCoursesState();

  @override
  List<Object?> get props => [];
}

class StudentCoursesInitial extends StudentCoursesState {
  const StudentCoursesInitial();
}

class StudentCoursesLoading extends StudentCoursesState {
  const StudentCoursesLoading();
}

class StudentCoursesLoaded extends StudentCoursesState {
  final List<CourseModel> courses;

  const StudentCoursesLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class StudentCoursesError extends StudentCoursesState {
  final String message;

  const StudentCoursesError(this.message);

  @override
  List<Object?> get props => [message];
}
