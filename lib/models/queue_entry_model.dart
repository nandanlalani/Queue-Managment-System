class QueueEntryModel {
  final int id;
  final int? tokenNumber;
  final String status;
  final String? queueDate;
  final int? appointmentId;

  // Nested patient info via appointment.patient
  final String? patientName;
  final String? patientPhone;

  QueueEntryModel({
    required this.id,
    this.tokenNumber,
    required this.status,
    this.queueDate,
    this.appointmentId,
    this.patientName,
    this.patientPhone,
  });

  factory QueueEntryModel.fromJson(Map<String, dynamic> json) {
    // patient nested under appointment.patient
    final appointment = json['appointment'];
    final patient = appointment is Map ? appointment['patient'] : null;

    return QueueEntryModel(
      id: json['id'] ?? 0,
      tokenNumber: json['tokenNumber'],
      status: json['status'] ?? 'waiting',
      queueDate: json['queueDate'],
      appointmentId: json['appointmentId'],
      patientName: patient is Map ? patient['name'] : null,
      patientPhone: patient is Map ? patient['phone'] : null,
    );
  }
}
