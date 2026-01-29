import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/event_cubit.dart';
import '../widgets/event_card.dart';

class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventCubit()..loadEvents(),
      child: const _EventListView(),
    );
  }
}

class _EventListView extends StatefulWidget {
  const _EventListView();

  @override
  State<_EventListView> createState() => _EventListViewState();
}

class _EventListViewState extends State<_EventListView> {
  String _selectedCategory = 'All Events';
  final List<String> _categories = [
    'All Events',
    'Birthdays',
    'Saree Functions',
    'Anniversaries',
    'Weddings',
    'Corporate'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: CustomScrollView(
        slivers: [
          // 1. Custom App Bar
          SliverAppBar(
            backgroundColor: Colors.white,
            floating: true,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {},
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
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: () {},
              )
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                height: 60,
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = category),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFC107) : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

          // 3. Responsive Grid
          BlocBuilder<EventCubit, EventState>(
            builder: (context, state) {
              if (state is EventLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is EventError) {
                return SliverFillRemaining(
                  child: Center(child: Text(state.message)),
                );
              } else if (state is EventLoaded) {
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

                    // Padding logic
                    double horizontalPadding = width > 900 ? 40.0 : 24.0;

                    return SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          // Aspect Ratio Calculation:
                          // Card has significant vertical content. 
                          // Let's approximate a vertical card shape.
                          childAspectRatio: 0.75, 
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final event = state.events[index];
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
                          childCount: state.events.length,
                        ),
                      ),
                    );
                  },
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
