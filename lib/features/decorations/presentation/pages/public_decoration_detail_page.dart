import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            return _DetailContent(
              detail: state.detail,
              decorationId: decorationId,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final PublicDecorationDetail detail;
  final String decorationId;

  const _DetailContent({
    required this.detail,
    required this.decorationId,
  });

  String get _imageUrl =>
      detail.firstImageUrl.isNotEmpty ? detail.firstImageUrl : _defaultDetailImage;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroImage(),
                  const SizedBox(height: 20),
                  _buildHeaderCard(),
                  if (_hasInclusionsOrExclusions) ...[
                    const SizedBox(height: 16),
                    _buildInclusionsExclusionsCard(),
                  ],
                  const SizedBox(height: 24),
                  _buildBookCard(context),
                ],
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
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Text(
        detail.name,
        style: AppTextStyles.headingM.copyWith(
          fontWeight: FontWeight.bold,
          fontFamily: 'Serif',
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeroImage() {
    // Shorter banner: max height 320px, aspect 2.5:1 so image doesn't dominate or force scroll
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = (width / 2.5).clamp(200.0, 320.0);
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  _imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.divider,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.35),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      detail.eventTypeName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.name,
            style: AppTextStyles.headingL.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
              color: AppColors.textPrimary,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail.eventTypeName.toUpperCase(),
            style: AppTextStyles.labelM.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(detail.eventTypeName),
              _buildChip(detail.cityName),
            ],
          ),
          if (detail.description != null && detail.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              detail.description!,
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelM.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInclusionsExclusionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.inclusions != null && detail.inclusions!.isNotEmpty) ...[
            Text(
              'Inclusions',
              style: AppTextStyles.headingS.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail.inclusions!,
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (detail.exclusions != null &&
                detail.exclusions!.isNotEmpty) ...[
              const SizedBox(height: 20),
            ],
          ],
          if (detail.exclusions != null && detail.exclusions!.isNotEmpty) ...[
            Text(
              'Exclusions',
              style: AppTextStyles.headingS.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail.exclusions!,
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TOTAL ESTIMATE',
                style: AppTextStyles.labelS.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail.formattedPrice,
                style: AppTextStyles.headingL.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                final isLoggedIn = authState is AuthAuthenticated;
                return ElevatedButton.icon(
                  onPressed: () {
                    if (isLoggedIn) {
                      context.push('/booking', extra: decorationId);
                    } else {
                      // Flipkart-style: after login user lands on booking. Use path-based
                      // nextRoute so GoRouter redirect can navigate without context.go() from OTP.
                      LoginRedirectData.pending = LoginRedirectData(
                        nextRoute: '/booking/$decorationId',
                        extra: null,
                      );
                      context.push('/login', extra: LoginRedirectData.pending);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_today, size: 20),
                  label: Text(
                    'Book This Service',
                    style: AppTextStyles.buttonPrimary.copyWith(fontSize: 15),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
