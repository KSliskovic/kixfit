import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout_exercise.dart';
import '../providers/gym_provider.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  double _calculateOneRepMax(double weight, int reps) {
    if (reps <= 0) return 0.0;
    if (reps == 1) return weight;
    // Epley formula
    return weight * (1 + reps / 30.0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name, style: AppTypography.h3),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: historyAsync.when(
          data: (sessions) {
            // Find all instances of this exercise in history
            final List<Map<String, dynamic>> occurrences = [];
            double maxWeight = 0.0;
            double maxOneRepMax = 0.0;
            int maxReps = 0;

            for (var session in sessions) {
              final exercises = session.exercises.where((e) =>
                  e.exerciseId == exercise.id ||
                  e.exerciseName.toLowerCase() == exercise.name.toLowerCase());
              
              for (var ex in exercises) {
                occurrences.add({
                  'date': session.startTime,
                  'sessionName': session.name,
                  'exercise': ex,
                });

                for (var set in ex.sets) {
                  if (set.weight > maxWeight) {
                    maxWeight = set.weight;
                  }
                  if (set.reps > maxReps) {
                    maxReps = set.reps;
                  }
                  final orm = _calculateOneRepMax(set.weight, set.reps);
                  if (orm > maxOneRepMax) {
                    maxOneRepMax = orm;
                  }
                }
              }
            }

            // Sort occurrences by date descending
            occurrences.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Info Badges
                  Row(
                    children: [
                      _buildBadge(exercise.muscleGroup, AppColors.primaryLight),
                      const SizedBox(width: 8),
                      _buildBadge(exercise.equipment, AppColors.secondary),
                      const SizedBox(width: 8),
                      _buildBadge(exercise.type == 'strength' ? 'Snaga' : 'Kardio', AppColors.accent),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 2. Personal Records Card
                  if (occurrences.isNotEmpty) ...[
                    Text('Osobni rekordi (PR)', style: AppTypography.h3),
                    const SizedBox(height: 12),
                    GlassCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPRStat('Maks. Težina', '${maxWeight.toStringAsFixed(1)} kg'),
                          _buildPRStat('Maks. Reps', '$maxReps pon.'),
                          _buildPRStat('Procijenjeni 1RM', '${maxOneRepMax.toStringAsFixed(1)} kg'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 3. Exercise Description / Instructions
                  Text('Upute za izvođenje', style: AppTypography.h3),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.description.isNotEmpty
                              ? exercise.description
                              : 'Pravilna forma je ključna. Fokusiraj se na kontrolirani pokret kroz cijeli opseg pokreta (ROM). Zadrži napetost u ciljanom mišiću i izbjegavaj korištenje inercije.',
                          style: AppTypography.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. History
                  Text('Povijest izvedbe', style: AppTypography.h3),
                  const SizedBox(height: 12),
                  if (occurrences.isEmpty)
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.history, size: 40, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'Još nemaš zabilježene povijesti za ovu vježbu.',
                            style: AppTypography.label,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tvoji prošli treninzi će se pojaviti ovdje.',
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
                      itemCount: occurrences.length,
                      itemBuilder: (context, index) {
                        final occ = occurrences[index];
                        final dateStr = DateFormat('dd.MM.yyyy.', 'hr').format(occ['date'] as DateTime);
                        final ex = occ['exercise'] as WorkoutExercise;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: AppColors.backgroundCard,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.glassStroke),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        occ['sessionName'] as String,
                                        style: AppTypography.label,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      dateStr,
                                      style: AppTypography.bodySm.copyWith(color: AppColors.primaryLight),
                                    ),
                                  ],
                                ),
                                const Divider(color: AppColors.glassStroke, height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 6,
                                  children: ex.sets.asMap().entries.map((entry) {
                                    final i = entry.key;
                                    final set = entry.value;
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.glassFill,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'S${i + 1}: ${set.weight.toStringAsFixed(1)} kg x ${set.reps}',
                                        style: AppTypography.bodySm,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, _) => Center(
            child: Text('Greška: $err', style: AppTypography.body),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPRStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelLg.copyWith(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
