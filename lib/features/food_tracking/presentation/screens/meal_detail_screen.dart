import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/nutrition_info.dart';
import '../providers/meal_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../services/storage/storage_service.dart';

class MealDetailScreen extends ConsumerStatefulWidget {
  final NutritionInfo meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  ConsumerState<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen> {
  late NutritionInfo _currentMeal;
  bool _isUploadingImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentMeal = widget.meal;
  }

  Future<void> _pickAndUploadImage() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _currentMeal.id == null) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      final uploadedUrl = await ref.read(storageServiceProvider).uploadMealImage(user.id, File(pickedFile.path));
      if (uploadedUrl != null) {
        final updatedMeal = _currentMeal.copyWith(imageUrl: uploadedUrl);
        await ref.read(mealRepositoryProvider).saveMeal(user.id, updatedMeal);
        setState(() {
          _currentMeal = updatedMeal;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _showFullScreenImage() {
    if (_currentMeal.imageUrl == null) return;
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.9),
      pageBuilder: (context, _, __) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: Hero(
                tag: 'meal_image_${_currentMeal.id ?? _currentMeal.mealName}',
                child: InteractiveViewer(
                  child: Image.network(_currentMeal.imageUrl!),
                ),
              ),
            ),
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeaderInfo(),
                const SizedBox(height: AppSpacing.xl),
                _buildMacrosSummary(),
                const SizedBox(height: AppSpacing.xl),
                if (_currentMeal.ingredients.isNotEmpty) ...[
                  _buildIngredientsList(),
                  const SizedBox(height: AppSpacing.xl),
                ],
                _buildDetailedMicros(),
                const SizedBox(height: AppSpacing.xxl),
                _buildActionButtons(context, ref),
                const SizedBox(height: AppSpacing.xxxl), // padding for bottom
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: _currentMeal.imageUrl != null ? 300.0 : 200.0,
      pinned: true,
      backgroundColor: AppColors.backgroundDeep,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_currentMeal.imageUrl != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: _pickAndUploadImage,
            tooltip: 'Promijeni sliku',
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _currentMeal.imageUrl != null
            ? GestureDetector(
                onTap: _showFullScreenImage,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'meal_image_${_currentMeal.id ?? _currentMeal.mealName}',
                      child: Image.network(
                        _currentMeal.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderHeader(),
                      ),
                    ),
                    // Gradijent da se tekst bolje vidi na dnu slike
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.backgroundDeep.withOpacity(0.8),
                            AppColors.backgroundDeep,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : _buildPlaceholderHeader(),
      ),
    );
  }

  Widget _buildPlaceholderHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.darkGradient,
      ),
      child: Center(
        child: _isUploadingImage 
          ? const CircularProgressIndicator(color: AppColors.primaryLight)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant, size: 60, color: AppColors.primaryLight),
                const SizedBox(height: AppSpacing.md),
                TextButton.icon(
                  onPressed: _pickAndUploadImage, 
                  icon: const Icon(Icons.add_a_photo, color: Colors.white), 
                  label: const Text('Dodaj sliku', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    final timeStr = _currentMeal.timestamp != null 
        ? DateFormat('HH:mm').format(_currentMeal.timestamp!) 
        : '';
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
              ),
              child: Text(_currentMeal.category, style: AppTypography.caption.copyWith(color: AppColors.primaryLight)),
            ),
            if (timeStr.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.white54),
                  const SizedBox(width: 4),
                  Text(timeStr, style: AppTypography.caption.copyWith(color: Colors.white54)),
                ],
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(_currentMeal.mealName, style: AppTypography.h2),
      ],
    );
  }

  Widget _buildMacrosSummary() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ukupno', style: AppTypography.h4),
              Text('${_currentMeal.calories} kcal', style: AppTypography.h3.copyWith(color: AppColors.primary)),
            ],
          ),
          const Divider(height: AppSpacing.xl, color: AppColors.glassStroke),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroCircle('Protein', _currentMeal.protein, AppColors.macroProtein),
              _buildMacroCircle('Ugljiko.', _currentMeal.carbs, AppColors.macroCarbs),
              _buildMacroCircle('Masti', _currentMeal.fat, AppColors.macroFat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCircle(String label, double value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: 1.0, // Pun krug
                strokeWidth: 6,
                color: color.withOpacity(0.3),
              ),
            ),
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: value / 150, // Neka fiktivna skala samo za vizualni efekt
                strokeWidth: 6,
                color: color,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text('${value.toInt()}g', style: AppTypography.labelLg),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTypography.caption.copyWith(color: Colors.white70)),
      ],
    );
  }

  Widget _buildIngredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sastojci', style: AppTypography.labelLg),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _currentMeal.ingredients.map((ing) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.fiber_manual_record, size: 8, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ing, style: AppTypography.bodySm)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedMicros() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detalji (Mikronutrijenti)', style: AppTypography.labelLg),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              _buildMicroRow('Šećeri', '${_currentMeal.sugar}g'),
              _buildMicroRow('Vlakna', '${_currentMeal.fiber}g'),
              _buildMicroRow('Zasićene masti', '${_currentMeal.saturatedFat}g'),
              _buildMicroRow('Natrij', '${_currentMeal.sodium}mg'),
              _buildMicroRow('Kolesterol', '${_currentMeal.cholesterol}mg'),
              _buildMicroRow('Trans-masti', '${_currentMeal.transFat}g', isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMicroRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodySm.copyWith(color: Colors.white70)),
            Text(value, style: AppTypography.label),
          ],
        ),
        if (!isLast) const Divider(height: 16, color: AppColors.glassStroke),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AppButton(
          text: 'Pojedi ponovo',
          style: AppButtonStyle.primary,
          onPressed: () async {
            final user = ref.read(currentUserProvider);
            if (user != null) {
              final newMeal = _currentMeal.copyWith(
                id: null, // Novi ID da se tretira kao novi unos
                timestamp: DateTime.now(), // Današnji datum
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dodano u današnji dnevnik!')),
              );
              await ref.read(mealRepositoryProvider).saveMeal(user.id, newMeal);
              if (context.mounted) Navigator.pop(context);
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Uredi',
                style: AppButtonStyle.secondary,
                onPressed: () {
                  context.push('/food-entry', extra: _currentMeal);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                text: 'Obriši',
                style: AppButtonStyle.outline,
                onPressed: () async {
                  final user = ref.read(currentUserProvider);
                  if (user != null && _currentMeal.id != null) {
                    await ref.read(mealRepositoryProvider).deleteMeal(user.id, _currentMeal.id!);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Obrok uspješno obrisan')),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
