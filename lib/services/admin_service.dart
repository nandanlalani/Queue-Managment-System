import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';

class AdminService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> getClinic() async {
    try {
      final res = await _dio.get(ApiConstants.adminClinic);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getUsers() async {
    try {
      final res = await _dio.get(ApiConstants.adminUsers);
      final data = res.data;
      if (data is List) return data;
      if (data is Map && data['users'] != null) return data['users'] as List;
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post(ApiConstants.adminUsers, data: payload);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
      return 'Error ${e.response?.statusCode}';
    }
    return 'Network error. Please check your connection.';
  }
}
