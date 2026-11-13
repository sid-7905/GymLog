const Routine = require('../models/Routine');

// @desc    Get all routines for logged-in user
// @route   GET /api/routines
// @access  Private
const getRoutines = async (req, res) => {
  try {
    const routines = await Routine.find({ userId: req.user._id }).sort({
      createdAt: -1,
    });
    return res.status(200).json({
      success: true,
      count: routines.length,
      routines,
    });
  } catch (error) {
    console.error('Error in getRoutines:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error fetching routines',
    });
  }
};

// @desc    Create a new routine
// @route   POST /api/routines
// @access  Private
const createRoutine = async (req, res) => {
  try {
    const { name, exercises } = req.body;

    if (!name || name.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Routine name is required',
      });
    }

    const routine = await Routine.create({
      userId: req.user._id,
      name: name.trim(),
      exercises: Array.isArray(exercises) ? exercises : [],
    });

    return res.status(201).json({
      success: true,
      routine,
    });
  } catch (error) {
    console.error('Error in createRoutine:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error creating routine',
    });
  }
};

// @desc    Get routine by ID
// @route   GET /api/routines/:id
// @access  Private
const getRoutineById = async (req, res) => {
  try {
    const routine = await Routine.findById(req.params.id);

    if (!routine) {
      return res.status(404).json({
        success: false,
        message: 'Routine not found',
      });
    }

    // Verify ownership
    if (routine.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this routine',
      });
    }

    return res.status(200).json({
      success: true,
      routine,
    });
  } catch (error) {
    console.error('Error in getRoutineById:', error);
    if (error.kind === 'ObjectId') {
      return res.status(404).json({
        success: false,
        message: 'Routine not found (Invalid ID format)',
      });
    }
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error fetching routine',
    });
  }
};

// @desc    Update routine
// @route   PUT /api/routines/:id
// @access  Private
const updateRoutine = async (req, res) => {
  try {
    const routine = await Routine.findById(req.params.id);

    if (!routine) {
      return res.status(404).json({
        success: false,
        message: 'Routine not found',
      });
    }

    // Verify ownership
    if (routine.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to modify this routine',
      });
    }

    const { name, exercises } = req.body;

    if (name !== undefined) routine.name = name.trim();
    if (exercises !== undefined && Array.isArray(exercises)) {
      routine.exercises = exercises;
    }

    const updatedRoutine = await routine.save();

    return res.status(200).json({
      success: true,
      routine: updatedRoutine,
    });
  } catch (error) {
    console.error('Error in updateRoutine:', error);
    if (error.kind === 'ObjectId') {
      return res.status(404).json({
        success: false,
        message: 'Routine not found (Invalid ID format)',
      });
    }
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error updating routine',
    });
  }
};

// @desc    Delete routine
// @route   DELETE /api/routines/:id
// @access  Private
const deleteRoutine = async (req, res) => {
  try {
    const routine = await Routine.findById(req.params.id);

    if (!routine) {
      return res.status(404).json({
        success: false,
        message: 'Routine not found',
      });
    }

    // Verify ownership
    if (routine.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this routine',
      });
    }

    await routine.deleteOne();

    return res.status(200).json({
      success: true,
      message: 'Routine deleted successfully',
      id: req.params.id,
    });
  } catch (error) {
    console.error('Error in deleteRoutine:', error);
    if (error.kind === 'ObjectId') {
      return res.status(404).json({
        success: false,
        message: 'Routine not found (Invalid ID format)',
      });
    }
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error deleting routine',
    });
  }
};

module.exports = {
  getRoutines,
  createRoutine,
  getRoutineById,
  updateRoutine,
  deleteRoutine,
};
