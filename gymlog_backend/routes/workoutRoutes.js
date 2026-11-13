const express = require('express');
const router = express.Router();
const {
  createWorkout,
  getWorkouts,
  updateWorkout,
  deleteWorkout,
  getExerciseHistory,
  getWorkoutStats,
  getWorkoutById,
} = require('../controllers/workoutController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.route('/')
  .get(getWorkouts)
  .post(createWorkout);

router.route('/stats')
  .get(getWorkoutStats);

router.route('/exercise-history/:name')
  .get(getExerciseHistory);

router.route('/:id')
  .get(getWorkoutById)
  .put(updateWorkout)
  .delete(deleteWorkout);

module.exports = router;
