import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/repositories/profile_repository.dart';
import '../../domain/entities/meal_recommendation.dart';
import '../providers/meal_provider.dart';

class RecommendationScreen extends ConsumerStatefulWidget {
  final int currentCalories;
  final double currentProtein;
  final double currentCarbs;
  final double currentFat;

  const RecommendationScreen({
    super.key,
    required this.currentCalories,
    required this.currentProtein,
    required this.currentCarbs,
    required this.currentFat,
  });

  @override
  ConsumerState<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends ConsumerState<RecommendationScreen> {
  List<MealRecommendation>? _recommendations;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pokrećemo nakon što se widget izgradi kako bismo imali pristup ref-u sigurno
    Future.microtask(() => _fetchRecommendations());
  }

  Future<void> _fetchRecommendations() async {
    // Čekamo profil iz stream-a
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;
    
    if (profile == null) {
      setState(() {
        _error = "Prvo postavi profil u postavkama.";
        _isLoading = false;
      });
      return;
    }

    try {
      final aiService = ref.read(aiServiceProvider);
      final results = await aiService.getRecommendations(
        profile: profile,
        currentCalories: widget.currentCalories,
        currentProtein: widget.currentProtein,
        currentCarbs: widget.currentCarbs,
        currentFat: widget.currentFat,
      );
      if (mounted) {
        setState(() {
          _recommendations = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Ups! AI kuhar je trenutno zauzet. Probaj ponovo.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: Text('AI Preporuke', style: AppTypography.h3),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: AppTypography.label))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evo što ti tvoj trener predlaže za danas:',
                        style: AppTypography.label.copyWith(color: AppColors.primaryLight),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ..._recommendations!.map((rec) => _buildRecommendationCard(rec)).toList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRecommendationCard(MealRecommendation rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(rec.type, style: AppTypography.caption.copyWith(color: AppColors.primaryLight)),
            ),
            const SizedBox(height: 12),
            Text(rec.title, style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(rec.description, style: AppTypography.label.copyWith(color: Colors.white70)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMacroInfo('Kalorije', '${rec.calories} kcal'),
                _buildMacroInfo('P', '${rec.protein.toInt()}g'),
                _buildMacroInfo('U', '${rec.carbs.toInt()}g'),
                _buildMacroInfo('M', '${rec.fat.toInt()}g'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTypography.caption),
        Text(value, style: AppTypography.label.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
