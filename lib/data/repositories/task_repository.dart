import 'package:dio/dio.dart';
import '../api/task_api.dart';
import '../models/api_error_model.dart';
import '../models/task_model.dart';

class TaskRepository {
  final TaskApi _api;

  TaskRepository(this._api);

  Future<List<TaskModel>> getCourseTasks(int courseId) async {
    try {
      return await _api.getCourseTasks(courseId);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<TaskModel> getTask(int taskId) async {
    try {
      return await _api.getTask(taskId);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<TaskModel> createTask({
    required int courseId,
    required String title,
    required String description,
    required DateTime deadline,
    required int maxScore,
    List<TaskCriteriaModel>? criteria,
  }) async {
    try {
      return await _api.createTask(
        courseId: courseId,
        title: title,
        description: description,
        deadline: deadline,
        maxScore: maxScore,
        criteria: criteria,
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
      return 'No connection to the server.';
    }
    return 'An error occurred: ${e.message}';
  }
}
