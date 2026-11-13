const Workout = require('../models/Workout');

// @desc    Get public community feed of workouts
// @route   GET /api/feed
// @access  Private
const getFeed = async (req, res) => {
  try {
    const workouts = await Workout.find({ isPublic: true })
      .populate('userId', 'name')
      .sort({ createdAt: -1 })
      .limit(50);

    const feed = workouts.map((w) => {
      let totalVol = 0;
      let totalSets = 0;

      if (w.exercises) {
        w.exercises.forEach((ex) => {
          if (ex.sets) {
            ex.sets.forEach((s) => {
              totalSets++;
              const wt = Number(s.weight) || 0;
              const r = Number(s.reps) || 0;
              if (s.completed || (wt > 0 && r > 0)) {
                totalVol += wt * r;
              }
            });
          }
        });
      }

      const likes = w.likes || [];
      const isLikedByMe = likes.some(
        (id) => id.toString() === req.user._id.toString()
      );

      return {
        _id: w._id,
        user: {
          _id: w.userId ? w.userId._id : null,
          name: w.userId ? w.userId.name : 'Athlete',
        },
        routineName: w.routineName,
        duration: w.duration,
        completedAt: w.completedAt || w.createdAt,
        caption: w.caption || '',
        mediaUrls: w.mediaUrls || [],
        exercisesCount: w.exercises ? w.exercises.length : 0,
        totalSets,
        totalVolume: totalVol,
        likesCount: likes.length,
        isLikedByMe,
      };
    });

    return res.status(200).json({
      success: true,
      count: feed.length,
      feed,
    });
  } catch (error) {
    console.error('Error in getFeed:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error fetching feed',
    });
  }
};

// @desc    Like or unlike a community workout post
// @route   POST /api/feed/:id/like
// @access  Private
const toggleLike = async (req, res) => {
  try {
    const workout = await Workout.findById(req.params.id);

    if (!workout) {
      return res.status(404).json({
        success: false,
        message: 'Workout post not found',
      });
    }

    if (!workout.likes) {
      workout.likes = [];
    }

    const index = workout.likes.findIndex(
      (id) => id.toString() === req.user._id.toString()
    );

    let isLikedByMe = false;
    if (index === -1) {
      workout.likes.push(req.user._id);
      isLikedByMe = true;
    } else {
      workout.likes.splice(index, 1);
      isLikedByMe = false;
    }

    await workout.save();

    return res.status(200).json({
      success: true,
      likesCount: workout.likes.length,
      isLikedByMe,
    });
  } catch (error) {
    console.error('Error in toggleLike:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error toggling like',
    });
  }
};

module.exports = {
  getFeed,
  toggleLike,
};
