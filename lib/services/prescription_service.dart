import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';

class PrescriptionService {
  final Dio _dio = ApiClient().dio;

  Future<List<dynamic>> getMyPrescriptions() async {
    try {
      final response = await _dio.get(ApiConstants.myPrescriptions);
      final data = response.data;
      if (data is List) return data;
      if (data is Map && data['prescriptions'] != null) {
        return data['prescriptions'] as List;
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> addPrescription(
      String appointmentId, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.prescriptions}/$appointmentId',
        data: payload,
      );
      return response.data as Map<String, dynamic>;
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
