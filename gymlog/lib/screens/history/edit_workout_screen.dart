import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/workout_model.dart';
import '../../providers/workout_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditWorkoutScreen extends StatefulWidget {
  final WorkoutModel workout;

  const EditWorkoutScreen({super.key, required this.workout});

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  late WorkoutModel _editableWorkout;
  late TextEditingController _titleController;
  late TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    _editableWorkout = widget.workout.copy();
    _titleController =
        TextEditingController(text: _editableWorkout.routineName);
    _captionController =
        TextEditingController(text: _editableWorkout.caption);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a routine name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _editableWorkout.routineName = title;
    _editableWorkout.caption = _captionController.text.trim();

    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    final success = await provider.updateWorkout(_editableWorkout);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, _editableWorkout);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to update workout'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Workout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: provider.isLoading ? null : _saveChanges,
            child: Text(
              'Save',
              style: TextStyle(
                color:
                    provider.isLoading ? AppColors.textMuted : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Workout Name',
              hint: 'e.g. Push Day',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _captionController,
              label: 'Caption / Notes',
              hint: 'How did this session feel?',
            ),
            const SizedBox(height: 24),
            const Text(
              'EXERCISES & SETS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            ..._editableWorkout.exercises.map((ex) {

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ex.name,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          ex.muscleGroup,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Exercise Notes
                    TextFormField(
                      initialValue: ex.notes,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Notes for this exercise...',
                        hintStyle: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) => ex.notes = val,
                    ),
                    const SizedBox(height: 12),

                    // Sets Header
                    const Row(
                      children: [
                        SizedBox(
                            width: 34,
                            child: Text('SET',
                                style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Center(
                                child: Text('KG',
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)))),
                        Expanded(
                            child: Center(
                                child: Text('REPS',
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)))),
                        SizedBox(width: 36),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Sets list
                    ...ex.sets.asMap().entries.map((setEntry) {
                      final sIndex = setEntry.key;
                      final s = setEntry.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 34,
                              child: Text(
                                '${s.setNumber}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 36,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: TextFormField(
                                  initialValue: '${s.weight}',
                                  keyboardType: const TextInputType
                                      .numberWithOptions(decimal: true),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: AppColors.text, fontSize: 14),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.inputBackground,
                                    contentPadding: EdgeInsets.zero,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    s.weight =
                                        double.tryParse(val) ?? s.weight;
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 36,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: TextFormField(
                                  initialValue: '${s.reps}',
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: AppColors.text, fontSize: 14),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.inputBackground,
                                    contentPadding: EdgeInsets.zero,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    s.reps = int.tryParse(val) ?? s.reps;
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  size: 18, color: AppColors.error),
                              onPressed: () {
                                setState(() {
                                  ex.sets.removeAt(sIndex);
                                  for (int i = 0; i < ex.sets.length; i++) {
                                    ex.sets[i].setNumber = i + 1;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          ex.sets.add(
                            WorkoutSetModel(
                              setNumber: ex.sets.length + 1,
                              weight: ex.sets.isNotEmpty
                                  ? ex.sets.last.weight
                                  : 0,
                              reps: ex.sets.isNotEmpty
                                  ? ex.sets.last.reps
                                  : 10,
                              completed: true,
                            ),
                          );
                        });
                      },
                      icon: const Icon(Icons.add,
                          size: 16, color: AppColors.primary),
                      label: const Text(
                        'Add Set',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),
            CustomButton(
              text: 'Save Changes',
              isLoading: provider.isLoading,
              onPressed: _saveChanges,
            ),
          ],
        ),
      ),
    );
  }
}
