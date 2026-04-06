import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_online/features/cities/presentation/cubit/city_cubit.dart';
import 'package:flutter_online/features/cities/presentation/widgets/city_selector_widget.dart';
import 'package:flutter_online/features/decorations/presentation/cubit/decoration_list_cubit.dart';
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

const List<String> _kHeroFallbackImages = [
  'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1600&q=80',
  'https://images.pexels.com/photos/2072181/pexels-photo-2072181.jpeg?auto=compress&cs=tinysrgb&w=800',
  'https://images.pexels.com/photos/1729799/pexels-photo-1729799.jpeg?auto=compress&cs=tinysrgb&w=800',
];

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
        extendBodyBehindAppBar: false,
        appBar: _buildAppBar(context),
        drawer: const AppDrawer(),
        body: MultiBlocListener(
          listeners: [
            BlocListener<CityCubit, CityState>(
              listener: (context, state) {
                String? cityId;
                if (state is CitySelected) {
                  cityId = state.cityId;
                } else if (state is CityListLoaded) {
                  cityId = state.cityId;
                }
                if (cityId != null && cityId.isNotEmpty) {
                  context.read<DecorationListCubit>().loadDecorations(
                        cityId: cityId,
                        size: 4,
                      );
                }
              },
            ),
          ],
          child: BlocBuilder<AdminHomeBloc, AdminHomeState>(
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
                // Also trigger initial load if city is already selected
                final cityState = context.read<CityCubit>().state;
                String? initialCityId;
                if (cityState is CitySelected) initialCityId = cityState.cityId;
                if (cityState is CityListLoaded) initialCityId = cityState.cityId;
                
                if (initialCityId != null && 
                    context.read<DecorationListCubit>().state is DecorationListInitial) {
                   context.read<DecorationListCubit>().loadDecorations(
                        cityId: initialCityId,
                        size: 4,
                      );
                }

                return _buildContent(context, state.data);
              }
              return const LoadingWidget(message: 'Loading...');
            },
          ),
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
                    _buildSectionHeader(
                      'Browse by Essential Categories',
                      isWeb,
                      kicker: 'DISCOVER',
                    ),
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
                      'Popular Vendors',
                      isWeb,
                      kicker: 'HANDPICKED',
                      showViewAll: true,
                      onViewAll: () => context.push(AppRoutes.eventList),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<DecorationListCubit, DecorationListState>(
                      builder: (context, state) {
                        // Determine which decorations to show: 
                        // 1. Preferred: City-specific decorations from DecorationListCubit
                        // 2. Fallback: Global trending decorations from AdminHomeModel
                        
                        List<AdminHomeTrendingDecorationModel> decorationsToShow = [];

                        if (state is DecorationListLoaded && state.decorations.isNotEmpty) {
                          decorationsToShow = state.decorations.take(4).map((d) {
                            return AdminHomeTrendingDecorationModel(
                              id: d.id,
                              name: d.name,
                              price: d.price,
                              imageUrls: d.thumbnailUrl != null ? [d.thumbnailUrl!] : [],
                            );
                          }).toList();
                        } else if (data.trendingDecorations.isNotEmpty) {
                          decorationsToShow = data.trendingDecorations.take(4).toList();
                        }

                        if (decorationsToShow.isEmpty) {
                          if (state is DecorationListLoading || state is DecorationListInitial) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'No decorations found',
                                style: AppTextStyles.bodyM,
                              ),
                            ),
                          );
                        }

                        return _TrendingGrid(
                          trendingDecorations: decorationsToShow,
                          isWeb: isWeb,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _TrustSection(isWeb: isWeb)),
            SliverToBoxAdapter(child: _buildFooter(isWeb: isWeb)),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 768 && width < 1024;
    final isMobile = width < 768;

    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: _isScrolled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SafeArea(
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final isLoggedIn = authState is AuthAuthenticated;

              if (isMobile) {
                return _buildMobileAppBar(context);
              }
              if (isTablet) {
                return _buildTabletAppBar(context, isLoggedIn);
              }
              return _buildDesktopAppBar(context, isLoggedIn);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileAppBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.menu,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Meeveduka',
              style: AppTextStyles.displaySerif.copyWith(fontSize: 18),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.search,
            color: AppColors.primary,
          ),
          onPressed: () => context.push(AppRoutes.eventList),
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
                    color: AppColors.accentRose.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.primaryDark,
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
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
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
    bool isLoggedIn,
  ) {
    return Row(
      children: [
        Text(
          'Meeveduka',
          style: AppTextStyles.displaySerif.copyWith(fontSize: 20),
        ),
        const Spacer(),
        _HeaderSearchPill(compact: true),
        const SizedBox(width: 12),
        CitySelectorWidget(isScrolled: true),
        if (isLoggedIn) ...[
          const SizedBox(width: 16),
          const _MyBookingsLink(),
          const SizedBox(width: 12),
          const _ProfileIcon(),
        ] else ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => context.push(AppRoutes.login),
            child: Text(
              'Login',
              style: AppTextStyles.labelM.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        IconButton(
          icon: Icon(
            Icons.menu,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ],
    );
  }

  Widget _buildDesktopAppBar(
    BuildContext context,
    bool isLoggedIn,
  ) {
    return Row(
      children: [
        Text(
          'Meeveduka',
          style: AppTextStyles.displaySerif.copyWith(fontSize: 22),
        ),
        const SizedBox(width: 40),
        _DesktopNavCapsule(
          label: 'Venues',
          onTap: () => context.push(AppRoutes.eventList),
        ),
        _DesktopNavCapsule(
          label: 'Photography',
          onTap: () => context.push(AppRoutes.eventList),
        ),
        _DesktopNavCapsule(
          label: 'Catering',
          onTap: () => context.push(AppRoutes.eventList),
        ),
        const Spacer(),
        const _HeaderSearchPill(compact: false),
        const SizedBox(width: 20),
        CitySelectorWidget(isScrolled: true),
        if (isLoggedIn) ...[
          const SizedBox(width: 20),
          const _MyBookingsLink(),
          const SizedBox(width: 12),
          const _ProfileIcon(),
        ] else ...[
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => context.push(AppRoutes.login),
            child: Text(
              'Login',
              style: AppTextStyles.labelM.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.menu,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    bool isWeb, {
    String? kicker,
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
            if (kicker != null) ...[
              Text(
                kicker.toUpperCase(),
                style: AppTextStyles.labelM.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              title,
              textAlign: isWeb ? TextAlign.center : TextAlign.start,
              style: AppTextStyles.headingL.copyWith(
                fontSize: isWeb ? 30 : 24,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 2,
              width: 56,
              decoration: BoxDecoration(
                color: AppColors.accentRose,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        if (showViewAll && !isWeb)
          TextButton(
            onPressed: onViewAll ?? () {},
            child: Text(
              'View All  ›',
              style: AppTextStyles.labelM.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooter({required bool isWeb}) {
    final year = DateTime.now().year;
    final columnStyle = AppTextStyles.bodyS.copyWith(
      color: AppColors.textSecondary,
      height: 1.6,
    );
    Widget link(String t) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(t, style: columnStyle),
        );

    final brand = Column(
      crossAxisAlignment:
          isWeb ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'Meeveduka',
          style: AppTextStyles.displaySerif.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 12),
        Text(
          'Curated wedding experiences, meticulously crafted for your story.',
          textAlign: isWeb ? TextAlign.start : TextAlign.center,
          style: AppTextStyles.bodyM.copyWith(
            color: AppColors.textSecondary,
            height: 1.55,
          ),
        ),
      ],
    );

    final col = ({
      required String title,
      required List<String> lines,
    }) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: AppTextStyles.labelM.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            ...lines.map(link),
          ],
        );

    if (isWeb) {
      return Container(
        width: double.infinity,
        color: AppColors.surfaceMuted,
        padding: const EdgeInsets.fromLTRB(64, 56, 64, 36),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: brand),
                Expanded(
                  child: col(
                    title: 'Resources',
                    lines: const [
                      'Vendor directory',
                      'Planning guide',
                      'Style lookbook',
                    ],
                  ),
                ),
                Expanded(
                  child: col(
                    title: 'Support',
                    lines: const [
                      'Help center',
                      'Privacy policy',
                      'Terms of use',
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEWSLETTER',
                        style: AppTextStyles.labelM.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Occasional notes on new collections and venues.',
                        style: columnStyle,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  'Your email',
                                  style: AppTextStyles.bodyS.copyWith(
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Join',
                                style: AppTextStyles.labelM.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            Text(
              '© $year Meeveduka. All rights reserved.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: AppColors.surfaceMuted,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          brand,
          const SizedBox(height: 32),
          col(
            title: 'Resources',
            lines: const ['Vendor directory', 'Planning guide'],
          ),
          const SizedBox(height: 24),
          Text(
            '© $year Meeveduka. All rights reserved.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

/* =================================================================
   SUB-WIDGETS 
   ================================================================= */

/// Premium nav link for "My Bookings" – text link with hover gold underline.
class _MyBookingsLink extends StatefulWidget {
  const _MyBookingsLink();

  @override
  State<_MyBookingsLink> createState() => _MyBookingsLinkState();
}

class _MyBookingsLinkState extends State<_MyBookingsLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color =
        _hover ? AppColors.primary : AppColors.textPrimary;

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
            letterSpacing: 0.4,
            decoration: _hover ? TextDecoration.underline : TextDecoration.none,
            decorationColor: AppColors.primary,
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
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Scaffold.of(context).openDrawer(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.accentRose.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_outline,
          color: AppColors.primaryDark,
          size: 22,
        ),
      ),
    );
  }
}

/// Pill search in header — navigates to the public events list (same as before).
class _HeaderSearchPill extends StatelessWidget {
  final bool compact;

  const _HeaderSearchPill({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.eventList),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          constraints: BoxConstraints(
            minWidth: compact ? 120 : 260,
            maxWidth: compact ? 200 : 420,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 18,
            vertical: compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search,
                size: compact ? 18 : 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  compact
                      ? 'Search…'
                      : 'Find your dream vendor…',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopNavCapsule extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _DesktopNavCapsule({
    required this.label,
    required this.onTap,
  });

  @override
  State<_DesktopNavCapsule> createState() => _DesktopNavCapsuleState();
}

class _DesktopNavCapsuleState extends State<_DesktopNavCapsule> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: TextButton(
          onPressed: widget.onTap,
          style: TextButton.styleFrom(
            foregroundColor:
                _hover ? AppColors.primary : AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: AppTextStyles.labelM.copyWith(
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
              color: _hover ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
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
    if (isWeb) {
      return _SplitWebHero(hero: hero);
    }
    const heroHeight = 380.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: heroHeight,
          width: double.infinity,
          child: _HeroCarousel(hero: hero),
        ),
      ),
    );
  }
}

class _SplitWebHero extends StatelessWidget {
  final AdminHomeHeroModel hero;
  const _SplitWebHero({required this.hero});

  @override
  Widget build(BuildContext context) {
    final title = hero.title.isNotEmpty
        ? hero.title
        : 'Your Love Story, Meticulously Crafted.';
    final subtitle = hero.subtitle.isNotEmpty
        ? hero.subtitle
        : 'Discover curated venues, artisans, and décor tailored to the tone of your celebration.';

    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(56, 36, 56, 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURATED WEDDING EXPERIENCES',
                  style: AppTextStyles.labelM.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 2.6,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: AppTextStyles.headingXL.copyWith(
                    fontSize: 46,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyL.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: () => context.push(AppRoutes.eventList),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        'START PLANNING',
                        style: AppTextStyles.buttonPrimary.copyWith(fontSize: 13),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => context.push(AppRoutes.eventList),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        'BROWSE PORTFOLIO',
                        style: AppTextStyles.labelM.copyWith(
                          color: AppColors.textPrimary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 5,
            child: _WebHeroCollage(hero: hero),
          ),
        ],
      ),
    );
  }
}

class _WebHeroCollage extends StatelessWidget {
  final AdminHomeHeroModel hero;
  const _WebHeroCollage({required this.hero});

  List<String> get _imageUrls {
    final h = hero.imageUrl;
    if (h != null && h.isNotEmpty) {
      return [h, _kHeroFallbackImages[1], _kHeroFallbackImages[2]];
    }
    return _kHeroFallbackImages;
  }

  @override
  Widget build(BuildContext context) {
    final urls = _imageUrls;
    return SizedBox(
      height: 420,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Image.network(
                urls[0],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.divider),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.network(
                      urls[1],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.divider),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.network(
                          urls[2],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: AppColors.divider),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentRose.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '“Every detail reflects the depth of your devotion.”',
                            style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.textPrimary,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
    return _kHeroFallbackImages;
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
                onTap: () => context.push('/events/${categories[index].id}'),
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
          'WITH CONFIDENCE',
          style: AppTextStyles.labelM.copyWith(
            color: AppColors.primary,
            letterSpacing: 2.4,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Plan with Confidence',
          textAlign: TextAlign.center,
          style: AppTextStyles.headingL.copyWith(fontSize: 30),
        ),
        const SizedBox(height: 12),
        Text(
          'Thoughtful curation, transparent pricing, and partners who show up.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 40),
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
                  context
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildServiceCard(IconData icon, String title, String desc,BuildContext context) {
    bool isComingSoon = title != 'Custom Decor';
    
    return Stack(
      children: [
        GestureDetector(
          onTap: isComingSoon?null:(){
             context.push(AppRoutes.eventList);
          },
          child: Container(
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
                    color: AppColors.accentRose.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primaryDark, size: 26),
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
          ),
        ),
        if (isComingSoon)
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'COMING SOON',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isWeb ? 64 : 16),
          child: Column(
            children: [
              Text(
                "THE CURATOR'S CHOICE",
                style: AppTextStyles.labelM.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Featured collections',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingL.copyWith(fontSize: isWeb ? 30 : 24),
              ),
              const SizedBox(height: 8),
              Text(
                'Hand-selected themes and décor moments to inspire your celebration.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isWeb ? 36 : 24),
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
            color: isWeb ? AppColors.textPrimary : Colors.white,
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
              style: AppTextStyles.labelM.copyWith(
                color: isWeb ? AppColors.primaryDark : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: isWeb ? AppColors.primaryDark : Colors.white,
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
      color: AppColors.surfaceMuted,
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
                ? Center(
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
      return Center(
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
            childAspectRatio: 0.68,
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
    final imageUrl = item.firstImageUrl ?? _defaultDecorationImage;
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.decorationDetailPath(item.id));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
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
                  top: Radius.circular(22),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.divider,
                        child: const Icon(Icons.image_not_supported, size: 48),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
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
                    style: AppTextStyles.headingS.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '4.9',
                        style: AppTextStyles.labelM.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PRICE RANGE',
                    style: AppTextStyles.labelS.copyWith(
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatPrice(item.price),
                    style: AppTextStyles.price.copyWith(
                      fontSize: 16,
                      color: AppColors.primaryDark,
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
      padding: EdgeInsets.symmetric(
        vertical: isWeb ? 72 : 56,
        horizontal: isWeb ? 64 : 24,
      ),
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Column(
        children: [
          Text(
            'OUR PROMISE',
            style: AppTextStyles.labelM.copyWith(
              color: AppColors.primary,
              letterSpacing: 2.4,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Celebrate with peace of mind',
            textAlign: TextAlign.center,
            style: AppTextStyles.headingL.copyWith(fontSize: isWeb ? 30 : 24),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: isWeb ? 56 : 40,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              _buildTrustItem(
                Icons.auto_awesome,
                'Curated vendors',
                'Every partner is vetted for craft and reliability.',
              ),
              _buildTrustItem(
                Icons.calendar_month_outlined,
                'Seamless planning',
                'Clear timelines and responsive coordination.',
              ),
              _buildTrustItem(
                Icons.account_balance_wallet_outlined,
                'Transparent pricing',
                'Know what to expect before you commit.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String title, String desc) {
    return SizedBox(
      width: isWeb ? 240 : 200,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentRose.withOpacity(0.55),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headingS.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
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
