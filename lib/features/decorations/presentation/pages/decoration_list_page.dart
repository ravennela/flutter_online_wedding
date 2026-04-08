import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';
import 'package:flutter_online/core/widgets/app_drawer.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/cities/presentation/cubit/city_cubit.dart';
import 'package:flutter_online/features/cities/presentation/widgets/city_selector_widget.dart';
import 'package:flutter_online/features/decorations/domain/models/decoration_item.dart';
import 'package:flutter_online/features/decorations/domain/models/public_decoration_list_item.dart';
import 'package:flutter_online/features/decorations/presentation/cubit/decoration_list_cubit.dart';
import 'package:flutter_online/features/decorations/presentation/widgets/decoration_card.dart';
import 'package:flutter_online/shared/widgets/error_widget.dart' as app_error;
import 'package:go_router/go_router.dart';

class DecorationListPage extends StatelessWidget {
  final String eventId;

  const DecorationListPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DecorationListCubit>(),
      child: _DecorationListView(eventId: eventId),
    );
  }
}

class _DecorationListView extends StatefulWidget {
  final String eventId;

  const _DecorationListView({required this.eventId});

  @override
  State<_DecorationListView> createState() => _DecorationListViewState();
}

class _DecorationListViewState extends State<_DecorationListView> {
  String _selectedFilter = 'All';
  String? _lastLoadedCityId;
  final Set<String> _favoriteIds = {};

  static const List<String> _filters = [
    'All',
    'Stage',
    'Floral',
    'Entrance',
    'Lighting',
    'Backdrop',
  ];

  List<PublicDecorationListItem> _filtered(List<PublicDecorationListItem> all) {
    if (_selectedFilter == 'All') return all;
    final q = _selectedFilter.toLowerCase();
    return all.where((d) {
      final t = '${d.name} ${d.eventTypeName}'.toLowerCase();
      switch (q) {
        case 'stage':
          return t.contains('stage') ||
              t.contains('mandap') ||
              t.contains('tablescape') ||
              t.contains('glasshouse');
        case 'floral':
          return t.contains('floral') ||
              t.contains('flower') ||
              t.contains('garden') ||
              t.contains('eden') ||
              t.contains('wildflower');
        case 'entrance':
          return t.contains('entrance') ||
              t.contains('walkway') ||
              t.contains('heritage');
        case 'lighting':
          return t.contains('light') ||
              t.contains('glow') ||
              t.contains('nocturnal') ||
              t.contains('fairy');
        case 'backdrop':
          return t.contains('backdrop') ||
              t.contains('arch') ||
              t.contains('luxe') ||
              t.contains('linear');
        default:
          return t.contains(q);
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CityCubit, CityState>(
      listener: (context, cityState) {
        final cityId = cityState is CitySelected
            ? cityState.cityId
            : cityState is CityListLoaded
                ? cityState.cityId
                : null;
        if (cityId != null && cityId.isNotEmpty && _lastLoadedCityId != cityId) {
          _lastLoadedCityId = cityId;
          context.read<DecorationListCubit>().loadDecorations(
                cityId: cityId,
                eventTypeId: widget.eventId.isEmpty ? null : widget.eventId,
              );
        }
      },
      builder: (context, cityState) {
        final cityId = cityState is CitySelected
            ? cityState.cityId
            : cityState is CityListLoaded
                ? cityState.cityId
                : null;
        final hasCity = cityId != null && cityId.isNotEmpty;

        if (hasCity && _lastLoadedCityId != cityId) {
          final id = cityId!;
          _lastLoadedCityId = id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<DecorationListCubit>().loadDecorations(
                    cityId: id,
                    eventTypeId:
                        widget.eventId.isEmpty ? null : widget.eventId,
                  );
            }
          });
        }

        if (!hasCity) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              title: Text('Select city', style: AppTextStyles.headingM),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_city,
                        size: 64, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    Text(
                      'Please select a city to view decorations',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyL,
                    ),
                    const SizedBox(height: 24),
                    const CitySelectorWidget(isScrolled: true),
                  ],
                ),
              ),
            ),
          );
        }

        return _buildDecorationList(context, cityId!);
      },
    );
  }

  Widget _buildDecorationList(BuildContext context, String cityId) {
    const maxContent = 1120.0;
    const hPad = 20.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: AppColors.textPrimary, size: 22),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icon/app_logo.png',
              height: 26,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              'Meeveduka',
              style: AppTextStyles.headingS.copyWith(letterSpacing: 0.4),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: BlocBuilder<DecorationListCubit, DecorationListState>(
        builder: (context, state) {
          if (state is DecorationListLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is DecorationListError) {
            return Center(
              child: app_error.ErrorWidget(
                message: state.message,
                onRetry: () => context.read<DecorationListCubit>().loadDecorations(
                      cityId: cityId,
                      eventTypeId:
                          widget.eventId.isEmpty ? null : widget.eventId,
                    ),
              ),
            );
          }
          if (state is DecorationListEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_mosaic_outlined,
                      size: 48, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No collections available', style: AppTextStyles.bodyL),
                ],
              ),
            );
          }
          if (state is DecorationListLoaded) {
            final filtered = _filtered(state.decorations);
            final spotlight =
                filtered.isNotEmpty ? filtered.first : null;
            final gridItems = filtered.length > 1
                ? filtered.sublist(1)
                : <PublicDecorationListItem>[];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: maxContent),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'CURATED COLLECTIONS',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelM
                                  .copyWith(letterSpacing: 2.4),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Marriage Decorations',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.headingXL.copyWith(
                                fontSize:
                                    MediaQuery.sizeOf(context).width > 600
                                        ? 38
                                        : 28,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Hand-selected installations and full-venue concepts — staged for clarity and effortless booking in your city.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyL
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 22),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _filters.map((filter) {
                                  final selected = filter == _selectedFilter;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Material(
                                      color: selected
                                          ? AppColors.buttonPrimary
                                          : AppColors.surfaceMuted,
                                      borderRadius: BorderRadius.circular(24),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(24),
                                        onTap: () => setState(
                                            () => _selectedFilter = filter),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 10,
                                          ),
                                          child: Text(
                                            filter,
                                            style: AppTextStyles.bodyS.copyWith(
                                              color: selected
                                                  ? AppColors.onPrimary
                                                  : AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 28),
                            if (spotlight != null)
                              _SpotlightBannerDecoration(
                                item: spotlight,
                                onViewConcept: () => context.push(
                                  '/decoration/${spotlight.id}',
                                ),
                              ),
                            if (spotlight != null)
                              const SizedBox(height: 28),
                            if (filtered.isEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 32),
                                child: Text(
                                  'No concepts in this category yet.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyM.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (gridItems.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: maxContent),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: hPad),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final cw = constraints.maxWidth;
                              final cols =
                                  cw > 900 ? 3 : (cw > 560 ? 2 : 1);
                              const gap = 16.0;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  mainAxisSpacing: gap,
                                  crossAxisSpacing: gap,
                                  childAspectRatio: 0.68,
                                ),
                                itemCount: gridItems.length,
                                itemBuilder: (context, index) {
                                  final raw = gridItems[index];
                                  final item =
                                      DecorationItem.fromPublic(raw);
                                  final fav = _favoriteIds.contains(item.id);
                                  return DecorationCard(
                                    item: item,
                                    favorited: fav,
                                    onFavoriteChanged: (v) {
                                      setState(() {
                                        if (v) {
                                          _favoriteIds.add(item.id);
                                        } else {
                                          _favoriteIds.remove(item.id);
                                        }
                                      });
                                    },
                                    onTap: () => context.push(
                                      '/decoration/${raw.id}',
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: maxContent),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(hPad, 28, hPad, 20),
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            'DISCOVER MORE COLLECTIONS',
                            style: AppTextStyles.labelL.copyWith(
                              letterSpacing: 1.2,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _CollectionsFooter()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SpotlightBannerDecoration extends StatelessWidget {
  const _SpotlightBannerDecoration({
    required this.item,
    required this.onViewConcept,
  });

  final PublicDecorationListItem item;
  final VoidCallback onViewConcept;

  @override
  Widget build(BuildContext context) {
    final deco = DecorationItem.fromPublic(item);
    final imageUrl =
        item.thumbnailUrl ?? DecorationItem.defaultImageUrl;
    final desc =
        'Estate-scale concepts tailored to ${item.cityName.isNotEmpty ? item.cityName : 'your venue'} — florals, lighting, and flow designed for photography and guest comfort.';

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppColors.surfaceMuted),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.12),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 16,
              bottom: 16,
              width: MediaQuery.sizeOf(context).width > 560 ? 300 : null,
              right: MediaQuery.sizeOf(context).width > 560 ? null : 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SPOTLIGHT VENDOR',
                            style: AppTextStyles.labelM.copyWith(
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.name,
                            style: AppTextStyles.headingL.copyWith(fontSize: 22),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            desc,
                            style: AppTextStyles.bodyM.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            deco.displayPriceLine,
                            style: AppTextStyles.price.copyWith(fontSize: 17),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: onViewConcept,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              padding: EdgeInsets.zero,
                            ),
                            icon: const Icon(Icons.arrow_forward, size: 18),
                            label: Text(
                              'VIEW CONCEPT',
                              style: AppTextStyles.labelL.copyWith(
                                letterSpacing: 1.0,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionsFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: w > 720
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/icon/app_logo.png', height: 22),
                              const SizedBox(width: 8),
                              Text('Meeveduka', style: AppTextStyles.headingS),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Editorial tools for planning luxury celebrations — venues, decor, and vendors in one calm canvas.',
                            style: AppTextStyles.bodyS.copyWith(height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '© 2024 Meeveduka. All rights reserved.',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _foot('About Us'),
                          _foot('Press'),
                          _foot('Privacy Policy'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _foot('Terms of Service'),
                          _foot('Vendor Portal'),
                          _foot('Contact'),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/icon/app_logo.png', height: 22),
                        const SizedBox(width: 8),
                        Text('Meeveduka', style: AppTextStyles.headingS),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Editorial tools for planning luxury celebrations.',
                      style: AppTextStyles.bodyS.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _foot('About Us'),
                        _foot('Press'),
                        _foot('Privacy'),
                        _foot('Contact'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('© 2024 Meeveduka.', style: AppTextStyles.caption),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _foot(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t,
        style: AppTextStyles.link.copyWith(decoration: TextDecoration.none),
      ),
    );
  }
}
