import 'package:dio/dio.dart';
import '../models/review_model.dart';

class ReviewApi {
  final Dio _dio;

  ReviewApi(this._dio);

  Future<CodeReviewModel> getSubmissionReview(int submissionId) async {
    final response = await _dio.get('/submissions/$submissionId/reviews');
    return CodeReviewModel.fromJson(response.data as Map<String, dynamic>);
  }
}
