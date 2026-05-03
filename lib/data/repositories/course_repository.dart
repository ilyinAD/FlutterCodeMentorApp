import 'package:dio/dio.dart';
import '../api/course_api.dart';
import '../models/api_error_model.dart';
import '../models/course_model.dart';

class CourseRepository {
  final CourseApi _api;

  CourseRepository(this._api);

  Future<List<CourseModel>> getTeacherCourses(int teacherId) async {
    try {
      return await _api.getTeacherCourses(teacherId);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<CourseModel> getCourse(int courseId) async {
    try {
      return await _api.getCourse(courseId);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<CourseModel> createCourse({
    required int teacherId,
    required String title,
    String? description,
    required DateTime startDate,
    DateTime? endDate,
    bool isActive = true,
  }) async {
    try {
      return await _api.createCourse(
        teacherId: teacherId,
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        isActive: isActive,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<CourseModel> joinCourse(int studentId, int courseId) async {
    try {
      await _api.enrollStudent(courseId: courseId, studentId: studentId);
      return await _api.getCourse(courseId);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw 'Course with this code not found';
      }
      throw _mapError(e);
    }
  }

  Future<List<CourseModel>> getStudentCourses(int studentId) async {
    try {
      return await _api.getStudentCourses(studentId);
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
