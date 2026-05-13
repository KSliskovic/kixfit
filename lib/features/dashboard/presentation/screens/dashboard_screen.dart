import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/repositories/profile_repository.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../../features/food_tracking/presentation/providers/meal_provider.dart';
import '../../../../features/food_tracking/domain/entities/nutrition_info.dart';
import '../../../../features/water_tracking/presentation/providers/water_provider.dart';
import '../widgets/macro_ring.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final mealsAsync = user != null ? ref.watch(todayMealsProvider(user.id)) : const AsyncValue.data(<NutritionInfo>[]);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: mealsAsync.when(
            data: (meals) => profileAsync.when(
              data: (profile) => _buildContent(context, ref, meals, profile, profile?.displayName ?? 'Korisnik', user?.id ?? ''),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Greška profila: $err')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Greška obroka: $err')),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => context.push('/food-entry'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, size: 36, color: Colors.white),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<NutritionInfo> meals, UserProfile? profile, String name, String userId) {
    int totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalSugar = 0;
    double totalFiber = 0;
    double totalSodium = 0;
    double totalSaturatedFat = 0;
    double totalCholesterol = 0;
    double totalTransFat = 0;

    final Map<String, List<NutritionInfo>> groupedMeals = {
      'Doručak': [],
      'Ručak': [],
      'Večera': [],
      'Snack': [],
    };

    for (var meal in meals) {
      totalCalories += meal.calories;
      totalProtein += meal.protein;
      totalCarbs += meal.carbs;
      totalFat += meal.fat;
      totalSugar += meal.sugar;
      totalFiber += meal.fiber;
      totalSodium += meal.sodium;
      totalSaturatedFat += meal.saturatedFat;
      totalCholesterol += meal.cholesterol;
      totalTransFat += meal.transFat;
      
      if (groupedMeals.containsKey(meal.category)) {
        groupedMeals[meal.category]!.add(meal);
      } else {
        groupedMeals['Snack']!.add(meal);
      }
    }

    final targetCals = profile?.dailyCaloriesTarget ?? 2000;
    final todayStr = DateFormat('EEEE, d. MMMM', 'hr').format(DateTime.now());
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, name),
          const SizedBox(height: AppSpacing.sm),
          Text(todayStr.toUpperCase(), style: AppTypography.label.copyWith(color: AppColors.secondary)),
          const SizedBox(height: AppSpacing.lg),
          
          _buildCoachCard(profile, meals, totalCalories, targetCals),
          const SizedBox(height: AppSpacing.xl),
          
          GestureDetector(
            onLongPress: () => _showDetailedMacros(
              context, 
              profile,
              totalProtein, totalCarbs, totalFat, 
              totalSugar, totalFiber, totalSodium, totalSaturatedFat,
              totalCholesterol, totalTransFat,
            ),
            child: _buildMacroSection(totalCalories, targetCals, totalProtein, totalCarbs, totalFat),
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildAIRecommendationButton(context, totalCalories, totalProtein, totalCarbs, totalFat),
          const SizedBox(height: AppSpacing.xl),
          
          _buildWaterSection(context, ref, profile, userId),
          const SizedBox(height: AppSpacing.xl),
          
          Text('Današnji obroci', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          
          _buildCategorySection(context, ref, userId, 'Doručak', groupedMeals['Doručak']!),
          _buildCategorySection(context, ref, userId, 'Ručak', groupedMeals['Ručak']!),
          _buildCategorySection(context, ref, userId, 'Večera', groupedMeals['Večera']!),
          _buildCategorySection(context, ref, userId, 'Snack', groupedMeals['Snack']!),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showDetailedMacros(
    BuildContext context, 
    UserProfile? profile,
    double p, double c, double f, 
    double s, double fiber, double sod, double sf,
    double chol, double trans,
  ) {
    // Ako profil nije učitan, koristimo defaultne vrijednosti
    final sugarLimit = profile?.sugarTarget ?? 50.0;
    final fiberTarget = profile?.fiberTarget ?? 30.0;
    final sodiumLimit = profile?.sodiumTarget ?? 2300.0;
    final satFatLimit = profile?.saturatedFatTarget ?? 22.0;
    final cholLimit = profile?.cholesterolTarget ?? 300.0;
    final transLimit = profile?.transFatTarget ?? 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4, 
                  decoration: BoxDecoration(color: AppColors.glassStroke, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Detaljni nutritivni status', style: AppTypography.h3),
              Text('Ciljevi izračunati prema tvom profilu', style: AppTypography.caption),
              const SizedBox(height: AppSpacing.xl),
              
              _buildDetailRow('Proteini', '${p.toInt()}g', AppColors.macroProtein),
              _buildDetailRow('Ugljikohidrati', '${c.toInt()}g', AppColors.macroCarbs),
              _buildDetailRow('Masti', '${f.toInt()}g', AppColors.macroFat),
              const Divider(color: AppColors.glassStroke, height: 32),
              
              _buildDetailRow(
                'Šećeri', 
                '${s.toInt()}g / ${sugarLimit.toInt()}g', 
                s > sugarLimit ? AppColors.error : Colors.orange,
                subtitle: s > sugarLimit ? 'Pazi, previše šećera!' : 'U granicama normale',
              ),
              _buildDetailRow(
                'Vlakna', 
                '${fiber.toInt()}g / ${fiberTarget.toInt()}g', 
                fiber >= fiberTarget ? AppColors.success : Colors.green,
                subtitle: fiber >= fiberTarget ? 'Odličan unos vlakana!' : 'Pokušaj unijeti više povrća',
              ),
              _buildDetailRow(
                'Zasićene masti', 
                '${sf.toInt()}g / ${satFatLimit.toInt()}g', 
                sf > satFatLimit ? AppColors.error : Colors.redAccent,
                subtitle: sf > satFatLimit ? 'Smanji unos masnog mesa/sira' : 'U granicama normale',
              ),
              _buildDetailRow(
                'Natrij', 
                '${sod.toInt()}mg / ${sodiumLimit.toInt()}mg', 
                sod > sodiumLimit ? AppColors.error : Colors.blueGrey,
                subtitle: sod > sodiumLimit ? 'Pazi na sol!' : 'U granicama normale',
              ),
              _buildDetailRow(
                'Kolesterol', 
                '${chol.toInt()}mg / ${cholLimit.toInt()}mg', 
                chol > cholLimit ? AppColors.error : Colors.brown,
                subtitle: chol > cholLimit ? 'Pazi na životinjske masnoće' : 'U granicama normale',
              ),
              _buildDetailRow(
                'Trans-masti', 
                '${trans.toInt()}g', 
                trans > transLimit ? AppColors.error : AppColors.success,
                subtitle: trans > transLimit ? 'Izbjegavaj prženu/procesiranu hranu!' : 'Izvrsno, nema loših masti',
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              AppButton(text: 'Zatvori', onPressed: () => Navigator.pop(context)),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Text(label, style: AppTypography.body),
              const Spacer(),
              Text(value, style: AppTypography.labelLg.copyWith(color: color)),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 4),
              child: Text(subtitle, style: AppTypography.caption.copyWith(color: color.withOpacity(0.7))),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, WidgetRef ref, String userId, String title, List<NutritionInfo> categoryMeals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Text(title, style: AppTypography.labelLg.copyWith(color: AppColors.primaryLight)),
              const SizedBox(width: 8),
              Expanded(child: Divider(color: AppColors.glassStroke)),
            ],
          ),
        ),
        if (categoryMeals.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
            child: Text('Nema unosa', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
          )
        else
          ...categoryMeals.map((meal) => _buildMealItem(context, ref, userId, meal)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zdravo, $name!', style: AppTypography.h2),
            Text('Tvoj AI trener je spreman.', style: AppTypography.bodySm),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => context.push('/restaurants'),
              icon: const Icon(Icons.restaurant_menu, color: AppColors.primaryLight),
              tooltip: 'Pronađi fit restorane',
            ),
            IconButton(
              onPressed: () => context.push('/stats'),
              icon: const Icon(Icons.bar_chart, color: AppColors.primaryLight),
            ),
            IconButton(
              onPressed: () => context.push('/profile'),
              icon: const Icon(Icons.person_outline, color: AppColors.primaryLight),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoachCard(UserProfile? profile, List<NutritionInfo> meals, int total, int target) {
    String message = "Spreman sam da analiziram tvoj dan! Unesi svoj prvi obrok.";
    if (meals.isNotEmpty) {
      if (total < target * 0.5) {
        message = "Na dobrom si putu! Pazi na unos proteina, to je ključno za tvoj oporavak.";
      } else if (total > target) {
        message = "Malo smo premašili kalorije danas. Pokušaj sa laganom šetnjom večeras.";
      } else {
        message = "Odličan balans! Tvoj profil se savršeno uklapa u današnji meni.";
      }
    }
    
    if (profile?.medicalConditions.contains('MS') ?? false) {
      message += " S obzirom na tvoje stanje, fokusiraj se na anti-inflamatorne namirnice.";
    }

    return GlassCard(
      gradient: LinearGradient(
        colors: [AppColors.primary.withOpacity(0.2), AppColors.secondary.withOpacity(0.1)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.auto_awesome, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SAVJET TRENERA', style: AppTypography.label.copyWith(color: AppColors.primaryLight)),
                const SizedBox(height: 4),
                Text(message, style: AppTypography.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendationButton(BuildContext context, int calories, double protein, double carbs, double fat) {
    return GestureDetector(
      onTap: () => context.push('/recommendations', extra: {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      }),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.8),
              AppColors.secondary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              'Što da pojedem sljedeće?',
              style: AppTypography.label.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroSection(int total, int target, double p, double c, double f) {
    final remaining = target - total;
    final isExceeded = remaining < 0;

    return GlassCard(
      child: Column(
        children: [
          MacroRing(
            size: 150,
            strokeWidth: 12,
            progress: total / target,
            color: isExceeded ? AppColors.error : AppColors.primary,
            label: isExceeded ? 'kcal premašeno' : 'kcal preostalo',
            value: isExceeded ? '$remaining' : '$remaining',
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallMacro('Protein', p, 150, p > 150 ? AppColors.error : AppColors.macroProtein, Icons.fitness_center),
              _buildSmallMacro('Ugljik.', c, 250, c > 250 ? AppColors.error : AppColors.macroCarbs, Icons.bolt),
              _buildSmallMacro('Masti', f, 70, f > 70 ? AppColors.error : AppColors.macroFat, Icons.water_drop),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMacro(String label, double val, double target, Color color, IconData icon) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: val / target,
                backgroundColor: color.withOpacity(0.1),
                color: color,
                strokeWidth: 6,
              ),
            ),
            Icon(icon, size: 18, color: color),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTypography.caption),
        Text('${val.toInt()}g', style: AppTypography.label),
      ],
    );
  }

  Widget _buildMealItem(BuildContext context, WidgetRef ref, String userId, NutritionInfo meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassStroke),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.mealName, style: AppTypography.labelLg),
                Text('${meal.calories} kcal • P:${meal.protein.toInt()}g U:${meal.carbs.toInt()}g M:${meal.fat.toInt()}g', 
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: () => _confirmDelete(context, ref, userId, meal),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterSection(BuildContext context, WidgetRef ref, UserProfile? profile, String userId) {
    final waterAsync = ref.watch(todayWaterProvider(userId));
    final double weight = profile?.weight.toDouble() ?? 80.0;
    final double targetWater = (weight * 0.033); // Litara po kg
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hidratacija', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onLongPress: () => _confirmResetWater(context, ref, userId),
          child: GlassCard(
            child: waterAsync.when(
              data: (amount) => Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${amount.toStringAsFixed(1)} / ${targetWater.toStringAsFixed(1)} L',
                          style: AppTypography.h3.copyWith(color: AppColors.primaryLight),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (amount / targetWater).clamp(0, 1),
                            minHeight: 12,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          amount >= targetWater ? 'Odlično! Hidriran si.' : 'Još malo do cilja!',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Column(
                    children: [
                      _buildWaterButton(ref, userId, 0.25, Icons.local_drink, '0.25L'),
                      const SizedBox(height: 12),
                      _buildWaterButton(ref, userId, 1.0, Icons.water_drop, '1.0L'),
                      const SizedBox(height: 12),
                      _buildCustomWaterButton(context, ref, userId),
                    ],
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Greška: $err'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomWaterButton(BuildContext context, WidgetRef ref, String userId) {
    return GestureDetector(
      onTap: () => _showCustomWaterDialog(context, ref, userId),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: const Icon(Icons.add, color: AppColors.secondary, size: 24),
          ),
          const SizedBox(height: 4),
          Text('Custom', style: AppTypography.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  void _showCustomWaterDialog(BuildContext context, WidgetRef ref, String userId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: Text('Custom unos vode', style: AppTypography.h3),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Unesi litre (npr. 0.5)',
            suffixText: 'L',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Odustani')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                ref.read(waterRepositoryProvider).updateWater(userId, amount);
              }
              Navigator.pop(context);
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }

  void _confirmResetWater(BuildContext context, WidgetRef ref, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: Text('Resetiranje vode', style: AppTypography.h3),
        content: const Text('Želiš li poništiti sav današnji unos vode?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ne')),
          TextButton(
            onPressed: () {
              ref.read(waterRepositoryProvider).resetWater(userId);
              Navigator.pop(context);
            },
            child: const Text('Da, resetiraj', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterButton(WidgetRef ref, String userId, double amount, IconData icon, String label) {
    return GestureDetector(
      onTap: () => ref.read(waterRepositoryProvider).updateWater(userId, amount),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Icon(icon, color: AppColors.primaryLight, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String userId, NutritionInfo meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: Text('Obriši obrok?', style: AppTypography.h3),
        content: Text('Da li si siguran da želiš obrisati ${meal.mealName}?', style: AppTypography.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () {
              if (meal.id != null) {
                ref.read(mealRepositoryProvider).deleteMeal(userId, meal.id!);
              }
              Navigator.pop(context);
            },
            child: const Text('Obriši', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
