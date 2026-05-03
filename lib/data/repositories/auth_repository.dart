import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../api/auth_api.dart';
import '../models/api_error_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthApi _api;
  final SharedPreferences _prefs;

  AuthRepository(this._api, this._prefs);

  Future<UserModel> login(String email, String password) async {
    try {
      final user = await _api.login(email, password);
      await _saveUser(user);
      return user;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String role,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final user = await _api.register(
        email: email,
        password: password,
        role: role,
        firstName: firstName,
        lastName: lastName,
      );
      await _saveUser(user);
      return user;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> logout() async {
    await _prefs.remove(AppConstants.prefUserId);
    await _prefs.remove(AppConstants.prefEmail);
    await _prefs.remove(AppConstants.prefRole);
    await _prefs.remove(AppConstants.prefFirstName);
    await _prefs.remove(AppConstants.prefLastName);
  }

  UserModel? getCurrentUser() {
    final userId = _prefs.getInt(AppConstants.prefUserId);
    final email = _prefs.getString(AppConstants.prefEmail);
    final role = _prefs.getString(AppConstants.prefRole);
    if (userId == null || email == null || role == null) return null;
    return UserModel(
      userId: userId,
      email: email,
      role: role,
      firstName: _prefs.getString(AppConstants.prefFirstName),
      lastName: _prefs.getString(AppConstants.prefLastName),
    );
  }

  Future<void> _saveUser(UserModel user) async {
    await _prefs.setInt(AppConstants.prefUserId, user.userId);
    await _prefs.setString(AppConstants.prefEmail, user.email);
    await _prefs.setString(AppConstants.prefRole, user.role);
    if (user.firstName != null) {
      await _prefs.setString(AppConstants.prefFirstName, user.firstName!);
    }
    if (user.lastName != null) {
      await _prefs.setString(AppConstants.prefLastName, user.lastName!);
    }
  }

  String _mapError(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final apiError =
          ApiErrorModel.fromJson(e.response!.data as Map<String, dynamic>);
      return apiError.error;
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Server is not responding. Try again later.';
      case DioExceptionType.connectionError:
        return 'No connection to the server.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
