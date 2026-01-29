import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PublicHomePage extends StatefulWidget {
  const PublicHomePage({super.key});

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

class _PublicHomePageState extends State<PublicHomePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  String _selectedCity = 'Hyderabad';
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isScrolled = _scrollController.offset > 50;
      if (isScrolled != _isScrolled) {
        setState(() {
          _isScrolled = isScrolled;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true, 
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth > 900;
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 1. Combined Hero + Search (Fixed Alignment)
              SliverToBoxAdapter(
                child: _HeroHeaderSection(isWeb: isWeb),
              ),

              // 2. Categories
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 64 : 16, vertical: 32),
                  child: Column(
                    children: [
                      _buildSectionHeader('Explore Categories', isWeb),
                      const SizedBox(height: 32),
                      _CategoryRail(isWeb: isWeb),
                    ],
                  ),
                ),
              ),

              // 3. New Content: "Our Premium Services"
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: _ServicesSection(isWeb: isWeb),
                ),
              ),

              // 4. Featured Collections (Editorial Style)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: _FeaturedCollections(isWeb: isWeb),
                ),
              ),

              // 5. New Content: "Real Celebrations" (Gallery/Testimonial look)
              SliverToBoxAdapter(
                child: _RealEventsSection(isWeb: isWeb),
              ),

              // 6. Trending Decorations (Grid)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 64 : 16, vertical: 32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildSectionHeader('Trending Decorations', isWeb, showViewAll: true),
                      const SizedBox(height: 24),
                      _TrendingGrid(isWeb: isWeb),
                    ],
                  ),
                ),
              ),

              // 7. Trust & Footer
              SliverToBoxAdapter(
                child: _TrustSection(isWeb: isWeb),
              ),
              SliverToBoxAdapter(
                child: _buildFooter(),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _isScrolled ? AppColors.surface : Colors.black.withOpacity(0.2), // Darker overlay initially
       
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isScrolled ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.diamond_outlined, 
                  color: _isScrolled ? AppColors.primary : Colors.white
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'LuxeEvents',
                style: AppTextStyles.headingM.copyWith(
                  color: _isScrolled ? AppColors.textPrimary : Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              _buildGlassyLocationBadge(isScrolled: _isScrolled),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(Icons.menu, color: _isScrolled ? AppColors.textPrimary : Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              image: DecorationImage(
                 image: NetworkImage('https://images.pexels.com/photos/2072181/pexels-photo-2072181.jpeg?auto=compress&cs=tinysrgb&w=800'),
                 fit: BoxFit.cover,
                 opacity: 0.5,
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.person, size: 30, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text('Welcome, Guest', style: AppTextStyles.headingM.copyWith(color: Colors.white)),
              ],
            ),
          ),
          ListTile(leading: const Icon(Icons.home), title: const Text('Home'), onTap: (){Navigator.pop(context);}),
          ListTile(leading: const Icon(Icons.event), title: const Text('My Events'), onTap: (){}),
          ListTile(leading: const Icon(Icons.favorite), title: const Text('Wishlist'), onTap: (){}),
          const Divider(),
          ListTile(leading: const Icon(Icons.support_agent), title: const Text('Help Center'), onTap: (){}),
        ],
      ),
    );
  }

  Widget _buildGlassyLocationBadge({required bool isScrolled}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isScrolled ? AppColors.background : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isScrolled ? AppColors.divider : Colors.white30,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, size: 14, color: isScrolled ? AppColors.primary : Colors.white),
          const SizedBox(width: 6),
          Text(
            _selectedCity,
            style: AppTextStyles.labelM.copyWith(
              color: isScrolled ? AppColors.textPrimary : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 16, color: isScrolled ? AppColors.textSecondary : Colors.white70),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isWeb, {bool showViewAll = false}) {
    return Row(
      mainAxisAlignment: isWeb ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: isWeb ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: AppTextStyles.labelM.copyWith(
                color: AppColors.primary, 
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2, 
              width: 60,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ],
        ),
        if (showViewAll && !isWeb)
           TextButton(
             onPressed: (){}, 
             child: const Text('View All', style: TextStyle(color: AppColors.textSecondary)),
           )
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF1A1A1A), // Dark footer
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.diamond_outlined, size: 40, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'LuxeEvents', 
            style: AppTextStyles.headingL.copyWith(color: Colors.white)
          ),
          const SizedBox(height: 24),
          Text(
            'Making your dreams come true, one event at a time.',
            style: AppTextStyles.bodyM.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 32),
          Text(
            '© 2026 LuxeEvents. All rights reserved.',
            style: AppTextStyles.bodyS.copyWith(color: Colors.white24),
          ),
        ],
      ),
    );
  }
}

/* =================================================================
   SUB-WIDGETS 
   ================================================================= */

class _HeroHeaderSection extends StatelessWidget {
  final bool isWeb;
  const _HeroHeaderSection({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final double heroHeight = isWeb ? 600 : 500;
    const double searchOverlap = 30;

    return SizedBox(
      height: heroHeight + searchOverlap + 20,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none, // Allow overflow for search bar
        children: [
          SizedBox(
            height: heroHeight,
            width: double.infinity,
            child: const _HeroCarousel(),
          ),
          Positioned(
            top: heroHeight - 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: isWeb ? 800 : 500),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: _SearchCard(isWeb: isWeb),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final List<String> images = [
    'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1600&q=80',
    'https://images.pexels.com/photos/2072181/pexels-photo-2072181.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.pexels.com/photos/1729799/pexels-photo-1729799.jpeg?auto=compress&cs=tinysrgb&w=800',
  ];
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if(mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 1000),
          child: Image.network(
            images[_currentIndex],
            key: ValueKey<String>(images[_currentIndex]),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create Timeless Memories',
                style: AppTextStyles.headingM.copyWith(
                  color: Colors.white70,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Elegance in \nEvery Detail',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingXL.copyWith(
                  color: Colors.white,
                  fontSize: 48,
                  height: 1.1,
                  fontFamily: 'Serif',
                  shadows: [
                    const Shadow(
                      offset: Offset(0, 4),
                      blurRadius: 10,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchCard extends StatelessWidget {
  final bool isWeb;
  const _SearchCard({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64, // Slightly taller for better touch targets
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32), // More pill-shaped
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: isWeb 
                  ? 'Search specific themes, venues...' 
                  : 'Search events...',
                hintStyle: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                minimumSize: const Size(0, 44), // Ensure reasonable target size but minimal width constraints
              ),
              child: const Text('Search', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  final bool isWeb;
  const _CategoryRail({required this.isWeb});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'Weddings', 'icon': Icons.favorite_border},
    {'name': 'Birthdays', 'icon': Icons.cake_outlined},
    {'name': 'Corporate', 'icon': Icons.business_center_outlined},
    {'name': 'Parties', 'icon': Icons.celebration_outlined},
    {'name': 'Decor', 'icon': Icons.camera_alt_outlined},
    {'name': 'Catering', 'icon': Icons.restaurant_menu},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 32),
          itemBuilder: (context, index) {
            return _HoverScale(
              child: _buildItem(categories[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(item['icon'], color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 14),
        Text(
          item['name'],
          style: AppTextStyles.labelS.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _ServicesSection extends StatelessWidget {
  final bool isWeb;
  const _ServicesSection({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('OUR SERVICES', style: AppTextStyles.labelM.copyWith(color: AppColors.primary, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text('Everything you need for a\nperfect event', textAlign: TextAlign.center, style: AppTextStyles.headingL),
        const SizedBox(height: 48),
        Wrap(
          spacing: 32,
          runSpacing: 32,
          alignment: WrapAlignment.center,
          children: [
            _buildServiceCard(Icons.design_services, 'Custom Decor', 'Tailored designs that match your vision perfectly.'),
            _buildServiceCard(Icons.photo_camera, 'Photography', 'Capturing every moment with professional excellence.'),
            _buildServiceCard(Icons.music_note, 'Entertainment', 'Live bands, DJs, and performances to keep you moving.'),
            if(isWeb) _buildServiceCard(Icons.restaurant, 'Catering', 'Exquisite menus crafted by top chefs.'),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceCard(IconData icon, String title, String desc) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.headingS),
          const SizedBox(height: 8),
          Text(desc, style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}

class _FeaturedCollections extends StatelessWidget {
  final bool isWeb;
  const _FeaturedCollections({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBigCard(
          context,
          title: "The Royal Wedding",
          subtitle: "Elegant Palaces & Premium Decor",
          imageUrl: 'https://images.pexels.com/photos/948185/pexels-photo-948185.jpeg?auto=compress&cs=tinysrgb&w=800'
,
          alignLeft: true,
        ),
        const SizedBox(height: 2),
        _buildBigCard(
          context,
          title: "Birthday Bash",
          subtitle: "Fun Themes for Kids & Adults",
          imageUrl: 'https://images.pexels.com/photos/1467992/pexels-photo-1467992.jpeg?auto=compress&cs=tinysrgb&w=800'
,
          alignLeft: false,
        ),
      ],
    );
  }

  Widget _buildBigCard(BuildContext context, {required String title, required String subtitle, required String imageUrl, required bool alignLeft}) {
    // Shared Content
    final textContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: isWeb ? CrossAxisAlignment.start : CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headingXL.copyWith(fontSize: isWeb ? 36 : 28, color: isWeb ? AppColors.secondary : Colors.white)),
        const SizedBox(height: 12),
        Text(subtitle, style: AppTextStyles.bodyL.copyWith(fontSize: isWeb ? 18 : 16, color: isWeb ? AppColors.textSecondary : Colors.white70)),
        const SizedBox(height: 24),
        Row(
           children: [
             Text('EXPLORE NOW', style: AppTextStyles.buttonPrimary.copyWith(color: isWeb ? AppColors.primary : Colors.white, fontSize: 14)),
             const SizedBox(width: 8),
             Icon(Icons.arrow_forward, size: 16, color: isWeb ? AppColors.primary : Colors.white)
           ],
        )
      ],
    );

    if (!isWeb) {
      return Container(
        height: 350,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 2),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.4)),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: textContent,
              ),
            ),
          ],
        ),
      );
    } 

    // Web Layout
    return Container(
      height: 450,
      color: AppColors.background,
      child: Row(
        children: alignLeft 
          ? [
             Expanded(child: Padding(padding: const EdgeInsets.all(80), child: textContent)),
             Expanded(child: Image.network(imageUrl, fit: BoxFit.cover)),
            ]
          : [
             Expanded(child: Image.network(imageUrl, fit: BoxFit.cover)),
             Expanded(child: Padding(padding: const EdgeInsets.all(80), child: textContent)),
            ],
      ),
    );
  }
}

class _RealEventsSection extends StatelessWidget {
  final bool isWeb;
  const _RealEventsSection({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: isWeb ? 64 : 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Real Celebrations', style: AppTextStyles.headingL),
             GestureDetector( onTap: () {
              context.push(AppRoutes.adminDashboard);
             },
              child: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary))
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildEventCard('Suhas & Priya', 'Wedding', 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622'),
                _buildEventCard('Corporate Annual Meet', 'Corporate', 'https://images.unsplash.com/photo-1511578314322-379afb476865'),
                _buildEventCard('Aravind\'s 25th', 'Birthday', 'https://images.pexels.com/photos/3014856/pexels-photo-3014856.jpeg?auto=compress&cs=tinysrgb&w=800'),
                _buildEventCard('Music Fest 2025', 'Concert', 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, String type, String url) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.bodyL.copyWith(fontWeight: FontWeight.w600)),
          Text(type, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _TrendingGrid extends StatelessWidget {
  final bool isWeb;
  _TrendingGrid({required this.isWeb});

  final List<Map<String, dynamic>> items = [
    {'title': 'Floral Stage', 'price': '₹42,000', 'image': 'https://images.unsplash.com/photo-1469334031218-e382a71b716b'},
    {'title': 'Cabana Setup', 'price': '₹15,500', 'image': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3'},
    {'title': 'Balloon Decor', 'price': '₹5,000', 'image': 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7'},
    {'title': 'Vintage Entrance', 'price': '₹12,000', 'image': 'https://images.unsplash.com/photo-1527529482837-4698179dc6ce'},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = isWeb ? 4 : 2;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
          ),
          itemBuilder: (context, index) {
            return _HoverScale(child: _buildCard(items[index]));
          },
        );
      },
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(item['image'], fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'], maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyL.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(item['price'], style: AppTextStyles.labelL.copyWith(color: AppColors.primary)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _TrustSection extends StatelessWidget {
  final bool isWeb;
  const _TrustSection({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05)),
      child: Column(
        children: [
          Icon(Icons.verified, size: 40, color: AppColors.secondary),
          const SizedBox(height: 16),
          Text('Why Customers Love Us', style: AppTextStyles.headingL),
          const SizedBox(height: 40),
          Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              _buildTrustItem('4.9/5', 'Average Rating', 'Based on 5000+ reviews'),
              _buildTrustItem('1000+', 'Events Planned', 'Across 10+ cities'),
              _buildTrustItem('100%', 'Satisfaction', 'Or your money back'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem(String stat, String title, String desc) {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          Text(stat, style: AppTextStyles.headingXL.copyWith(color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.headingS),
          const SizedBox(height: 4),
          Text(desc, textAlign: TextAlign.center, style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// Animation Wrapper
class _HoverScale extends StatefulWidget {
  final Widget child;
  const _HoverScale({required this.child});
  @override
  State<_HoverScale> createState() => _HoverScaleState();
}
class _HoverScaleState extends State<_HoverScale> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
