import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/repositories/profile_repository.dart';
import '../../../auth/domain/entities/user_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Moj Profil', style: AppTypography.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: profileAsync.when(
          data: (profile) => _buildContent(context, ref, profile, profile?.displayName ?? 'Korisnik'),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Greška: $err')),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, UserProfile? profile, String name) {
    if (profile == null) {
      return Center(
        child: AppButton(
          text: 'Podesi profil',
          onPressed: () => context.push('/profile-setup'),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(name, style: AppTypography.h2),
          Text('Personalizovani AI plan aktivan', style: AppTypography.caption.copyWith(color: AppColors.secondary)),
          
          const SizedBox(height: AppSpacing.xxl),
          
          _buildInfoSection('Osnovni podaci', [
            _buildInfoRow('Godine', '${profile.age} god'),
            _buildInfoRow('Visina', '${profile.height.toInt()} cm'),
            _buildInfoRow('Težina', '${profile.weight.toInt()} kg'),
            _buildInfoRow('Spol', profile.gender),
          ]),
          
          const SizedBox(height: AppSpacing.lg),
          
          _buildInfoSection('AI Kontekst & Zdravlje', [
            _buildInfoRow('Stanja', profile.medicalConditions.isEmpty ? 'Nema' : profile.medicalConditions),
            _buildInfoRow('Cilj', profile.goals),
            _buildInfoRow('Dnevni cilj', '${profile.dailyCaloriesTarget} kcal'),
          ]),
          
          const SizedBox(height: AppSpacing.xxl),
          
          AppButton(
            text: 'Izmijeni podatke',
            onPressed: () => context.push('/profile-setup'),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          TextButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            child: const Text('Odjavi se', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.labelLg.copyWith(color: AppColors.primaryLight)),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTypography.labelLg),
        ],
      ),
    );
  }
}
