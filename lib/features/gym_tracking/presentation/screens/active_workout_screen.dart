import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/workout_exercise.dart';
import '../../domain/entities/workout_set.dart';
import '../providers/active_workout_provider.dart';
import '../widgets/exercise_picker.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  bool _showRestTimer = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = 90; // Default 90 seconds
      _showRestTimer = true;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining <= 1) {
        _stopRestTimer();
      } else {
        setState(() {
          _restSecondsRemaining--;
        });
      }
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _showRestTimer = false;
      _restSecondsRemaining = 0;
    });
  }

  void _adjustRestTime(int seconds) {
    setState(() {
      _restSecondsRemaining = (_restSecondsRemaining + seconds).clamp(0, 600);
      if (_restSecondsRemaining == 0) {
        _stopRestTimer();
      }
    });
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

    final secondsElapsed = session.durationSeconds;
    final isTimerPaused = session.isPaused;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.name, style: AppTypography.labelLg),
            Row(
              children: [
                Text(
                  'Trajanje: ${_formatDuration(secondsElapsed)}',
                  style: AppTypography.caption.copyWith(color: AppColors.secondary),
                ),
                if (isTimerPaused) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'PAUZIRANO',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.error,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isTimerPaused ? Icons.play_arrow : Icons.pause,
              color: isTimerPaused ? AppColors.success : AppColors.primaryLight,
            ),
            onPressed: () {
              ref.read(activeWorkoutProvider.notifier).togglePause();
            },
            tooltip: isTimerPaused ? 'Nastavi trening' : 'Pauziraj trening',
          ),
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
            _buildRestTimerBanner(),
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
                    final nextVal = !set.isCompleted;
                    ref.read(activeWorkoutProvider.notifier).updateSet(
                          ex.id,
                          set.id,
                          isCompleted: nextVal,
                        );
                    if (nextVal) {
                      _startRestTimer();
                    }
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
    showExercisePicker(context, ref, (exercise) {
      ref.read(activeWorkoutProvider.notifier).addExercise(exercise);
    });
  }

  Widget _buildRestTimerBanner() {
    if (!_showRestTimer) return const SizedBox.shrink();

    final progress = _restSecondsRemaining / 90.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withOpacity(0.95),
        border: const Border(
          top: BorderSide(color: AppColors.glassStroke),
          bottom: BorderSide(color: AppColors.glassStroke),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text('Vrijeme odmora', style: AppTypography.label),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _adjustRestTime(-15),
                    child: Text('-15s', style: AppTypography.bodySm.copyWith(color: AppColors.primaryLight)),
                  ),
                  TextButton(
                    onPressed: () => _adjustRestTime(15),
                    child: Text('+15s', style: AppTypography.bodySm.copyWith(color: AppColors.primaryLight)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.glassFill,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    onPressed: _stopRestTimer,
                    child: Text('Preskoči', style: AppTypography.bodySm.copyWith(color: AppColors.error)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.glassFill,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _formatDuration(_restSecondsRemaining),
                style: AppTypography.labelLg.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
