import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/restaurant_provider.dart';

class RestaurantSearchScreen extends ConsumerStatefulWidget {
  const RestaurantSearchScreen({super.key});

  @override
  ConsumerState<RestaurantSearchScreen> createState() => _RestaurantSearchScreenState();
}

class _RestaurantSearchScreenState extends ConsumerState<RestaurantSearchScreen> {
  final _cityController = TextEditingController();
  String _selectedCategory = 'Fit hrana';
  
  final List<String> _categories = [
    'Fit hrana',
    'Bez glutena',
    'Vegan',
    'High Protein',
    'Zdravi Fast Food',
  ];

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _onSearch() {
    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Molimo unesite grad')),
      );
      return;
    }
    ref.read(restaurantSearchProvider.notifier).search(
      _cityController.text.trim(), 
      _selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResult = ref.watch(restaurantSearchProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.background.withBlue(40),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSearchSection(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildResultsSection(searchResult),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      floating: true,
      title: Text('AI Restaurant Finder', style: AppTypography.h3),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSearchSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pronađi zdrave opcije', style: AppTypography.labelLg),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _cityController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Grad (npr. Split, Zagreb...)',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    backgroundColor: Colors.white.withOpacity(0.05),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: 'Pretraži s AI',
            onPressed: _onSearch,
            style: AppButtonStyle.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(AsyncValue searchResult) {
    return searchResult.when(
      data: (restaurants) {
        if (restaurants.isEmpty) {
          return const Center(
            child: Text(
              'Unesite grad i kategoriju za pretragu',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return Column(
          children: restaurants.map<Widget>((res) => _buildRestaurantCard(res)).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (err, stack) => Center(
        child: Text('Greška: $err', style: const TextStyle(color: AppColors.error)),
      ),
    );
  }

  Widget _buildRestaurantCard(dynamic res) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(res.name, style: AppTypography.h4),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${res.rating}', style: AppTypography.label.copyWith(color: AppColors.primaryLight)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(res.address, style: AppTypography.caption.copyWith(color: AppColors.primaryLight)),
            const SizedBox(height: AppSpacing.md),
            Text(res.description, style: AppTypography.bodySm),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: res.tags.map<Widget>((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.glassStroke),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(tag, style: AppTypography.caption),
              )).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: 'Pogledaj detalje',
              onPressed: () => _launchURL(res.websiteUrl),
              style: AppButtonStyle.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ne mogu otvoriti link')),
        );
      }
    }
  }
}
