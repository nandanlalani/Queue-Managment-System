class ReportModel {
  final int id;
  final int? appointmentId;
  final String diagnosis;
  final String? testRecommended;
  final String? remarks;
  final String? createdAt;

  ReportModel({
    required this.id,
    this.appointmentId,
    required this.diagnosis,
    this.testRecommended,
    this.remarks,
    this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? 0,
      appointmentId: json['appointmentId'],
      diagnosis: json['diagnosis'] ?? '',
      testRecommended: json['testRecommended'],
      remarks: json['remarks'],
      createdAt: json['createdAt'],
    );
  }
}
