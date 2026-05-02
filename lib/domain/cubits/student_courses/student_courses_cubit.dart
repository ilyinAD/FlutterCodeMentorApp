import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/course_repository.dart';
import 'student_courses_state.dart';

class StudentCoursesCubit extends Cubit<StudentCoursesState> {
  final CourseRepository _repository;
  final AuthRepository _authRepository;

  StudentCoursesCubit(this._repository, this._authRepository)
      : super(const StudentCoursesInitial());

  Future<void> load() async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      emit(const StudentCoursesError('Вы не авторизованы'));
      return;
    }
    emit(const StudentCoursesLoading());
    try {
      final courses = await _repository.getStudentCourses(user.userId);
      emit(StudentCoursesLoaded(courses));
    } catch (e) {
      emit(StudentCoursesError(e.toString()));
    }
  }
}
