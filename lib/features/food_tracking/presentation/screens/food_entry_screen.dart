import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/nutrition_info.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/repositories/profile_repository.dart';
import '../providers/meal_provider.dart';
import '../../../../services/storage/storage_service.dart';

class FoodEntryScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  final NutritionInfo? initialMeal;
  const FoodEntryScreen({super.key, this.initialCategory, this.initialMeal});

  @override
  ConsumerState<FoodEntryScreen> createState() => _FoodEntryScreenState();
}

class _FoodEntryScreenState extends ConsumerState<FoodEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ImagePicker _picker = ImagePicker();
  
  bool _isListening = false;
  bool _isAnalyzing = false;
  bool _isSaving = false;
  NutritionInfo? _result;
  late String _selectedCategory;
  XFile? _imageFile;
  Uint8List? _imageBytes;

  final List<String> _categories = ['Doručak', 'Ručak', 'Večera', 'Snack'];

  @override
  void initState() {
    super.initState();
    if (widget.initialMeal != null) {
      _result = widget.initialMeal;
      _selectedCategory = widget.initialMeal!.category;
      _controller.text = widget.initialMeal!.mealName;
    } else {
      _selectedCategory = widget.initialCategory ?? 'Ručak';
    }
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? selected = await _picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 800,
      );
      
      if (selected != null) {
        final bytes = await selected.readAsBytes();
        setState(() {
          _imageFile = selected;
          _imageBytes = bytes;
          _result = null; // Reset result when new image is picked
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri odabiru slike: $e')),
        );
      }
    }
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
    if (_controller.text.isEmpty && _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Molimo unesite tekst ili uslikajte obrok.')),
      );
      return;
    }

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
        imageBytes: _imageBytes,
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
    final profile = ref.watch(userProfileProvider).value;
    final isFemale = profile?.gender == 'Žensko';

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
                isFemale ? 'Šta si danas pojela?' : 'Šta si danas pojeo?',
                style: AppTypography.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              
              Text('Kategorija obroka', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              _buildCategorySelector(),
              
              const SizedBox(height: AppSpacing.xl),

              _buildRecentMealsSection(),
              
              const SizedBox(height: AppSpacing.xl),

              // Image Preview Area
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(_imageFile!.path),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ).animate().fadeIn().scale(),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () => setState(() {
                            _imageFile = null;
                            _imageBytes = null;
                          }),
                          icon: const CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              GlassCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Opiši obrok ili samo uslikaj...',
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
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 28),
                        ),
                        IconButton(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 8),
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
                text: _isAnalyzing ? 'Analiziram...' : 'Analiziraj pomoću AI',
                isLoading: _isAnalyzing,
                onPressed: _analyzeFood,
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              if (_isAnalyzing)
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: AppSpacing.md),
                      Text('AI analizira, pričekajte...', style: AppTypography.caption.copyWith(color: AppColors.primaryLight)),
                    ],
                  ),
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
                    child: _buildEditableText(
                      info.mealName, 
                      AppTypography.h4,
                      (val) => setState(() => _result = _result!.copyWith(mealName: val)),
                    ),
                  ),
                  _buildEditableNumber(
                    info.calories.toDouble(), 
                    'kcal',
                    AppTypography.h4.copyWith(color: AppColors.primary),
                    (val) => setState(() => _result = _result!.copyWith(calories: val.toInt())),
                  ),
                ],
              ),
              const Divider(height: AppSpacing.xl, color: AppColors.glassStroke),
              
              _buildMacroRow('Protein', info.protein, AppColors.macroProtein, (val) => setState(() => _result = _result!.copyWith(protein: val))),
              _buildMacroRow('Ugljikohidrati', info.carbs, AppColors.macroCarbs, (val) => setState(() => _result = _result!.copyWith(carbs: val))),
              _buildMacroRow('Masti', info.fat, AppColors.macroFat, (val) => setState(() => _result = _result!.copyWith(fat: val))),
              
              const SizedBox(height: AppSpacing.md),
              Text('DETALJI (Mikronutrijenti)', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              _buildMacroRow('Šećeri', info.sugar, Colors.orange, (val) => setState(() => _result = _result!.copyWith(sugar: val))),
              _buildMacroRow('Vlakna', info.fiber, Colors.green, (val) => setState(() => _result = _result!.copyWith(fiber: val))),
              _buildMacroRow('Zasićene masti', info.saturatedFat, Colors.redAccent, (val) => setState(() => _result = _result!.copyWith(saturatedFat: val))),
              _buildMacroRow('Natrij (mg)', info.sodium, Colors.blueGrey, (val) => setState(() => _result = _result!.copyWith(sodium: val))),
              _buildMacroRow('Kolesterol (mg)', info.cholesterol, Colors.brown, (val) => setState(() => _result = _result!.copyWith(cholesterol: val))),
              _buildMacroRow('Trans-masti', info.transFat, Colors.red, (val) => setState(() => _result = _result!.copyWith(transFat: val))),
              
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
                text: _isSaving ? 'Spremanje...' : 'Spremi u dnevnik',
                style: AppButtonStyle.secondary,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : () async {
                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    setState(() => _isSaving = true);
                    try {
                      String? uploadedImageUrl;
                      if (_imageFile != null) {
                        uploadedImageUrl = await ref.read(storageServiceProvider).uploadMealImage(user.id, File(_imageFile!.path));
                      }
                      
                      final mealToSave = _result!.copyWith(imageUrl: uploadedImageUrl);
                      await ref.read(mealRepositoryProvider).saveMeal(user.id, mealToSave);
                      
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      setState(() => _isSaving = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Greška pri spremanju: $e')),
                        );
                      }
                    }
                  }
                },
              ),
              Center(
                child: Text(
                  'Savjet: Dodirnite brojke za ispravak',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary.withOpacity(0.5)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableText(String initialValue, TextStyle style, Function(String) onSave) {
    return GestureDetector(
      onTap: () async {
        final controller = TextEditingController(text: initialValue);
        final result = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundElevated,
            title: const Text('Naziv obroka', style: TextStyle(color: Colors.white)),
            content: TextField(
              controller: controller, 
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Unesi naziv...', hintStyle: TextStyle(color: Colors.white54)),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Odustani')),
              TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Spremi', style: TextStyle(color: AppColors.primary))),
            ],
          ),
        );
        if (result != null) onSave(result);
      },
      child: Text(initialValue, style: style),
    );
  }

  Widget _buildEditableNumber(double initialValue, String suffix, TextStyle style, Function(double) onSave) {
    return GestureDetector(
      onTap: () async {
        final controller = TextEditingController(text: initialValue.toStringAsFixed(1));
        final result = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundElevated,
            title: Text('Uredi $suffix', style: const TextStyle(color: Colors.white)),
            content: TextField(
              controller: controller, 
              autofocus: true, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Unesi broj...', hintStyle: TextStyle(color: Colors.white54)),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Odustani')),
              TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Spremi', style: TextStyle(color: AppColors.primary))),
            ],
          ),
        );
        if (result != null) {
          final val = double.tryParse(result);
          if (val != null) onSave(val);
        }
      },
      child: Text('${initialValue.toStringAsFixed(0)} $suffix', style: style),
    );
  }

  Widget _buildRecentMealsSection() {
    return GestureDetector(
      onTap: () => context.push('/meal-library'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history, color: AppColors.primaryLight),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vaša česta jela', style: AppTypography.labelLg),
                  const SizedBox(height: 2),
                  Text('Pretraži povijest obroka', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(String label, double value, Color color, Function(double) onEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: InkWell(
        onTap: () async {
          final controller = TextEditingController(text: value.toStringAsFixed(1));
          final result = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.backgroundElevated,
              title: Text('Uredi $label', style: const TextStyle(color: Colors.white)),
              content: TextField(
                controller: controller, 
                autofocus: true, 
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Unesi gramažu...', hintStyle: TextStyle(color: Colors.white54)),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Odustani')),
                TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Spremi', style: TextStyle(color: AppColors.primary))),
              ],
            ),
          );
          if (result != null) {
            final val = double.tryParse(result);
            if (val != null) onEdit(val);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: AppTypography.body),
              const Spacer(),
              Text('${value.toStringAsFixed(1)}g', style: AppTypography.labelLg),
              const SizedBox(width: 8),
              Icon(Icons.edit, size: 14, color: AppColors.textSecondary.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
