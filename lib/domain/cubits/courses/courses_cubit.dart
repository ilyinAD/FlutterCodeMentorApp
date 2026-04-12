import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/course_repository.dart';
import 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  final CourseRepository _repository;
  final AuthRepository _authRepository;

  CoursesCubit(this._repository, this._authRepository)
      : super(const CoursesInitial());

  int? get _teacherId => _authRepository.getCurrentUser()?.userId;

  Future<void> loadCourses() async {
    final teacherId = _teacherId;
    if (teacherId == null) {
      emit(const CoursesError('Вы не авторизованы'));
      return;
    }
    emit(const CoursesLoading());
    try {
      final courses = await _repository.getTeacherCourses(teacherId);
      emit(CoursesLoaded(courses));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> createCourse({
    required String title,
    String? description,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final teacherId = _teacherId;
    if (teacherId == null) {
      emit(const CoursesError('Вы не авторизованы'));
      return;
    }
    try {
      await _repository.createCourse(
        teacherId: teacherId,
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
      );
      await loadCourses();
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }
}
