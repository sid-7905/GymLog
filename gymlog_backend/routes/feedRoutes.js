const express = require('express');
const router = express.Router();
const { getFeed, toggleLike } = require('../controllers/feedController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.get('/', getFeed);
router.post('/:id/like', toggleLike);

module.exports = router;
