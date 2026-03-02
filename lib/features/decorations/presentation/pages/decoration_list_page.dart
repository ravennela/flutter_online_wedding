import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';
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
      appBar: AppBar(
        title: Text(
          'Decorations',
          style: AppTextStyles.headingM.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: CitySelectorWidget(isScrolled: true),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1565C0)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Decorations',
                  style: AppTextStyles.headingM,
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore our curated selection of premium decor themes.',
                  style: AppTextStyles.bodyS.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<DecorationListCubit, DecorationListState>(
              builder: (context, state) {
                if (state is DecorationListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is DecorationListError) {
                  return app_error.ErrorWidget(
                    message: state.message,
                    onRetry: () => context.read<DecorationListCubit>().loadDecorations(
                          cityId: cityId,
                          eventTypeId:
                              widget.eventId.isEmpty ? null : widget.eventId,
                        ),
                  );
                }
                if (state is DecorationListEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.deck_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No decorations found',
                          style: AppTextStyles.bodyL,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try changing your city or event type',
                          style: AppTextStyles.bodyS.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (state is DecorationListLoaded) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      double width = MediaQuery.of(context).size.width;
                      int crossAxisCount =
                          width > 900 ? 3 : (width > 600 ? 2 : 1);
                      double padding = 16;

                      return AnimationLimiter(
                        child: GridView.builder(
                          padding: EdgeInsets.all(padding),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: width < 600 ? 1.2 : 0.75,
                          ),
                          itemCount: state.decorations.length,
                          itemBuilder: (context, index) {
                            final item = state.decorations[index];
                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              duration: const Duration(milliseconds: 500),
                              columnCount: crossAxisCount,
                              child: ScaleAnimation(
                                child: FadeInAnimation(
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
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
