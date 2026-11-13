const mongoose = require('mongoose');

const workoutSetSchema = new mongoose.Schema(
  {
    setNumber: {
      type: Number,
      default: 1,
    },
    weight: {
      type: Number,
      default: 0,
      min: 0,
    },
    reps: {
      type: Number,
      default: 0,
      min: 0,
    },
    completed: {
      type: Boolean,
      default: false,
    },
  },
  { _id: true }
);

const workoutExerciseSchema = new mongoose.Schema(
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
    sets: [workoutSetSchema],
  },
  { _id: true }
);

const workoutSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    routineId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Routine',
      default: null,
    },
    routineName: {
      type: String,
      default: 'Quick Workout',
      trim: true,
    },
    exercises: [workoutExerciseSchema],
    duration: {
      type: Number, // Duration in seconds
      default: 0,
      min: 0,
    },
    startedAt: {
      type: Date,
      default: Date.now,
    },
    completedAt: {
      type: Date,
      default: Date.now,
    },
    caption: {
      type: String,
      default: '',
      trim: true,
    },
    mediaUrls: [
      {
        type: String,
        trim: true,
      },
    ],
    isPublic: {
      type: Boolean,
      default: false,
      index: true,
    },
    likes: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
    ],
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Workout', workoutSchema);
