class AppointmentModel {
  final int id;
  final String appointmentDate;
  final String? timeSlot;
  final String status;
  final int? patientId;
  final int? clinicId;
  final String? createdAt;

  // From nested queueEntry
  final int? queueId;
  final int? tokenNumber;
  final String? queueStatus;

  AppointmentModel({
    required this.id,
    required this.appointmentDate,
    this.timeSlot,
    required this.status,
    this.patientId,
    this.clinicId,
    this.createdAt,
    this.queueId,
    this.tokenNumber,
    this.queueStatus,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final queue = json['queueEntry'];
    return AppointmentModel(
      id: json['id'] ?? 0,
      appointmentDate: json['appointmentDate'] ?? '',
      timeSlot: json['timeSlot'],
      status: json['status'] ?? 'scheduled',
      patientId: json['patientId'],
      clinicId: json['clinicId'],
      createdAt: json['createdAt'],
      queueId: queue is Map ? queue['id'] : null,
      tokenNumber: queue is Map ? queue['tokenNumber'] : null,
      queueStatus: queue is Map ? queue['status'] : null,
    );
  }
}
