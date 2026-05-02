import 'package:dio/dio.dart';
import '../models/submission_model.dart';

class SubmissionApi {
  final Dio _dio;

  SubmissionApi(this._dio);

  Future<List<SubmissionModel>> getTaskSubmissions(
    int taskId, {
    int? studentId,
  }) async {
    final response = await _dio.get(
      '/tasks/$taskId/submissions',
      queryParameters: {
        'student_id': ?studentId,
      },
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => SubmissionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SubmissionModel> getSubmission(int submissionId) async {
    final response = await _dio.get('/submissions/$submissionId');
    return SubmissionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> postTeacherReview({
    required int submissionId,
    List<Map<String, dynamic>>? feedbackActions,
    List<Map<String, dynamic>>? teacherFeedbacks,
  }) async {
    await _dio.post('/submissions/$submissionId/teacher-review', data: {
      if (feedbackActions != null && feedbackActions.isNotEmpty)
        'actions': feedbackActions,
      if (teacherFeedbacks != null && teacherFeedbacks.isNotEmpty)
        'teacher_feedbacks': teacherFeedbacks,
    });
  }

  Future<void> setGrade({
    required int submissionId,
    required double grade,
  }) async {
    await _dio.put('/submissions/$submissionId/grade', data: {
      'score': grade,
    });
  }

  Future<void> createSubmission({
    required int taskId,
    required int userId,
    required String submissionType,
    String? code,
    String? githubUrl,
  }) async {
    await _dio.post('/submission', data: {
      'task_id': taskId,
      'user_id': userId,
      'submission_type': submissionType,
      'code': ?code,
      'github_url': ?githubUrl,
    });
  }
}
