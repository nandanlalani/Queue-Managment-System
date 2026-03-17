import 'medicine_model.dart';

class PrescriptionModel {
  final int id;
  final int? appointmentId;
  final List<MedicineModel> medicines;
  final String? notes;
  final String? createdAt;

  PrescriptionModel({
    required this.id,
    this.appointmentId,
    required this.medicines,
    this.notes,
    this.createdAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] ?? 0,
      appointmentId: json['appointmentId'],
      medicines: (json['medicines'] as List<dynamic>? ?? [])
          .map((m) => MedicineModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      notes: json['notes'],
      createdAt: json['createdAt'],
    );
  }
}
