import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/admin/bookings/models/vendor_model.dart';
import 'package:flutter_online/features/admin/vendors/domain/entities/vendor_entity.dart';
import 'package:flutter_online/features/admin/vendors/presentation/bloc/vendor_bloc.dart';
import 'package:flutter_online/features/admin/vendors/presentation/bloc/vendor_event.dart';
import 'package:flutter_online/features/admin/vendors/presentation/bloc/vendor_state.dart';
import 'package:go_router/go_router.dart';
import '../../../../../di/service_locator.dart';
import '../bloc/admin_booking_detail_bloc.dart';
import '../widgets/vendor_card.dart';
import '../widgets/vendor_skeleton_card.dart';

class SelectVendorScreen extends StatelessWidget {
  final SelectVendorArgs args;

  const SelectVendorScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<VendorBloc>()
                ..add(GetVendorsEvent(bookingId: args.bookingId)),
        ),
        BlocProvider(create: (_) => getIt<AdminBookingDetailBloc>()),
      ],
      child: _SelectVendorContent(args: args),
    );
  }
}

class _SelectVendorContent extends StatefulWidget {
  final SelectVendorArgs args;
  const _SelectVendorContent({required this.args});

  @override
  State<_SelectVendorContent> createState() => _SelectVendorContentState();
}

class _SelectVendorContentState extends State<_SelectVendorContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All Categories';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBookingDetailBloc, AdminBookingDetailState>(
      listener: (context, state) {
        if (state.status == AdminBookingDetailStatus.assignSuccess) {
          _showSuccessDialog('Vendor assigned successfully');
        } else if (state.status == AdminBookingDetailStatus.assignFailure) {
          _showErrorSnackBar(state.errorMessage ?? 'Failed to assign vendor');
        } else if (state.status == AdminBookingDetailStatus.deAssignSuccess) {
          _showSuccessDialog('Vendor de-assigned successfully');
        } else if (state.status == AdminBookingDetailStatus.deAssignFailure) {
          _showErrorSnackBar(
            state.errorMessage ?? 'Failed to de-assign vendor',
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            Column(
              children: [
                _buildSearchAndFilters(),
                _buildFilterChips(),
                Expanded(
                  child: BlocBuilder<VendorBloc, VendorState>(
                    builder: (context, state) {
                      if (state is VendorLoading) {
                        return _buildLoadingGrid();
                      } else if (state is VendorError) {
                        return _buildErrorState(state.message);
                      } else if (state is VendorLoaded) {
                        return _buildVendorGrid(state.vendors);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                _buildFooter(),
              ],
            ),
            BlocBuilder<AdminBookingDetailBloc, AdminBookingDetailState>(
              builder: (context, state) {
                if (state.status == AdminBookingDetailStatus.assigning ||
                    state.status == AdminBookingDetailStatus.deAssigning) {
                  return Container(
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Vendor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            'For Booking #${widget.args.bookingCode}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFE2E8F0), height: 1),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search vendor name...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Color(0xFF64748B),
                size: 20,
              ),
              onPressed: () => context.read<VendorBloc>().add(
                GetVendorsEvent(bookingId: widget.args.bookingId),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      'All Categories',
      widget.args.city,
      'Rating 4.5+',
      'Active Only',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              selected: isSelected,
              onSelected: (val) {
                setState(() => _selectedFilter = filter);
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFF97316),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFF97316)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVendorGrid(List<VendorEntity> vendors) {
    final filteredVendors = vendors.where((v) {
      final query = _searchController.text.toLowerCase();
      final nameMatches =
          (v.companyName.toLowerCase().contains(query)) ||
          (v.name?.toLowerCase().contains(query) ?? false);

      if (!nameMatches) return false;

      if (_selectedFilter == 'Active Only' && !v.active) return false;
      if (_selectedFilter == 'Rating 4.5+' && v.rating < 4.5) return false;
      if (_selectedFilter == widget.args.city && v.city != widget.args.city)
        return false;

      return true;
    }).toList();

    if (filteredVendors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            const Text(
              'No vendors found matching your criteria.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'All Categories';
                  _searchController.clear();
                });
              },
              child: const Text('Reset Filters'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1000) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: filteredVendors.length,
          itemBuilder: (context, index) {
            final vendor = filteredVendors[index];
            return VendorCard(
              vendor: vendor,
              bookingCategory: widget.args.eventCategory,
              isAssigned: vendor.assigned ?? false,
              onAssign: () => _showAssignConfirmation(vendor),
              onDeAssign: () => _showDeAssignConfirmation(vendor),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1000) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => const VendorSkeletonCard(),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<VendorBloc>().add(
              GetVendorsEvent(bookingId: widget.args.bookingId),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAssignConfirmation(VendorEntity vendor) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text('Assign Vendor'),
        content: Text(
          'Are you sure you want to assign "${vendor.companyName}" to this booking?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(innerContext);
              context.read<AdminBookingDetailBloc>().add(
                AssignVendors(widget.args.bookingId, [vendor.id]),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showDeAssignConfirmation(VendorEntity vendor) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text('De-Assign Vendor'),
        content: Text(
          'Are you sure you want to de-assign "${vendor.companyName}" from this booking?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(innerContext);
              context.read<AdminBookingDetailBloc>().add(
                DeAssignVendor(widget.args.bookingId, vendor.id),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('De-Assign'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (innerContext) => AlertDialog(
        title: const Text('Done!'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(innerContext); // Close dialog
              context.pop(true); // Return true to indicate change
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
            ),
            child: const Text('Return to Booking Details'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Showing all available vendors',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPaginationButton(Icons.chevron_left, () {}),
              const SizedBox(width: 16),
              _buildPaginationButton(Icons.chevron_right, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
      ),
    );
  }
}
