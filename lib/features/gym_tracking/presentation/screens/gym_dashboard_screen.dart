import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/repositories/profile_repository.dart';
import '../../domain/entities/workout_template.dart';
import '../../domain/entities/workout_session.dart';
import '../providers/gym_provider.dart';
import '../providers/active_workout_provider.dart';
import '../../../food_tracking/presentation/providers/meal_provider.dart'; // contains aiServiceProvider
import 'template_form_screen.dart';
import 'exercises_library_screen.dart';
import 'exercise_detail_screen.dart';
import '../../domain/entities/exercise.dart';

class GymDashboardScreen extends ConsumerWidget {
  const GymDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWorkout = ref.watch(activeWorkoutProvider);
    final templatesAsync = ref.watch(workoutTemplatesProvider);
    final historyAsync = ref.watch(workoutHistoryProvider);
    final userId = ref.watch(currentUserProvider)?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Trening'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined, color: AppColors.primaryLight),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExercisesLibraryScreen()),
            ),
            tooltip: 'Biblioteka vježbi',
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppColors.secondary),
            onPressed: () => _showAiSplitGenerator(context, ref),
            tooltip: 'Generiraj AI Split',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Aktivni Trening Banner
              if (activeWorkout != null) ...[
                _buildActiveWorkoutBanner(context, ref, activeWorkout),
                const SizedBox(height: AppSpacing.lg),
              ],

              // 2. Quick Action - Start Workout
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                onPressed: () {
                  ref.read(activeWorkoutProvider.notifier).startWorkout();
                  context.push('/gym/active');
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  'Započni prazan trening',
                  style: AppTypography.labelLg.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 3. Moji Programi / Splitovi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Moji programi', style: AppTypography.h3),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TemplateFormScreen()),
                        ),
                        icon: const Icon(Icons.add, color: AppColors.primaryLight),
                        tooltip: 'Novi program',
                      ),
                      IconButton(
                        onPressed: () => _showAiSplitGenerator(context, ref),
                        icon: const Icon(Icons.auto_awesome, color: AppColors.secondary),
                        tooltip: 'Generiraj AI Split',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              templatesAsync.when(
                data: (templates) {
                  if (templates.isEmpty) {
                    return _buildEmptyState(
                      'Nemaš spremljenih programa.',
                      'Iskoristi naš AI generator za izradu savršenog splita treninga!',
                      onPressed: () => _showAiSplitGenerator(context, ref),
                      btnText: 'Generiraj AI Split',
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      return _buildTemplateCard(context, ref, userId, templates[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Greška: $err', style: AppTypography.body),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 4. Povijest Treninga
              Text('Povijest treninga', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              historyAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return _buildEmptyState(
                      'Još nemaš odrađenih treninga.',
                      'Započni svoj prvi trening i prati svoj napredak!',
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      return _buildSessionCard(context, ref, userId, sessions[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Greška: $err', style: AppTypography.body),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveWorkoutBanner(BuildContext context, WidgetRef ref, WorkoutSession session) {
    return GlassCard(
      borderColor: AppColors.primary,
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.primaryLight, size: 36),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trening u tijeku', style: AppTypography.label.copyWith(color: AppColors.primaryLight)),
                Text(session.name, style: AppTypography.h3),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(80, 36),
            ),
            onPressed: () => context.push('/gym/active'),
            child: const Text('Nastavi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, WidgetRef ref, String userId, WorkoutTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(
          color: template.isAiGenerated ? AppColors.secondary.withOpacity(0.3) : AppColors.glassStroke,
        ),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            if (template.isAiGenerated) ...[
              const Icon(Icons.auto_awesome, size: 16, color: AppColors.secondary),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(template.name, style: AppTypography.labelLg)),
          ],
        ),
        subtitle: template.description.isNotEmpty
            ? Text(template.description, style: AppTypography.caption)
            : null,
        childrenPadding: const EdgeInsets.all(AppSpacing.md),
        expandedAlignment: Alignment.topLeft,
        children: [
          ...template.exercises.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: InkWell(
                  onTap: () {
                    final ex = ref.read(allExercisesProvider).firstWhere(
                      (element) => element.name.toLowerCase() == e.exerciseName.toLowerCase(),
                      orElse: () => Exercise(id: e.exerciseId, name: e.exerciseName, muscleGroup: e.muscleGroup),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExerciseDetailScreen(exercise: ex)),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('${e.sets.length}S', style: AppTypography.caption.copyWith(color: AppColors.primaryLight)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.exerciseName,
                          style: AppTypography.bodySm.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryLight.withOpacity(0.4),
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 14, color: AppColors.textMuted),
                    ],
                  ),
                ),
              )),
          const Divider(color: AppColors.glassStroke, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TemplateFormScreen(template: template),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () {
                  _showDeleteConfirmDialog(context, 'program', () {
                    ref.read(gymRepositoryProvider).deleteTemplate(userId, template.id);
                  });
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.8),
                  minimumSize: const Size(100, 40),
                ),
                onPressed: () {
                  ref.read(activeWorkoutProvider.notifier).startWorkout(template: template);
                  context.push('/gym/active');
                },
                icon: const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                label: const Text('Pokreni', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, WidgetRef ref, String userId, WorkoutSession session) {
    final dateStr = DateFormat('dd.MM.yyyy HH:mm', 'hr').format(session.startTime);
    final durationMin = (session.durationSeconds / 60).round();

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
                    Text(session.name, style: AppTypography.labelLg),
                    Text(dateStr, style: AppTypography.caption),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                onPressed: () {
                  _showDeleteConfirmDialog(context, 'trening iz povijesti', () {
                    ref.read(gymRepositoryProvider).deleteSession(userId, session.id);
                  });
                },
              ),
            ],
          ),
          const Divider(color: AppColors.glassStroke, height: 16),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.timer_outlined, '$durationMin min', 'Trajanje'),
              _buildStatItem(Icons.fitness_center, '${session.totalVolume.toInt()} kg', 'Volumen'),
              _buildStatItem(Icons.local_fire_department, '${session.caloriesBurned} kcal', 'Potrošnja'),
            ],
          ),
          const SizedBox(height: 12),
          // Exercises Summary
          ...session.exercises.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: InkWell(
                  onTap: () {
                    final ex = ref.read(allExercisesProvider).firstWhere(
                      (element) => element.name.toLowerCase() == e.exerciseName.toLowerCase(),
                      orElse: () => Exercise(id: e.exerciseId, name: e.exerciseName, muscleGroup: e.muscleGroup),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExerciseDetailScreen(exercise: ex)),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: AppColors.primaryLight),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${e.exerciseName} (${e.sets.length} serija)',
                            style: AppTypography.caption.copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primaryLight.withOpacity(0.4),
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 12, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.secondary),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.label),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, {VoidCallback? onPressed, String? btnText}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          const Icon(Icons.info_outline, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(title, style: AppTypography.label, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTypography.bodySm, textAlign: TextAlign.center),
          if (onPressed != null && btnText != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                minimumSize: const Size(120, 44),
              ),
              onPressed: onPressed,
              icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
              label: Text(btnText, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String itemType, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: Text('Obriši $itemType?'),
        content: Text('Jesi li siguran/na da želiš trajno obrisati ovaj $itemType?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Odustani', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
            child: const Text('Obriši', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // AI Split Generator Sheet
  void _showAiSplitGenerator(BuildContext context, WidgetRef ref) {
    int days = 3;
    String equipment = 'Teretana (Full Gym)';
    String focus = 'Hipertrofija (Izgradnja mišića)';
    bool useCustomFocus = false;
    final customFocusController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassStroke,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text('AI Generator Treninga ⚡', style: AppTypography.h3),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Generiraj personalizirani plan treninga na temelju tvojih prehrambenih ciljeva i profila.',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.lg),

              if (isLoading) ...[
                const SizedBox(height: 40),
                const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
                const SizedBox(height: 16),
                Text(
                  'Gemini sastavlja tvoj program treninga...\n(Ovo može potrajati nekoliko sekundi)',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(color: AppColors.secondary),
                ),
                const SizedBox(height: 40),
              ] else ...[
                // Days selector
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Text('Koliko dana u tjednu želiš trenirati?', style: AppTypography.label),
                  ],
                ),
                const SizedBox(height: 8),
                 Row(
                  children: [2, 3, 4, 5].map((d) {
                    final isSelected = days == d;
                    String emoji = '⚡';
                    if (d == 2) emoji = '🧘';
                    if (d == 3) emoji = '⚡';
                    if (d == 4) emoji = '💪';
                    if (d == 5) emoji = '🔥';
                    return Expanded(
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        color: isSelected ? AppColors.secondary : AppColors.glassFill,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: isSelected ? AppColors.secondary : AppColors.glassStroke),
                        ),
                        child: InkWell(
                          onTap: () => setState(() => days = d),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(emoji, style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 2),
                                Text(
                                  '$d dana',
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Equipment selector
                Row(
                  children: [
                    const Icon(Icons.fitness_center, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Text('Dostupna oprema:', style: AppTypography.label),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: equipment,
                  dropdownColor: AppColors.backgroundCard,
                  decoration: InputDecoration(
                    fillColor: AppColors.glassFill,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: ['Teretana (Full Gym)', 'Kućna teretana (Bučice)', 'Samo vlastita težina (Calisthenics)']
                      .map((val) => DropdownMenuItem(value: val, child: Text(val, style: AppTypography.body)))
                      .toList(),
                  onChanged: (val) => setState(() => equipment = val!),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Custom focus switch
                Row(
                  children: [
                    const Icon(Icons.edit_note, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Text('Želim ručno opisati fokus', style: AppTypography.label),
                    const Spacer(),
                    Switch(
                      value: useCustomFocus,
                      activeColor: AppColors.secondary,
                      onChanged: (val) => setState(() => useCustomFocus = val),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (useCustomFocus) ...[
                  TextField(
                    controller: customFocusController,
                    decoration: InputDecoration(
                      hintText: 'Npr. kombinacija snage i hipertrofije, fokus na ramena i trbuh...',
                      hintStyle: AppTypography.caption,
                      fillColor: AppColors.glassFill,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    style: AppTypography.body,
                  ),
                ] else ...[
                  // Focus selector
                  DropdownButtonFormField<String>(
                    value: focus,
                    dropdownColor: AppColors.backgroundCard,
                    decoration: InputDecoration(
                      fillColor: AppColors.glassFill,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: ['Hipertrofija (Izgradnja mišića)', 'Snaga (Powerlifting)', 'Izdržljivost i Kondicija']
                        .map((val) => DropdownMenuItem(value: val, child: Text(val, style: AppTypography.body)))
                        .toList(),
                    onChanged: (val) => setState(() => focus = val!),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  label: const Text('Generiraj Program ✨', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    final finalFocus = useCustomFocus && customFocusController.text.trim().isNotEmpty
                        ? customFocusController.text.trim()
                        : focus;

                    setState(() => isLoading = true);
                    try {
                      final profile = ref.read(userProfileProvider).value;
                      if (profile == null) throw Exception('Profil nije učitan.');

                      final aiService = ref.read(aiServiceProvider);
                      final templates = await aiService.generateWorkoutTemplates(
                        profile: profile,
                        daysPerWeek: days,
                        equipment: equipment,
                        focus: finalFocus,
                      );

                      final repo = ref.read(gymRepositoryProvider);
                      final userId = ref.read(currentUserProvider)?.id ?? '';

                      for (var t in templates) {
                        await repo.saveTemplate(userId, t);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Uspješno generiran AI split! 🏋️'), backgroundColor: AppColors.success),
                        );
                      }
                    } catch (e) {
                      setState(() => isLoading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Greška pri generiranju: $e'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
