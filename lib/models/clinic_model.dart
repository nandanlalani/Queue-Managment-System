class ClinicModel {
  final int? id;
  final String name;
  final String? code;
  final int? userCount;
  final int? appointmentCount;
  final int? queueCount;

  ClinicModel({
    this.id,
    required this.name,
    this.code,
    this.userCount,
    this.appointmentCount,
    this.queueCount,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'],
      userCount: json['userCount'],
      appointmentCount: json['appointmentCount'],
      queueCount: json['queueCount'],
    );
  }
}
