import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_online/features/cities/presentation/widgets/city_selector_widget.dart';
import 'package:flutter_online/features/home/domain/models/admin_home_model.dart';
import 'package:flutter_online/features/home/presentation/bloc/admin_home_bloc.dart';
import 'package:flutter_online/features/home/presentation/bloc/admin_home_event.dart';
import 'package:flutter_online/features/home/presentation/bloc/admin_home_state.dart';
import 'package:flutter_online/shared/widgets/error_widget.dart' as app_error;
import 'package:flutter_online/shared/widgets/loading_widget.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_drawer.dart';

class PublicHomePage extends StatefulWidget {
  const PublicHomePage({super.key});

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

class _PublicHomePageState extends State<PublicHomePage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

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
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context),
        drawer: const AppDrawer(),
        body: BlocBuilder<AdminHomeBloc, AdminHomeState>(
          builder: (context, state) {
            if (state is AdminHomeLoading) {
              return const LoadingWidget(message: 'Loading...');
            }
            if (state is AdminHomeFailure) {
              return app_error.ErrorWidget(
                message: state.message,
                onRetry: () =>
                    context.read<AdminHomeBloc>().add(const FetchAdminHome()),
              );
            }
            if (state is AdminHomeLoaded) {
              return _buildContent(context, state.data);
            }
            return const LoadingWidget(message: 'Loading...');
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AdminHomeModel data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > 900;
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _HeroHeaderSection(hero: data.hero, isWeb: isWeb),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 64 : 16,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    _buildSectionHeader('Explore Categories', isWeb),
                    const SizedBox(height: 32),
                    _CategoryRail(categories: data.categories, isWeb: isWeb),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: _ServicesSection(services: data.services, isWeb: isWeb),
              ),
            ),
            if (data.featuredEvents.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: _FeaturedCollections(
                    featuredEvents: data.featuredEvents,
                    isWeb: isWeb,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: _RealEventsSection(
                realCelebrations: data.realCelebrations,
                isWeb: isWeb,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 64 : 16,
                vertical: 32,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildSectionHeader(
                      'Trending Decorations',
                      isWeb,
                      showViewAll: true,
                      onViewAll: () => context.push(AppRoutes.eventList),
                    ),
                    const SizedBox(height: 24),
                    _TrendingGrid(
                      trendingDecorations: data.trendingDecorations,
                      isWeb: isWeb,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _TrustSection(isWeb: isWeb)),
            SliverToBoxAdapter(child: _buildFooter()),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 768 && width < 1024;
    final isMobile = width < 768;

    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _isScrolled ? AppColors.surface : Colors.black.withOpacity(0.2),

        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SafeArea(
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final isLoggedIn = authState is AuthAuthenticated;
              final isScrolled = _isScrolled;

              if (isMobile) {
                return _buildMobileAppBar(context, isScrolled);
              }
              if (isTablet) {
                return _buildTabletAppBar(context, isScrolled, isLoggedIn);
              }
              return _buildDesktopAppBar(context, isScrolled, isLoggedIn);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileAppBar(BuildContext context, bool isScrolled) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.menu,
            color: isScrolled ? AppColors.textPrimary : Colors.white,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        Expanded(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isScrolled
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.diamond_outlined,
                    color: isScrolled ? AppColors.primary : Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Elegant Events',
                  style: AppTextStyles.headingM.copyWith(
                    color: isScrolled ? AppColors.textPrimary : Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final isLoggedIn = authState is AuthAuthenticated;
            if (isLoggedIn) {
              return GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              );
            }
            return TextButton(
              onPressed: () => context.push(AppRoutes.login),
              child: Text(
                'Login',
                style: AppTextStyles.labelM.copyWith(
                  color: isScrolled ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTabletAppBar(
    BuildContext context,
    bool isScrolled,
    bool isLoggedIn,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isScrolled
                ? AppColors.primary.withOpacity(0.1)
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.diamond_outlined,
            color: isScrolled ? AppColors.primary : Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Elegant Events',
          style: AppTextStyles.headingM.copyWith(
            color: isScrolled ? AppColors.textPrimary : Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        CitySelectorWidget(isScrolled: isScrolled),
        if (isLoggedIn) ...[
          const SizedBox(width: 24),
          _MyBookingsLink(isScrolled: isScrolled),
          const SizedBox(width: 24),
          _ProfileIcon(isScrolled: isScrolled),
        ] else ...[
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => context.push(AppRoutes.login),
            child: Text(
              'Login',
              style: AppTextStyles.labelM.copyWith(
                color: isScrolled ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.menu,
            color: isScrolled ? AppColors.textPrimary : Colors.white,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ],
    );
  }

  Widget _buildDesktopAppBar(
    BuildContext context,
    bool isScrolled,
    bool isLoggedIn,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isScrolled
                ? AppColors.primary.withOpacity(0.1)
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.diamond_outlined,
            color: isScrolled ? AppColors.primary : Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Elegant Events',
          style: AppTextStyles.headingM.copyWith(
            color: isScrolled ? AppColors.textPrimary : Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        CitySelectorWidget(isScrolled: isScrolled),
        if (isLoggedIn) ...[
          const SizedBox(width: 28),
          _MyBookingsLink(isScrolled: isScrolled),
          const SizedBox(width: 28),
          _ProfileIcon(isScrolled: isScrolled),
        ] else ...[
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => context.push(AppRoutes.login),
            child: Text(
              'Login',
              style: AppTextStyles.labelM.copyWith(
                color: isScrolled ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(width: 12),
        IconButton(
          icon: Icon(
            Icons.menu,
            color: isScrolled ? AppColors.textPrimary : Colors.white,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ],
    );
  }

      
  }

  Widget _buildSectionHeader(
    String title,
    bool isWeb, {
    bool showViewAll = false,
    VoidCallback? onViewAll,
  }) {
    return Row(
      mainAxisAlignment: isWeb
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: isWeb
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
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
            onPressed: onViewAll ?? () {},
            child: const Text(
              'View All',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF1A1A1A), // Dark footer
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          const Icon(
            Icons.diamond_outlined,
            size: 40,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Elegant Events',
            style: AppTextStyles.headingL.copyWith(
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Making your dreams come true, one event at a time.',
            style: AppTextStyles.bodyM.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 32),
          Text(
            '© 2026 Elegant Events. All rights reserved.',
            style: AppTextStyles.bodyS.copyWith(color: Colors.white24),
          ),
        ],
      ),
    );
  }

/* =================================================================
   SUB-WIDGETS 
   ================================================================= */

/// Premium nav link for "My Bookings" – text link with hover gold underline.
class _MyBookingsLink extends StatefulWidget {
  final bool isScrolled;

  const _MyBookingsLink({required this.isScrolled});

  @override
  State<_MyBookingsLink> createState() => _MyBookingsLinkState();
}

class _MyBookingsLinkState extends State<_MyBookingsLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isScrolled = widget.isScrolled;
    final color = _hover || !isScrolled
        ? (isScrolled ? AppColors.primary : Colors.white)
        : (isScrolled ? AppColors.textPrimary : Colors.white70);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.myBookings),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTextStyles.labelM.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            decoration: _hover ? TextDecoration.underline : TextDecoration.none,
            decorationColor: isScrolled ? AppColors.primary : Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('My Bookings'),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _hover ? 2 : 0,
                margin: const EdgeInsets.only(top: 2),
                width: 60,
                color: isScrolled ? AppColors.primary : Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  final bool isScrolled;

  const _ProfileIcon({required this.isScrolled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Scaffold.of(context).openDrawer(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isScrolled
              ? AppColors.primary.withOpacity(0.1)
              : Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_outline,
          color: isScrolled ? AppColors.primary : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

class _HeroHeaderSection extends StatelessWidget {
  final AdminHomeHeroModel hero;
  final bool isWeb;
  const _HeroHeaderSection({required this.hero, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final double heroHeight = isWeb ? 520 : 420;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: _HeroCarousel(hero: hero),
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  final AdminHomeHeroModel hero;
  const _HeroCarousel({required this.hero});

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  static const List<String> _defaultImages = [
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
      if (mounted) {
        setState(() {
          final images = _getImages();
          _currentIndex = (_currentIndex + 1) % images.length;
        });
      }
    });
  }

  List<String> _getImages() {
    if (widget.hero.imageUrl != null && widget.hero.imageUrl!.isNotEmpty) {
      return [widget.hero.imageUrl!];
    }
    return _defaultImages;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _getImages();
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
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.primary.withOpacity(0.2)),
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
                widget.hero.subtitle.isNotEmpty
                    ? widget.hero.subtitle
                    : 'Discover decorations and event themes for every occasion',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyL.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.hero.title.isNotEmpty
                    ? widget.hero.title
                    : 'Plan Your Perfect\nCelebration',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingXL.copyWith(
                  color: Colors.white,
                  fontSize: 48,
                  height: 1.2,
                  fontFamily: 'Serif',
                  fontWeight: FontWeight.w600,
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

IconData _categoryIconFromString(String icon) {
  switch (icon.toLowerCase()) {
    case 'wedding':
      return Icons.favorite_border;
    case 'birthday':
      return Icons.cake_outlined;
    case 'corporate':
      return Icons.business_center_outlined;
    case 'saree':
      return Icons.style_outlined;
    default:
      return Icons.celebration_outlined;
  }
}

class _CategoryRail extends StatelessWidget {
  final List<AdminHomeCategoryModel> categories;
  final bool isWeb;
  const _CategoryRail({required this.categories, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
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
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.eventList),
                child: _buildItem(categories[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(AdminHomeCategoryModel item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: item.imageUrl != null && item.imageUrl!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    width: 72,
                    height: 72,
                    errorBuilder: (_, __, ___) => Icon(
                      _categoryIconFromString(item.name),
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                )
              : Icon(
                  _categoryIconFromString(item.name),
                  color: AppColors.primary,
                  size: 28,
                ),
        ),
        const SizedBox(height: 14),
        Text(
          item.name,
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

IconData _serviceIconFromString(String icon) {
  switch (icon.toLowerCase()) {
    case 'decor':
      return Icons.design_services;
    case 'camera':
      return Icons.photo_camera;
    case 'music':
      return Icons.music_note;
    case 'food':
      return Icons.restaurant;
    default:
      return Icons.design_services;
  }
}

class _ServicesSection extends StatelessWidget {
  final List<AdminHomeServiceModel> services;
  final bool isWeb;
  const _ServicesSection({required this.services, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'OUR SERVICES',
          style: AppTextStyles.labelM.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Everything you need for a\nperfect event',
          textAlign: TextAlign.center,
          style: AppTextStyles.headingL,
        ),
        const SizedBox(height: 48),
        Wrap(
          spacing: 32,
          runSpacing: 32,
          alignment: WrapAlignment.center,
          children: services
              .map(
                (s) => _buildServiceCard(
                  _serviceIconFromString(s.icon),
                  s.title,
                  s.description,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildServiceCard(IconData icon, String title, String desc) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.headingS),
          const SizedBox(height: 8),
          Text(
            desc,
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

const String _defaultFeaturedImage1 =
    'https://images.pexels.com/photos/948185/pexels-photo-948185.jpeg?auto=compress&cs=tinysrgb&w=800';
const String _defaultFeaturedImage2 =
    'https://images.pexels.com/photos/1467992/pexels-photo-1467992.jpeg?auto=compress&cs=tinysrgb&w=800';

class _FeaturedCollections extends StatelessWidget {
  final List<AdminHomeFeaturedEventModel> featuredEvents;
  final bool isWeb;
  const _FeaturedCollections({
    required this.featuredEvents,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < featuredEvents.length; i++) ...[
          if (i > 0) const SizedBox(height: 2),
          _buildBigCard(
            context,
            title: featuredEvents[i].title.isNotEmpty
                ? featuredEvents[i].title
                : (i == 0 ? "The Royal Wedding" : "Birthday"),
            subtitle: featuredEvents[i].subtitle.isNotEmpty
                ? featuredEvents[i].subtitle
                : (i == 0
                      ? "Elegant Palaces & Premium Decor"
                      : "Fun Themes for Kids & Adults"),
            imageUrl:
                featuredEvents[i].imageUrl ??
                (i == 0 ? _defaultFeaturedImage1 : _defaultFeaturedImage2),
            alignLeft: i.isEven,
          ),
        ],
      ],
    );
  }

  Widget _buildBigCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imageUrl,
    required bool alignLeft,
  }) {
    // Shared Content
    final textContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: isWeb
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headingXL.copyWith(
            fontSize: isWeb ? 36 : 28,
            color: isWeb ? AppColors.secondary : Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: AppTextStyles.bodyL.copyWith(
            fontSize: isWeb ? 18 : 16,
            color: isWeb ? AppColors.textSecondary : Colors.white70,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              'EXPLORE NOW',
              style: AppTextStyles.buttonPrimary.copyWith(
                color: isWeb ? AppColors.primary : Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: isWeb ? AppColors.primary : Colors.white,
            ),
          ],
        ),
      ],
    );

    if (!isWeb) {
      return Container(
        height: 350,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(80),
                    child: textContent,
                  ),
                ),
                Expanded(child: Image.network(imageUrl, fit: BoxFit.cover)),
              ]
            : [
                Expanded(child: Image.network(imageUrl, fit: BoxFit.cover)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(80),
                    child: textContent,
                  ),
                ),
              ],
      ),
    );
  }
}

const String _defaultCelebrationImage =
    'https://images.unsplash.com/photo-1511795409834-ef04bbd61622';

class _RealEventsSection extends StatelessWidget {
  final List<AdminHomeRealCelebrationModel> realCelebrations;
  final bool isWeb;
  const _RealEventsSection({
    required this.realCelebrations,
    required this.isWeb,
  });

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
              GestureDetector(
                onTap: () {
                  context.push(AppRoutes.eventList);
                },
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: realCelebrations.isEmpty
                ? const Center(
                    child: Text(
                      'No celebrations to show',
                      style: AppTextStyles.bodyM,
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: realCelebrations.length,
                    itemBuilder: (context, index) {
                      final item = realCelebrations[index];
                      return _buildEventCard(
                        item.title,
                        item.type,
                        item.imageUrl ?? _defaultCelebrationImage,
                      );
                    },
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.divider,
                    child: const Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyL.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            type.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPrice(double price) {
  if (price >= 100000) {
    return '₹${(price / 100000).toStringAsFixed(1)}L';
  }
  return '₹${price.toStringAsFixed(0)}';
}

const String _defaultDecorationImage =
    'https://images.unsplash.com/photo-1469334031218-e382a71b716b';

class _TrendingGrid extends StatelessWidget {
  final List<AdminHomeTrendingDecorationModel> trendingDecorations;
  final bool isWeb;
  const _TrendingGrid({required this.trendingDecorations, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    if (trendingDecorations.isEmpty) {
      return const Center(
        child: Text(
          'No trending decorations to show',
          style: AppTextStyles.bodyM,
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = isWeb ? 4 : 2;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: trendingDecorations.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
          ),
          itemBuilder: (context, index) {
            return _HoverScale(
              child: _buildCard(trendingDecorations[index], context),
            );
          },
        );
      },
    );
  }

  Widget _buildCard(
    AdminHomeTrendingDecorationModel item,
    BuildContext context,
  ) {
    final imageUrl = item.imageUrl ?? _defaultDecorationImage;
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.decorationDetailPath(item.id));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.divider,
                    child: const Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyL.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatPrice(item.price),
                    style: AppTextStyles.labelL.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              _buildTrustItem(
                '4.9/5',
                'Average Rating',
                'Based on 5000+ reviews',
              ),
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
          Text(
            stat,
            style: AppTextStyles.headingXL.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.headingS),
          const SizedBox(height: 4),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
          ),
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
