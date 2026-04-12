import 'package:dio/dio.dart';
import '../models/user_model.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<UserModel> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _dio.post('/user', data: {
      'email': email,
      'password': password,
      'role': 'teacher',
      'first_name': firstName,
      'last_name': lastName,
    });
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
