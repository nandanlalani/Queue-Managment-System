import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';

class AppointmentService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> bookAppointment(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post(ApiConstants.appointments, data: payload);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getMyAppointments() async {
    try {
      final res = await _dio.get(ApiConstants.myAppointments);
      final data = res.data;
      if (data is List) return data;
      if (data is Map && data['appointments'] != null) return data['appointments'] as List;
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getAppointmentById(String id) async {
    try {
      final res = await _dio.get('${ApiConstants.appointments}/$id');
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
