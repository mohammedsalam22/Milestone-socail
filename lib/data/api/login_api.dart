import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../core/servcies/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../model/user_model.dart';

class LoginApi {
  final ApiService _apiService;

  LoginApi(this._apiService);

  Future<UserModel> login(String userName, String password) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        data: {'username': userName, 'password': password},
      );

      // Assuming a successful response (e.g., statusCode 200)
      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        final String accessToken = responseData['access'];
        final String refreshToken = responseData['refresh'];
        final UserModel user = UserModel.fromJson(responseData['user']);

        // Store the access token, user role, and user info
        await _storeAuthData(accessToken, user.role, user);

        // You might want to store the refresh token securely as well
        // For simplicity, we are returning the user model on success
        return user;
      } else {
        // Handle different error status codes from the backend
        throw Exception('Login failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Rethrow the exception to be handled by the repository and cubit
      rethrow;
    }
  }

  Future<void> _storeAuthData(String token, String role, UserModel user) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', role);
      await prefs.setString(
        'user_info',
        jsonEncode({
          'pk': user.pk,
          'username': user.username,
          'email': user.email,
          'first_name': user.firstName,
          'last_name': user.lastName,
          'role': user.role,
        }),
      );
    } catch (e) {
      // Handle potential errors from SharedPreferences
      throw Exception('Failed to store authentication data.');
    }
  }
}
