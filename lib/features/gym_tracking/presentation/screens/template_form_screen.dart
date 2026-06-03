import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout_exercise.dart';
import '../../domain/entities/workout_set.dart';
import '../../domain/entities/workout_template.dart';
import '../providers/gym_provider.dart';
import '../widgets/exercise_picker.dart';

class TemplateFormScreen extends ConsumerStatefulWidget {
  final WorkoutTemplate? template;

  const TemplateFormScreen({super.key, this.template});

  @override
  ConsumerState<TemplateFormScreen> createState() => _TemplateFormScreenState();
}

class _TemplateFormScreenState extends ConsumerState<TemplateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  List<WorkoutExercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _descController = TextEditingController(text: widget.template?.description ?? '');
    if (widget.template != null) {
      // Create fresh instances to avoid mutating the original until saved
      _exercises = widget.template!.exercises.map((e) => e.copyWith(
        sets: e.sets.map((s) => s.copyWith()).toList(),
      )).toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addExercise(Exercise exercise) {
    setState(() {
      _exercises.add(WorkoutExercise(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        muscleGroup: exercise.muscleGroup,
        sets: [
          WorkoutSet(reps: 10, weight: 0.0),
        ],
      ));
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _updateExerciseSets(int index, List<WorkoutSet> newSets) {
    setState(() {
      _exercises[index] = _exercises[index].copyWith(sets: newSets);
    });
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodaj barem jednu vježbu u program.')),
      );
      return;
    }

    final userId = ref.read(currentUserProvider)?.id ?? '';
    if (userId.isEmpty) return;

    final template = WorkoutTemplate(
      id: widget.template?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      exercises: _exercises,
      isAiGenerated: widget.template?.isAiGenerated ?? false,
      createdAt: widget.template?.createdAt,
    );

    try {
      await ref.read(gymRepositoryProvider).saveTemplate(userId, template);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.template == null
                  ? 'Program je uspješno kreiran!'
                  : 'Program je uspješno ažuriran!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri spremanju programa: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.template == null ? 'Novi program' : 'Uredi program',
          style: AppTypography.h3,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primaryLight, size: 28),
            onPressed: _saveTemplate,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Naziv programa (npr. Push Day)',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      style: AppTypography.body,
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Naziv je obavezan' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Opis ili fokus (npr. Ponedjeljak - prsa i ramena)',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      style: AppTypography.body,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Vježbe u programu', style: AppTypography.h3),
                  TextButton.icon(
                    onPressed: () {
                      showExercisePicker(context, ref, _addExercise);
                    },
                    icon: const Icon(Icons.add, size: 18, color: AppColors.primaryLight),
                    label: Text(
                      'Dodaj vježbu',
                      style: AppTypography.label.copyWith(color: AppColors.primaryLight),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_exercises.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Column(
                    children: [
                      const Icon(Icons.fitness_center, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'Još nemaš dodanih vježbi.',
                        style: AppTypography.label,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Klikni "Dodaj vježbu" iznad i sastavi svoj plan.',
                        style: AppTypography.bodySm,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TemplateExerciseItem(
                        key: ValueKey(exercise.id),
                        exercise: exercise,
                        onDelete: () => _removeExercise(index),
                        onUpdateSets: (newSets) => _updateExerciseSets(index, newSets),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveTemplate,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('Spremi program', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class TemplateExerciseItem extends StatefulWidget {
  final WorkoutExercise exercise;
  final VoidCallback onDelete;
  final Function(List<WorkoutSet>) onUpdateSets;

  const TemplateExerciseItem({
    super.key,
    required this.exercise,
    required this.onDelete,
    required this.onUpdateSets,
  });

  @override
  State<TemplateExerciseItem> createState() => _TemplateExerciseItemState();
}

class _TemplateExerciseItemState extends State<TemplateExerciseItem> {
  late List<WorkoutSet> _sets;

  @override
  void initState() {
    super.initState();
    _sets = List.from(widget.exercise.sets);
  }

  void _addSet() {
    setState(() {
      final defaultWeight = _sets.isNotEmpty ? _sets.last.weight : 0.0;
      final defaultReps = _sets.isNotEmpty ? _sets.last.reps : 10;
      _sets.add(WorkoutSet(weight: defaultWeight, reps: defaultReps));
      widget.onUpdateSets(_sets);
    });
  }

  void _removeSet(int index) {
    if (_sets.length <= 1) {
      // Keep at least one set or user can delete the exercise
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vježba mora imati barem jednu seriju. Za brisanje vježbe, klikni kantu gore desno.')),
      );
      return;
    }
    setState(() {
      _sets.removeAt(index);
      widget.onUpdateSets(_sets);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.exercise.exerciseName, style: AppTypography.labelLg),
                    const SizedBox(height: 2),
                    Text(
                      widget.exercise.muscleGroup,
                      style: AppTypography.caption.copyWith(color: AppColors.primaryLight),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: widget.onDelete,
              ),
            ],
          ),
          const Divider(color: AppColors.glassStroke, height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const SizedBox(width: 40, child: Text('SERIJA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                const Expanded(
                  child: Text('TEŽINA (kg)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted), textAlign: TextAlign.center),
                ),
                const Expanded(
                  child: Text('PONAVLJANJA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted), textAlign: TextAlign.center),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sets.length,
            itemBuilder: (context, index) {
              final set = _sets[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.glassFill,
                          child: Text(
                            '${index + 1}',
                            style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextFormField(
                          initialValue: set.weight == 0 ? '' : set.weight.toString(),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            fillColor: AppColors.glassFill,
                            filled: true,
                            hintText: '0.0',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          style: AppTypography.body,
                          onChanged: (val) {
                            final weight = double.tryParse(val) ?? 0.0;
                            _sets[index] = _sets[index].copyWith(weight: weight);
                            widget.onUpdateSets(_sets);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextFormField(
                          initialValue: set.reps == 0 ? '' : set.reps.toString(),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            fillColor: AppColors.glassFill,
                            filled: true,
                            hintText: '0',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          style: AppTypography.body,
                          onChanged: (val) {
                            final reps = int.tryParse(val) ?? 0;
                            _sets[index] = _sets[index].copyWith(reps: reps);
                            widget.onUpdateSets(_sets);
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                        onPressed: () => _removeSet(index),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _addSet,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.add, size: 16, color: AppColors.primaryLight),
            label: Text(
              'Dodaj seriju',
              style: AppTypography.label.copyWith(fontSize: 12, color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }
}
