import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../di/service_locator.dart';
import '../../domain/entities/vendor_entity.dart';
import '../bloc/vendor_bloc.dart';
import '../bloc/vendor_event.dart';
import '../bloc/vendor_state.dart';
import '../../../presentation/widgets/admin_scaffold.dart';

class AdminVendorsPage extends StatelessWidget {
  const AdminVendorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VendorBloc>()..add(GetVendorsEvent()),
      child: const _AdminVendorsContentWrapper(),
    );
  }
}

class _AdminVendorsContentWrapper extends StatelessWidget {
  const _AdminVendorsContentWrapper();

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Vendors',
      selectedIndex: 4, // Index for Vendors in sidebar
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 1000;
          return _VendorsContent(isMobile: isMobile);
        },
      ),
    );
  }
}

class _VendorsContent extends StatefulWidget {
  final bool isMobile;
  const _VendorsContent({required this.isMobile});

  @override
  State<_VendorsContent> createState() => _VendorsContentState();
}

class _VendorsContentState extends State<_VendorsContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = !widget.isMobile;
    final horizontalPadding = isDesktop ? 32.0 : 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        widget.isMobile ? 16 : 32,
        horizontalPadding,
        48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop) _buildDesktopHeader(context),
              if (isDesktop) const SizedBox(height: 32),
              _buildSearchAndFilters(context, isDesktop),
              const SizedBox(height: 24),
              _buildVendorList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vendors',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1F36),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage all registered vendors',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vendors...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) {
                // Ideally add debounce and filter local list or trigger API search
              },
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => context.read<VendorBloc>().add(GetVendorsEvent()),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildVendorList(BuildContext context) {
    return BlocBuilder<VendorBloc, VendorState>(
      builder: (context, state) {
        if (state is VendorLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is VendorError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                   const Icon(Icons.error_outline, color: Colors.red, size: 48),
                   const SizedBox(height: 16),
                   Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<VendorBloc>().add(GetVendorsEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is VendorLoaded) {
          final vendors = state.vendors;
          if (vendors.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vendors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _VendorCard(vendor: vendors[index], isMobile: widget.isMobile);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No vendors found',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final VendorEntity vendor;
  final bool isMobile;
  const _VendorCard({required this.vendor, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isMobile ? _buildMobileRow() : _buildDesktopRow(),
      ),
    );
  }

  Widget _buildDesktopRow() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.business, color: Colors.blue.shade600, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vendor.companyName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                vendor.serviceType,
                style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phone', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(vendor.phone, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(width: 32),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rating', style: TextStyle(color: Colors.grey, fontSize: 12)),
             Row(
               children: [
                 const Icon(Icons.star, color: Colors.amber, size: 16),
                 const SizedBox(width: 4),
                 Text(vendor.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
               ],
             ),
          ],
        ),
        const SizedBox(width: 32),
        _StatusBadge(isActive: vendor.active),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Widget _buildMobileRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(
              vendor.companyName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
             _StatusBadge(isActive: vendor.active),
          ],
        ),
        const SizedBox(height: 8),
         Text(
          vendor.serviceType,
          style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.phone, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(vendor.phone, style: const TextStyle(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 14),
            const SizedBox(width: 4),
            Text(vendor.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
