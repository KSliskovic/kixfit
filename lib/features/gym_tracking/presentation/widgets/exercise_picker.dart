import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/exercise.dart';
import '../providers/gym_provider.dart';

void showExercisePicker(
  BuildContext context,
  WidgetRef ref,
  Function(Exercise) onSelected,
) {
  String searchQuery = '';
  String selectedMuscle = 'Sve';
  String selectedEquipment = 'Sve';

  final List<String> muscles = [
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

  final List<String> equipments = [
    'Sve',
    'Barbell',
    'Dumbbell',
    'Machine',
    'Cable',
    'Bodyweight',
    'Kettlebell',
    'Other'
  ];
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final exercises = ref.watch(allExercisesProvider);
        final filtered = exercises.where((ex) {
          final query = searchQuery.toLowerCase();
          final matchesSearch = ex.name.toLowerCase().contains(query) ||
              ex.muscleGroup.toLowerCase().contains(query);
          final matchesMuscle = selectedMuscle == 'Sve' ||
              ex.muscleGroup.toLowerCase() == selectedMuscle.toLowerCase();
          final matchesEquipment = selectedEquipment == 'Sve' ||
              ex.equipment.toLowerCase() == selectedEquipment.toLowerCase();
          return matchesSearch && matchesMuscle && matchesEquipment;
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
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.glassStroke,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Pretraži vježbe...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (val) => setState(() => searchQuery = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Muscle group chips
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: muscles.length,
                    itemBuilder: (context, index) {
                      final muscle = muscles[index];
                      final isSelected = selectedMuscle == muscle;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(muscle),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.glassFill,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.glassStroke,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => selectedMuscle = muscle);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),

                // Equipment chips
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: equipments.length,
                    itemBuilder: (context, index) {
                      final eq = equipments[index];
                      final isSelected = selectedEquipment == eq;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(eq),
                          selected: isSelected,
                          selectedColor: AppColors.secondary,
                          backgroundColor: AppColors.glassFill,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: isSelected ? AppColors.secondary : AppColors.glassStroke,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => selectedEquipment = eq);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Vježbe', style: AppTypography.label),
                    TextButton.icon(
                      onPressed: () => _showCreateCustomExerciseDialog(context, ref, (newExercise) {
                        setState(() {
                          // Force local build refresh
                        });
                        onSelected(newExercise);
                        Navigator.pop(context); // Close picker
                      }),
                      icon: const Icon(Icons.add, size: 16, color: AppColors.secondary),
                      label: Text(
                        'Kreiraj vježbu',
                        style: AppTypography.label.copyWith(color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                          onSelected(ex);
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

void _showCreateCustomExerciseDialog(
  BuildContext context,
  WidgetRef ref,
  Function(Exercise) onCreated,
) {
  final nameController = TextEditingController();
  String selectedMuscle = 'Prsa';
  String selectedEquipment = 'Barbell';

  final muscleGroups = ['Prsa', 'Leđa', 'Ramena', 'Noge', 'Ruke', 'Trbuh', 'Kardio', 'Drugo'];
  final equipments = ['Barbell', 'Dumbbell', 'Machine', 'Cable', 'Bodyweight', 'Kettlebell', 'Other'];

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: Text('Kreiraj vlastitu vježbu', style: AppTypography.h3),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Naziv vježbe', style: AppTypography.caption),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'npr. Čučanj s girjom',
                ),
                style: AppTypography.body,
              ),
              const SizedBox(height: 16),
              Text('Mišićna skupina', style: AppTypography.caption),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedMuscle,
                dropdownColor: AppColors.backgroundCard,
                decoration: const InputDecoration(),
                items: muscleGroups
                    .map((m) => DropdownMenuItem(value: m, child: Text(m, style: AppTypography.body)))
                    .toList(),
                onChanged: (val) => setState(() => selectedMuscle = val!),
              ),
              const SizedBox(height: 16),
              Text('Oprema', style: AppTypography.caption),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedEquipment,
                dropdownColor: AppColors.backgroundCard,
                decoration: const InputDecoration(),
                items: equipments
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTypography.body)))
                    .toList(),
                onChanged: (val) => setState(() => selectedEquipment = val!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Odustani', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(80, 36),
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final userId = ref.read(currentUserProvider)?.id ?? '';
              if (userId.isEmpty) return;

              final exercise = Exercise(
                id: 'custom_${const Uuid().v4()}',
                name: name,
                muscleGroup: selectedMuscle,
                equipment: selectedEquipment,
              );

              await ref.read(gymRepositoryProvider).saveCustomExercise(userId, exercise);
              onCreated(exercise);
              Navigator.pop(context);
            },
            child: const Text('Spremi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}
