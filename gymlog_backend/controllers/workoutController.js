const Workout = require('../models/Workout');

// @desc    Log a new workout
// @route   POST /api/workouts
// @access  Private
const createWorkout = async (req, res) => {
  try {
    const {
      routineId,
      routineName,
      exercises,
      duration,
      startedAt,
      completedAt,
      caption,
      mediaUrls,
      isPublic,
    } = req.body;

    if (!exercises || !Array.isArray(exercises) || exercises.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'At least one exercise is required to log a workout',
      });
    }

    const workout = await Workout.create({
      userId: req.user._id,
      routineId: routineId || null,
      routineName: routineName || 'Quick Workout',
      exercises,
      duration: duration || 0,
      startedAt: startedAt || Date.now(),
      completedAt: completedAt || Date.now(),
      caption: caption || '',
      mediaUrls: Array.isArray(mediaUrls) ? mediaUrls : [],
      isPublic: isPublic === true,
    });

    return res.status(201).json({
      success: true,
      workout,
    });
  } catch (error) {
    console.error('Error in createWorkout:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error logging workout',
    });
  }
};

// @desc    Get all workouts for logged-in user
// @route   GET /api/workouts
// @access  Private
const getWorkouts = async (req, res) => {
  try {
    const workouts = await Workout.find({ userId: req.user._id }).sort({
      completedAt: -1,
      createdAt: -1,
    });

    return res.status(200).json({
      success: true,
      count: workouts.length,
      workouts,
    });
  } catch (error) {
    console.error('Error in getWorkouts:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error fetching workouts',
    });
  }
};

// @desc    Update an existing workout
// @route   PUT /api/workouts/:id
// @access  Private
const updateWorkout = async (req, res) => {
  try {
    const workout = await Workout.findById(req.params.id);

    if (!workout) {
      return res.status(404).json({
        success: false,
        message: 'Workout not found',
      });
    }

    if (workout.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to modify this workout',
      });
    }

    const {
      routineName,
      exercises,
      duration,
      completedAt,
      caption,
      mediaUrls,
      isPublic,
    } = req.body;

    if (routineName !== undefined) workout.routineName = routineName;
    if (exercises !== undefined && Array.isArray(exercises)) {
      workout.exercises = exercises;
    }
    if (duration !== undefined) workout.duration = duration;
    if (completedAt !== undefined) workout.completedAt = completedAt;
    if (caption !== undefined) workout.caption = caption;
    if (mediaUrls !== undefined && Array.isArray(mediaUrls)) {
      workout.mediaUrls = mediaUrls;
    }
    if (isPublic !== undefined) workout.isPublic = isPublic;

    const updated = await workout.save();

    return res.status(200).json({
      success: true,
      workout: updated,
    });
  } catch (error) {
    console.error('Error in updateWorkout:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error updating workout',
    });
  }
};

// @desc    Delete a workout
// @route   DELETE /api/workouts/:id
// @access  Private
const deleteWorkout = async (req, res) => {
  try {
    const workout = await Workout.findById(req.params.id);

    if (!workout) {
      return res.status(404).json({
        success: false,
        message: 'Workout not found',
      });
    }

    if (workout.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this workout',
      });
    }

    await workout.deleteOne();

    return res.status(200).json({
      success: true,
      message: 'Workout deleted successfully',
      id: req.params.id,
    });
  } catch (error) {
    console.error('Error in deleteWorkout:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error deleting workout',
    });
  }
};

// @desc    Get unified global history and analytics for a specific exercise
// @route   GET /api/workouts/exercise-history/:name
// @access  Private
const getExerciseHistory = async (req, res) => {
  try {
    const exerciseName = decodeURIComponent(req.params.name).trim();

    // Find all workouts for this user containing this exercise (case-insensitive)
    const workouts = await Workout.find({
      userId: req.user._id,
      'exercises.name': { $regex: new RegExp(`^${exerciseName}$`, 'i') },
    }).sort({ completedAt: 1 });

    const history = [];

    workouts.forEach((w) => {
      const match = w.exercises.find(
        (ex) => ex.name.toLowerCase() === exerciseName.toLowerCase()
      );

      if (match && match.sets && match.sets.length > 0) {
        let maxWeight = 0;
        let volume = 0;
        let totalReps = 0;
        let best1RM = 0;

        match.sets.forEach((s) => {
          const wt = Number(s.weight) || 0;
          const r = Number(s.reps) || 0;
          if (s.completed || (wt > 0 && r > 0)) {
            if (wt > maxWeight) maxWeight = wt;
            volume += wt * r;
            totalReps += r;

            // Epley 1RM formula: Weight * (1 + Reps / 30)
            const e1rm = r === 1 ? wt : wt * (1 + r / 30);
            if (e1rm > best1RM) best1RM = e1rm;
          }
        });

        if (maxWeight > 0 || volume > 0) {
          history.push({
            workoutId: w._id,
            routineName: w.routineName,
            date: w.completedAt || w.createdAt,
            setsCount: match.sets.length,
            maxWeight: Math.round(maxWeight * 10) / 10,
            volume: Math.round(volume * 10) / 10,
            estimated1RM: Math.round(best1RM * 10) / 10,
            notes: match.notes || '',
            sets: match.sets,
          });
        }
      }
    });

    return res.status(200).json({
      success: true,
      exerciseName,
      history,
    });
  } catch (error) {
    console.error('Error in getExerciseHistory:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error fetching exercise history',
    });
  }
};

// @desc    Get workout stats (Total workouts, sets, volume)
// @route   GET /api/workouts/stats
// @access  Private
const getWorkoutStats = async (req, res) => {
  try {
    const workouts = await Workout.find({ userId: req.user._id }).sort({
      completedAt: 1,
    });

    let totalWorkouts = workouts.length;
    let totalSets = 0;
    let totalVolume = 0;

    const history = workouts.map((workout) => {
      let workoutVolume = 0;
      let workoutSets = 0;

      if (workout.exercises && Array.isArray(workout.exercises)) {
        workout.exercises.forEach((exercise) => {
          if (exercise.sets && Array.isArray(exercise.sets)) {
            exercise.sets.forEach((set) => {
              workoutSets += 1;
              const weight = Number(set.weight) || 0;
              const reps = Number(set.reps) || 0;
              if (set.completed || (weight > 0 && reps > 0)) {
                workoutVolume += weight * reps;
              }
            });
          }
        });
      }

      totalSets += workoutSets;
      totalVolume += workoutVolume;

      return {
        workoutId: workout._id,
        routineName: workout.routineName,
        completedAt: workout.completedAt || workout.createdAt,
        volume: workoutVolume,
        sets: workoutSets,
        duration: workout.duration || 0,
      };
    });

    return res.status(200).json({
      success: true,
      stats: {
        totalWorkouts,
        totalSets,
        totalVolume,
        history,
      },
    });
  } catch (error) {
    console.error('Error in getWorkoutStats:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error computing workout statistics',
    });
  }
};

// @desc    Get workout by ID
// @route   GET /api/workouts/:id
// @access  Private
const getWorkoutById = async (req, res) => {
  try {
    const workout = await Workout.findById(req.params.id);

    if (!workout) {
      return res.status(404).json({
        success: false,
        message: 'Workout not found',
      });
    }

    if (workout.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this workout',
      });
    }

    return res.status(200).json({
      success: true,
      workout,
    });
  } catch (error) {
    console.error('Error in getWorkoutById:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error fetching workout',
    });
  }
};

module.exports = {
  createWorkout,
  getWorkouts,
  updateWorkout,
  deleteWorkout,
  getExerciseHistory,
  getWorkoutStats,
  getWorkoutById,
};
