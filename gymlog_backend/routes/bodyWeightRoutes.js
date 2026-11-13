const express = require('express');
const router = express.Router();
const {
  logBodyWeight,
  getBodyWeightHistory,
  deleteBodyWeight,
} = require('../controllers/bodyWeightController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.route('/')
  .post(logBodyWeight)
  .get(getBodyWeightHistory);

router.route('/:id')
  .delete(deleteBodyWeight);

module.exports = router;
