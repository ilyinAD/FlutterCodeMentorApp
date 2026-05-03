import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/submission_repository.dart';
import 'submit_solution_state.dart';

class SubmitSolutionCubit extends Cubit<SubmitSolutionState> {
  final SubmissionRepository _repository;
  final AuthRepository _authRepository;
  final int taskId;

  SubmitSolutionCubit(this._repository, this._authRepository, this.taskId)
      : super(const SubmitSolutionIdle());

  Future<void> submit({
    required String submissionType,
    String? code,
    String? githubUrl,
  }) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      emit(const SubmitSolutionError('You are not signed in'));
      return;
    }
    emit(const SubmitSolutionSubmitting());
    try {
      await _repository.createSubmission(
        taskId: taskId,
        userId: user.userId,
        submissionType: submissionType,
        code: code,
        githubUrl: githubUrl,
      );
      emit(const SubmitSolutionSuccess());
    } catch (e) {
      emit(SubmitSolutionError(e.toString()));
    }
  }
}
