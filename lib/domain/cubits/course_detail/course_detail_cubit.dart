import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/task_repository.dart';
import 'course_detail_state.dart';

class CourseDetailCubit extends Cubit<CourseDetailState> {
  final CourseRepository _courseRepository;
  final TaskRepository _taskRepository;
  final int courseId;

  CourseDetailCubit(this._courseRepository, this._taskRepository, this.courseId)
      : super(const CourseDetailInitial());

  Future<void> load() async {
    emit(const CourseDetailLoading());
    try {
      final results = await Future.wait([
        _courseRepository.getCourse(courseId),
        _taskRepository.getCourseTasks(courseId),
      ]);
      emit(CourseDetailLoaded(
        course: results[0] as CourseModel,
        tasks: results[1] as List<TaskModel>,
      ));
    } catch (e) {
      emit(CourseDetailError(e.toString()));
    }
  }
}
