const express = require('express');
const router = express.Router();
const {
  getRoutines,
  createRoutine,
  getRoutineById,
  updateRoutine,
  deleteRoutine,
} = require('../controllers/routineController');
const { protect } = require('../middleware/authMiddleware');

// All routine routes are protected
router.use(protect);

router.route('/')
  .get(getRoutines)
  .post(createRoutine);

router.route('/:id')
  .get(getRoutineById)
  .put(updateRoutine)
  .delete(deleteRoutine);

module.exports = router;
