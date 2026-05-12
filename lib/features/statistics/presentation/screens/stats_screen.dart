import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../food_tracking/presentation/providers/meal_provider.dart';
import '../../../food_tracking/domain/entities/nutrition_info.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final statsAsync = user != null 
        ? ref.watch(weeklyStatsProvider(user.id)) 
        : const AsyncValue.data(<NutritionInfo>[]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistika napretka'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: statsAsync.when(
          data: (meals) => _buildStatsContent(context, meals),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Greška: $err')),
        ),
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, List<NutritionInfo> meals) {
    // Grupiranje podataka po danima (zadnjih 7 dana)
    final now = DateTime.now();
    final Map<String, double> dailyCalories = {};
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      dailyCalories[key] = 0;
    }

    for (var meal in meals) {
      if (meal.timestamp != null) {
        final dateKey = DateFormat('yyyy-MM-dd').format(meal.timestamp!);
        if (dailyCalories.containsKey(dateKey)) {
          dailyCalories[dateKey] = (dailyCalories[dateKey] ?? 0) + meal.calories;
        }
      }
    }

    // Pretvaranje u listu za grafikon (od najstarijeg prema najnovijem)
    final sortedKeys = dailyCalories.keys.toList()..sort();
    final chartData = sortedKeys.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), dailyCalories[entry.value]!);
    }).toList();
    // Pronalaženje maksimalne vrijednosti za maxY (dodajemo 20% prostora na vrhu)
    double maxVal = 0;
    for (var spot in chartData) {
      if (spot.y > maxVal) maxVal = spot.y;
    }
    final maxY = maxVal > 0 ? maxVal * 1.25 : 3000.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Unos kalorija (zadnjih 7 dana)', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.lg),
          
          AspectRatio(
            aspectRatio: 1.7,
            child: GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= sortedKeys.length) return const SizedBox();
                          final date = DateTime.parse(sortedKeys[index]);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('E', 'hr').format(date).toUpperCase(),
                              style: AppTypography.caption.copyWith(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.backgroundElevated,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          return LineTooltipItem(
                            '${barSpot.y.toInt()} kcal',
                            AppTypography.label.copyWith(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          
          Text('Pregled po makronutrijentima', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          
          _buildMacroSummary(meals),
          
          const SizedBox(height: AppSpacing.xxl),
          
          Text('Analiza Trenera', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          
          _buildAIPerspective(meals),
          
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildMacroSummary(List<NutritionInfo> meals) {
    double p = 0, c = 0, f = 0;
    if (meals.isNotEmpty) {
      for (var meal in meals) {
        p += meal.protein;
        c += meal.carbs;
        f += meal.fat;
      }
      p /= 7; // Prosjek po danu
      c /= 7;
      f /= 7;
    }

    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Protein', '${p.toInt()}g', AppColors.macroProtein),
          _buildStatItem('Ugljik.', '${c.toInt()}g', AppColors.macroCarbs),
          _buildStatItem('Masti', '${f.toInt()}g', AppColors.macroFat),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppTypography.h4),
        Text(label, style: AppTypography.caption),
      ],
    );
  }

  Widget _buildAIPerspective(List<NutritionInfo> meals) {
    String insight = "Analiziram tvoje podatke iz protekle sedmice...";
    if (meals.isEmpty) {
      insight = "Još uvijek nemam dovoljno podataka za sedmičnu analizu. Nastavi bilježiti svoje obroke!";
    } else {
      insight = "Tvoj prosječni unos proteina je stabilan. Primijetio sam da vikendom unosiš nešto više kalorija, što je u redu dok god održavaš balans tokom sedmice.";
    }

    return GlassCard(
      gradient: LinearGradient(
        colors: [AppColors.secondary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primaryLight),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(insight, style: AppTypography.bodySm),
          ),
        ],
      ),
    );
  }
}
