import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';

class QueueService {
  final Dio _dio = ApiClient().dio;

  Future<List<dynamic>> getQueueByDate(String date) async {
    try {
      final response = await _dio.get(
        ApiConstants.queue,
        queryParameters: {'date': date},
      );
      final data = response.data;
      if (data is List) return data;
      if (data is Map && data['queue'] != null) return data['queue'] as List;
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateQueueStatus(
      String id, String status) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.queue}/$id',
        data: {'status': status},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getDoctorQueue() async {
    try {
      final response = await _dio.get(ApiConstants.doctorQueue);
      final data = response.data;
      if (data is List) return data;
      if (data is Map && data['queue'] != null) return data['queue'] as List;
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return 'Error ${e.response?.statusCode}';
    }
    return 'Network error. Please check your connection.';
  }
}
