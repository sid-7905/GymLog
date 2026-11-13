import 'package:flutter/material.dart';
import '../models/routine_model.dart';
import '../services/workout_service.dart';

class RoutineProvider extends ChangeNotifier {
  final WorkoutService _workoutService;

  List<RoutineModel> _routines = [];
  bool _isLoading = false;
  String? _errorMessage;

  RoutineProvider({WorkoutService? workoutService})
      : _workoutService = workoutService ?? WorkoutService();

  List<RoutineModel> get routines => _routines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchRoutines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _routines = await _workoutService.getRoutines();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRoutine({
    required String name,
    required List<RoutineExerciseModel> exercises,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newRoutine = await _workoutService.createRoutine(
        name: name,
        exercises: exercises,
      );
      _routines.insert(0, newRoutine);
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

  Future<bool> updateRoutine({
    required String id,
    required String name,
    required List<RoutineExerciseModel> exercises,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _workoutService.updateRoutine(
        id: id,
        name: name,
        exercises: exercises,
      );
      final index = _routines.indexWhere((r) => r.id == id);
      if (index != -1) {
        _routines[index] = updated;
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

  Future<bool> deleteRoutine(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _workoutService.deleteRoutine(id);
      _routines.removeWhere((r) => r.id == id);
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
}
