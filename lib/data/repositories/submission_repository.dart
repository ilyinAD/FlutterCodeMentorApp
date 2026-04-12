import 'package:dio/dio.dart';
import '../api/review_api.dart';
import '../api/submission_api.dart';
import '../models/api_error_model.dart';
import '../models/review_model.dart';
import '../models/submission_model.dart';

class SubmissionRepository {
  final SubmissionApi _submissionApi;
  final ReviewApi _reviewApi;

  SubmissionRepository(this._submissionApi, this._reviewApi);

  Future<List<SubmissionModel>> getTaskSubmissions(int taskId) async {
    try {
      return await _submissionApi.getTaskSubmissions(taskId);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<SubmissionModel> getSubmission(int submissionId) async {
    try {
      return await _submissionApi.getSubmission(submissionId);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<CodeReviewModel> getSubmissionReview(int submissionId) async {
    try {
      return await _reviewApi.getSubmissionReview(submissionId);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> postTeacherReview({
    required int submissionId,
    List<Map<String, dynamic>>? feedbackActions,
    List<Map<String, dynamic>>? teacherFeedbacks,
  }) async {
    try {
      await _submissionApi.postTeacherReview(
        submissionId: submissionId,
        feedbackActions: feedbackActions,
        teacherFeedbacks: teacherFeedbacks,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> setGrade({
    required int submissionId,
    required double grade,
  }) async {
    try {
      await _submissionApi.setGrade(
        submissionId: submissionId,
        grade: grade,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  String _mapError(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      return ApiErrorModel.fromJson(e.response!.data as Map<String, dynamic>)
          .error;
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Нет соединения с сервером.';
    }
    return 'Произошла ошибка: ${e.message}';
  }
}
