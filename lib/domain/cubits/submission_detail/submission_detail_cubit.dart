import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/review_model.dart';
import '../../../data/repositories/submission_repository.dart';
import 'submission_detail_state.dart';

class SubmissionDetailCubit extends Cubit<SubmissionDetailState> {
  final SubmissionRepository _repository;
  final int submissionId;

  SubmissionDetailCubit(this._repository, this.submissionId)
      : super(const SubmissionDetailState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final submission = await _repository.getSubmission(submissionId);
      CodeReviewModel? review;
      try {
        review = await _repository.getSubmissionReview(submissionId);
      } catch (_) {
        review = null;
      }
      emit(state.copyWith(
        loading: false,
        submission: submission,
        review: review,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  Future<void> applyFeedbackAction({
    required int feedbackId,
    bool? approved,
    String? comment,
  }) async {
    emit(state.copyWith(submittingAction: true, clearActionMessage: true));
    try {
      await _repository.postTeacherReview(
        submissionId: submissionId,
        feedbackActions: [
          {
            'feedback_id': feedbackId,
            if (approved != null) 'teacher_approved': approved,
            if (comment != null) 'teacher_comment': comment,
          }
        ],
      );
      final review = await _repository.getSubmissionReview(submissionId);
      emit(state.copyWith(
        submittingAction: false,
        review: review,
        actionMessage: 'Сохранено',
      ));
    } catch (e) {
      emit(state.copyWith(
        submittingAction: false,
        actionMessage: 'Ошибка: $e',
      ));
    }
  }

  Future<void> addTeacherFeedback({
    required String description,
    required int severity,
    String? feedbackType,
    String? filePath,
    int? lineStart,
    int? lineEnd,
    String? codeSnippet,
    String? suggestedFix,
  }) async {
    emit(state.copyWith(submittingAction: true, clearActionMessage: true));
    try {
      await _repository.postTeacherReview(
        submissionId: submissionId,
        teacherFeedbacks: [
          {
            'description': description,
            'severity': severity,
            if (feedbackType != null && feedbackType.isNotEmpty)
              'feedback_type': feedbackType,
            if (filePath != null && filePath.isNotEmpty) 'file_path': filePath,
            if (lineStart != null) 'line_start': lineStart,
            if (lineEnd != null) 'line_end': lineEnd,
            if (codeSnippet != null && codeSnippet.isNotEmpty)
              'code_snippet': codeSnippet,
            if (suggestedFix != null && suggestedFix.isNotEmpty)
              'suggested_fix': suggestedFix,
          }
        ],
      );
      final review = await _repository.getSubmissionReview(submissionId);
      emit(state.copyWith(
        submittingAction: false,
        review: review,
        actionMessage: 'Фидбек добавлен',
      ));
    } catch (e) {
      emit(state.copyWith(
        submittingAction: false,
        actionMessage: 'Ошибка: $e',
      ));
    }
  }

  void clearActionMessage() {
    emit(state.copyWith(clearActionMessage: true));
  }

  Future<void> setGrade(double grade) async {
    emit(state.copyWith(submittingAction: true, clearActionMessage: true));
    try {
      await _repository.setGrade(submissionId: submissionId, grade: grade);
      final submission = await _repository.getSubmission(submissionId);
      emit(state.copyWith(
        submittingAction: false,
        submission: submission,
        actionMessage: 'Оценка выставлена',
      ));
    } catch (e) {
      emit(state.copyWith(
        submittingAction: false,
        actionMessage: 'Ошибка: $e',
      ));
    }
  }
}
