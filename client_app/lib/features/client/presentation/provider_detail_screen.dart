import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/provider_model.dart';

class ProviderDetailScreen extends StatelessWidget {
  final String providerId;
  final ProviderModel? provider;

  const ProviderDetailScreen({
    super.key,
    required this.providerId,
    this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = provider ?? ProviderModel(
      id: providerId,
      businessName: 'Verified Provider',
      category: 'Entertainment',
      city: 'Prayagraj',
      basePricePaisa: 1500000,
      rating: 4.9,
      reviewCount: 42,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: p.heroImageUrl ?? '',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(color: Colors.grey.shade900),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.statusSuccess.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 15, color: AppColors.statusSuccess),
                            SizedBox(width: 4),
                            Text(
                              'HS Certified Partner',
                              style: TextStyle(fontSize: 12, color: AppColors.statusSuccess, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      // High-Contrast Star Rating Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${p.rating}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                            ),
                            Text(
                              ' (${p.reviewCount} Reviews)',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(p.businessName, style: theme.textTheme.displayLarge?.copyWith(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('${p.category} • ${p.city}', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('About Provider', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    p.bio ?? 'Verified event service provider on the HS Music platform.',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Text('Guarantees & Compliance', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  const ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.lock_clock, color: AppColors.actionPrimary),
                    title: Text('14-Day Nodal Escrow Protection', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Funds are only released after successful event fulfillment.'),
                  ),
                  const ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.security, color: AppColors.actionPrimary),
                    title: Text('Zero-Conflict Concurrency', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Direct calendar slot reservation locking via PostgreSQL GiST.'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar with SafeArea to avoid system buttons overlap
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.08))),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          bottom: true,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Starting Quote', style: theme.textTheme.labelSmall),
                    Text(
                      p.formattedPrice,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.actionPrimary),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, 48), // Strict 48dp WCAG AA target
                ),
                onPressed: () {
                  context.push('/client/cart');
                },
                child: const Text('Book Service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}