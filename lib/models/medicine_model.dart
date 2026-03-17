class MedicineModel {
  final String name;
  final String dosage;
  final String duration;

  MedicineModel({
    required this.name,
    required this.dosage,
    required this.duration,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      duration: json['duration'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'dosage': dosage,
        'duration': duration,
      };
}
