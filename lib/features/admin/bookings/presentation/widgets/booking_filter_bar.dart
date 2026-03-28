import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bookings_bloc.dart';

class BookingFilterBar extends StatefulWidget {
  const BookingFilterBar({super.key});

  @override
  State<BookingFilterBar> createState() => _BookingFilterBarState();
}

class _BookingFilterBarState extends State<BookingFilterBar> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final state = context.read<AdminBookingsBloc>().state;
    _searchController = TextEditingController(text: state.searchQuery);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBookingsBloc, AdminBookingsState>(
      listenWhen: (previous, current) => previous.searchQuery != current.searchQuery,
      listener: (context, state) {
        if (_searchController.text != state.searchQuery) {
          _searchController.text = state.searchQuery ?? '';
        }
      },
      child: BlocBuilder<AdminBookingsBloc, AdminBookingsState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return _buildMobileFilters(context, state);
              }
              return _buildDesktopFilters(context, state);
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopFilters(BuildContext context, AdminBookingsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 90, // Increased height to prevent vertical overflow with labels
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 220,
                    child: _buildSearchField(context, state),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusDropdown(context, state),
                  const SizedBox(width: 12),
                  _buildPaymentDropdown(context, state),
                  const SizedBox(width: 12),
                  _buildCityDropdown(context, state),
                  const SizedBox(width: 12),
                  _buildEventDropdown(context, state),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 200,
                    child: _buildDateRangeButton(context, state),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: _buildClearButton(context),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: _buildExportButton(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, AdminBookingsState state) {
    return SizedBox(
      width: 180,
      child: _buildDropdown(
        'Status',
        ['All', 'Requested', 'Approved', 'Confirmed', 'Cancelled', 'VENDOR_ASSIGNED', 'COMPLETED'],
        state.selectedStatus ?? 'All',
        (val) => context.read<AdminBookingsBloc>().add(UpdateFilters(status: val)),
      ),
    );
  }

  Widget _buildPaymentDropdown(BuildContext context, AdminBookingsState state) {
    return SizedBox(
      width: 140,
      child: _buildDropdown(
        'Payment',
        ['All', 'Pending', 'Success', 'Failed'],
        state.selectedPaymentStatus ?? 'All',
        (val) => context.read<AdminBookingsBloc>().add(UpdateFilters(paymentStatus: val)),
      ),
    );
  }

  Widget _buildCityDropdown(BuildContext context, AdminBookingsState state) {
    return SizedBox(
      width: 140,
      child: _buildDropdown(
        'City',
        ['All Cities', 'Delhi', 'Hyderabad', 'Bangalore', 'Mumbai'],
        state.selectedCity ?? 'All Cities',
        (val) => context.read<AdminBookingsBloc>().add(UpdateFilters(city: val)),
      ),
    );
  }

  Widget _buildEventDropdown(BuildContext context, AdminBookingsState state) {
    final List<String> eventNames = ['All', ...state.eventTypes.map((e) => e.name)];
    String currentValue = 'All';
    if (state.selectedEventType != null && state.selectedEventType != 'All') {
      final selectedType = state.eventTypes.where((e) => e.id == state.selectedEventType).firstOrNull;
      if (selectedType != null) {
        currentValue = selectedType.name;
      }
    }

    return SizedBox(
      width: 220,
      child: _buildDropdown(
        'Event',
        eventNames,
        currentValue,
        (val) {
          if (val == 'All') {
            context.read<AdminBookingsBloc>().add(const UpdateFilters(eventType: 'All'));
          } else {
            final selectedType = state.eventTypes.where((e) => e.name == val).firstOrNull;
            if (selectedType != null) {
              context.read<AdminBookingsBloc>().add(UpdateFilters(eventType: selectedType.id));
            }
          }
        },
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
      controller: _searchController,
      onSubmitted: (val) {
        context.read<AdminBookingsBloc>().add(UpdateFilters(query: val));
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        fillColor: Colors.grey.shade50,
        filled: true,
        suffixIcon: (state.searchQuery != null && state.searchQuery!.isNotEmpty) || _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchController.clear();
                  context.read<AdminBookingsBloc>().add(const UpdateFilters(query: ''));
                },
              )
            : null,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : (items.isNotEmpty ? items[0] : null),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateRangeButton(BuildContext context, AdminBookingsState state) {
    String label = 'Date Range';
    if (state.selectedStartDate != null && state.selectedEndDate != null && state.selectedStartDate!.isNotEmpty) {
      label = '${state.selectedStartDate} - ${state.selectedEndDate}';
    }

    return OutlinedButton.icon(
      onPressed: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialDateRange: state.selectedStartDate != null && state.selectedEndDate != null && state.selectedStartDate!.isNotEmpty
              ? DateTimeRange(
                  start: DateTime.parse(state.selectedStartDate!),
                  end: DateTime.parse(state.selectedEndDate!),
                )
              : null,
        );

        if (picked != null) {
          if (mounted) {
            context.read<AdminBookingsBloc>().add(UpdateFilters(
                  startDate: picked.start.toIso8601String().split('T')[0],
                  endDate: picked.end.toIso8601String().split('T')[0],
                ));
          }
        }
      },
      icon: const Icon(Icons.calendar_today, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        _searchController.clear();
        context.read<AdminBookingsBloc>().add(const UpdateFilters(
              status: 'All',
              city: 'All Cities',
              paymentStatus: 'All',
              query: '',
              startDate: '',
              endDate: '',
              eventType: 'All',
            ));
      },
      child: const Text('Clear'),
    );
  }

  Widget _buildExportButton() {
    return ElevatedButton.icon(
      onPressed: null,
      icon: const Icon(Icons.download, size: 16),
      label: const Text('Export'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      ['All', 'Requested', 'Approved', 'Confirmed', 'Cancelled', 'VENDOR_ASSIGNED', 'COMPLETED'],
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
                    const SizedBox(height: 12),
                    _buildEventDropdown(context, state),
                    const SizedBox(height: 12),
                    _buildDateRangeButton(context, state),
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
