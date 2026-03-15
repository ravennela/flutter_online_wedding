import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_online/features/cities/presentation/widgets/city_selector_widget.dart';
import 'package:flutter_online/features/public_events/domain/models/public_event_item.dart';
import 'package:flutter_online/features/public_events/presentation/bloc/public_events_bloc.dart';
import 'package:flutter_online/features/public_events/presentation/bloc/public_events_event.dart';
import 'package:flutter_online/features/public_events/presentation/bloc/public_events_state.dart';
import 'package:flutter_online/shared/widgets/error_widget.dart' as app_error;
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/event_type.dart';
import '../widgets/event_card.dart';

// Default: beautiful wedding/celebration image when event has no image
const String _defaultEventImage =
    'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=900&q=80';

/// Converts PublicEventItem to EventType for EventCard display.
EventType _toEventType(PublicEventItem item) {
  return EventType(
    id: item.id,
    name: item.name,
    imageUrl: item.imageUrl ?? _defaultEventImage,
    dateText: 'View Decorations',
    categoryTag: item.name.toUpperCase(),
  );
}

class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _EventListView();
  }
}

class _EventListView extends StatefulWidget {
  const _EventListView();

  @override
  State<_EventListView> createState() => _EventListViewState();
}

class _EventListViewState extends State<_EventListView> {
  String _selectedCategory = 'All Events';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      drawer: const AppDrawer(),
      body: BlocBuilder<PublicEventsBloc, PublicEventsState>(
        builder: (context, state) {
          final categories = _buildCategories(state);
          final filteredEvents = _filterEvents(state, _selectedCategory);

          return CustomScrollView(
            slivers: [
              // 1. Custom App Bar
              SliverAppBar(
                backgroundColor: Colors.white,
                floating: true,
                pinned: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                title: Text(
                  'Elegant Events',
                  style: AppTextStyles.headingM.copyWith(
                    fontFamily: 'Serif',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                centerTitle: true,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: CitySelectorWidget(isScrolled: true),
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    height: 60,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = category == _selectedCategory;
                        return GestureDetector(
                          onTap: () => setState(
                            () => _selectedCategory = category,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFC107)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey[700],
                                fontWeight:
                                    isSelected ? FontWeight.w600 : FontWeight.w500,
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

              // 2. Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Featured Celebrations',
                            style: AppTextStyles.headingL.copyWith(
                              fontFamily: 'Serif',
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          Text(
                            'See all',
                            style: AppTextStyles.labelS.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hand-picked events just for you',
                        style: AppTextStyles.bodyS.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Content based on state
              _buildContent(context, state, filteredEvents),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  List<String> _buildCategories(PublicEventsState state) {
    if (state is PublicEventsLoaded && state.events.isNotEmpty) {
      return [
        'All Events',
        ...state.events.map((e) => e.name).toSet().toList()
          ..sort(),
      ];
    }
    return ['All Events'];
  }

  List<EventType> _filterEvents(
    PublicEventsState state,
    String selectedCategory,
  ) {
    if (state is! PublicEventsLoaded) return [];
    if (selectedCategory == 'All Events') {
      return state.events.map(_toEventType).toList();
    }
    return state.events
        .where((e) => e.name == selectedCategory)
        .map(_toEventType)
        .toList();
  }

  Widget _buildContent(
    BuildContext context,
    PublicEventsState state,
    List<EventType> events,
  ) {
    if (state is PublicEventsLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state is PublicEventsFailure) {
      return SliverFillRemaining(
        child: app_error.ErrorWidget(
          message: state.message,
          onRetry: () =>
              context.read<PublicEventsBloc>().add(const FetchPublicEvents()),
        ),
      );
    }
    if (state is PublicEventsLoaded && events.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            'No events to show',
            style: AppTextStyles.bodyM,
          ),
        ),
      );
    }
    if (events.isNotEmpty) {
      return SliverLayoutBuilder(
        builder: (context, constraints) {
          double width = MediaQuery.of(context).size.width;
          int crossAxisCount;
          if (width > 1200) {
            crossAxisCount = 4;
          } else if (width > 900) {
            crossAxisCount = 3;
          } else if (width > 600) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 1;
          }
          double horizontalPadding = width > 900 ? 40.0 : 24.0;

          return SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final event = events[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    columnCount: crossAxisCount,
                    child: ScaleAnimation(
                      scale: 0.9,
                      child: FadeInAnimation(
                        child: EventCard(
                          event: event,
                          onTap: () => context.push('/events/${event.id}'),
                        ),
                      ),
                    ),
                  );
                },
                childCount: events.length,
              ),
            ),
          );
        },
      );
    }
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
