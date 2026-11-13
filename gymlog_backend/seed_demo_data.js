const dns = require('dns');
try {
  dns.setServers(['8.8.8.8', '1.1.1.1']);
} catch (e) {}

require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const User = require('./models/User');
const Routine = require('./models/Routine');
const Workout = require('./models/Workout');
const BodyWeight = require('./models/BodyWeight');

async function seedDemoData() {
  console.log('Connecting to MongoDB Atlas...');
  await mongoose.connect(process.env.MONGO_URI);
  console.log('✓ Connected to MongoDB');

  const demoEmail = 'siddhesh@gymlog.app';
  const demoPassword = 'password123';

  // 1. Remove existing demo user if exists to refresh cleanly
  await User.deleteMany({ email: demoEmail });
  console.log('Cleared any previous demo user data.');

  // 2. Create Demo User "Siddhesh"
  const user = await User.create({
    name: 'Siddhesh',
    email: demoEmail,
    password: demoPassword,
  });
  console.log(`✓ Created demo user: ${user.name} (${user.email})`);

  // Also clean up any orphan routines/workouts for this user
  await Routine.deleteMany({ userId: user._id });
  await Workout.deleteMany({ userId: user._id });
  await BodyWeight.deleteMany({ userId: user._id });

  // 3. Create Sample Routines
  console.log('Creating sample routines...');
  const pushRoutine = await Routine.create({
    userId: user._id,
    name: 'Push Day (Chest, Shoulders, Triceps)',
    exercises: [
      {
        name: 'Barbell Bench Press',
        muscleGroup: 'Chest',
        targetSets: 4,
        targetWeight: 80,
        targetReps: 8,
        restTimeSeconds: 90,
        notes: 'Keep shoulder blades retracted and elbows at 45 degrees.',
      },
      {
        name: 'Incline Dumbbell Press',
        muscleGroup: 'Chest',
        targetSets: 3,
        targetWeight: 26,
        targetReps: 10,
        restTimeSeconds: 90,
        notes: 'Incline bench at 30 degrees.',
      },
      {
        name: 'Overhead Press (OHP)',
        muscleGroup: 'Shoulders',
        targetSets: 3,
        targetWeight: 50,
        targetReps: 8,
        restTimeSeconds: 120,
        notes: 'Brace core tightly and press directly overhead.',
      },
      {
        name: 'Dumbbell Lateral Raise',
        muscleGroup: 'Shoulders',
        targetSets: 4,
        targetWeight: 12,
        targetReps: 15,
        restTimeSeconds: 60,
        notes: 'Control the eccentric tempo.',
      },
      {
        name: 'Tricep Rope Pushdown',
        muscleGroup: 'Arms',
        targetSets: 3,
        targetWeight: 25,
        targetReps: 12,
        restTimeSeconds: 60,
        notes: 'Flare ropes outward at peak contraction.',
      },
    ],
  });

  const pullRoutine = await Routine.create({
    userId: user._id,
    name: 'Pull Day (Back & Biceps)',
    exercises: [
      {
        name: 'Barbell Deadlift',
        muscleGroup: 'Back',
        targetSets: 4,
        targetWeight: 120,
        targetReps: 5,
        restTimeSeconds: 180,
        notes: 'Reset each rep from the floor. Keep spine neutral.',
      },
      {
        name: 'Barbell Bent Over Row',
        muscleGroup: 'Back',
        targetSets: 3,
        targetWeight: 70,
        targetReps: 8,
        restTimeSeconds: 90,
        notes: 'Pull towards the lower ribcage.',
      },
      {
        name: 'Pull-Up',
        muscleGroup: 'Back',
        targetSets: 3,
        targetWeight: 0,
        targetReps: 10,
        restTimeSeconds: 90,
        notes: 'Full range of motion - dead hang to chest to bar.',
      },
      {
        name: 'Seated Cable Row',
        muscleGroup: 'Back',
        targetSets: 3,
        targetWeight: 60,
        targetReps: 10,
        restTimeSeconds: 60,
        notes: 'Squeeze lats at the peak.',
      },
      {
        name: 'Barbell Bicep Curl',
        muscleGroup: 'Arms',
        targetSets: 3,
        targetWeight: 35,
        targetReps: 10,
        restTimeSeconds: 60,
        notes: 'Do not swing hips.',
      },
    ],
  });

  const legsRoutine = await Routine.create({
    userId: user._id,
    name: 'Legs & Core',
    exercises: [
      {
        name: 'Barbell Back Squat',
        muscleGroup: 'Legs',
        targetSets: 4,
        targetWeight: 100,
        targetReps: 6,
        restTimeSeconds: 180,
        notes: 'Hit parallel or below depth.',
      },
      {
        name: 'Romanian Deadlift (RDL)',
        muscleGroup: 'Legs',
        targetSets: 3,
        targetWeight: 80,
        targetReps: 8,
        restTimeSeconds: 90,
        notes: 'Focus on maximum hamstring stretch.',
      },
      {
        name: 'Leg Press',
        muscleGroup: 'Legs',
        targetSets: 3,
        targetWeight: 180,
        targetReps: 10,
        restTimeSeconds: 90,
        notes: 'Feet shoulder-width on platform.',
      },
      {
        name: 'Standing Calf Raise',
        muscleGroup: 'Legs',
        targetSets: 4,
        targetWeight: 50,
        targetReps: 15,
        restTimeSeconds: 60,
        notes: 'Pause at the bottom stretch.',
      },
      {
        name: 'Hanging Leg Raise',
        muscleGroup: 'Core',
        targetSets: 3,
        targetWeight: 0,
        targetReps: 12,
        restTimeSeconds: 60,
        notes: 'Curl pelvis up towards chest.',
      },
    ],
  });

  console.log('✓ Created 3 routines: Push, Pull, Legs');

  // 4. Create Historical Workouts (over last 14 days to generate beautiful charts!)
  console.log('Creating historical workouts...');
  const now = Date.now();
  const day = 24 * 60 * 60 * 1000;

  // Session 1: 14 days ago - Push Day A
  await Workout.create({
    userId: user._id,
    routineId: pushRoutine._id,
    routineName: 'Push Day (Chest, Shoulders, Triceps)',
    duration: 3400,
    startedAt: new Date(now - 14 * day - 3600000),
    completedAt: new Date(now - 14 * day),
    caption: 'First push session of the block. Focused on smooth form.',
    mediaUrls: [
      'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=60',
    ],
    isPublic: true,
    likes: [],
    exercises: [
      {
        name: 'Barbell Bench Press',
        muscleGroup: 'Chest',
        notes: 'Paused at chest',
        restTimeSeconds: 90,
        sets: [
          { setNumber: 1, weight: 70, reps: 10, completed: true },
          { setNumber: 2, weight: 75, reps: 8, completed: true },
          { setNumber: 3, weight: 75, reps: 8, completed: true },
          { setNumber: 4, weight: 75, reps: 7, completed: true },
        ],
      },
      {
        name: 'Overhead Press (OHP)',
        muscleGroup: 'Shoulders',
        notes: '',
        restTimeSeconds: 120,
        sets: [
          { setNumber: 1, weight: 45, reps: 8, completed: true },
          { setNumber: 2, weight: 45, reps: 8, completed: true },
          { setNumber: 3, weight: 45, reps: 7, completed: true },
        ],
      },
      {
        name: 'Tricep Rope Pushdown',
        muscleGroup: 'Arms',
        notes: '',
        restTimeSeconds: 60,
        sets: [
          { setNumber: 1, weight: 20, reps: 12, completed: true },
          { setNumber: 2, weight: 22.5, reps: 10, completed: true },
          { setNumber: 3, weight: 22.5, reps: 10, completed: true },
        ],
      },
    ],
  });

  // Session 2: 11 days ago - Pull Day A
  await Workout.create({
    userId: user._id,
    routineId: pullRoutine._id,
    routineName: 'Pull Day (Back & Biceps)',
    duration: 3800,
    startedAt: new Date(now - 11 * day - 3900000),
    completedAt: new Date(now - 11 * day),
    caption: 'Deadlifts felt rock solid today.',
    mediaUrls: [],
    isPublic: false,
    likes: [],
    exercises: [
      {
        name: 'Barbell Deadlift',
        muscleGroup: 'Back',
        notes: 'Warmups were crisp',
        restTimeSeconds: 180,
        sets: [
          { setNumber: 1, weight: 100, reps: 5, completed: true },
          { setNumber: 2, weight: 110, reps: 5, completed: true },
          { setNumber: 3, weight: 115, reps: 5, completed: true },
          { setNumber: 4, weight: 115, reps: 4, completed: true },
        ],
      },
      {
        name: 'Barbell Bent Over Row',
        muscleGroup: 'Back',
        notes: '',
        restTimeSeconds: 90,
        sets: [
          { setNumber: 1, weight: 65, reps: 8, completed: true },
          { setNumber: 2, weight: 65, reps: 8, completed: true },
          { setNumber: 3, weight: 65, reps: 8, completed: true },
        ],
      },
      {
        name: 'Barbell Bicep Curl',
        muscleGroup: 'Arms',
        notes: '',
        restTimeSeconds: 60,
        sets: [
          { setNumber: 1, weight: 30, reps: 10, completed: true },
          { setNumber: 2, weight: 30, reps: 10, completed: true },
          { setNumber: 3, weight: 32.5, reps: 8, completed: true },
        ],
      },
    ],
  });

  // Session 3: 8 days ago - Legs
  await Workout.create({
    userId: user._id,
    routineId: legsRoutine._id,
    routineName: 'Legs & Core',
    duration: 4100,
    startedAt: new Date(now - 8 * day - 4200000),
    completedAt: new Date(now - 8 * day),
    caption: 'Heavy squats. Legs are toasted!',
    mediaUrls: [
      'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=60',
    ],
    isPublic: true,
    likes: [],
    exercises: [
      {
        name: 'Barbell Back Squat',
        muscleGroup: 'Legs',
        notes: 'Hit depth on all reps',
        restTimeSeconds: 180,
        sets: [
          { setNumber: 1, weight: 90, reps: 6, completed: true },
          { setNumber: 2, weight: 95, reps: 6, completed: true },
          { setNumber: 3, weight: 95, reps: 6, completed: true },
          { setNumber: 4, weight: 100, reps: 5, completed: true },
        ],
      },
      {
        name: 'Romanian Deadlift (RDL)',
        muscleGroup: 'Legs',
        notes: '',
        restTimeSeconds: 90,
        sets: [
          { setNumber: 1, weight: 75, reps: 8, completed: true },
          { setNumber: 2, weight: 75, reps: 8, completed: true },
          { setNumber: 3, weight: 80, reps: 8, completed: true },
        ],
      },
    ],
  });

  // Session 4: 5 days ago - Push Day B (Progression)
  await Workout.create({
    userId: user._id,
    routineId: pushRoutine._id,
    routineName: 'Push Day (Chest, Shoulders, Triceps)',
    duration: 3600,
    startedAt: new Date(now - 5 * day - 3700000),
    completedAt: new Date(now - 5 * day),
    caption: 'Weight increase on bench felt easy.',
    mediaUrls: [],
    isPublic: false,
    likes: [],
    exercises: [
      {
        name: 'Barbell Bench Press',
        muscleGroup: 'Chest',
        notes: 'Felt very explosive off the chest',
        restTimeSeconds: 90,
        sets: [
          { setNumber: 1, weight: 75, reps: 10, completed: true },
          { setNumber: 2, weight: 80, reps: 8, completed: true },
          { setNumber: 3, weight: 80, reps: 8, completed: true },
          { setNumber: 4, weight: 80, reps: 7, completed: true },
        ],
      },
      {
        name: 'Overhead Press (OHP)',
        muscleGroup: 'Shoulders',
        notes: '',
        restTimeSeconds: 120,
        sets: [
          { setNumber: 1, weight: 47.5, reps: 8, completed: true },
          { setNumber: 2, weight: 47.5, reps: 8, completed: true },
          { setNumber: 3, weight: 47.5, reps: 7, completed: true },
        ],
      },
      {
        name: 'Tricep Rope Pushdown',
        muscleGroup: 'Arms',
        notes: '',
        restTimeSeconds: 60,
        sets: [
          { setNumber: 1, weight: 25, reps: 12, completed: true },
          { setNumber: 2, weight: 25, reps: 10, completed: true },
          { setNumber: 3, weight: 25, reps: 10, completed: true },
        ],
      },
    ],
  });

  // Session 5: 2 days ago - Push Day PR! (Latest session with PR & community post)
  await Workout.create({
    userId: user._id,
    routineId: pushRoutine._id,
    routineName: 'Push Day (Chest, Shoulders, Triceps)',
    duration: 3950,
    startedAt: new Date(now - 2 * day - 4000000),
    completedAt: new Date(now - 2 * day),
    caption: 'NEW BENCH PR: 85kg for 5 clean reps! Consistent training paying off 🔥💪',
    mediaUrls: [
      'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=60',
    ],
    isPublic: true,
    likes: [],
    exercises: [
      {
        name: 'Barbell Bench Press',
        muscleGroup: 'Chest',
        notes: 'PR on last set! Spotter didn’t touch the bar.',
        restTimeSeconds: 120,
        sets: [
          { setNumber: 1, weight: 75, reps: 10, completed: true },
          { setNumber: 2, weight: 80, reps: 8, completed: true },
          { setNumber: 3, weight: 82.5, reps: 6, completed: true },
          { setNumber: 4, weight: 85, reps: 5, completed: true },
        ],
      },
      {
        name: 'Incline Dumbbell Press',
        muscleGroup: 'Chest',
        notes: '28kg felt manageable',
        restTimeSeconds: 90,
        sets: [
          { setNumber: 1, weight: 26, reps: 10, completed: true },
          { setNumber: 2, weight: 28, reps: 9, completed: true },
          { setNumber: 3, weight: 28, reps: 8, completed: true },
        ],
      },
      {
        name: 'Overhead Press (OHP)',
        muscleGroup: 'Shoulders',
        notes: 'Clean lockout',
        restTimeSeconds: 120,
        sets: [
          { setNumber: 1, weight: 50, reps: 8, completed: true },
          { setNumber: 2, weight: 50, reps: 7, completed: true },
          { setNumber: 3, weight: 50, reps: 6, completed: true },
        ],
      },
      {
        name: 'Dumbbell Lateral Raise',
        muscleGroup: 'Shoulders',
        notes: 'Giant dropset on final set',
        restTimeSeconds: 60,
        sets: [
          { setNumber: 1, weight: 12, reps: 15, completed: true },
          { setNumber: 2, weight: 12, reps: 15, completed: true },
          { setNumber: 3, weight: 14, reps: 12, completed: true },
        ],
      },
      {
        name: 'Tricep Rope Pushdown',
        muscleGroup: 'Arms',
        notes: '',
        restTimeSeconds: 60,
        sets: [
          { setNumber: 1, weight: 25, reps: 12, completed: true },
          { setNumber: 2, weight: 27.5, reps: 10, completed: true },
          { setNumber: 3, weight: 27.5, reps: 10, completed: true },
        ],
      },
    ],
  });

  // Session 6: Yesterday - Pull Day
  await Workout.create({
    userId: user._id,
    routineId: pullRoutine._id,
    routineName: 'Pull Day (Back & Biceps)',
    duration: 3750,
    startedAt: new Date(now - 1 * day - 3800000),
    completedAt: new Date(now - 1 * day),
    caption: 'Heavy rows and high volume pull-ups. Feeling strong!',
    mediaUrls: [
      'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=800&auto=format&fit=crop&q=60',
    ],
    isPublic: true,
    likes: [],
    exercises: [
      {
        name: 'Barbell Deadlift',
        muscleGroup: 'Back',
        notes: 'Locked out 120kg easily',
        restTimeSeconds: 180,
        sets: [
          { setNumber: 1, weight: 100, reps: 5, completed: true },
          { setNumber: 2, weight: 110, reps: 5, completed: true },
          { setNumber: 3, weight: 120, reps: 5, completed: true },
          { setNumber: 4, weight: 120, reps: 5, completed: true },
        ],
      },
      {
        name: 'Barbell Bent Over Row',
        muscleGroup: 'Back',
        notes: 'Strict angle, no jerking',
        restTimeSeconds: 90,
        sets: [
          { setNumber: 1, weight: 70, reps: 8, completed: true },
          { setNumber: 2, weight: 70, reps: 8, completed: true },
          { setNumber: 3, weight: 72.5, reps: 7, completed: true },
        ],
      },
      {
        name: 'Pull-Up',
        muscleGroup: 'Back',
        notes: 'Bodyweight only',
        restTimeSeconds: 90,
        sets: [
          { setNumber: 1, weight: 0, reps: 10, completed: true },
          { setNumber: 2, weight: 0, reps: 9, completed: true },
          { setNumber: 3, weight: 0, reps: 8, completed: true },
        ],
      },
    ],
  });

  console.log('✓ Created 6 historical workouts with exercises, sets & media');

  // 5. Create Body Weight Trend Data (Weekly logs over past month)
  console.log('Creating body weight history...');
  await BodyWeight.create([
    {
      userId: user._id,
      weight: 78.6,
      date: new Date(now - 28 * day),
      notes: 'Initial check-in after bulk phase.',
    },
    {
      userId: user._id,
      weight: 78.1,
      date: new Date(now - 21 * day),
      notes: 'Deficit starting to show.',
    },
    {
      userId: user._id,
      weight: 77.5,
      date: new Date(now - 14 * day),
      notes: 'Morning weigh-in after rest day.',
    },
    {
      userId: user._id,
      weight: 76.9,
      date: new Date(now - 7 * day),
      notes: 'Feeling lighter and maintaining strength.',
    },
    {
      userId: user._id,
      weight: 76.4,
      date: new Date(now - 1 * day),
      notes: 'Lowest weight so far! Down 2.2 kg.',
    },
  ]);
  console.log('✓ Created 5 body weight entries (showing clear downward trend)');

  console.log('\n======================================================');
  console.log(' DEMO PROFILE SUCCESSFULLY POPULATED!');
  console.log('======================================================');
  console.log('Credentials to log in:');
  console.log('  Email:    siddhesh@gymlog.app');
  console.log('  Password: password123');
  console.log('======================================================');

  await mongoose.disconnect();
  process.exit(0);
}

seedDemoData().catch((err) => {
  console.error('Seeding failed:', err);
  process.exit(1);
});
