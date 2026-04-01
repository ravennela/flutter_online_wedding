import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/decorations/domain/usecases/get_decoration_by_id_usecase.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/decoration_detail_bloc.dart';
import '../../domain/models/decoration_detail.dart';
import '../widgets/tag_chip.dart';
import '../widgets/feature_tile.dart';

class DecorationDetailPage extends StatelessWidget {
  final String decorationId;

  const DecorationDetailPage({super.key, required this.decorationId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DecorationDetailBloc(getDecorationByIdUseCase: getIt<GetDecorationByIdUseCase>())..add(LoadDecorationDetail(decorationId)),
      child: const _DecorationDetailView(),
    );
  }
}

class _DecorationDetailView extends StatelessWidget {
  const _DecorationDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Deep Dark Background (from Tablet/Mobile screens)
      body: BlocBuilder<DecorationDetailBloc, DecorationDetailState>(
        builder: (context, state) {
          if (state is DecorationDetailLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is DecorationDetailError) {
             return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
          } else if (state is DecorationDetailLoaded) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return _buildDesktopLayout(context, state.detail);
                } else {
                  return _buildMobileLayout(context, state.detail);
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ==========================================
  // DESKTOP LAYOUT (Side-by-Side)
  // ==========================================
  Widget _buildDesktopLayout(BuildContext context, DecorationDetail detail) {
    return Row(
      children: [
        // Left: Fixed Image Gallery
        Expanded(
          flex: 5,
          child: Container(
            height: double.infinity,
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                detail.images.isNotEmpty
                    ? Image.network(detail.images.first, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey.shade900,
                        alignment: Alignment.center,
                        child: Icon(Icons.image_not_supported_outlined,
                            size: 80, color: Colors.white24),
                      ),
                // Overlay Gradient
                Container(decoration: BoxDecoration(color: Colors.black.withOpacity(0.2))),
                // Back Button
                Positioned(
                  top: 40,
                  left: 40,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Right: Scrollable Details
        Expanded(
          flex: 4,
          child: Container(
             color: const Color(0xFF0F0F0F),
             child: ListView(
               padding: const EdgeInsets.all(48),
               children: [
                  _buildHeaderSection(detail),
                  const SizedBox(height: 32),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 32),
                  _buildProviderSection(detail),
                  const SizedBox(height: 32),
                  _buildFeaturesSection(detail),
                  const SizedBox(height: 48),
                  _buildBottomBar(detail, isFloating: false),
               ],
             ),
          ),
        )
      ],
    );
  }

  // ==========================================
  // MOBILE / TABLET LAYOUT (Single Column)
  // ==========================================
  Widget _buildMobileLayout(BuildContext context, DecorationDetail detail) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
             SliverAppBar(
               expandedHeight: 350,
               pinned: true,
               backgroundColor: const Color(0xFF0F0F0F),
               leading: Container(
                 margin: const EdgeInsets.all(8),
                 decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                 child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
               ),
               actions: [
                 Container(
                   margin: const EdgeInsets.all(8),
                   decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                   child: IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
                 ),
                 Container(
                   margin: const EdgeInsets.all(8),
                   decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                   child: IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {}),
                 ),
               ],
               flexibleSpace: FlexibleSpaceBar(
                 background: Stack(
                   fit: StackFit.expand,
                   children: [
                     detail.images.isNotEmpty
                         ? Image.network(detail.images.first, fit: BoxFit.cover)
                         : Container(
                             color: Colors.grey.shade900,
                             alignment: Alignment.center,
                             child: Icon(Icons.image_not_supported_outlined,
                                 size: 64, color: Colors.white24),
                           ),
                     Container(
                       decoration: const BoxDecoration(
                         gradient: LinearGradient(
                           begin: Alignment.topCenter,
                           end: Alignment.bottomCenter,
                           colors: [Colors.transparent, Colors.black87],
                           stops: [0.6, 1.0]
                         )
                       ),
                     )
                   ],
                 ),
               ),
             ),
             
             SliverToBoxAdapter(
               child: Padding(
                 padding: const EdgeInsets.all(20),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     _buildHeaderSection(detail),
                      const SizedBox(height: 24),
                      _buildProviderSection(detail),
                      const SizedBox(height: 24),
                      const Text("What's Included", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildFeaturesSection(detail),
                      const SizedBox(height: 100), // Space for floating bar
                   ],
                 ),
               ),
             ),
          ],
        ),
        
        // Floating Bottom Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomBar(detail, isFloating: true),
        ),
      ],
    );
  }

  // ==========================================
  // SHARED WIDGETS
  // ==========================================
  
  Widget _buildHeaderSection(DecorationDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(detail.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
            if(detail.rating > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                  const SizedBox(width: 4),
                  Text(detail.rating.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text("PREMIUM SELECTION", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: detail.tags.map((tag) => TagChip(label: tag)).toList(),
        ),
      ],
    );
  }

  Widget _buildProviderSection(DecorationDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(detail.providerImage),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail.providerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text("Top-Rated Decorator Since 2018", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          const Text("View Profile", style: TextStyle(color: Color(0xFF42A5F5), fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(DecorationDetail detail) {
    final featuresList = detail.features.entries.toList();
    return Column(
      children: List.generate(featuresList.length, (index) {
        final entry = featuresList[index];
        IconData icon = Icons.check_circle_outline;
        if(index == 0) icon = Icons.handyman_outlined;
        if(index == 1) icon = Icons.color_lens_outlined;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FeatureTile(
            icon: icon,
            title: entry.key,
            description: entry.value,
          ),
        );
      }),
    );
  }

  Widget _buildBottomBar(DecorationDetail detail, {required bool isFloating}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: isFloating ? BoxDecoration(
         color: const Color(0xFF0F0F0F).withOpacity(0.95),
         border: const Border(top: BorderSide(color: Colors.white10)),
      ) : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("TOTAL ESTIMATE", style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(detail.price, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
