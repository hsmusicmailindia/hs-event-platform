import 'package:flutter/material.dart';
import '../../cart/presentation/cart_screen.dart';

class VideoSampleItem {
  final String title;
  final String youtubeUrl;
  final String thumbnailUrl;
  final String duration;

  const VideoSampleItem({
    required this.title,
    required this.youtubeUrl,
    required this.thumbnailUrl,
    required this.duration,
  });
}

class ReviewItem {
  final String clientName;
  final double rating;
  final String date;
  final String comment;
  final bool isVerifiedEvent;

  const ReviewItem({
    required this.clientName,
    required this.rating,
    required this.date,
    required this.comment,
    required this.isVerifiedEvent,
  });
}

class ProviderDetailScreen extends StatelessWidget {
  final String providerId;
  final String businessName;
  final String category;
  final String city;
  final int startingPricePaisa;
  final double rating;
  final int reviewCount;
  final String bio;
  final String avatarUrl;
  final List<String> technicalRiders;
  final List<VideoSampleItem> videoSamples;
  final List<ReviewItem> reviews;

  const ProviderDetailScreen({
    super.key,
    required this.providerId,
    required this.businessName,
    required this.category,
    required this.city,
    required this.startingPricePaisa,
    required this.rating,
    required this.reviewCount,
    required this.bio,
    required this.avatarUrl,
    this.technicalRiders = const [
      'Stage PA System & Audio Engineering Excluded (Client / Venue must provide)',
      '4x Stage Floor Monitor Wedges (Dedicated Audio Mixes Required)',
      '3x Shure SM58 Vocal Microphones + Boom Stands',
      'Direct Input (DI) Box for Acoustic Guitar & Keys',
      'Dedicated 16A Clean Ground Power Extension on Stage',
    ],
    this.videoSamples = const [
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
    this.reviews = const [
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
  });

  @override
  Widget build(BuildContext context) {
    final priceRupees = startingPricePaisa ~/ 100;
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * 0.70; // 70% viewport for immersive blend

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Stack(
        children: [
          // 1. Scrollable Flow with Continuous Gradient Blend
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: heroHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Base Image
                      Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF1D1D1F),
                          child: const Center(
                            child: Icon(Icons.music_note_rounded, size: 80, color: Colors.white24),
                          ),
                        ),
                      ),

                      // Multi-Stop Seamless Gradient (Blends Photo into #0F0F12)
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black54,
                              Colors.transparent,
                              Color(0x990F0F12),
                              Color(0xFF0F0F12),
                            ],
                            stops: [0.0, 0.35, 0.70, 1.0],
                          ),
                        ),
                      ),

                      // Overlaid Hero Content
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0071E3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'HS CERTIFIED ARTIST',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white.withAlpha(30)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFA000)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$rating ($reviewCount Reviews)',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    businessName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 28,
                                      letterSpacing: -0.6,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.verified, color: Color(0xFF2997FF), size: 26),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$category • $city',
                              style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Continuous Glassmorphic Content Sections
              SliverPadding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // About Section
                    _buildGlassSection(
                      title: 'About The Artist / Service',
                      icon: Icons.info_outline_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bio,
                            style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(210), height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildBadgePill('HS Certified Performer', Icons.shield_outlined, const Color(0xFF2997FF)),
                              _buildBadgePill('48h Escrow Protection', Icons.lock_outline, const Color(0xFF34C759)),
                              _buildBadgePill('Stage Audio Setup Excluded', Icons.speaker_notes_off_outlined, const Color(0xFFFF9F0A)),
                              _buildBadgePill('Open to Outstation Travel', Icons.flight_takeoff_rounded, Colors.white70),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Performance Video Samples
                    _buildGlassSection(
                      title: 'Performance Samples & Videos',
                      icon: Icons.play_circle_outline_rounded,
                      child: Column(
                        children: videoSamples.map((video) => _buildVideoSampleCard(context, video)).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Technical Riders
                    _buildGlassSection(
                      title: 'Technical Riders (Stage & AV Specs)',
                      icon: Icons.settings_input_component_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The organizer or venue must fulfill these production requirements (or book a separate Sound & Light vendor):',
                            style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(150)),
                          ),
                          const SizedBox(height: 14),
                          ...technicalRiders.map((rider) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      rider.contains('Excluded') ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                                      size: 16,
                                      color: rider.contains('Excluded') ? const Color(0xFFFF9F0A) : const Color(0xFF2997FF),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        rider,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: rider.contains('Excluded') ? const Color(0xFFFF9F0A) : Colors.white.withAlpha(220),
                                          fontWeight: rider.contains('Excluded') ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Client Reviews
                    _buildGlassSection(
                      title: 'Client Reviews & Verified Feedback',
                      icon: Icons.rate_review_outlined,
                      child: Column(
                        children: [
                          _buildRatingSummary(),
                          const SizedBox(height: 16),
                          Divider(height: 1, thickness: 0.5, color: Colors.white.withAlpha(20)),
                          const SizedBox(height: 16),
                          ...reviews.map((review) => _buildReviewCard(review)),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // 3. Translucent Floating Back Button (Top Left)
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(120),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(40)),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. Integrated Seamless Bottom Conversion Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildSeamlessBottomBar(context, priceRupees),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10), // Seamless frosted layer
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2997FF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white, letterSpacing: -0.2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildVideoSampleCard(BuildContext context, VideoSampleItem video) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening Performance Sample: ${video.title}'),
              backgroundColor: const Color(0xFF0071E3),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withAlpha(15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Image.network(
                      video.thumbnailUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.white10,
                        child: const Icon(Icons.music_video_rounded, size: 48, color: Colors.white30),
                      ),
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(180),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(200),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        video.duration,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.smart_display_outlined, size: 18, color: Color(0xFFFF453A)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        video.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$rating',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            Row(
              children: List.generate(
                5,
                (index) => const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFA000)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Based on $reviewCount reviews',
              style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(140)),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '100% Verified Bookings',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF34C759)),
              ),
              const SizedBox(height: 4),
              Text(
                'Only clients with completed event contracts and verified escrow settlement can publish reviews.',
                style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(160), height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(ReviewItem review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.clientName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                ),
                Text(
                  review.date,
                  style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(130)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                ...List.generate(
                  review.rating.floor(),
                  (index) => const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFA000)),
                ),
                const SizedBox(width: 6),
                if (review.isVerifiedEvent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withAlpha(35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Verified Contract',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF34C759)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(200), height: 1.35),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgePill(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildSeamlessBottomBar(BuildContext context, int priceRupees) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F12).withAlpha(230), // Dark frosted blend
        border: Border(top: BorderSide(color: Colors.white.withAlpha(20))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Starting Package', style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(140))),
                Text(
                  '₹$priceRupees',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CartScreen(
                          preselectedServiceId: providerId,
                          preselectedPricePaisa: startingPricePaisa,
                          providerName: businessName,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0071E3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}