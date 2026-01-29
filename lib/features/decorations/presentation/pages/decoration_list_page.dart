import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/decoration_cubit.dart';
import '../widgets/decoration_card.dart';

class DecorationListPage extends StatelessWidget {
  final String eventId;

  const DecorationListPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DecorationCubit()..loadDecorations(eventId),
      child: const _DecorationListView(),
    );
  }
}

class _DecorationListView extends StatefulWidget {
  const _DecorationListView();

  @override
  State<_DecorationListView> createState() => _DecorationListViewState();
}

class _DecorationListViewState extends State<_DecorationListView> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Stage', 'Floral', 'Entrance', 'Lighting', 'Backdrop'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Wedding', style: AppTextStyles.headingM.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
             icon: const Icon(Icons.tune, color: Colors.black),
             onPressed: (){},
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
             height: 60,
             decoration: const BoxDecoration(
               border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))
             ),
             child: ListView.separated(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
               scrollDirection: Axis.horizontal,
               itemCount: _filters.length,
               separatorBuilder: (_,__) => const SizedBox(width: 8),
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
                       color: isSelected ? const Color(0xFF1565C0) : const Color(0xFFF5F5F5), // Blue for selected (from screenshot)
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
          // Section Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Available Decorations', style: AppTextStyles.headingM),
                const SizedBox(height: 8),
                 Text(
                   'Explore our curated selection of premium decor themes to make your special day unforgettable.',
                   style: AppTextStyles.bodyS.copyWith(color: Colors.grey[600]),
                 ),
              ],
            ),
          ),
          
          // Grid
          Expanded(
            child: BlocBuilder<DecorationCubit, DecorationState>(
              builder: (context, state) {
                if (state is DecorationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DecorationError) {
                  return Center(child: Text(state.message));
                } else if (state is DecorationLoaded) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                       double width = MediaQuery.of(context).size.width;
                       int crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 2); // 2 even on mobile to match screenshot? No, text said single column mobile.
                       // Screenshot "Mobile View" text said: Single-column scrollable.
                       
                       // Let's stick to the text prompt requirements strictly.
                       if (width < 600) crossAxisCount = 1;

                       double padding = 16;
                       
                       return AnimationLimiter(
                         child: GridView.builder(
                           padding: EdgeInsets.all(padding),
                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                             crossAxisCount: crossAxisCount,
                             crossAxisSpacing: 16,
                             mainAxisSpacing: 16,
                             childAspectRatio: width < 600 ? 1.2 : 0.75, // Adjust ratio
                           ),
                           itemCount: state.decorations.length,
                           itemBuilder: (context, index) {
                             return AnimationConfiguration.staggeredGrid(
                               position: index,
                               duration: const Duration(milliseconds: 500),
                               columnCount: crossAxisCount,
                               child: ScaleAnimation(
                                 child: FadeInAnimation(
                                   child: DecorationCard(
                                     item: state.decorations[index],
                                     onTap: () {
                                       context.push('/decoration/${state.decorations[index].id}');
                                     },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){},
        backgroundColor: const Color(0xFF1E1E1E),
        icon: const Icon(Icons.sort, color: Colors.white),
        label: const Text("Sort & Filter", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
