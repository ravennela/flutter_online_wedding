import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bookings_bloc.dart';

class BookingFilterBar extends StatelessWidget {
  const BookingFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBookingsBloc, AdminBookingsState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _buildMobileFilters(context, state);
            } else if (constraints.maxWidth < 1024) {
              return _buildTabletFilters(context, state);
            } else {
              return _buildDesktopFilters(context, state);
            }
          },
        );
      },
    );
  }

  Widget _buildDesktopFilters(BuildContext context, AdminBookingsState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: _buildSearchField(context, state),
          ),
          SizedBox(
            width: 150,
            child: _buildDropdown(
              'Status',
              ['All', 'Requested', 'Approved', 'Confirmed', 'Cancelled'],
              state.selectedStatus ?? 'All',
              (val) => context.read<AdminBookingsBloc>().add(UpdateFilters(status: val)),
            ),
          ),
          SizedBox(
            width: 150,
            child: _buildDropdown(
              'Payment',
              ['All', 'Pending', 'Success', 'Failed'],
              state.selectedPaymentStatus ?? 'All',
              (val) => context.read<AdminBookingsBloc>().add(UpdateFilters(paymentStatus: val)),
            ),
          ),
          SizedBox(
            width: 150,
            child: _buildDropdown(
              'City',
              ['All Cities', 'Delhi', 'Hyderabad', 'Bangalore', 'Mumbai'],
              state.selectedCity ?? 'All Cities',
              (val) => context.read<AdminBookingsBloc>().add(UpdateFilters(city: val)),
            ),
          ),
          _buildDateRangeButton(),
          _buildClearButton(context),
          _buildExportButton(),
        ],
      ),
    );
  }

  Widget _buildTabletFilters(BuildContext context, AdminBookingsState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 250,
            child: _buildSearchField(context, state),
          ),
          SizedBox(
            width: 140,
            child: _buildDropdown(
              'Status',
              ['All', 'Requested', 'Approved', 'Confirmed', 'Cancelled'],
              state.selectedStatus ?? 'All',
              (val) => context.read<AdminBookingsBloc>().add(UpdateFilters(status: val)),
            ),
          ),
          SizedBox(
            width: 140,
            child: _buildDropdown(
              'Payment',
              ['All', 'Pending', 'Success', 'Failed'],
              state.selectedPaymentStatus ?? 'All',
              (val) => context.read<AdminBookingsBloc>().add(UpdateFilters(paymentStatus: val)),
            ),
          ),
          SizedBox(
            width: 140,
            child: _buildDropdown(
              'City',
              ['All Cities', 'Delhi', 'Hyderabad', 'Bangalore', 'Mumbai'],
              state.selectedCity ?? 'All Cities',
              (val) => context.read<AdminBookingsBloc>().add(UpdateFilters(city: val)),
            ),
          ),
          _buildDateRangeButton(),
          _buildClearButton(context),
          _buildExportButton(),
        ],
      ),
    );
  }

  Widget _buildMobileFilters(BuildContext context, AdminBookingsState state) {
    return Row(
      children: [
        Expanded(child: _buildSearchField(context, state)),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: () => _showMobileFilterBottomSheet(context, state),
          icon: const Icon(Icons.filter_list),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context, AdminBookingsState state) {
    return TextField(
      onChanged: (val) {
        // You might want to debounce this
        // context.read<AdminBookingsBloc>().add(UpdateFilters(query: val));
      },
      decoration: InputDecoration(
        hintText: 'Search bookings...',
        prefixIcon: const Icon(Icons.search, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        fillColor: Colors.grey.shade50,
        filled: true,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : items[0],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateRangeButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.calendar_today, size: 16),
      label: const Text('Date Range'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.read<AdminBookingsBloc>().add(const UpdateFilters(
          status: 'All',
          city: 'All Cities',
          paymentStatus: 'All',
          query: '',
        ));
      },
      child: const Text('Clear'),
    );
  }

  Widget _buildExportButton() {
    return ElevatedButton.icon(
      onPressed: null, // Disabled
      icon: const Icon(Icons.download, size: 16),
      label: const Text('Export'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showMobileFilterBottomSheet(BuildContext context, AdminBookingsState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bContext) {
        return BlocProvider.value(
          value: context.read<AdminBookingsBloc>(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(bContext).viewInsets.bottom + 20),
            child: BlocBuilder<AdminBookingsBloc, AdminBookingsState>(
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    _buildDropdown(
                      'Status',
                      ['All', 'Requested', 'Approved', 'Confirmed', 'Cancelled'],
                      state.selectedStatus ?? 'All',
                      (val) => context.read<AdminBookingsBloc>().add(UpdateFilters(status: val)),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      'Payment',
                      ['All', 'Pending', 'Success', 'Failed'],
                      state.selectedPaymentStatus ?? 'All',
                      (val) => context.read<AdminBookingsBloc>().add(UpdateFilters(paymentStatus: val)),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      'City',
                      ['All Cities', 'Delhi', 'Hyderabad', 'Bangalore', 'Mumbai'],
                      state.selectedCity ?? 'All Cities',
                      (val) => context.read<AdminBookingsBloc>().add(UpdateFilters(city: val)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildClearButton(context)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(bContext),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
