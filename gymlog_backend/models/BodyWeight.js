const mongoose = require('mongoose');

const bodyWeightSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    weight: {
      type: Number,
      required: [true, 'Weight value is required'],
      min: [10, 'Weight must be at least 10 kg'],
      max: [500, 'Weight must be realistic'],
    },
    date: {
      type: Date,
      default: Date.now,
      index: true,
    },
    notes: {
      type: String,
      default: '',
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('BodyWeight', bodyWeightSchema);
