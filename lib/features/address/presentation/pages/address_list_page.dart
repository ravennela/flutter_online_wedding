import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:go_router/go_router.dart';
import '../cubit/address_cubit.dart';
import '../cubit/address_state.dart';
import '../../domain/models/address_entity.dart';

class AddressListPage extends StatelessWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AddressCubit>()..fetchAddresses(),
      child: const _AddressListView(),
    );
  }
}

class _AddressListView extends StatelessWidget {
  const _AddressListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Saved Locations',
          style: AppTextStyles.headingM,
        ),
        centerTitle: true,
      ),
      body: BlocListener<AddressCubit, AddressState>(
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
                content: Text('Address removed from profile'),
                backgroundColor: AppColors.textPrimary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<AddressCubit, AddressState>(
          buildWhen: (previous, current) =>
              current is! AddressFailure && current is! AddressDeleteSuccess,
          builder: (context, state) {
            if (state is AddressLoading) {
              return _buildShimmerLoader();
            } else if (state is AddressEmpty) {
              return _buildEmptyState(context);
            } else if (state is AddressLoaded || state is AddressDeleting) {
              return _buildAddressList(context);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addAddress).then((_) {
          context.read<AddressCubit>().fetchAddresses();
        }),
        backgroundColor: AppColors.textPrimary,
        elevation: 8,
        icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white, size: 20),
        label: Text(
          'ADD NEW LOCATION',
          style: AppTextStyles.labelM.copyWith(color: Colors.white, letterSpacing: 1.2, fontWeight: FontWeight.w800),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildAddressList(BuildContext context) {
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        List<AddressEntity> addresses = [];
        if (state is AddressLoaded) {
          addresses = state.addresses;
        } else if (state is AddressDeleting) {
          addresses = state.currentAddresses;
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          itemCount: addresses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            return _AddressCard(
              address: addresses[index],
              allAddresses: addresses,
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          height: 160,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 48, height: 48, decoration: const BoxDecoration(color: AppColors.divider, shape: BoxShape.circle)),
                    const SizedBox(width: 16),
                    Container(width: 100, height: 20, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(6))),
                  ],
                ),
                const SizedBox(height: 24),
                Container(width: 180, height: 24, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 12),
                Container(width: double.infinity, height: 16, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, 20))
                ],
              ),
              child: const Icon(Icons.location_off_outlined, size: 80, color: AppColors.accentRose),
            ),
            const SizedBox(height: 48),
            Text(
              'No Saved Locations',
              textAlign: TextAlign.center,
              style: AppTextStyles.headingL,
            ),
            const SizedBox(height: 16),
            Text(
              'Your curated experience requires a venue. Add the locations where you would like us to create magic.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyL.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressEntity address;
  final List<AddressEntity> allAddresses;

  const _AddressCard({
    required this.address,
    required this.allAddresses,
  });

  @override
  Widget build(BuildContext context) {
    final isDefault = address.isDefault;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDefault ? AppColors.primary.withOpacity(0.4) : AppColors.divider,
          width: isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeIllustration(),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                address.addressType.toUpperCase(),
                                style: AppTextStyles.labelS.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              if (isDefault) ...[
                                const SizedBox(width: 12),
                                _buildPrimaryBadge(),
                              ],
                            ],
                          ),
                          _buildCustomMenu(context),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        address.fullName,
                        style: AppTextStyles.headingS.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.mobileNumber,
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1, color: AppColors.divider),
                      ),
                      Text(
                        '${address.houseNo}, ${address.area}\n${address.city}, ${address.state} - ${address.pincode}',
                        style: AppTextStyles.bodyM.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIllustration() {
    IconData icon;
    switch (address.addressType.toUpperCase()) {
      case 'HOME': icon = Icons.home_rounded; break;
      case 'WORK': icon = Icons.business_center_rounded; break;
      default: icon = Icons.map_rounded;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentRose.withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  Widget _buildPrimaryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'PRIMARY',
        style: AppTextStyles.labelS.copyWith(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildCustomMenu(BuildContext context) {
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        final isDeleting = state is AddressDeleting && state.addressId == address.id;

        if (isDeleting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
          );
        }

        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint, size: 24),
          padding: EdgeInsets.zero,
          elevation: 12,
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onSelected: (value) {
            if (value == 'delete') _showPremiumDeleteDialog(context);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_note_rounded, size: 20, color: AppColors.textPrimary),
                  const SizedBox(width: 12),
                  Text('Edit Venue', style: AppTextStyles.bodyM),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
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

  void _showPremiumDeleteDialog(BuildContext context) {
    if (allAddresses.length == 1 && address.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A primary location is required for Meeveduka bookings."),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Text('Remove Location', style: AppTextStyles.headingS),
        content: Text(
          'Are you sure you want to remove this venue location from your profile?',
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('CANCEL', style: AppTextStyles.labelM),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AddressCubit>().deleteAddress(address.id!);
            },
            child: Text('REMOVE', style: AppTextStyles.labelM.copyWith(color: AppColors.error, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
