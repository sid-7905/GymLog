class WorkoutHistoryPoint {
  final String workoutId;
  final String routineName;
  final DateTime completedAt;
  final double volume;
  final int sets;
  final int duration;

  WorkoutHistoryPoint({
    required this.workoutId,
    required this.routineName,
    required this.completedAt,
    required this.volume,
    required this.sets,
    required this.duration,
  });

  factory WorkoutHistoryPoint.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryPoint(
      workoutId: json['workoutId']?.toString() ?? '',
      routineName: json['routineName'] ?? 'Workout',
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
      sets: (json['sets'] as num?)?.toInt() ?? 0,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
    );
  }
}

class WorkoutStatsModel {
  final int totalWorkouts;
  final int totalSets;
  final double totalVolume;
  final List<WorkoutHistoryPoint> history;

  WorkoutStatsModel({
    required this.totalWorkouts,
    required this.totalSets,
    required this.totalVolume,
    required this.history,
  });

  factory WorkoutStatsModel.empty() {
    return WorkoutStatsModel(
      totalWorkouts: 0,
      totalSets: 0,
      totalVolume: 0.0,
      history: [],
    );
  }

  factory WorkoutStatsModel.fromJson(Map<String, dynamic> json) {
    var rawHistory = json['history'] as List? ?? [];
    List<WorkoutHistoryPoint> historyList = rawHistory
        .map((p) => WorkoutHistoryPoint.fromJson(p as Map<String, dynamic>))
        .toList();

    return WorkoutStatsModel(
      totalWorkouts: (json['totalWorkouts'] as num?)?.toInt() ?? 0,
      totalSets: (json['totalSets'] as num?)?.toInt() ?? 0,
      totalVolume: (json['totalVolume'] as num?)?.toDouble() ?? 0.0,
      history: historyList,
    );
  }
}
