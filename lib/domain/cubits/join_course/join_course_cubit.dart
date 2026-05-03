import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/course_repository.dart';
import 'join_course_state.dart';

class JoinCourseCubit extends Cubit<JoinCourseState> {
  final CourseRepository _repository;
  final AuthRepository _authRepository;

  JoinCourseCubit(this._repository, this._authRepository)
      : super(const JoinCourseIdle());

  Future<void> join(int courseId) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      emit(const JoinCourseError('You are not signed in'));
      return;
    }
    emit(const JoinCourseSubmitting());
    try {
      await _repository.joinCourse(user.userId, courseId);
      emit(const JoinCourseSuccess());
    } catch (e) {
      emit(JoinCourseError(e.toString()));
    }
  }
}
