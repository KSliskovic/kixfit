import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/gym_provider.dart';
import 'exercise_detail_screen.dart';

class ExercisesLibraryScreen extends ConsumerStatefulWidget {
  const ExercisesLibraryScreen({super.key});

  @override
  ConsumerState<ExercisesLibraryScreen> createState() => _ExercisesLibraryScreenState();
}

class _ExercisesLibraryScreenState extends ConsumerState<ExercisesLibraryScreen> {
  String _searchQuery = '';
  String _selectedMuscle = 'Sve';

  final List<String> _muscles = [
    'Sve',
    'Prsa',
    'Leđa',
    'Ramena',
    'Noge',
    'Ruke',
    'Trbuh',
    'Kardio',
    'Drugo'
  ];

  void _showDeleteConfirmDialog(BuildContext context, String name, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Obriši vježbu?'),
        content: Text('Jesi li siguran/na da želiš trajno obrisati vježbu "$name"?'),
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

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(allExercisesProvider);

    final filtered = exercises.where((ex) {
      final matchesSearch = ex.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ex.muscleGroup.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesMuscle = _selectedMuscle == 'Sve' ||
          ex.muscleGroup.toLowerCase() == _selectedMuscle.toLowerCase();
      return matchesSearch && matchesMuscle;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteka vježbi'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: Column(
          children: [
            // 1. Search Bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Pretraži vježbe...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  fillColor: AppColors.glassFill,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.glassStroke),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.glassStroke),
                  ),
                ),
                style: AppTypography.body,
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            // 2. Muscle Group Selector Chips
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: _muscles.length,
                itemBuilder: (context, index) {
                  final muscle = _muscles[index];
                  final isSelected = _selectedMuscle == muscle;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(muscle),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.glassFill,
                      labelStyle: AppTypography.caption.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.glassStroke,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedMuscle = muscle);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // 3. Exercise List
            Expanded(
              child: filtered.isEmpty
                   ? Center(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           const Icon(Icons.fitness_center, size: 48, color: AppColors.textMuted),
                           const SizedBox(height: 12),
                           Text('Nema pronađenih vježbi.', style: AppTypography.label),
                         ],
                       ),
                     )
                   : ListView.builder(
                       padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                       itemCount: filtered.length,
                       itemBuilder: (context, index) {
                         final ex = filtered[index];
                         return Card(
                           margin: const EdgeInsets.only(bottom: 10),
                           color: AppColors.backgroundCard,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(12),
                             side: const BorderSide(color: AppColors.glassStroke),
                           ),
                           child: ListTile(
                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                             title: Text(ex.name, style: AppTypography.label),
                             subtitle: Text(
                               '${ex.muscleGroup} • ${ex.equipment}',
                               style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
                             ),
                             trailing: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 if (ex.id.startsWith('custom_')) ...[
                                   IconButton(
                                     icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                     onPressed: () {
                                       _showDeleteConfirmDialog(context, ex.name, () async {
                                         final userId = ref.read(currentUserProvider)?.id ?? '';
                                         if (userId.isNotEmpty) {
                                           await ref.read(gymRepositoryProvider).deleteCustomExercise(userId, ex.id);
                                         }
                                       });
                                     },
                                   ),
                                   const SizedBox(width: 4),
                                 ],
                                 const Icon(
                                   Icons.arrow_forward_ios,
                                   size: 14,
                                   color: AppColors.textMuted,
                                 ),
                               ],
                             ),
                             onTap: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => ExerciseDetailScreen(exercise: ex),
                                 ),
                               );
                             },
                           ),
                         );
                       },
                     ),
             ),
           ],
         ),
       ),
     );
   }
 }
