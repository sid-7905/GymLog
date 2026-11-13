class WorkoutSetModel {
  final String? id;
  int setNumber;
  double weight;
  int reps;
  bool completed;

  WorkoutSetModel({
    this.id,
    required this.setNumber,
    this.weight = 0.0,
    this.reps = 0,
    this.completed = false,
  });

  factory WorkoutSetModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSetModel(
      id: json['_id']?.toString(),
      setNumber: json['setNumber'] is int
          ? json['setNumber']
          : int.tryParse(json['setNumber']?.toString() ?? '1') ?? 1,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      completed: json['completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'completed': completed,
    };
  }

  WorkoutSetModel copy() {
    return WorkoutSetModel(
      id: id,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      completed: completed,
    );
  }
}

class WorkoutExerciseModel {
  final String? id;
  final String name;
  final String muscleGroup;
  String notes;
  int restTimeSeconds;
  List<WorkoutSetModel> sets;

  WorkoutExerciseModel({
    this.id,
    required this.name,
    this.muscleGroup = 'Other',
    this.notes = '',
    this.restTimeSeconds = 90,
    required this.sets,
  });

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    var rawSets = json['sets'] as List? ?? [];
    List<WorkoutSetModel> setList = rawSets
        .map((s) => WorkoutSetModel.fromJson(s as Map<String, dynamic>))
        .toList();

    return WorkoutExerciseModel(
      id: json['_id']?.toString(),
      name: json['name'] ?? '',
      muscleGroup: json['muscleGroup'] ?? 'Other',
      notes: json['notes'] ?? '',
      restTimeSeconds: json['restTimeSeconds'] is int
          ? json['restTimeSeconds']
          : int.tryParse(json['restTimeSeconds']?.toString() ?? '90') ?? 90,
      sets: setList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'muscleGroup': muscleGroup,
      'notes': notes,
      'restTimeSeconds': restTimeSeconds,
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }

  WorkoutExerciseModel copy() {
    return WorkoutExerciseModel(
      id: id,
      name: name,
      muscleGroup: muscleGroup,
      notes: notes,
      restTimeSeconds: restTimeSeconds,
      sets: sets.map((s) => s.copy()).toList(),
    );
  }
}

class WorkoutModel {
  final String id;
  final String? routineId;
  String routineName;
  List<WorkoutExerciseModel> exercises;
  int duration; // in seconds
  DateTime startedAt;
  DateTime completedAt;
  String caption;
  List<String> mediaUrls;
  bool isPublic;
  int likesCount;
  bool isLikedByMe;

  WorkoutModel({
    required this.id,
    this.routineId,
    required this.routineName,
    required this.exercises,
    required this.duration,
    required this.startedAt,
    required this.completedAt,
    this.caption = '',
    this.mediaUrls = const [],
    this.isPublic = false,
    this.likesCount = 0,
    this.isLikedByMe = false,
  });

  double get totalVolume {
    double vol = 0;
    for (var ex in exercises) {
      for (var s in ex.sets) {
        if (s.completed || (s.weight > 0 && s.reps > 0)) {
          vol += (s.weight * s.reps);
        }
      }
    }
    return vol;
  }

  int get totalSets {
    int count = 0;
    for (var ex in exercises) {
      count += ex.sets.length;
    }
    return count;
  }

  int get completedSets {
    int count = 0;
    for (var ex in exercises) {
      for (var s in ex.sets) {
        if (s.completed) count++;
      }
    }
    return count;
  }

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    var rawExercises = json['exercises'] as List? ?? [];
    List<WorkoutExerciseModel> exerciseList = rawExercises
        .map((e) => WorkoutExerciseModel.fromJson(e as Map<String, dynamic>))
        .toList();

    var rawMedia = json['mediaUrls'] as List? ?? [];
    List<String> mediaList = rawMedia.map((m) => m.toString()).toList();

    var likesList = json['likes'] as List? ?? [];

    return WorkoutModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      routineId: json['routineId']?.toString(),
      routineName: json['routineName'] ?? 'Workout',
      exercises: exerciseList,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      caption: json['caption'] ?? '',
      mediaUrls: mediaList,
      isPublic: json['isPublic'] == true,
      likesCount: json['likesCount'] is int
          ? json['likesCount']
          : likesList.length,
      isLikedByMe: json['isLikedByMe'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routineId': routineId,
      'routineName': routineName,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'duration': duration,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'caption': caption,
      'mediaUrls': mediaUrls,
      'isPublic': isPublic,
    };
  }

  WorkoutModel copy() {
    return WorkoutModel(
      id: id,
      routineId: routineId,
      routineName: routineName,
      exercises: exercises.map((e) => e.copy()).toList(),
      duration: duration,
      startedAt: startedAt,
      completedAt: completedAt,
      caption: caption,
      mediaUrls: List.from(mediaUrls),
      isPublic: isPublic,
      likesCount: likesCount,
      isLikedByMe: isLikedByMe,
    );
  }
}
