import 'package:dio/dio.dart';
import '../models/task_model.dart';

class TaskApi {
  final Dio _dio;

  TaskApi(this._dio);

  Future<List<TaskModel>> getCourseTasks(int courseId) async {
    final response = await _dio.get('/courses/$courseId/tasks');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> getTask(int taskId) async {
    final response = await _dio.get('/tasks/$taskId');
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> createTask({
    required int courseId,
    required String title,
    required String description,
    required DateTime deadline,
    required int maxScore,
    List<TaskCriteriaModel>? criteria,
  }) async {
    final response = await _dio.post('/task', data: {
      'course_id': courseId,
      'title': title,
      'description': description,
      'deadline': deadline.toUtc().toIso8601String(),
      'max_score': maxScore,
      if (criteria != null) 'criteria': criteria.map((c) => c.toJson()).toList(),
    });
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }
}
