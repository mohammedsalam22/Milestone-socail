// Custom Exception
import 'package:milestone_social/core/constants/api_url_constants.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return 'ApiException: $statusCode - $message';
  }
}

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU3NTQ1MzM1LCJpYXQiOjE3NTcxMTMzMzUsImp0aSI6ImM4MTE5MTVlMzZhNDQyNTE4N2ZkY2FlOWY0NGI0Y2IzIiwidXNlcl9pZCI6Mn0.A9l9kBGyKDiZQsAxg7gKQe4DyUTc5bF-m3e4rLNmDFs';
          }

          // print('Request Path: ${options.path}');
          // print('Request Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // print('Response Path: ${response.requestOptions.path}');
          // print('Response Status: ${response.statusCode}');
          // print('Response Data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('Error Path: ${e.requestOptions.path}');
          print('Error Type: ${e.type}');
          print('Error Message: ${e.message}');

          if (e.response != null) {
            print('Error Status Code: ${e.response?.statusCode}');
            print('Error Response Data: ${e.response?.data}');
          }

          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(path, queryParameters: params);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Dio get dio => _dio;

  // Centralized error handling
  ApiException _handleDioError(DioException error) {
    String message = 'An unexpected error occurred.';
    int? statusCode = error.response?.statusCode;

    if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout. Please check your internet connection.';
    } else if (error.response != null) {
      switch (error.response!.statusCode) {
        case 400:
          message = 'Bad request.';
          break;
        case 401:
          message = 'Unauthorized. Please login again.';
          break;
        case 403:
          message = 'Forbidden.';
          break;
        case 404:
          message = 'Not found.';
          break;
        case 500:
          message = 'Server error.';
          break;
        default:
          message = 'An error occurred: ${error.response!.statusMessage}';
      }
    } else {
      message = 'Please check your internet connection.';
    }

    return ApiException(message, statusCode: statusCode);
  }
}
