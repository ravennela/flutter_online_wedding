import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/address/domain/models/address_entity.dart';
import 'package:flutter_online/features/address/presentation/cubit/address_cubit.dart';
import 'package:flutter_online/features/address/presentation/cubit/address_state.dart';
import 'package:flutter_online/features/booking/domain/models/booking_args.dart';
import 'package:flutter_online/features/decorations/domain/models/public_decoration_detail.dart';
import 'package:flutter_online/features/decorations/presentation/cubit/decoration_detail_cubit.dart';
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
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () {
                  // Always use go() to avoid pop() revealing a disposed route (didPopNext crash
                  // after login redirect). Back goes to decoration detail for this booking.
                  context.go('/decoration/${widget.decorationId}');
                },
              ),
              title: const Text(
                'Select Event Location',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
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
                          backgroundColor: const Color(0xFFEF4444),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                    if (state is AddressDeleteSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address deleted successfully'),
                          backgroundColor: Color(0xFF10B981),
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
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BookingProgressBar(currentStep: 1, totalSteps: 4),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Where's the event?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => context.push(AppRoutes.addressList).then((_) {
                        context.read<AddressCubit>().fetchAddresses();
                      }),
                      icon: const Icon(Icons.settings_outlined, size: 18),
                      label: const Text('Manage'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose a saved location or add a new one for your booking.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                _buildAddressSelectionList(context),
                _AddAddressButton(onTap: () => context.push(AppRoutes.addAddress).then((_) {
                  context.read<AddressCubit>().fetchAddresses();
                })),
                const SizedBox(height: 32),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BookingProgressBar(currentStep: 1, totalSteps: 4),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Where's the event?",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push(AppRoutes.addressList).then((_) {
                            context.read<AddressCubit>().fetchAddresses();
                          }),
                          icon: const Icon(Icons.settings_outlined, size: 18),
                          label: const Text('Manage'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Choose a saved location or add a new one for your booking.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildAddressSelectionList(context),
                    _AddAddressButton(onTap: () => context.push(AppRoutes.addAddress).then((_) {
                      context.read<AddressCubit>().fetchAddresses();
                    })),
                    const SizedBox(height: 32),
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
                          const Text(
                            "Where's the event?",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => context.push(AppRoutes.addressList).then((_) {
                              context.read<AddressCubit>().fetchAddresses();
                            }),
                            icon: const Icon(Icons.settings_outlined, size: 18),
                            label: const Text('Manage Addresses'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Choose a saved location or add a new one for your booking.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildAddressSelectionList(context),
                      _AddAddressButton(onTap: () => context.push(AppRoutes.addAddress).then((_) {
                        context.read<AddressCubit>().fetchAddresses();
                      })),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 60),
              // Right side: Sticky Summary
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _BookingSummaryCard(detail: detail),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFF3F4F6),
                            disabledForegroundColor: const Color(0xFF9CA3AF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40), // Bottom padding for summary list
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
        if (state is AddressLoaded && selectedAddressId == null) {
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
            child: Center(child: CircularProgressIndicator()),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(Icons.location_off_outlined, size: 48, color: Color(0xFF9BA3AF)),
          const SizedBox(height: 16),
          const Text(
            "No saved addresses yet",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add an address to proceed with your booking.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
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
    final percent = (currentStep / totalSteps * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STEP $currentStep OF $totalSteps',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const Text(
              'Checkout Progress',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PROGRESS',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            minHeight: 6,
          ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIcon(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address.addressType,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (address.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${address.fullName} • ${address.mobileNumber}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${address.houseNo}, ${address.area}, ${address.city}, ${address.state} ${address.pincode}',
                          style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Color(0xFF2563EB), size: 24)
                      else
                        const Icon(Icons.radio_button_off, color: Color(0xFFD1D5DB), size: 24),
                      const Spacer(),
                      _buildMenu(context),
                    ],
                  ),
                ],
              ),
            ),
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
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            ),
          );
        }

        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280), size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 120),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  Icon(Icons.delete_outline, size: 18, color: Colors.red[600]),
                  const SizedBox(width: 10),
                  Text('Delete', style: TextStyle(color: Colors.red[600])),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    // Check if it's the last default address
    final state = context.read<AddressCubit>().state;
    if (state is AddressLoaded) {
      if (state.addresses.length == 1 && address.isDefault) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You must keep at least one address."),
            backgroundColor: Color(0xFF64748B),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return Future.value(false);
      }
    }

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData = Icons.location_on;
    final type = address.addressType.toLowerCase();
    if (type.contains('home')) iconData = Icons.home;
    if (type.contains('work')) iconData = Icons.work;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: isSelected ? Colors.white : const Color(0xFF6B7280),
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
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: const Color(0xFFD1D5DB),
            strokeWidth: 1.5,
            radius: 16,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFF9FAFB),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Color(0xFF6B7280)),
                SizedBox(width: 8),
                Text(
                  'Add New Address',
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    ));

    final dashPath = _buildDashedPath(path, 8, 4);
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: const Text(
              'BOOKING SUMMARY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    detail.firstImageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DECORATION PACKAGE',
                        style: TextStyle(
                          color: const Color(0xFF2563EB),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        detail.providerName ?? 'Premium Floral Arrangement',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _SummaryRow(label: 'City', value: detail.cityName),
          _SummaryRow(label: 'Event Type', value: detail.eventTypeName),
          _SummaryRow(label: 'Base Price', value: detail.formattedPrice),
          _SummaryRow(label: 'Service Fee', value: '₹150'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  '₹${(detail.price + 150).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Color(0xFF2563EB),
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text(
            'Continue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
