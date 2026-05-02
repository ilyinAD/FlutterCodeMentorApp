import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/submission_repository.dart';
import 'submissions_state.dart';

class SubmissionsCubit extends Cubit<SubmissionsState> {
  final SubmissionRepository _repository;
  final int taskId;
  final int? studentId;

  SubmissionsCubit(this._repository, this.taskId, {this.studentId})
      : super(const SubmissionsInitial());

  Future<void> load() async {
    emit(const SubmissionsLoading());
    try {
      final submissions = await _repository.getTaskSubmissions(
        taskId,
        studentId: studentId,
      );
      emit(SubmissionsLoaded(submissions));
    } catch (e) {
      emit(SubmissionsError(e.toString()));
    }
  }
}
