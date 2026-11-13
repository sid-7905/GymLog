import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine_model.dart';
import '../../providers/routine_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../workout/exercise_selection_dialog.dart';

class CreateEditRoutineScreen extends StatefulWidget {
  final RoutineModel? routine;

  const CreateEditRoutineScreen({super.key, this.routine});

  @override
  State<CreateEditRoutineScreen> createState() =>
      _CreateEditRoutineScreenState();
}

class _CreateEditRoutineScreenState extends State<CreateEditRoutineScreen> {
  final _nameController = TextEditingController();
  final List<RoutineExerciseModel> _exercises = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.routine != null) {
      _isEditing = true;
      _nameController.text = widget.routine!.name;
      _exercises.addAll(widget.routine!.exercises);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _openExerciseSelector() async {
    final selected = await showModalBottomSheet<ExerciseDefinition>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExerciseSelectionDialog(),
    );

    if (selected != null) {
      setState(() {
        _exercises.add(
          RoutineExerciseModel(
            name: selected.name,
            muscleGroup: selected.muscleGroup,
            targetSets: 3,
            targetReps: 10,
            targetWeight: 0.0,
            restTimeSeconds: 90,
            notes: '',
          ),
        );
      });
    }
  }

  void _saveRoutine() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a routine name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise to the routine'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = Provider.of<RoutineProvider>(context, listen: false);
    bool success;

    if (_isEditing) {
      success = await provider.updateRoutine(
        id: widget.routine!.id,
        name: name,
        exercises: _exercises,
      );
    } else {
      success = await provider.createRoutine(
        name: name,
        exercises: _exercises,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save routine'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final routineProvider = Provider.of<RoutineProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Routine' : 'New Routine',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: routineProvider.isLoading ? null : _saveRoutine,
            child: Text(
              'Save',
              style: TextStyle(
                color: routineProvider.isLoading
                    ? AppColors.textMuted
                    : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'Routine Title',
              hint: 'e.g., Push Day A (Chest & Triceps)',
              prefixIcon: Icons.fitness_center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'EXERCISES & TARGET SETS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                TextButton.icon(
                  onPressed: _openExerciseSelector,
                  icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                  label: const Text(
                    'Add Exercise',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_exercises.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center_outlined,
                      size: 48,
                      color: AppColors.textMuted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No exercises added yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap "Add Exercise" above to select from predefined exercises',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) newIndex -= 1;
                    final item = _exercises.removeAt(oldIndex);
                    _exercises.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final ex = _exercises[index];
                  return Container(
                    key: ValueKey('${ex.name}_$index'),
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exercise Header & Delete
                        Row(
                          children: [
                            const Icon(Icons.drag_indicator,
                                color: AppColors.textMuted, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.name,
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    ex.muscleGroup,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.error, size: 20),
                              onPressed: () {
                                setState(() {
                                  _exercises.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: 12),

                        // Granular Set Tracking Inputs
                        Row(
                          children: [
                            // Target Sets
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TARGET SETS',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (ex.targetSets > 1) {
                                            setState(() => ex.targetSets--);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.cardElevated,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.remove,
                                              size: 16, color: AppColors.text),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          '${ex.targetSets}',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() => ex.targetSets++);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.cardElevated,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.add,
                                              size: 16, color: AppColors.text),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Target Reps
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TARGET REPS',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 36,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.inputBackground,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: TextFormField(
                                      initialValue: '${ex.targetReps}',
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                          color: AppColors.text, fontSize: 13),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      onChanged: (v) {
                                        ex.targetReps =
                                            int.tryParse(v) ?? ex.targetReps;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Rest Timer Selector
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'REST TIMER',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 36,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.inputBackground,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: DropdownButton<int>(
                                      value: ex.restTimeSeconds,
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      dropdownColor: AppColors.surface,
                                      style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 30, child: Text('30s')),
                                        DropdownMenuItem(
                                            value: 60, child: Text('60s')),
                                        DropdownMenuItem(
                                            value: 90, child: Text('90s')),
                                        DropdownMenuItem(
                                            value: 120, child: Text('2m')),
                                        DropdownMenuItem(
                                            value: 180, child: Text('3m')),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() =>
                                              ex.restTimeSeconds = val);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Exercise Note Input
                        TextFormField(
                          initialValue: ex.notes,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Notes: e.g. seat height 4, 3s eccentric...',
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
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),
            CustomButton(
              text: _isEditing ? 'Update Routine' : 'Create Routine',
              isLoading: routineProvider.isLoading,
              onPressed: _saveRoutine,
            ),
          ],
        ),
      ),
    );
  }
}
