const mongoose = require('mongoose');

const routineExerciseSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Exercise name is required'],
      trim: true,
    },
    muscleGroup: {
      type: String,
      default: 'Other',
      trim: true,
    },
    notes: {
      type: String,
      default: '',
      trim: true,
    },
    restTimeSeconds: {
      type: Number,
      default: 90,
      min: 0,
    },
    targetSets: {
      type: Number,
      default: 3,
      min: [1, 'Target sets must be at least 1'],
    },
    targetWeight: {
      type: Number,
      default: 0,
      min: 0,
    },
    targetReps: {
      type: Number,
      default: 10,
      min: 1,
    },
  },
  { _id: true }
);

const routineSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    name: {
      type: String,
      required: [true, 'Routine name is required'],
      trim: true,
    },
    exercises: [routineExerciseSchema],
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Routine', routineSchema);
