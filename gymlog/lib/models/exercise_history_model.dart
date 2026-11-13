import 'workout_model.dart';

class ExerciseHistoryPoint {
  final String workoutId;
  final String routineName;
  final DateTime date;
  final int setsCount;
  final double maxWeight;
  final double volume;
  final double estimated1RM;
  final String notes;
  final List<WorkoutSetModel> sets;

  ExerciseHistoryPoint({
    required this.workoutId,
    required this.routineName,
    required this.date,
    required this.setsCount,
    required this.maxWeight,
    required this.volume,
    required this.estimated1RM,
    required this.notes,
    required this.sets,
  });

  factory ExerciseHistoryPoint.fromJson(Map<String, dynamic> json) {
    var rawSets = json['sets'] as List? ?? [];
    List<WorkoutSetModel> setList = rawSets
        .map((s) => WorkoutSetModel.fromJson(s as Map<String, dynamic>))
        .toList();

    return ExerciseHistoryPoint(
      workoutId: json['workoutId']?.toString() ?? '',
      routineName: json['routineName'] ?? 'Workout',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      setsCount: (json['setsCount'] as num?)?.toInt() ?? 0,
      maxWeight: (json['maxWeight'] as num?)?.toDouble() ?? 0.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
      estimated1RM: (json['estimated1RM'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] ?? '',
      sets: setList,
    );
  }
}
