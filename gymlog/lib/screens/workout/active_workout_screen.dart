import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import 'exercise_selection_dialog.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final _captionController = TextEditingController();
  final _mediaUrlController = TextEditingController();
  bool _shareToCommunity = false;

  @override
  void dispose() {
    _captionController.dispose();
    _mediaUrlController.dispose();
    super.dispose();
  }

  void _openExerciseSelector() async {
    final selected = await showModalBottomSheet<ExerciseDefinition>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExerciseSelectionDialog(),
    );

    if (selected != null && mounted) {
      Provider.of<WorkoutProvider>(context, listen: false).addExercise(
        selected.name,
        selected.muscleGroup,
        initialSets: 3,
        restTimeSeconds: 90,
      );
    }
  }

  void _showFinishDialog() async {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);

    if (provider.activeExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise before finishing'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _captionController.clear();
    _mediaUrlController.clear();
    _shareToCommunity = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Finish Workout',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          provider.formattedDuration,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Summary Snippet
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          '${provider.activeExercises.length} exercises',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const Text('•',
                            style: TextStyle(color: AppColors.textMuted)),
                        Text(
                          '${provider.activeExercises.fold(0, (sum, ex) => sum + ex.sets.length)} sets logged',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Caption / Notes for workout
                  const Text(
                    'WORKOUT CAPTION / NOTES',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _captionController,
                    maxLines: 2,
                    style: const TextStyle(color: AppColors.text, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. New PR on bench press! Felt great energy 🔥',
                      hintStyle:
                          const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Photo / Media URL
                  const Text(
                    'ATTACH PHOTO / MEDIA URL (OPTIONAL)',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _mediaUrlController,
                    style: const TextStyle(color: AppColors.text, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'https://images.unsplash.com/...',
                      prefixIcon: const Icon(Icons.image_outlined,
                          color: AppColors.textSecondary, size: 20),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Share to Community Toggle
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share to Community Feed',
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Let other athletes view and react to your workout',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _shareToCommunity,
                          activeThumbColor: const Color(0xFF121212),
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            setModalState(() {
                              _shareToCommunity = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Workout Button
                  ElevatedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(context);
                      Navigator.pop(ctx);
                      final media = _mediaUrlController.text.trim().isNotEmpty
                          ? [_mediaUrlController.text.trim()]
                          : <String>[];

                      final success = await provider.finishWorkout(
                        caption: _captionController.text.trim(),
                        mediaUrls: media,
                        isPublic: _shareToCommunity,
                      );

                      if (success) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Workout saved successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        nav.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: const Color(0xFF121212),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Save & Log Workout',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _discardWorkout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Discard Workout',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to discard this workout session? All logged data will be lost.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Resume',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Provider.of<WorkoutProvider>(context, listen: false).discardWorkout();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.text, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workoutProvider.activeRoutineName,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.timer_outlined,
                    color: AppColors.primary, size: 14),
                const SizedBox(width: 4),
                Text(
                  workoutProvider.formattedDuration,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
              onPressed:
                  workoutProvider.isLoading ? null : () => _showFinishDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color(0xFF121212),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              child: const Text(
                'Finish',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          workoutProvider.activeExercises.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center_outlined,
                          size: 64,
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No exercises in session',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add an exercise to start logging your sets, weights, reps, and notes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _openExerciseSelector,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Exercise'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: const Color(0xFF121212),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      workoutProvider.isRestTimerActive ? 140 : 80),
                  itemCount: workoutProvider.activeExercises.length + 1,
                  itemBuilder: (context, index) {
                    if (index == workoutProvider.activeExercises.length) {
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _openExerciseSelector,
                            icon: const Icon(Icons.add, color: AppColors.primary),
                            label: const Text(
                              'Add Exercise',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _discardWorkout,
                            icon: const Icon(Icons.close,
                                color: AppColors.error, size: 18),
                            label: const Text(
                              'Discard Workout',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    final exercise = workoutProvider.activeExercises[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Exercise Header & Controls
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exercise.name,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        exercise.muscleGroup,
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Rest timer adjuster
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardElevated,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButton<int>(
                                    value: exercise.restTimeSeconds,
                                    underline: const SizedBox(),
                                    dropdownColor: AppColors.surface,
                                    icon: const Icon(Icons.timer_outlined,
                                        size: 14, color: AppColors.primary),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 30, child: Text('30s ')),
                                      DropdownMenuItem(
                                          value: 60, child: Text('60s ')),
                                      DropdownMenuItem(
                                          value: 90, child: Text('90s ')),
                                      DropdownMenuItem(
                                          value: 120, child: Text('2m ')),
                                      DropdownMenuItem(
                                          value: 180, child: Text('3m ')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        workoutProvider.updateExerciseRestTime(
                                            index, val);
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppColors.error, size: 20),
                                  onPressed: () {
                                    workoutProvider.removeExercise(index);
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Exercise-Specific Notes Field
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: TextFormField(
                              initialValue: exercise.notes,
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13),
                              decoration: InputDecoration(
                                hintText:
                                    'Add notes: seat #4, 2s pause at bottom...',
                                hintStyle: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 12),
                                prefixIcon: const Icon(Icons.edit_note,
                                    size: 16, color: AppColors.textMuted),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (val) {
                                workoutProvider.updateExerciseNotes(index, val);
                              },
                            ),
                          ),

                          // Set Table Header
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 38,
                                  child: Text(
                                    'SET',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'KG',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'REPS',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 44,
                                  child: Center(
                                    child: Icon(Icons.check,
                                        size: 16, color: AppColors.textMuted),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Set Rows
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: exercise.sets.length,
                            itemBuilder: (context, setIndex) {
                              final set = exercise.sets[setIndex];
                              return Dismissible(
                                key: ValueKey(
                                    '${exercise.name}_${setIndex}_${set.setNumber}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: AppColors.error.withValues(alpha: 0.2),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: const Icon(Icons.delete,
                                      color: AppColors.error),
                                ),
                                onDismissed: (_) {
                                  workoutProvider.removeSet(index, setIndex);
                                },
                                child: Container(
                                  color: set.completed
                                      ? AppColors.primary
                                          .withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 38,
                                        child: Text(
                                          '${set.setNumber}',
                                          style: TextStyle(
                                            color: set.completed
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          height: 38,
                                          child: TextFormField(
                                            initialValue: set.weight > 0
                                                ? (set.weight % 1 == 0
                                                    ? set.weight
                                                        .toInt()
                                                        .toString()
                                                    : set.weight.toString())
                                                : '',
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: set.completed
                                                  ? AppColors.primary
                                                  : AppColors.text,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: '0',
                                              hintStyle: const TextStyle(
                                                  color: AppColors.textMuted),
                                              contentPadding: EdgeInsets.zero,
                                              filled: true,
                                              fillColor:
                                                  AppColors.inputBackground,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            onChanged: (val) {
                                              final parsed =
                                                  double.tryParse(val) ?? 0.0;
                                              workoutProvider.updateSetWeight(
                                                  index, setIndex, parsed);
                                            },
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          height: 38,
                                          child: TextFormField(
                                            initialValue: set.reps > 0
                                                ? set.reps.toString()
                                                : '',
                                            keyboardType:
                                                TextInputType.number,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: set.completed
                                                  ? AppColors.primary
                                                  : AppColors.text,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: '0',
                                              hintStyle: const TextStyle(
                                                  color: AppColors.textMuted),
                                              contentPadding: EdgeInsets.zero,
                                              filled: true,
                                              fillColor:
                                                  AppColors.inputBackground,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            onChanged: (val) {
                                              final parsed =
                                                  int.tryParse(val) ?? 0;
                                              workoutProvider.updateSetReps(
                                                  index, setIndex, parsed);
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 44,
                                        child: Center(
                                          child: InkWell(
                                            onTap: () {
                                              workoutProvider
                                                  .toggleSetCompleted(
                                                      index, setIndex);
                                            },
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: set.completed
                                                    ? AppColors.primary
                                                    : AppColors.cardElevated,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: set.completed
                                                      ? AppColors.primary
                                                      : AppColors.border,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                size: 18,
                                                color: set.completed
                                                    ? const Color(0xFF121212)
                                                    : AppColors.textMuted,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Add Set Button
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: TextButton.icon(
                              onPressed: () {
                                workoutProvider.addSet(index);
                              },
                              icon: const Icon(Icons.add,
                                  size: 16, color: AppColors.primary),
                              label: const Text(
                                'Add Set',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

          // Custom Rest Timer Floating Overlay Bar
          if (workoutProvider.isRestTimerActive)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.hourglass_top,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'REST TIMER',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            workoutProvider.formattedRestTime,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => workoutProvider.addRestSeconds(30),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.cardElevated,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                      ),
                      child: const Text(
                        '+30s',
                        style: TextStyle(
                            color: AppColors.text, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      tooltip: 'Skip Rest',
                      onPressed: () => workoutProvider.stopRestTimer(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
