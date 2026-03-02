import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/auth/domain/models/login_redirect_data.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_online/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_online/features/decorations/domain/models/public_decoration_detail.dart';
import 'package:flutter_online/features/decorations/presentation/cubit/decoration_detail_cubit.dart';
import 'package:flutter_online/features/decorations/presentation/widgets/tag_chip.dart';
import 'package:flutter_online/shared/widgets/error_widget.dart' as app_error;
import 'package:go_router/go_router.dart';

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
      backgroundColor: const Color(0xFF0F0F0F),
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
              onRetry: () => context.read<DecorationDetailCubit>().loadDecorationDetail(decorationId),
            );
          }
          if (state is DecorationDetailLoaded) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return _buildDesktopLayout(context, state.detail);
                }
                return _buildMobileLayout(context, state.detail);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, PublicDecorationDetail detail) {
    final imageUrl = detail.firstImageUrl.isNotEmpty
        ? detail.firstImageUrl
        : 'https://placehold.co/600x400?text=No+Image';

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            height: double.infinity,
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 40,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                _buildInfoSection(detail),
                const SizedBox(height: 32),
                _buildBottomBar(context, detail, isFloating: false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, PublicDecorationDetail detail) {
    final imageUrl = detail.firstImageUrl.isNotEmpty
        ? detail.firstImageUrl
        : 'https://placehold.co/600x400?text=No+Image';

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
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[800]),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                          stops: [0.6, 1.0],
                        ),
                      ),
                    ),
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
                    _buildInfoSection(detail),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomBar(context, detail, isFloating: true),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(PublicDecorationDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detail.eventTypeName.toUpperCase(),
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TagChip(label: detail.eventTypeName),
            TagChip(label: detail.cityName),
          ],
        ),
        if (detail.description != null && detail.description!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            detail.description!,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoSection(PublicDecorationDetail detail) {
    final entries = <MapEntry<String, String>>[];
    if (detail.inclusions != null && detail.inclusions!.isNotEmpty) {
      entries.add(MapEntry('Inclusions', detail.inclusions!));
    }
    if (detail.exclusions != null && detail.exclusions!.isNotEmpty) {
      entries.add(MapEntry('Exclusions', detail.exclusions!));
    }

    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.value,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, PublicDecorationDetail detail,
      {required bool isFloating}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: isFloating
          ? BoxDecoration(
              color: const Color(0xFF0F0F0F).withOpacity(0.95),
              border: const Border(top: BorderSide(color: Colors.white10)),
            )
          : null,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TOTAL ESTIMATE',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail.formattedPrice,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
                  context.push(
                    '/booking',
                    extra: decorationId,
                  );
                } else {
                  context.push(
                    '/login',
                    extra: LoginRedirectData(
                      nextRoute: '/booking',
                      extra: decorationId,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.calendar_today, size: 18),
              label: const Text(
                'Book This Service',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            );
      }),
      )],
      ),
    );
  }
}
