class RoutineExerciseModel {
  final String? id;
  final String name;
  final String muscleGroup;
  int targetSets;
  double targetWeight;
  int targetReps;
  int restTimeSeconds;
  String notes;

  RoutineExerciseModel({
    this.id,
    required this.name,
    this.muscleGroup = 'Other',
    this.targetSets = 3,
    this.targetWeight = 0.0,
    this.targetReps = 10,
    this.restTimeSeconds = 90,
    this.notes = '',
  });

  factory RoutineExerciseModel.fromJson(Map<String, dynamic> json) {
    return RoutineExerciseModel(
      id: json['_id']?.toString(),
      name: json['name'] ?? '',
      muscleGroup: json['muscleGroup'] ?? 'Other',
      targetSets: json['targetSets'] is int
          ? json['targetSets']
          : int.tryParse(json['targetSets']?.toString() ?? '3') ?? 3,
      targetWeight: (json['targetWeight'] as num?)?.toDouble() ?? 0.0,
      targetReps: json['targetReps'] is int
          ? json['targetReps']
          : int.tryParse(json['targetReps']?.toString() ?? '10') ?? 10,
      restTimeSeconds: json['restTimeSeconds'] is int
          ? json['restTimeSeconds']
          : int.tryParse(json['restTimeSeconds']?.toString() ?? '90') ?? 90,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'targetSets': targetSets,
      'targetWeight': targetWeight,
      'targetReps': targetReps,
      'restTimeSeconds': restTimeSeconds,
      'notes': notes,
    };
  }
}

class RoutineModel {
  final String id;
  String name;
  List<RoutineExerciseModel> exercises;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RoutineModel({
    required this.id,
    required this.name,
    required this.exercises,
    this.createdAt,
    this.updatedAt,
  });

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    var rawExercises = json['exercises'] as List? ?? [];
    List<RoutineExerciseModel> exerciseList = rawExercises
        .map((e) => RoutineExerciseModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return RoutineModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      exercises: exerciseList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}
