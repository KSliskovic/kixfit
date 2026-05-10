import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/nutrition_info.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/repositories/profile_repository.dart';
import '../providers/meal_provider.dart';

class FoodEntryScreen extends ConsumerStatefulWidget {
  const FoodEntryScreen({super.key});

  @override
  ConsumerState<FoodEntryScreen> createState() => _FoodEntryScreenState();
}

class _FoodEntryScreenState extends ConsumerState<FoodEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAnalyzing = false;
  NutritionInfo? _result;
  String _selectedCategory = 'Ručak';

  final List<String> _categories = ['Doručak', 'Ručak', 'Večera', 'Snack'];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() {
            _controller.text = val.recognizedWords;
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _analyzeFood() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _result = null;
    });

    try {
      final profile = ref.read(userProfileProvider).value;
      final aiService = ref.read(aiServiceProvider);
      
      final result = await aiService.parseFood(
        _controller.text, 
        profile: profile,
        category: _selectedCategory,
      );
      
      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Greška: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Trener - Unos')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Šta si danas pojeo?',
                style: AppTypography.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              
              Text('Kategorija obroka', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              _buildCategorySelector(),
              
              const SizedBox(height: AppSpacing.xl),
              
              GlassCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'npr. "Pojeo sam 2 jaja, parče hljeba i avokado. Napravi mi analizu."',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                      ),
                      style: AppTypography.bodyLg,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: _listen,
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? AppColors.accent : AppColors.primary,
                            size: 32,
                          ),
                        ).animate(target: _isListening ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              AppButton(
                text: 'Analiziraj pomoću AI',
                isLoading: _isAnalyzing,
                onPressed: _analyzeFood,
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              if (_isAnalyzing)
                const Center(
                  child: CircularProgressIndicator(),
                ).animate().fadeIn(),
                
              if (_result != null)
                _buildResultCard(_result!).animate().fadeIn().slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Row(
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppColors.primaryLight : Colors.transparent),
              ),
              child: Text(
                cat,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultCard(NutritionInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Analiza & Savjet', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          backgroundColor: AppColors.primary.withOpacity(0.05),
          borderColor: AppColors.primary.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(info.mealName, style: AppTypography.h4),
                  ),
                  Text('${info.calories} kcal', style: AppTypography.h4.copyWith(color: AppColors.primary)),
                ],
              ),
              const Divider(height: AppSpacing.xl, color: AppColors.glassStroke),
              
              _buildMacroRow('Protein', info.protein, AppColors.macroProtein),
              _buildMacroRow('Ugljikohidrati', info.carbs, AppColors.macroCarbs),
              _buildMacroRow('Masti', info.fat, AppColors.macroFat),
              
              if (info.confidenceNote.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🤖 AI Savjet:', style: AppTypography.label.copyWith(color: AppColors.primaryLight)),
                      const SizedBox(height: 4),
                      Text(
                        info.confidenceNote,
                        style: AppTypography.bodySm.copyWith(color: Colors.white, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: 'Spremi u dnevnik',
                style: AppButtonStyle.secondary,
                onPressed: () async {
                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    // Ovdje spremamo obrok (idemo u repozitorij)
                    await ref.read(mealRepositoryProvider).saveMeal(user.id, info);
                    if (mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTypography.body),
          const Spacer(),
          Text('${value.toStringAsFixed(1)}g', style: AppTypography.labelLg),
        ],
      ),
    );
  }
}
