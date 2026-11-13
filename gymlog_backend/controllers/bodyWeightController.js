const BodyWeight = require('../models/BodyWeight');

// @desc    Log a new body weight entry
// @route   POST /api/bodyweight
// @access  Private
const logBodyWeight = async (req, res) => {
  try {
    const { weight, date, notes } = req.body;

    if (!weight) {
      return res.status(400).json({
        success: false,
        message: 'Please provide weight in kg',
      });
    }

    const entry = await BodyWeight.create({
      userId: req.user._id,
      weight: Number(weight),
      date: date ? new Date(date) : new Date(),
      notes: notes || '',
    });

    return res.status(201).json({
      success: true,
      entry,
    });
  } catch (error) {
    console.error('Error in logBodyWeight:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error logging body weight',
    });
  }
};

// @desc    Get body weight history for logged-in user
// @route   GET /api/bodyweight
// @access  Private
const getBodyWeightHistory = async (req, res) => {
  try {
    const history = await BodyWeight.find({ userId: req.user._id }).sort({
      date: 1,
    });

    return res.status(200).json({
      success: true,
      count: history.length,
      history,
    });
  } catch (error) {
    console.error('Error in getBodyWeightHistory:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error fetching body weight history',
    });
  }
};

// @desc    Delete a body weight entry
// @route   DELETE /api/bodyweight/:id
// @access  Private
const deleteBodyWeight = async (req, res) => {
  try {
    const entry = await BodyWeight.findById(req.params.id);

    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'Body weight entry not found',
      });
    }

    if (entry.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this entry',
      });
    }

    await entry.deleteOne();

    return res.status(200).json({
      success: true,
      message: 'Body weight entry deleted successfully',
      id: req.params.id,
    });
  } catch (error) {
    console.error('Error in deleteBodyWeight:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error deleting entry',
    });
  }
};

module.exports = {
  logBodyWeight,
  getBodyWeightHistory,
  deleteBodyWeight,
};
