import 'package:flutter/material.dart';
import '../../provider/presentation/provider_home_screen.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../event_dashboard/presentation/client_event_dashboard_screen.dart';
import '../../event_dashboard/presentation/guest_ticketing_screen.dart';
import '../../gate_scanner/presentation/gate_scanner_screen.dart';
import '../../admin/presentation/admin_dispute_panel_screen.dart';
import 'provider_detail_screen.dart';

class DiscoveryProviderItem {
  final String id;
  final String businessName;
  final String category;
  final String city;
  final int startingPricePaisa;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final String bio;
  final String avatarUrl;
  final List<String> technicalRiders;
  final List<VideoSampleItem> videoSamples;
  final List<ReviewItem> reviews;

  DiscoveryProviderItem({
    required this.id,
    required this.businessName,
    required this.category,
    required this.city,
    required this.startingPricePaisa,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.bio,
    required this.avatarUrl,
    required this.technicalRiders,
    required this.videoSamples,
    required this.reviews,
  });
}

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _categoryChips = [
    {'title': 'All', 'icon': Icons.all_inclusive_rounded},
    {'title': 'Singers & Bands', 'icon': Icons.mic_external_on_rounded},
    {'title': 'Sound & Light', 'icon': Icons.speaker_group_rounded},
    {'title': 'Venues', 'icon': Icons.location_city_rounded},
    {'title': 'Photography', 'icon': Icons.camera_alt_rounded},
    {'title': 'Wedding Decor', 'icon': Icons.celebration_rounded},
  ];

  final List<DiscoveryProviderItem> _catalog = [
    DiscoveryProviderItem(
      id: 'prov_royal_symphony',
      businessName: 'The Royal Symphony Band',
      category: 'Singers & Bands',
      city: 'Civil Lines, Prayagraj',
      startingPricePaisa: 3500000,
      rating: 4.95,
      reviewCount: 64,
      isVerified: true,
      bio: 'Concert-grade live musical ensemble specializing in Bollywood, Sufi, and Semi-Classical performances with in-house sound systems.',
      avatarUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&q=80',
      technicalRiders: [
        'Stage PA System & Audio Engineering Excluded (Client / Venue must provide)',
        '4x Stage Floor Monitor Wedges (Dedicated Audio Mixes Required)',
        '3x Shure SM58 Vocal Microphones + Boom Stands',
        'Direct Input (DI) Box for Acoustic Guitar & Keys',
        'Dedicated 16A Clean Ground Power Extension on Stage',
      ],
      videoSamples: [
        VideoSampleItem(
          title: 'Live Sufi & Bollywood Medley — Prayagraj Cultural Night',
          youtubeUrl: 'https://youtube.com/watch?v=sample1',
          thumbnailUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&q=80',
          duration: '04:15',
        ),
        VideoSampleItem(
          title: 'Acoustic Unplugged Performance — Riverfront Grand Gala',
          youtubeUrl: 'https://youtube.com/watch?v=sample2',
          thumbnailUrl: 'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=600&q=80',
          duration: '03:40',
        ),
      ],
      reviews: [
        ReviewItem(
          clientName: 'Amitabh S. (Wedding Organizer)',
          rating: 5.0,
          date: 'August 2026',
          comment: 'Outstanding vocal performance and punctual arrival. The musical energy kept all 600 guests mesmerized throughout the Sangeet.',
          isVerifiedEvent: true,
        ),
        ReviewItem(
          clientName: 'Pooja V. (Corporate Event Lead)',
          rating: 4.9,
          date: 'July 2026',
          comment: 'Very professional ensemble and prompt coordination. Handled the setlist seamlessly with our external sound vendor.',
          isVerifiedEvent: true,
        ),
      ],
    ),
    DiscoveryProviderItem(
      id: 'prov_acoustic_waves',
      businessName: 'Acoustic Waves Line Array',
      category: 'Sound & Light',
      city: 'Katra, Prayagraj',
      startingPricePaisa: 2200000,
      rating: 4.92,
      reviewCount: 39,
      isVerified: true,
      bio: 'JBL VTX digital sound engineering, multi-zone concert delay towers, beam lights, and aluminum truss systems.',
      avatarUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&q=80',
      technicalRiders: [
        '3-Phase 63A Power Supply with Neutral and Earthing (< 2V)',
        'Clear Line-of-Sight FOH Mixing Position (30m from Stage)',
        'Covered Truss Overhead Protection for Weather Defense',
      ],
      videoSamples: [
        VideoSampleItem(
          title: 'Concert Line Array Audio Calibration & Beam Laser Show',
          youtubeUrl: 'https://youtube.com/watch?v=sample3',
          thumbnailUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600&q=80',
          duration: '02:50',
        ),
      ],
      reviews: [
        ReviewItem(
          clientName: 'Rohan K. (Festival Director)',
          rating: 5.0,
          date: 'August 2026',
          comment: 'Zero audio distortion even at 105dB. The line-array delay towers reached the furthest spectators clearly.',
          isVerifiedEvent: true,
        ),
      ],
    ),
    DiscoveryProviderItem(
      id: 'prov_ganga_heritage',
      businessName: 'Ganga Heritage Grand Lawn',
      category: 'Venues',
      city: 'Riverfront, Prayagraj',
      startingPricePaisa: 8500000,
      rating: 4.88,
      reviewCount: 42,
      isVerified: true,
      bio: 'Exquisite 1,500 pax open-air venue with dedicated banquet halls, riverfront stage facing, and premium hospitality valet.',
      avatarUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800&q=80',
      technicalRiders: [
        'Dedicated Green Rooms for Performers with Attached Restrooms',
        'Generator Backup (DG Set 125 kVA) for Uninterrupted AV',
        'Loading Dock Access for Heavy Production Trucks',
      ],
      videoSamples: [
        VideoSampleItem(
          title: 'Drone Aerial Walkthrough — Riverfront Stage & Lawns',
          youtubeUrl: 'https://youtube.com/watch?v=sample4',
          thumbnailUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800&q=80',
          duration: '01:55',
        ),
      ],
      reviews: [
        ReviewItem(
          clientName: 'Sunita M. (Parent of Bride)',
          rating: 4.9,
          date: 'June 2026',
          comment: 'Picturesque location with unmatched Ganga views. The valet parking handled 200 cars without congestion.',
          isVerifiedEvent: true,
        ),
      ],
    ),
    DiscoveryProviderItem(
      id: 'prov_shutter_stories',
      businessName: 'CineAura Wedding Studios',
      category: 'Photography',
      city: 'Ashok Nagar, Prayagraj',
      startingPricePaisa: 4000000,
      rating: 4.96,
      reviewCount: 51,
      isVerified: true,
      bio: 'Award-winning cinematic 4K photography, live drone aerial coverage, same-day highlight reels, and premium photo books.',
      avatarUrl: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=800&q=80',
      technicalRiders: [
        'Access to Stage Front and Center Pit Area for Steadycam Operation',
        'Secure Media Staging Room for Live Backups and Tethering',
      ],
      videoSamples: [
        VideoSampleItem(
          title: '4K Cinematic Wedding Teaser — Same Day Edit Reel',
          youtubeUrl: 'https://youtube.com/watch?v=sample5',
          thumbnailUrl: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=600&q=80',
          duration: '02:30',
        ),
      ],
      reviews: [
        ReviewItem(
          clientName: 'Vikram D. (Groom)',
          rating: 5.0,
          date: 'May 2026',
          comment: 'The cinematic color grading and drone shots were movie-like. Delivered the highlight teaser within 24 hours!',
          isVerifiedEvent: true,
        ),
      ],
    ),
  ];

  List<DiscoveryProviderItem> get _filteredProviders {
    if (_selectedCategory == 'All') return _catalog;
    return _catalog.where((p) => p.category == _selectedCategory).toList();
  }

  void _openDetail(DiscoveryProviderItem provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderDetailScreen(
          providerId: provider.id,
          businessName: provider.businessName,
          category: provider.category,
          city: provider.city,
          startingPricePaisa: provider.startingPricePaisa,
          rating: provider.rating,
          reviewCount: provider.reviewCount,
          bio: provider.bio,
          avatarUrl: provider.avatarUrl,
          technicalRiders: provider.technicalRiders,
          videoSamples: provider.videoSamples,
          reviews: provider.reviews,
        ),
      ),
    );
  }

  void _openEcosystemNavigator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ecosystem Direct Navigator',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 1. ADMIN DISPUTE ARBITRATION (Explicitly routes to AdminDisputePanelScreen)
              _buildNavTile(
                ctx,
                icon: Icons.gavel_rounded,
                iconColor: const Color(0xFFDC3545),
                title: 'Admin Dispute Arbitration',
                subtitle: 'Split-slider double-entry escrow settlement & fee protection',
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminDisputePanelScreen()),
                  );
                },
              ),

              // 2. BME MULTI-VENDOR CART
              _buildNavTile(
                ctx,
                icon: Icons.shopping_cart_outlined,
                iconColor: const Color(0xFF0071E3),
                title: 'BME Multi-Vendor Cart',
                subtitle: '15-min soft holds & authoritative BigInt Paisa math',
                onTap: () {
                  Navigator.of(ctx).pop();
                  final item = _catalog.first;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        preselectedServiceId: item.id,
                        preselectedPricePaisa: item.startingPricePaisa,
                        providerName: item.businessName,
                      ),
                    ),
                  );
                },
              ),

              // 3. EVENT HUB & TIMELINE
              _buildNavTile(
                ctx,
                icon: Icons.event_available_outlined,
                iconColor: const Color(0xFF198754),
                title: 'Event Hub & Timeline',
                subtitle: 'Operational buffers, live timeline & mutual 6-digit escrow OTP',
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ClientEventDashboardScreen(
                        orderId: 'ORD-LIVE-782910',
                        bookingId: 'bkg_verified_01',
                        totalPaidFormatted: '₹41,300',
                      ),
                    ),
                  );
                },
              ),

              // 4. GUEST LIST & RSVP TICKETS
              _buildNavTile(
                ctx,
                icon: Icons.confirmation_number_outlined,
                iconColor: const Color(0xFF6F42C1),
                title: 'Guest List & RSVP Tickets',
                subtitle: 'Cryptographic passes embedding Ed25519 payload signatures',
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GuestTicketingScreen(
                        bookingId: 'bkg_verified_01',
                        eventName: 'Royal Wedding Sangeet',
                      ),
                    ),
                  );
                },
              ),

              // 5. GATE ACCESS SCANNER
              _buildNavTile(
                ctx,
                icon: Icons.qr_code_scanner_rounded,
                iconColor: const Color(0xFFFD7E14),
                title: 'Gate Access Scanner',
                subtitle: 'Centered viewfinder, anti-double-spend & cloud batch sync',
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GateScannerScreen(
                        bookingId: 'bkg_verified_01',
                        orderId: 'ORD-LIVE-782910',
                      ),
                    ),
                  );
                },
              ),

              // 6. PROVIDER OPERATIONS CONSOLE
              _buildNavTile(
                ctx,
                icon: Icons.storefront_outlined,
                iconColor: const Color(0xFF0071E3),
                title: 'Provider Operations Console',
                subtitle: 'Dynamic 24h/4h SLA countdowns, Accept, Counter & Decline',
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProviderHomeScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black38),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFD),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'HS Events Ecosystem',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.4),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.apps_rounded, color: Color(0xFF0071E3), size: 24),
              tooltip: 'Ecosystem Modules',
              onPressed: () => _openEcosystemNavigator(context),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProviderHomeScreen()),
                );
              },
              icon: const Icon(Icons.storefront_outlined, size: 18, color: Color(0xFF0071E3)),
              label: const Text('Provider Hub', style: TextStyle(color: Color(0xFF0071E3), fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Build My Event Hero Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0071E3), Color(0xFF004CB7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0071E3).withAlpha(70),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ECOSYSTEM OPERATING LAYER',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Build My Event',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Combine Live Artists, Stage Lights, Sound, and Venues into a single synchronized package with Nodal Escrow protection.',
                      style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final defaultItem = _catalog.first;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CartScreen(
                              preselectedServiceId: defaultItem.id,
                              preselectedPricePaisa: defaultItem.startingPricePaisa,
                              providerName: defaultItem.businessName,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0071E3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      child: const Text('Start Event Package', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Visual Category Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                  Text('${_filteredProviders.length} Available', style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categoryChips.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (ctx, index) {
                  final cat = _categoryChips[index];
                  final isSelected = cat['title'] == _selectedCategory;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = cat['title']),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0071E3) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? const Color(0xFF0071E3) : Colors.black.withAlpha(15)),
                      ),
                      child: Row(
                        children: [
                          Icon(cat['icon'] as IconData, size: 16, color: isSelected ? Colors.white : Colors.black87),
                          const SizedBox(width: 8),
                          Text(
                            cat['title'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Provider Cards List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _filteredProviders.map((provider) => _buildProviderCard(context, provider)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, DiscoveryProviderItem provider) {
    final priceRupees = provider.startingPricePaisa ~/ 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _openDetail(provider),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withAlpha(12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFE3F2FD),
                    backgroundImage: provider.avatarUrl.startsWith('http') ? NetworkImage(provider.avatarUrl) : null,
                    child: !provider.avatarUrl.startsWith('http')
                        ? const Icon(Icons.music_note_rounded, color: Color(0xFF0071E3), size: 28)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                provider.businessName,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: Color(0xFF0071E3), size: 16),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${provider.category} • ${provider.city}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFFA000)),
                        const SizedBox(width: 3),
                        Text(
                          '${provider.rating}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF8D6E63)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                provider.bio,
                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Starts From', style: TextStyle(fontSize: 11, color: Colors.black45)),
                      Text(
                        '₹$priceRupees',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F)),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _openDetail(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0071E3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('View Profile & Book', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}