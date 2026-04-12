import 'package:dio/dio.dart';
import '../models/course_model.dart';

class CourseApi {
  final Dio _dio;

  CourseApi(this._dio);

  Future<List<CourseModel>> getTeacherCourses(int teacherId) async {
    final response =
        await _dio.get('/courses', queryParameters: {'teacher_id': teacherId});
    final list = response.data as List<dynamic>;
    return list
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CourseModel> getCourse(int courseId) async {
    final response = await _dio.get('/courses/$courseId');
    return CourseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CourseModel> createCourse({
    required int teacherId,
    required String title,
    String? description,
    required DateTime startDate,
    DateTime? endDate,
    bool isActive = true,
  }) async {
    final response = await _dio.post('/courses', data: {
      'teacher_id': teacherId,
      'title': title,
      'description': description,
      'start_date': startDate.toUtc().toIso8601String(),
      'end_date': endDate?.toUtc().toIso8601String(),
      'is_active': isActive,
    });
    return CourseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
