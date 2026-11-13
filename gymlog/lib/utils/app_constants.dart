class ExerciseDefinition {
  final String name;
  final String muscleGroup;
  final String equipment;

  const ExerciseDefinition({
    required this.name,
    required this.muscleGroup,
    this.equipment = 'Barbell',
  });
}

class AppConstants {
  static const List<ExerciseDefinition> defaultExercises = [
    // --- CHEST ---
    ExerciseDefinition(name: 'Barbell Bench Press', muscleGroup: 'Chest', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Incline Barbell Bench Press', muscleGroup: 'Chest', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Decline Barbell Bench Press', muscleGroup: 'Chest', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Dumbbell Bench Press', muscleGroup: 'Chest', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Incline Dumbbell Press', muscleGroup: 'Chest', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Decline Dumbbell Press', muscleGroup: 'Chest', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Flat Dumbbell Flyes', muscleGroup: 'Chest', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Incline Dumbbell Flyes', muscleGroup: 'Chest', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Cable Crossover', muscleGroup: 'Chest', equipment: 'Cable'),
    ExerciseDefinition(name: 'High-to-Low Cable Fly', muscleGroup: 'Chest', equipment: 'Cable'),
    ExerciseDefinition(name: 'Low-to-High Cable Fly', muscleGroup: 'Chest', equipment: 'Cable'),
    ExerciseDefinition(name: 'Machine Chest Press', muscleGroup: 'Chest', equipment: 'Machine'),
    ExerciseDefinition(name: 'Pec Deck Machine', muscleGroup: 'Chest', equipment: 'Machine'),
    ExerciseDefinition(name: 'Chest Dips', muscleGroup: 'Chest', equipment: 'Bodyweight'),
    ExerciseDefinition(name: 'Standard Push-Up', muscleGroup: 'Chest', equipment: 'Bodyweight'),
    ExerciseDefinition(name: 'Diamond Push-Up', muscleGroup: 'Chest', equipment: 'Bodyweight'),

    // --- BACK ---
    ExerciseDefinition(name: 'Barbell Deadlift', muscleGroup: 'Back', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Barbell Bent Over Row', muscleGroup: 'Back', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Pendlay Row', muscleGroup: 'Back', equipment: 'Barbell'),
    ExerciseDefinition(name: 'One-Arm Dumbbell Row', muscleGroup: 'Back', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Pull-Up', muscleGroup: 'Back', equipment: 'Bodyweight'),
    ExerciseDefinition(name: 'Chin-Up', muscleGroup: 'Back', equipment: 'Bodyweight'),
    ExerciseDefinition(name: 'Lat Pulldown (Wide Grip)', muscleGroup: 'Back', equipment: 'Cable'),
    ExerciseDefinition(name: 'Lat Pulldown (Close Grip)', muscleGroup: 'Back', equipment: 'Cable'),
    ExerciseDefinition(name: 'Seated Cable Row', muscleGroup: 'Back', equipment: 'Cable'),
    ExerciseDefinition(name: 'T-Bar Row', muscleGroup: 'Back', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Chest Supported Row', muscleGroup: 'Back', equipment: 'Machine'),
    ExerciseDefinition(name: 'Straight Arm Cable Pulldown', muscleGroup: 'Back', equipment: 'Cable'),
    ExerciseDefinition(name: 'Inverted Row', muscleGroup: 'Back', equipment: 'Bodyweight'),
    ExerciseDefinition(name: 'Back Hyperextension', muscleGroup: 'Back', equipment: 'Bodyweight'),

    // --- SHOULDERS ---
    ExerciseDefinition(name: 'Overhead Press (OHP)', muscleGroup: 'Shoulders', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Seated Dumbbell Shoulder Press', muscleGroup: 'Shoulders', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Arnold Press', muscleGroup: 'Shoulders', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Dumbbell Lateral Raise', muscleGroup: 'Shoulders', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Cable Lateral Raise', muscleGroup: 'Shoulders', equipment: 'Cable'),
    ExerciseDefinition(name: 'Dumbbell Front Raise', muscleGroup: 'Shoulders', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Cable Face Pull', muscleGroup: 'Shoulders', equipment: 'Cable'),
    ExerciseDefinition(name: 'Reverse Pec Deck (Rear Delt)', muscleGroup: 'Shoulders', equipment: 'Machine'),
    ExerciseDefinition(name: 'Bent-Over Rear Delt Fly', muscleGroup: 'Shoulders', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Barbell Upright Row', muscleGroup: 'Shoulders', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Barbell Shrug', muscleGroup: 'Shoulders', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Dumbbell Shrug', muscleGroup: 'Shoulders', equipment: 'Dumbbell'),

    // --- LEGS (QUADS, HAMSTRINGS, GLUTES, CALVES) ---
    ExerciseDefinition(name: 'Barbell Back Squat', muscleGroup: 'Legs', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Barbell Front Squat', muscleGroup: 'Legs', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Leg Press', muscleGroup: 'Legs', equipment: 'Machine'),
    ExerciseDefinition(name: 'Hack Squat', muscleGroup: 'Legs', equipment: 'Machine'),
    ExerciseDefinition(name: 'Romanian Deadlift (RDL)', muscleGroup: 'Legs', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Dumbbell Romanian Deadlift', muscleGroup: 'Legs', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Bulgarian Split Squat', muscleGroup: 'Legs', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Walking Lunges', muscleGroup: 'Legs', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Leg Extension', muscleGroup: 'Legs', equipment: 'Machine'),
    ExerciseDefinition(name: 'Lying Hamstring Leg Curl', muscleGroup: 'Legs', equipment: 'Machine'),
    ExerciseDefinition(name: 'Seated Hamstring Leg Curl', muscleGroup: 'Legs', equipment: 'Machine'),
    ExerciseDefinition(name: 'Barbell Hip Thrust', muscleGroup: 'Legs', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Glute Kickback', muscleGroup: 'Legs', equipment: 'Cable'),
    ExerciseDefinition(name: 'Standing Calf Raise', muscleGroup: 'Legs', equipment: 'Machine'),
    ExerciseDefinition(name: 'Seated Calf Raise', muscleGroup: 'Legs', equipment: 'Machine'),
    ExerciseDefinition(name: 'Goblet Squat', muscleGroup: 'Legs', equipment: 'Dumbbell'),

    // --- ARMS (BICEPS, TRICEPS, FOREARMS) ---
    ExerciseDefinition(name: 'Barbell Bicep Curl', muscleGroup: 'Arms', equipment: 'Barbell'),
    ExerciseDefinition(name: 'EZ-Bar Bicep Curl', muscleGroup: 'Arms', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Dumbbell Hammer Curl', muscleGroup: 'Arms', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Incline Dumbbell Bicep Curl', muscleGroup: 'Arms', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Concentration Curl', muscleGroup: 'Arms', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Preacher Curl', muscleGroup: 'Arms', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Cable Bicep Curl', muscleGroup: 'Arms', equipment: 'Cable'),
    ExerciseDefinition(name: 'Tricep Rope Pushdown', muscleGroup: 'Arms', equipment: 'Cable'),
    ExerciseDefinition(name: 'Tricep Bar Pushdown', muscleGroup: 'Arms', equipment: 'Cable'),
    ExerciseDefinition(name: 'Skull Crushers (Lying Tricep Ext)', muscleGroup: 'Arms', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Overhead Dumbbell Tricep Extension', muscleGroup: 'Arms', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Close-Grip Bench Press', muscleGroup: 'Arms', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Bench Dips', muscleGroup: 'Arms', equipment: 'Bodyweight'),
    ExerciseDefinition(name: 'Wrist Curl', muscleGroup: 'Arms', equipment: 'Barbell'),
    ExerciseDefinition(name: 'Reverse Wrist Curl', muscleGroup: 'Arms', equipment: 'Barbell'),

    // --- CORE & ABS ---
    ExerciseDefinition(name: 'Standard Plank', muscleGroup: 'Core', equipment: 'Bodyweight'),
    ExerciseDefinition(name: 'Side Plank', muscleGroup: 'Core', equipment: 'Bodyweight'),
    ExerciseDefinition(name: 'Hanging Leg Raise', muscleGroup: 'Core', equipment: 'Bodyweight'),
    ExerciseDefinition(name: 'Hanging Knee Raise', muscleGroup: 'Core', equipment: 'Bodyweight'),
    ExerciseDefinition(name: 'Cable Crunch', muscleGroup: 'Core', equipment: 'Cable'),
    ExerciseDefinition(name: 'Ab Wheel Rollout', muscleGroup: 'Core', equipment: 'Bodyweight'),
    ExerciseDefinition(name: 'Russian Twists', muscleGroup: 'Core', equipment: 'Bodyweight'),
    ExerciseDefinition(name: 'Decline Sit-Up', muscleGroup: 'Core', equipment: 'Bodyweight'),
    ExerciseDefinition(name: 'Woodchoppers', muscleGroup: 'Core', equipment: 'Cable'),

    // --- CARDIO & FULL BODY ---
    ExerciseDefinition(name: 'Treadmill Running', muscleGroup: 'Cardio', equipment: 'Machine'),
    ExerciseDefinition(name: 'Stationary Cycling', muscleGroup: 'Cardio', equipment: 'Machine'),
    ExerciseDefinition(name: 'Rowing Machine', muscleGroup: 'Cardio', equipment: 'Machine'),
    ExerciseDefinition(name: 'Jump Rope', muscleGroup: 'Cardio', equipment: 'Bodyweight'),
    ExerciseDefinition(name: 'Kettlebell Swing', muscleGroup: 'Cardio', equipment: 'Dumbbell'),
    ExerciseDefinition(name: 'Burpees', muscleGroup: 'Cardio', equipment: 'Bodyweight'),
  ];
}
