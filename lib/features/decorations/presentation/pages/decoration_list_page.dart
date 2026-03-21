import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
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
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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

  final List<String> _filters = [
    'All',
    'Stage',
    'Floral',
    'Entrance',
    'Lighting',
    'Backdrop'
  ];

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
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                'Select City',
                style: AppTextStyles.headingM.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_city, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Please select a city to view decorations',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyL,
                    ),
                    const SizedBox(height: 24),
                    CitySelectorWidget(isScrolled: true),
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
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'The Atelier',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 20),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURATION GALLERY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[400],
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Marriage\nDecorations',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'An exclusive collection of curated, prestigious event themes. Each design is a testament to bespoke craftsmanship and the art of atmosphere.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = filter == _selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedFilter = filter),
                        borderRadius: BorderRadius.circular(30),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.grey[100],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Divider(color: Color(0xFFF1F1F1)),
            ),
          ),
          BlocBuilder<DecorationListCubit, DecorationListState>(
            builder: (context, state) {
              if (state is DecorationListLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is DecorationListError) {
                return SliverFillRemaining(
                  child: app_error.ErrorWidget(
                    message: state.message,
                    onRetry: () => context.read<DecorationListCubit>().loadDecorations(
                      cityId: cityId,
                      eventTypeId: widget.eventId.isEmpty ? null : widget.eventId,
                    ),
                  ),
                );
              }
              if (state is DecorationListEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome_mosaic_outlined, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('No collections available'),
                      ],
                    ),
                  ),
                );
              }
              if (state is DecorationListLoaded) {
                final width = MediaQuery.of(context).size.width;
                final crossAxisCount = width > 1200 ? 3 : (width > 750 ? 2 : 1);
                
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 32,
                      mainAxisSpacing: 40,
                      childAspectRatio: crossAxisCount == 1 ? 0.85 : 0.76,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = state.decorations[index];
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 600),
                          columnCount: crossAxisCount,
                          child: FadeInAnimation(
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: DecorationCard(
                                item: DecorationItem.fromPublic(item),
                                onTap: () => context.push(
                                  '/decoration/${item.id}',
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: state.decorations.length,
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
