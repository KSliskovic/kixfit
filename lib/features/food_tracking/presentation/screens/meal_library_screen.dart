import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/meal_provider.dart';
import '../../domain/entities/nutrition_info.dart';

class MealLibraryScreen extends ConsumerStatefulWidget {
  const MealLibraryScreen({super.key});

  @override
  ConsumerState<MealLibraryScreen> createState() => _MealLibraryScreenState();
}

class _MealLibraryScreenState extends ConsumerState<MealLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Niste prijavljeni')));
    }

    final recentMealsAsync = ref.watch(recentMealsProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: Text('Moja česta jela', style: AppTypography.h3),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Pretraži povijest obroka...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: recentMealsAsync.when(
                data: (meals) {
                  final filteredMeals = meals.where((m) => 
                    m.mealName.toLowerCase().contains(_searchQuery)
                  ).toList();

                  if (filteredMeals.isEmpty) {
                    return const Center(child: Text('Nema pronađenih jela', style: TextStyle(color: AppColors.textSecondary)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: filteredMeals.length,
                    itemBuilder: (context, index) {
                      final meal = filteredMeals[index];
                      return _buildMealCard(context, meal);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, _) => Center(child: Text('Greška: $err', style: const TextStyle(color: AppColors.error))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, NutritionInfo meal) {
    final String heroTag = 'meal_image_${meal.id ?? meal.mealName}';
    
    return GestureDetector(
      onTap: () => context.push('/meal-detail', extra: meal),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              // Slika ili lijepi Placeholder
              Hero(
                tag: heroTag,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSpacing.radiusMd),
                      bottomLeft: Radius.circular(AppSpacing.radiusMd),
                    ),
                    gradient: meal.imageUrl == null
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withOpacity(0.3),
                              AppColors.secondary.withOpacity(0.3),
                            ],
                          )
                        : null,
                    color: meal.imageUrl == null ? null : AppColors.backgroundDeep,
                  ),
                  child: meal.imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppSpacing.radiusMd),
                            bottomLeft: Radius.circular(AppSpacing.radiusMd),
                          ),
                          child: Image.network(
                            meal.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: AppColors.primaryLight, size: 40),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.restaurant, size: 40, color: AppColors.primaryLight),
                        ),
                ),
              ),
              // Detalji
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meal.mealName, style: AppTypography.h4, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text('${meal.calories} kcal', style: AppTypography.label.copyWith(color: AppColors.primaryLight)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildMacroBadge('P', meal.protein, AppColors.macroProtein),
                          const SizedBox(width: 8),
                          _buildMacroBadge('U', meal.carbs, AppColors.macroCarbs),
                          const SizedBox(width: 8),
                          _buildMacroBadge('M', meal.fat, AppColors.macroFat),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Icon(Icons.chevron_right, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroBadge(String label, double value, Color color) {
    return Row(
      children: [
        Text('$label:', style: AppTypography.caption.copyWith(color: Colors.white54)),
        const SizedBox(width: 2),
        Text('${value.toInt()}g', style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
