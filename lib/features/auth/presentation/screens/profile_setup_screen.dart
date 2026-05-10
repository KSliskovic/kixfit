import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../providers/auth_provider.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/entities/user_profile.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _conditionsController = TextEditingController();
  String _gender = 'Muško';
  String _goal = 'Održavanje težine';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicijalizacija sa postojećim podacima
    _ageController.addListener(_onProfileDataChanged);
    _heightController.addListener(_onProfileDataChanged);
    _weightController.addListener(_onProfileDataChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingProfile();
    });
  }

  void _onProfileDataChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _ageController.removeListener(_onProfileDataChanged);
    _heightController.removeListener(_onProfileDataChanged);
    _weightController.removeListener(_onProfileDataChanged);
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  void _loadExistingProfile() {
    final profile = ref.read(userProfileProvider).value;
    final user = ref.read(currentUserProvider);

    if (profile != null) {
      setState(() {
        _nameController.text = profile.displayName;
        _ageController.text = profile.age.toString();
        _heightController.text = profile.height.toInt().toString();
        _weightController.text = profile.weight.toInt().toString();
        _conditionsController.text = profile.medicalConditions;
        _gender = profile.gender;
        _goal = profile.goals;
      });
    } else if (user?.displayName != null) {
      _nameController.text = user!.displayName!;
    }
  }

  Future<void> _saveProfile() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final profile = UserProfile(
        id: user.id,
        displayName: _nameController.text.isEmpty ? 'Korisnik' : _nameController.text,
        age: int.tryParse(_ageController.text) ?? 25,
        height: double.tryParse(_heightController.text) ?? 180,
        weight: double.tryParse(_weightController.text) ?? 80,
        gender: _gender,
        medicalConditions: _conditionsController.text,
        goals: _goal,
        dailyCaloriesTarget: _calculateTargetCalories(),
      );

      await ref.read(profileRepositoryProvider).saveProfile(profile);
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri spremanju: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _calculateTargetCalories() {
    final age = int.tryParse(_ageController.text) ?? 25;
    final height = double.tryParse(_heightController.text) ?? 170;
    final weight = double.tryParse(_weightController.text) ?? 70;

    // BMR (Mifflin-St Jeor)
    double bmr;
    if (_gender == 'Muško') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // TDEE - Total Daily Energy Expenditure
    // Using 1.375 as a moderate activity factor default
    double tdee = bmr * 1.375;

    // Adjust based on goal
    if (_goal == 'Gubitak kilograma') {
      return (tdee * 0.85).round(); // 15% deficit
    } else if (_goal == 'Dobijanje mišića') {
      return (tdee * 1.10).round(); // 10% surplus
    } else {
      return tdee.round(); // Maintenance
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Text('Tvoj Profil', style: AppTypography.displayMd),
                const SizedBox(height: AppSpacing.sm),
                Text('Osvježi svoje podatke kako bi AI ostao precizan.', style: AppTypography.bodyLg),
                const SizedBox(height: AppSpacing.xxl),
                
                GlassCard(
                  child: Column(
                    children: [
                      _buildTextField(_nameController, 'Tvoje Ime', Icons.person_outline, TextInputType.name),
                      const SizedBox(height: AppSpacing.md),
                      _buildTextField(_ageController, 'Godine', Icons.cake_outlined, TextInputType.number),
                      const SizedBox(height: AppSpacing.md),
                      _buildTextField(_heightController, 'Visina (cm)', Icons.height, TextInputType.number),
                      const SizedBox(height: AppSpacing.md),
                      _buildTextField(_weightController, 'Težina (kg)', Icons.fitness_center, TextInputType.number),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                Text('Spol', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.sm),
                _buildToggleGroup(['Muško', 'Žensko'], _gender, (val) => setState(() => _gender = val)),
                
                const SizedBox(height: AppSpacing.lg),
                Text('Zdravstvena stanja (npr. MS, Dijabetes)', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _conditionsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Unesi ako imaš bilo kakve bolesti ili ograničenja...',
                    filled: true,
                    fillColor: AppColors.backgroundElevated,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tvoj cilj', style: AppTypography.h3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                      ),
                      child: Text(
                        '${_calculateTargetCalories()} kcal',
                        style: AppTypography.labelLg.copyWith(color: AppColors.primaryLight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildDropdown(['Gubitak kilograma', 'Održavanje težine', 'Dobijanje mišića']),

                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  text: 'Sačuvaj izmjene',
                  isLoading: _isLoading,
                  onPressed: _saveProfile,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildToggleGroup(List<String> options, String current, Function(String) onSelect) {
    return Row(
      children: options.map((opt) {
        final isSelected = opt == current;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(opt),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppColors.primaryLight : Colors.transparent),
              ),
              child: Text(
                opt,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
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

  Widget _buildDropdown(List<String> options) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _goal,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: AppColors.backgroundCard,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (val) => setState(() => _goal = val!),
      ),
    );
  }
}
