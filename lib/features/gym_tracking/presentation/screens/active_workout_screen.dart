import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/default_exercises.dart';
import '../../domain/entities/workout_exercise.dart';
import '../../domain/entities/workout_set.dart';
import '../providers/active_workout_provider.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    // Pokreni tajmer
    final session = ref.read(activeWorkoutProvider);
    if (session != null) {
      _secondsElapsed = DateTime.now().difference(session.startTime).inSeconds;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final hrs = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    final hrsStr = hrs > 0 ? '${hrs.toString().padLeft(2, '0')}:' : '';
    final minsStr = mins.toString().padLeft(2, '0');
    final secsStr = secs.toString().padLeft(2, '0');

    return '$hrsStr$minsStr:$secsStr';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeWorkoutProvider);
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trening')),
        body: const Center(
          child: Text('Nema aktivnog treninga.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.name, style: AppTypography.labelLg),
            Text(
              'Trajanje: ${_formatDuration(_secondsElapsed)}',
              style: AppTypography.caption.copyWith(color: AppColors.secondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _showCancelDialog(context),
            child: const Text('Odustani', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                itemCount: session.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = session.exercises[index];
                  return _buildWorkoutExerciseCard(exercise);
                },
              ),
            ),
            _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutExerciseCard(WorkoutExercise ex) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      color: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColors.glassStroke),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex.exerciseName, style: AppTypography.labelLg),
                      Text(ex.muscleGroup, style: AppTypography.caption.copyWith(color: AppColors.primaryLight)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: AppColors.textMuted),
                  onPressed: () => _showExerciseOptions(context, ex),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Sets Table Header
            Row(
              children: [
                SizedBox(width: 40, child: Text('SERIJA', style: AppTypography.caption, textAlign: TextAlign.center)),
                Expanded(child: Text('KG', style: AppTypography.caption, textAlign: TextAlign.center)),
                Expanded(child: Text('REPS', style: AppTypography.caption, textAlign: TextAlign.center)),
                SizedBox(width: 50, child: Text('GOTOVO', style: AppTypography.caption, textAlign: TextAlign.center)),
              ],
            ),
            const Divider(color: AppColors.glassStroke),

            // Sets List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ex.sets.length,
              itemBuilder: (context, sIndex) {
                final set = ex.sets[sIndex];
                return _buildSetRow(ex, set, sIndex);
              },
            ),

            // Add Set Button
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                ref.read(activeWorkoutProvider.notifier).addSetToExercise(ex.id);
              },
              icon: const Icon(Icons.add, size: 16, color: AppColors.primaryLight),
              label: Text('Dodaj seriju', style: AppTypography.label.copyWith(color: AppColors.primaryLight, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(WorkoutExercise ex, WorkoutSet set, int index) {
    final weightController = TextEditingController(text: set.weight > 0 ? set.weight.toString() : '');
    final repsController = TextEditingController(text: set.reps > 0 ? set.reps.toString() : '');

    // Postavljanje kursora na kraj unosa
    weightController.selection = TextSelection.fromPosition(TextPosition(offset: weightController.text.length));
    repsController.selection = TextSelection.fromPosition(TextPosition(offset: repsController.text.length));

    return Dismissible(
      key: Key(set.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(activeWorkoutProvider.notifier).removeSet(ex.id, set.id);
      },
      child: Container(
        color: set.isCompleted ? AppColors.success.withOpacity(0.08) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            // Set Number
            SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTypography.label.copyWith(
                    color: set.isCompleted ? AppColors.success : Colors.white,
                  ),
                ),
              ),
            ),

            // Weight input
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    hintText: '0',
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onChanged: (val) {
                    final weight = double.tryParse(val) ?? 0.0;
                    ref.read(activeWorkoutProvider.notifier).updateSet(ex.id, set.id, weight: weight);
                  },
                ),
              ),
            ),

            // Reps input
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    hintText: '0',
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onChanged: (val) {
                    final reps = int.tryParse(val) ?? 0;
                    ref.read(activeWorkoutProvider.notifier).updateSet(ex.id, set.id, reps: reps);
                  },
                ),
              ),
            ),

            // Checkbox
            SizedBox(
              width: 50,
              child: Center(
                child: IconButton(
                  icon: Icon(
                    set.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                    color: set.isCompleted ? AppColors.success : AppColors.textMuted,
                  ),
                  onPressed: () {
                    ref.read(activeWorkoutProvider.notifier).updateSet(
                          ex.id,
                          set.id,
                          isCompleted: !set.isCompleted,
                        );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(top: BorderSide(color: AppColors.glassStroke)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.glassFill,
                  side: const BorderSide(color: AppColors.glassStroke),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _showAddExerciseModal(context),
                icon: const Icon(Icons.add, color: AppColors.primaryLight),
                label: const Text('Dodaj vježbu', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _finishWorkout(context),
                child: const Text('Završi trening', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finishWorkout(BuildContext context) async {
    try {
      await ref.read(activeWorkoutProvider.notifier).finishWorkout();
      if (context.mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trening spremljen! Odličan posao!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri spremanju: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Prekini trening?'),
        content: const Text('Sav napredak iz ovog treninga će biti odbačen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nastavi trenirati', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              ref.read(activeWorkoutProvider.notifier).cancelWorkout();
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Prekini', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showExerciseOptions(BuildContext context, WorkoutExercise ex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Ukloni vježbu s treninga', style: TextStyle(color: AppColors.error)),
              onTap: () {
                ref.read(activeWorkoutProvider.notifier).removeExercise(ex.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Zatvori'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExerciseModal(BuildContext context) {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final filtered = defaultExercises.where((ex) {
            return ex.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                ex.muscleGroup.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) => Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: AppColors.glassStroke, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Pretraži vježbe po nazivu ili mišićnoj grupi...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => setState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final ex = filtered[index];
                        return ListTile(
                          title: Text(ex.name),
                          subtitle: Text('${ex.muscleGroup} • ${ex.equipment}'),
                          trailing: const Icon(Icons.add, color: AppColors.primaryLight),
                          onTap: () {
                            ref.read(activeWorkoutProvider.notifier).addExercise(ex);
                            Navigator.pop(context);
                          },
                        );
                      },
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
}
