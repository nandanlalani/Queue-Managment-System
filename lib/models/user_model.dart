class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final int? clinicId;
  final String? clinicName;
  final String? clinicCode;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.clinicId,
    this.clinicName,
    this.clinicCode,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'],
      clinicId: json['clinicId'],
      clinicName: json['clinicName'],
      clinicCode: json['clinicCode'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'clinicId': clinicId,
        'clinicName': clinicName,
        'clinicCode': clinicCode,
        'createdAt': createdAt,
      };
}
