import '../models/body_weight_model.dart';
import '../models/exercise_history_model.dart';
import '../models/feed_post_model.dart';
import '../models/routine_model.dart';
import '../models/workout_model.dart';
import '../models/workout_stats_model.dart';
import 'api_service.dart';

class WorkoutService {
  final ApiService _apiService;

  WorkoutService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Routines APIs
  Future<List<RoutineModel>> getRoutines() async {
    final response = await _apiService.get('/routines');
    final List list = response['routines'] ?? [];
    return list.map((json) => RoutineModel.fromJson(json)).toList();
  }

  Future<RoutineModel> createRoutine({
    required String name,
    required List<RoutineExerciseModel> exercises,
  }) async {
    final response = await _apiService.post(
      '/routines',
      body: {
        'name': name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      },
    );
    return RoutineModel.fromJson(response['routine']);
  }

  Future<RoutineModel> getRoutineById(String id) async {
    final response = await _apiService.get('/routines/$id');
    return RoutineModel.fromJson(response['routine']);
  }

  Future<RoutineModel> updateRoutine({
    required String id,
    required String name,
    required List<RoutineExerciseModel> exercises,
  }) async {
    final response = await _apiService.put(
      '/routines/$id',
      body: {
        'name': name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      },
    );
    return RoutineModel.fromJson(response['routine']);
  }

  Future<void> deleteRoutine(String id) async {
    await _apiService.delete('/routines/$id');
  }

  // Workouts APIs
  Future<WorkoutModel> createWorkout(Map<String, dynamic> workoutPayload) async {
    final response = await _apiService.post(
      '/workouts',
      body: workoutPayload,
    );
    return WorkoutModel.fromJson(response['workout']);
  }

  Future<WorkoutModel> updateWorkout(
      String id, Map<String, dynamic> workoutPayload) async {
    final response = await _apiService.put(
      '/workouts/$id',
      body: workoutPayload,
    );
    return WorkoutModel.fromJson(response['workout']);
  }

  Future<void> deleteWorkout(String id) async {
    await _apiService.delete('/workouts/$id');
  }

  Future<List<WorkoutModel>> getWorkouts() async {
    final response = await _apiService.get('/workouts');
    final List list = response['workouts'] ?? [];
    return list.map((json) => WorkoutModel.fromJson(json)).toList();
  }

  Future<WorkoutStatsModel> getWorkoutStats() async {
    final response = await _apiService.get('/workouts/stats');
    if (response['stats'] != null) {
      return WorkoutStatsModel.fromJson(response['stats']);
    }
    return WorkoutStatsModel.empty();
  }

  Future<WorkoutModel> getWorkoutById(String id) async {
    final response = await _apiService.get('/workouts/$id');
    return WorkoutModel.fromJson(response['workout']);
  }

  // Global Exercise Analytics
  Future<List<ExerciseHistoryPoint>> getExerciseHistory(
      String exerciseName) async {
    final encoded = Uri.encodeComponent(exerciseName);
    final response = await _apiService.get('/workouts/exercise-history/$encoded');
    final List list = response['history'] ?? [];
    return list.map((json) => ExerciseHistoryPoint.fromJson(json)).toList();
  }

  // Body Weight APIs
  Future<List<BodyWeightModel>> getBodyWeightHistory() async {
    final response = await _apiService.get('/bodyweight');
    final List list = response['history'] ?? [];
    return list.map((json) => BodyWeightModel.fromJson(json)).toList();
  }

  Future<BodyWeightModel> logBodyWeight({
    required double weight,
    DateTime? date,
    String notes = '',
  }) async {
    final response = await _apiService.post(
      '/bodyweight',
      body: {
        'weight': weight,
        'date': (date ?? DateTime.now()).toIso8601String(),
        'notes': notes,
      },
    );
    return BodyWeightModel.fromJson(response['entry']);
  }

  Future<void> deleteBodyWeight(String id) async {
    await _apiService.delete('/bodyweight/$id');
  }

  // Community Feed APIs
  Future<List<FeedPostModel>> getFeed() async {
    final response = await _apiService.get('/feed');
    final List list = response['feed'] ?? [];
    return list.map((json) => FeedPostModel.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> toggleLike(String workoutId) async {
    final response = await _apiService.post('/feed/$workoutId/like');
    return {
      'likesCount': response['likesCount'],
      'isLikedByMe': response['isLikedByMe'],
    };
  }
}
