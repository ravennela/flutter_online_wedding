import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';
import 'package:flutter_online/core/widgets/app_drawer.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/auth/domain/models/login_redirect_data.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_online/features/decorations/domain/models/public_decoration_detail.dart';
import 'package:flutter_online/features/decorations/presentation/cubit/decoration_detail_cubit.dart';
import 'package:flutter_online/shared/widgets/error_widget.dart' as app_error;
import 'package:go_router/go_router.dart';

/// Default image when API returns no image.
const String _defaultDetailImage =
    'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1200&q=80';

const List<IconData> _kInclusionRowIcons = [
  Icons.local_florist_outlined,
  Icons.lightbulb_outline,
  Icons.weekend_outlined,
  Icons.auto_fix_high_outlined,
];

class PublicDecorationDetailPage extends StatelessWidget {
  final String decorationId;

  const PublicDecorationDetailPage({super.key, required this.decorationId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<DecorationDetailCubit>()..loadDecorationDetail(decorationId),
      child: _PublicDecorationDetailView(decorationId: decorationId),
    );
  }
}

class _PublicDecorationDetailView extends StatelessWidget {
  final String decorationId;

  const _PublicDecorationDetailView({required this.decorationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: BlocBuilder<DecorationDetailCubit, DecorationDetailState>(
        builder: (context, state) {
          if (state is DecorationDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is DecorationDetailError) {
            return app_error.ErrorWidget(
              message: state.message,
              onRetry: () => context
                  .read<DecorationDetailCubit>()
                  .loadDecorationDetail(decorationId),
            );
          }
          if (state is DecorationDetailLoaded) {
            return _DetailContent(detail: state.detail);
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar:
          BlocBuilder<DecorationDetailCubit, DecorationDetailState>(
        builder: (context, state) {
          if (state is! DecorationDetailLoaded) {
            return const SizedBox.shrink();
          }
          return _StickyBookBar(
            detail: state.detail,
            decorationId: decorationId,
          );
        },
      ),
    );
  }
}

class _StickyBookBar extends StatelessWidget {
  final PublicDecorationDetail detail;
  final String decorationId;

  const _StickyBookBar({
    required this.detail,
    required this.decorationId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'TOTAL COST',
                    style: AppTextStyles.labelS.copyWith(letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail.formattedPrice,
                    style: AppTextStyles.price.copyWith(fontSize: 20, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Expanded(
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    final isLoggedIn = authState is AuthAuthenticated;
                    return ElevatedButton(
                      onPressed: () {
                        if (isLoggedIn) {
                          context.push('/booking/$decorationId');
                        } else {
                          LoginRedirectData.pending = LoginRedirectData(
                            nextRoute: '/booking/$decorationId',
                            extra: null,
                          );
                          context.push('/login', extra: LoginRedirectData.pending);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'RESERVE EXPERIENCE',
                        style: AppTextStyles.buttonPrimary.copyWith(
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final PublicDecorationDetail detail;

  const _DetailContent({required this.detail});

  List<String> get _galleryUrls {
    if (detail.imageUrls.isNotEmpty) return detail.imageUrls;
    final u = detail.firstImageUrl;
    if (u.isNotEmpty) return [u];
    return [_defaultDetailImage];
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildHeroGallery(context),
                    const SizedBox(height: 32),
                    _buildTitleSection(),
                    const SizedBox(height: 40),
                    if (detail.description != null && detail.description!.isNotEmpty) ...[
                      _buildSectionTitle('The Vision'),
                      const SizedBox(height: 12),
                      Text(
                        detail.description!,
                        style: AppTextStyles.bodyL.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.7,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                    if (_hasInclusionsOrExclusions) ...[
                      _buildIncludedSection(),
                      const SizedBox(height: 48),
                    ],
                    if (detail.providerName != null && detail.providerName!.trim().isNotEmpty) ...[
                      _buildSectionTitle('The Artist'),
                      const SizedBox(height: 20),
                      _buildProviderCard(),
                      const SizedBox(height: 120), // Bottom padding for sticky bar
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool get _hasInclusionsOrExclusions =>
      (detail.inclusions != null && detail.inclusions!.isNotEmpty) ||
      (detail.exclusions != null && detail.exclusions!.isNotEmpty);

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.background.withOpacity(0.9),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icon/app_logo.png',
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(
            'Meeveduka',
            style: AppTextStyles.displaySerif.copyWith(fontSize: 18),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeroGallery(BuildContext context) {
    final urls = _galleryUrls;
    final total = urls.length;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.2,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: PageView.builder(
                  itemCount: total,
                  itemBuilder: (context, index) => Image.network(
                    urls[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library_outlined, size: 14, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        '1 / $total',
                        style: AppTextStyles.labelS.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _pillBadge('PREMIUM COLLECTION', AppColors.badgeLavender),
            const SizedBox(width: 8),
            _pillBadge('LIMITED', AppColors.badgePeach),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          detail.name,
          style: AppTextStyles.headingXL.copyWith(
            fontSize: 34,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              detail.formattedPrice,
              style: AppTextStyles.price.copyWith(fontSize: 28, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'starting investment',
                style: AppTextStyles.labelM.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pillBadge(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelS.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 9,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelM.copyWith(
            letterSpacing: 2.0,
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 1,
          color: AppColors.primary.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildIncludedSection() {
    final lines = <String>[];
    if (detail.inclusions != null && detail.inclusions!.trim().isNotEmpty) {
      lines.addAll(
        detail.inclusions!
            .split(RegExp(r'[\n•·]+'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Experience Inclusions'),
        const SizedBox(height: 20),
        if (lines.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3,
            ),
            itemCount: lines.length,
            itemBuilder: (context, index) => _inclusionTile(lines[index], index),
          ),
        if (detail.exclusions != null && detail.exclusions!.isNotEmpty) ...[
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      'LOGISTICS & NOTES',
                      style: AppTextStyles.labelS.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  detail.exclusions!,
                  style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _inclusionTile(String label, int index) {
    final icon = _kInclusionRowIcons[index % _kInclusionRowIcons.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyM.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: const CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80'),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.providerName ?? 'Meeveduka Partner',
                  style: AppTextStyles.headingM.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'Award-winning Design Studio',
                  style: AppTextStyles.bodyS,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(Icons.star_rounded, size: 16, color: AppColors.primary.withOpacity(0.8)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '4.9',
                      style: AppTextStyles.labelS.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
