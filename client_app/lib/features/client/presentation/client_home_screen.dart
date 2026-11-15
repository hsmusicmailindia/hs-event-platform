import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/provider_model.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final List<String> _categories = [
    'All', 'Singer', 'Band', 'DJ', 'Guitarist', 'Decorator', 'Caterer', 'Venue', 'Photographer'
  ];
  String _selectedCategory = 'All';

  final List<ProviderModel> _mockProviders = const [
    ProviderModel(
      id: 'c138da64-6f3b-486a-9351-14022fb59141',
      businessName: 'The Royal Symphony Band',
      category: 'Band',
      city: 'Prayagraj',
      basePricePaisa: 1500000,
      rating: 4.9,
      reviewCount: 42,
      heroImageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&q=80',
      bio: 'Premium 6-piece live performance ensemble specializing in Sufi, Bollywood, and Classical Fusion.',
    ),
    ProviderModel(
      id: 'd249eb75-7a4c-497b-8462-25133ab60252',
      businessName: 'Grand Heritage Banquets',
      category: 'Venue',
      city: 'Prayagraj',
      basePricePaisa: 5000000,
      rating: 4.8,
      reviewCount: 68,
      heroImageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=600&q=80',
      bio: 'Luxury pillar-less banquet hall accommodating up to 800 guests with open lawn access.',
    ),
    ProviderModel(
      id: 'e350fc86-8b5d-408c-9573-36244bc71363',
      businessName: 'Aura Floral & Theme Decor',
      category: 'Decorator',
      city: 'Prayagraj',
      basePricePaisa: 2500000,
      rating: 5.0,
      reviewCount: 31,
      heroImageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&q=80',
      bio: 'Bespoke aesthetic floral arrangements, stage lighting, and modern minimalist wedding decors.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredProviders = _selectedCategory == 'All'
        ? _mockProviders
        : _mockProviders.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HS MUSIC EVENT ECOSYSTEM',
              style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700),
            ),
            Text(
              'Prayagraj, UP',
              style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18),
            ),
          ],
        ),
        actions: [
          // Switch to Provider Console
          IconButton(
            tooltip: 'Provider Console',
            icon: const Icon(Icons.storefront_outlined, size: 24, color: AppColors.actionPrimary),
            onPressed: () => context.push('/provider/home'),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined, size: 22),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout, size: 22),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/auth/phone');
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D6EFD), Color(0xFF003E9C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AI EVENT ARCHITECT',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Plan your entire event in seconds.',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tell us your budget, guest count, and requirements. We assemble and coordinate verified services.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.actionPrimary,
                        minimumSize: const Size(160, 48),
                      ),
                      onPressed: () => context.push('/client/ai-planner'),
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('Start Planning'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    selectedColor: AppColors.actionPrimary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.fgTextPrimaryLight,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Featured Providers', style: theme.textTheme.headlineSmall),
                  Text('${filteredProviders.length} Available', style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final provider = filteredProviders[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.push('/client/provider/${provider.id}', extra: provider),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgElevatedLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: CachedNetworkImage(
                                imageUrl: provider.heroImageUrl ?? '',
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: Colors.grey.shade300),
                                errorWidget: (context, url, error) => Container(
                                  height: 160,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.music_note, size: 48, color: Colors.grey),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          provider.businessName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star, size: 14, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(
                                              provider.rating.toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              ' (${provider.reviewCount})',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${provider.category} • ${provider.city}',
                                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        provider.formattedPrice,
                                        style: const TextStyle(
                                          color: AppColors.actionPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const Text(
                                        'View Details →',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: filteredProviders.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}