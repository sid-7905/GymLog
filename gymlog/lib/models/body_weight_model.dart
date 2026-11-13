class BodyWeightModel {
  final String id;
  final double weight;
  final DateTime date;
  final String notes;

  BodyWeightModel({
    required this.id,
    required this.weight,
    required this.date,
    this.notes = '',
  });

  factory BodyWeightModel.fromJson(Map<String, dynamic> json) {
    return BodyWeightModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }
}
