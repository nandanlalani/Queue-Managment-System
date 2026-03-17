class DoctorQueueItemModel {
  final int id;
  final int? tokenNumber;
  final String status;
  final String? patientName;
  final int? patientId;
  final int? appointmentId;

  DoctorQueueItemModel({
    required this.id,
    this.tokenNumber,
    required this.status,
    this.patientName,
    this.patientId,
    this.appointmentId,
  });

  factory DoctorQueueItemModel.fromJson(Map<String, dynamic> json) {
    return DoctorQueueItemModel(
      id: json['id'] ?? 0,
      tokenNumber: json['tokenNumber'],
      status: json['status'] ?? 'waiting',
      patientName: json['patientName'],
      patientId: json['patientId'],
      appointmentId: json['appointmentId'],
    );
  }
}
