import 'dart:async';
import 'package:flutter/material.dart';
import '../models/body_weight_model.dart';
import '../models/exercise_history_model.dart';
import '../models/feed_post_model.dart';
import '../models/routine_model.dart';
import '../models/workout_model.dart';
import '../models/workout_stats_model.dart';
import '../services/workout_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutService _workoutService;

  List<WorkoutModel> _workouts = [];
  WorkoutStatsModel _stats = WorkoutStatsModel.empty();
  bool _isLoading = false;
  String? _errorMessage;

  // Active Workout State
  bool _isWorkoutActive = false;
  String _activeRoutineName = 'Quick Workout';
  String? _activeRoutineId;
  DateTime? _workoutStartTime;
  int _elapsedSeconds = 0;
  Timer? _timer;
  List<WorkoutExerciseModel> _activeExercises = [];

  // Rest Timer State
  bool _isRestTimerActive = false;
  int _restSecondsRemaining = 0;
  int _restTotalSeconds = 90;
  Timer? _restTimer;

  // Body Weight State
  List<BodyWeightModel> _bodyWeightHistory = [];

  // Feed State
  List<FeedPostModel> _feed = [];
  bool _isFeedLoading = false;

  WorkoutProvider({WorkoutService? workoutService})
      : _workoutService = workoutService ?? WorkoutService();

  List<WorkoutModel> get workouts => _workouts;
  WorkoutStatsModel get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Active workout getters
  bool get isWorkoutActive => _isWorkoutActive;
  String get activeRoutineName => _activeRoutineName;
  String? get activeRoutineId => _activeRoutineId;
  int get elapsedSeconds => _elapsedSeconds;
  List<WorkoutExerciseModel> get activeExercises => _activeExercises;

  // Rest timer getters
  bool get isRestTimerActive => _isRestTimerActive;
  int get restSecondsRemaining => _restSecondsRemaining;
  int get restTotalSeconds => _restTotalSeconds;

  // Body weight & feed getters
  List<BodyWeightModel> get bodyWeightHistory => _bodyWeightHistory;
  List<FeedPostModel> get feed => _feed;
  bool get isFeedLoading => _isFeedLoading;

  String get formattedDuration {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    final hours = (_elapsedSeconds ~/ 3600);
    if (hours > 0) {
      final hrs = hours.toString().padLeft(2, '0');
      return '$hrs:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  String get formattedRestTime {
    final minutes = (_restSecondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_restSecondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchWorkouts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _workouts = await _workoutService.getWorkouts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStats() async {
    try {
      _stats = await _workoutService.getWorkoutStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    }
  }

  // --- Active Workout Management ---

  void startWorkout({RoutineModel? routine}) {
    _timer?.cancel();
    _stopRestTimer();
    _isWorkoutActive = true;
    _workoutStartTime = DateTime.now();
    _elapsedSeconds = 0;

    if (routine != null) {
      _activeRoutineId = routine.id;
      _activeRoutineName = routine.name;
      _activeExercises = routine.exercises.map((re) {
        final targetSets = re.targetSets > 0 ? re.targetSets : 3;
        final sets = List.generate(
          targetSets,
          (index) => WorkoutSetModel(
            setNumber: index + 1,
            weight: re.targetWeight,
            reps: re.targetReps,
            completed: false,
          ),
        );
        return WorkoutExerciseModel(
          name: re.name,
          muscleGroup: re.muscleGroup,
          notes: re.notes,
          restTimeSeconds: re.restTimeSeconds,
          sets: sets,
        );
      }).toList();
    } else {
      _activeRoutineId = null;
      _activeRoutineName = 'Quick Workout';
      _activeExercises = [];
    }

    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  // Rest Timer Control
  void startRestTimer(int durationSeconds) {
    _restTimer?.cancel();
    _restTotalSeconds = durationSeconds > 0 ? durationSeconds : 90;
    _restSecondsRemaining = _restTotalSeconds;
    _isRestTimerActive = true;
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restSecondsRemaining > 1) {
        _restSecondsRemaining--;
        notifyListeners();
      } else {
        _stopRestTimer();
      }
    });
  }

  void addRestSeconds(int seconds) {
    if (_isRestTimerActive) {
      _restSecondsRemaining += seconds;
      _restTotalSeconds += seconds;
      notifyListeners();
    }
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    _isRestTimerActive = false;
    _restSecondsRemaining = 0;
    notifyListeners();
  }

  void stopRestTimer() => _stopRestTimer();

  void addExercise(String name, String muscleGroup,
      {int initialSets = 3, int restTimeSeconds = 90}) {
    final sets = List.generate(
      initialSets,
      (index) => WorkoutSetModel(
        setNumber: index + 1,
        weight: 0.0,
        reps: 0,
        completed: false,
      ),
    );

    _activeExercises.add(
      WorkoutExerciseModel(
        name: name,
        muscleGroup: muscleGroup,
        restTimeSeconds: restTimeSeconds,
        notes: '',
        sets: sets,
      ),
    );
    notifyListeners();
  }

  void removeExercise(int exerciseIndex) {
    if (exerciseIndex >= 0 && exerciseIndex < _activeExercises.length) {
      _activeExercises.removeAt(exerciseIndex);
      notifyListeners();
    }
  }

  void addSet(int exerciseIndex) {
    if (exerciseIndex >= 0 && exerciseIndex < _activeExercises.length) {
      final exercise = _activeExercises[exerciseIndex];
      final newSetNumber = exercise.sets.length + 1;
      double prevWeight = 0.0;
      int prevReps = 0;
      if (exercise.sets.isNotEmpty) {
        prevWeight = exercise.sets.last.weight;
        prevReps = exercise.sets.last.reps;
      }

      exercise.sets.add(
        WorkoutSetModel(
          setNumber: newSetNumber,
          weight: prevWeight,
          reps: prevReps,
          completed: false,
        ),
      );
      notifyListeners();
    }
  }

  void removeSet(int exerciseIndex, int setIndex) {
    if (exerciseIndex >= 0 && exerciseIndex < _activeExercises.length) {
      final exercise = _activeExercises[exerciseIndex];
      if (setIndex >= 0 && setIndex < exercise.sets.length) {
        exercise.sets.removeAt(setIndex);
        for (int i = 0; i < exercise.sets.length; i++) {
          exercise.sets[i].setNumber = i + 1;
        }
        notifyListeners();
      }
    }
  }

  void toggleSetCompleted(int exerciseIndex, int setIndex) {
    if (exerciseIndex >= 0 && exerciseIndex < _activeExercises.length) {
      final exercise = _activeExercises[exerciseIndex];
      if (setIndex >= 0 && setIndex < exercise.sets.length) {
        final willComplete = !exercise.sets[setIndex].completed;
        exercise.sets[setIndex].completed = willComplete;

        // Automatically start customizable rest timer if completed
        if (willComplete) {
          startRestTimer(exercise.restTimeSeconds);
        }

        notifyListeners();
      }
    }
  }

  void updateSetWeight(int exerciseIndex, int setIndex, double weight) {
    if (exerciseIndex >= 0 && exerciseIndex < _activeExercises.length) {
      final exercise = _activeExercises[exerciseIndex];
      if (setIndex >= 0 && setIndex < exercise.sets.length) {
        exercise.sets[setIndex].weight = weight;
        notifyListeners();
      }
    }
  }

  void updateSetReps(int exerciseIndex, int setIndex, int reps) {
    if (exerciseIndex >= 0 && exerciseIndex < _activeExercises.length) {
      final exercise = _activeExercises[exerciseIndex];
      if (setIndex >= 0 && setIndex < exercise.sets.length) {
        exercise.sets[setIndex].reps = reps;
        notifyListeners();
      }
    }
  }

  void updateExerciseNotes(int exerciseIndex, String notes) {
    if (exerciseIndex >= 0 && exerciseIndex < _activeExercises.length) {
      _activeExercises[exerciseIndex].notes = notes;
      notifyListeners();
    }
  }

  void updateExerciseRestTime(int exerciseIndex, int seconds) {
    if (exerciseIndex >= 0 && exerciseIndex < _activeExercises.length) {
      _activeExercises[exerciseIndex].restTimeSeconds = seconds;
      notifyListeners();
    }
  }

  Future<bool> finishWorkout({
    String caption = '',
    List<String> mediaUrls = const [],
    bool isPublic = false,
  }) async {
    if (_activeExercises.isEmpty) {
      _errorMessage = 'Add at least one exercise before finishing';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final workoutPayload = {
        'routineId': _activeRoutineId,
        'routineName': _activeRoutineName,
        'exercises': _activeExercises.map((e) => e.toJson()).toList(),
        'duration': _elapsedSeconds,
        'startedAt': _workoutStartTime?.toIso8601String() ?? now.toIso8601String(),
        'completedAt': now.toIso8601String(),
        'caption': caption,
        'mediaUrls': mediaUrls,
        'isPublic': isPublic,
      };

      final savedWorkout = await _workoutService.createWorkout(workoutPayload);
      _workouts.insert(0, savedWorkout);

      // Stop timers and reset active workout
      _timer?.cancel();
      _stopRestTimer();
      _isWorkoutActive = false;
      _activeExercises = [];
      _elapsedSeconds = 0;
      _workoutStartTime = null;

      // Refresh stats & feed if public
      await fetchStats();
      if (isPublic) {
        await fetchFeed();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void discardWorkout() {
    _timer?.cancel();
    _stopRestTimer();
    _isWorkoutActive = false;
    _activeExercises = [];
    _elapsedSeconds = 0;
    _workoutStartTime = null;
    notifyListeners();
  }

  // --- Workout History Management (Edit & Delete) ---

  Future<bool> updateWorkout(WorkoutModel workout) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _workoutService.updateWorkout(
        workout.id,
        workout.toJson(),
      );
      final idx = _workouts.indexWhere((w) => w.id == workout.id);
      if (idx != -1) {
        _workouts[idx] = updated;
      }
      await fetchStats();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWorkout(String workoutId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _workoutService.deleteWorkout(workoutId);
      _workouts.removeWhere((w) => w.id == workoutId);
      await fetchStats();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Global Exercise Analytics ---

  Future<List<ExerciseHistoryPoint>> fetchExerciseHistory(
      String exerciseName) async {
    try {
      return await _workoutService.getExerciseHistory(exerciseName);
    } catch (e) {
      debugPrint('Error fetching exercise history: $e');
      return [];
    }
  }

  // --- Body Weight Tracking ---

  Future<void> fetchBodyWeightHistory() async {
    try {
      _bodyWeightHistory = await _workoutService.getBodyWeightHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching body weight history: $e');
    }
  }

  Future<bool> logBodyWeight(
      double weight, DateTime date, String notes) async {
    try {
      final entry = await _workoutService.logBodyWeight(
        weight: weight,
        date: date,
        notes: notes,
      );
      _bodyWeightHistory.add(entry);
      _bodyWeightHistory.sort((a, b) => a.date.compareTo(b.date));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBodyWeight(String id) async {
    try {
      await _workoutService.deleteBodyWeight(id);
      _bodyWeightHistory.removeWhere((entry) => entry.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- Community Feed ---

  Future<void> fetchFeed() async {
    _isFeedLoading = true;
    notifyListeners();

    try {
      _feed = await _workoutService.getFeed();
      _isFeedLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching feed: $e');
      _isFeedLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String workoutId) async {
    try {
      final res = await _workoutService.toggleLike(workoutId);
      final idx = _feed.indexWhere((p) => p.id == workoutId);
      if (idx != -1) {
        _feed[idx].likesCount = res['likesCount'];
        _feed[idx].isLikedByMe = res['isLikedByMe'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }
}
