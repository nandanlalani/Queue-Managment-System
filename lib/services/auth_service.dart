import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map) {
        // Backend returns either 'message' or 'error' key
        return (data['message'] ?? data['error'] ?? 'Login failed').toString();
      }
      return 'Error ${e.response?.statusCode}';
    }
    return 'Network error. Please check your connection.';
  }
}
