import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/address/domain/models/address_entity.dart';
import 'package:flutter_online/features/address/presentation/cubit/address_cubit.dart';
import 'package:flutter_online/features/address/presentation/cubit/address_state.dart';
import 'package:flutter_online/features/booking/domain/models/booking_args.dart';
import 'package:flutter_online/features/decorations/domain/models/public_decoration_detail.dart';
import 'package:flutter_online/features/decorations/presentation/cubit/decoration_detail_cubit.dart';
import 'package:flutter_online/shared/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

/// Premium Multi-Step Booking Page - Step 1: Address Selection
class BookingPage extends StatefulWidget {
  final String decorationId;

  const BookingPage({super.key, required this.decorationId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? selectedAddressId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<DecorationDetailCubit>()..loadDecorationDetail(widget.decorationId),
        ),
        BlocProvider(
          create: (_) => getIt<AddressCubit>()..fetchAddresses(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
                onPressed: () {
                  context.go('/decoration/${widget.decorationId}');
                },
              ),
              title: Text(
                'Reserve Experience',
                style: AppTextStyles.headingM,
              ),
              centerTitle: true,
            ),
            body: MultiBlocListener(
              listeners: [
                BlocListener<AddressCubit, AddressState>(
                  listener: (context, state) {
                    if (state is AddressFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                    if (state is AddressDeleteSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address removed'),
                          backgroundColor: AppColors.textPrimary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      if (selectedAddressId != null) {
                        context.read<AddressCubit>().fetchAddresses();
                      }
                    }
                  },
                ),
              ],
              child: BlocBuilder<DecorationDetailCubit, DecorationDetailState>(
                builder: (context, state) {
                  if (state is DecorationDetailLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (state is DecorationDetailError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  if (state is DecorationDetailLoaded) {
                    return LayoutBuilder(
                      builder: (layoutContext, constraints) {
                        if (constraints.maxWidth > 1000) {
                          return _buildDesktopLayout(layoutContext, state.detail);
                        } else if (constraints.maxWidth > 700) {
                          return _buildTabletLayout(layoutContext, state.detail);
                        } else {
                          return _buildMobileLayout(layoutContext, state.detail);
                        }
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Layouts ---

  Widget _buildMobileLayout(BuildContext context, PublicDecorationDetail detail) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BookingProgressBar(currentStep: 1, totalSteps: 4),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Venue Location",
                      style: AppTextStyles.headingL,
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.addressList).then((_) {
                        context.read<AddressCubit>().fetchAddresses();
                      }),
                      child: Text(
                        'MANAGE',
                        style: AppTextStyles.labelS.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose where you'd like your Meeveduka experience to be set up.",
                  style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                _buildAddressSelectionList(context),
                _AddAddressButton(onTap: () => context.push(AppRoutes.addAddress).then((_) {
                  context.read<AddressCubit>().fetchAddresses();
                })),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
        _StickyBottomBar(
          onContinue: () {
            final addressState = context.read<AddressCubit>().state;
            if (addressState is AddressLoaded && selectedAddressId != null) {
              final address = addressState.addresses.firstWhere((a) => a.id == selectedAddressId);
              context.push(
                AppRoutes.selectEventDate.replaceAll(':id', widget.decorationId),
                extra: BookingArgs(
                  decorationDetail: detail,
                  address: address,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, PublicDecorationDetail detail) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BookingProgressBar(currentStep: 1, totalSteps: 4),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Venue Location",
                          style: AppTextStyles.headingL,
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.addressList).then((_) {
                            context.read<AddressCubit>().fetchAddresses();
                          }),
                          child: Text(
                            'MANAGE ADDRESSES',
                            style: AppTextStyles.labelS.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Specify the location where our experts will bring your chosen wedding theme to life.",
                      style: AppTextStyles.bodyL.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    _buildAddressSelectionList(context),
                    _AddAddressButton(onTap: () => context.push(AppRoutes.addAddress).then((_) {
                      context.read<AddressCubit>().fetchAddresses();
                    })),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            _StickyBottomBar(
              onContinue: () {
                final addressState = context.read<AddressCubit>().state;
                if (addressState is AddressLoaded && selectedAddressId != null) {
                  final address = addressState.addresses.firstWhere((a) => a.id == selectedAddressId);
                  context.push(
                    AppRoutes.selectEventDate.replaceAll(':id', widget.decorationId),
                    extra: BookingArgs(
                      decorationDetail: detail,
                      address: address,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, PublicDecorationDetail detail) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Addresses
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _BookingProgressBar(currentStep: 1, totalSteps: 4),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Venue Location",
                            style: AppTextStyles.headingXL,
                          ),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.addressList).then((_) {
                              context.read<AddressCubit>().fetchAddresses();
                            }),
                            child: Text(
                              'MANAGE ADDRESSES',
                              style: AppTextStyles.labelM.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Specifying your venue location allows our styling and logistics teams to plan your Meeveduka experience with precision.",
                        style: AppTextStyles.bodyL.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildAddressSelectionList(context),
                      _AddAddressButton(onTap: () => context.push(AppRoutes.addAddress).then((_) {
                        context.read<AddressCubit>().fetchAddresses();
                      })),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 80),
              // Right side: Sticky Summary
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _BookingSummaryCard(detail: detail),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: 'PROCEED TO CALENDAR',
                        isLoading: false,
                        onPressed: selectedAddressId == null
                            ? null
                            : () {
                                final addressState = context.read<AddressCubit>().state;
                                if (addressState is AddressLoaded) {
                                  final address = addressState.addresses
                                      .firstWhere((a) => a.id == selectedAddressId);
                                  context.push(
                                    AppRoutes.selectEventDate.replaceAll(':id', widget.decorationId),
                                    extra: BookingArgs(
                                      decorationDetail: detail,
                                      address: address,
                                    ),
                                  );
                                }
                              },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSelectionList(BuildContext context) {
    return BlocConsumer<AddressCubit, AddressState>(
      listener: (context, state) {
        if (state is AddressLoaded && selectedAddressId == null && state.addresses.isNotEmpty) {
          final defaultAddr = state.addresses.any((a) => a.isDefault)
              ? state.addresses.firstWhere((a) => a.isDefault)
              : state.addresses.first;
          setState(() => selectedAddressId = defaultAddr.id);
        }
      },
      builder: (context, state) {
        if (state is AddressLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        if (state is AddressLoaded) {
          return Column(
            children: state.addresses.map((addr) => _AddressCard(
              address: addr,
              isSelected: selectedAddressId == addr.id,
              onTap: () => setState(() => selectedAddressId = addr.id),
            )).toList(),
          );
        }
        if (state is AddressEmpty) {
          return _buildEmptyAddressState();
        }
        if (state is AddressFailure) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyAddressState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentRose.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_off_outlined, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            "No saved locations",
            style: AppTextStyles.headingS,
          ),
          const SizedBox(height: 8),
          Text(
            "Add the address where you want us to create the magic.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// --- Components ---

class _BookingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _BookingProgressBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RESERVATION STEP $currentStep',
              style: AppTextStyles.labelS.copyWith(
                color: AppColors.textHint,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '${(currentStep / totalSteps * 100).round()}% Completed',
              style: AppTextStyles.labelS.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              height: 6,
              width: MediaQuery.of(context).size.width * (currentStep / totalSteps),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressEntity address;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.divider,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.addressType,
                          style: AppTextStyles.headingS.copyWith(fontSize: 16),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentRose.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'PRIMARY',
                              style: AppTextStyles.labelS.copyWith(
                                color: AppColors.primary,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${address.fullName} • ${address.mobileNumber}',
                      style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${address.houseNo}, ${address.area}, ${address.city}, ${address.state} ${address.pincode}',
                      style: AppTextStyles.bodyM.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Radio<String>(
                    value: address.id ?? '',
                    groupValue: isSelected ? address.id : '',
                    onChanged: (_) => onTap(),
                    activeColor: AppColors.primary,
                  ),
                  _buildMenu(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        final isDeleting = state is AddressDeleting && state.addressId == address.id;

        if (isDeleting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          );
        }

        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textHint, size: 20),
          padding: EdgeInsets.zero,
          elevation: 8,
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (value) async {
            if (value == 'delete') {
              final confirmed = await _showDeleteConfirmation(context);
              if (confirmed == true && context.mounted) {
                context.read<AddressCubit>().deleteAddress(address.id!);
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  const SizedBox(width: 12),
                  Text('Remove', style: AppTextStyles.bodyM.copyWith(color: AppColors.error)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    final state = context.read<AddressCubit>().state;
    if (state is AddressLoaded) {
      if (state.addresses.length == 1 && address.isDefault) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Primary address is required for service delivery."),
            backgroundColor: AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return Future.value(false);
      }
    }

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text('Remove Location', style: AppTextStyles.headingS),
        content: Text('Are you sure you want to remove this address?', style: AppTextStyles.bodyM),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('CANCEL', style: AppTextStyles.labelM.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('REMOVE', style: AppTextStyles.labelM.copyWith(color: AppColors.error, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData = Icons.location_on_outlined;
    final type = address.addressType.toLowerCase();
    if (type.contains('home')) iconData = Icons.home_outlined;
    if (type.contains('work')) iconData = Icons.work_outline;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accentRose.withOpacity(0.3) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: isSelected ? AppColors.primary : AppColors.textHint,
        size: 24,
      ),
    );
  }
}

class _AddAddressButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAddressButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: AppColors.divider,
            strokeWidth: 2,
            radius: 24,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: AppColors.surface.withOpacity(0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_location_alt_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Add New Venue Location',
                  style: AppTextStyles.labelM.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth/2, strokeWidth/2, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    ));

    final dashPath = _buildDashedPath(path, 12, 6);
    canvas.drawPath(dashPath, paint);
  }

  Path _buildDashedPath(Path source, double dashWidth, double dashSpace) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = draw ? dashWidth : dashSpace;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BookingSummaryCard extends StatelessWidget {
  final PublicDecorationDetail detail;

  const _BookingSummaryCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              'EXPERIENCE SUMMARY',
              style: AppTextStyles.labelS.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: AppColors.textHint,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    detail.firstImageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.divider, width: 70, height: 70),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.eventTypeName.toUpperCase(),
                        style: AppTextStyles.labelS.copyWith(
                          color: AppColors.primary,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail.name,
                        style: AppTextStyles.headingS.copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'By Meeveduka Curated',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _SummaryRow(label: 'Location', value: detail.cityName),
          _SummaryRow(label: 'Occasion', value: detail.eventTypeName),
          _SummaryRow(label: 'Base Styling', value: detail.formattedPrice),
          _SummaryRow(label: 'Service Fee', value: '₹150'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Investment',
                  style: AppTextStyles.bodyL.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  '₹${(detail.price + 150).toInt()}',
                  style: AppTextStyles.price.copyWith(fontSize: 24, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StickyBottomBar extends StatelessWidget {
  final VoidCallback onContinue;

  const _StickyBottomBar({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: PrimaryButton(
        text: 'PROCEED TO CALENDAR',
        onPressed: onContinue,
      ),
    );
  }
}
