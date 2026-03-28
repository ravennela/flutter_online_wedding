import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/admin/vendors/domain/entities/vendor_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_online/features/admin/bookings/presentation/bloc/admin_booking_detail_bloc.dart';
import 'package:flutter_online/features/admin/vendors/presentation/bloc/vendor_bloc.dart';
import 'package:flutter_online/features/admin/vendors/presentation/bloc/vendor_event.dart';
import 'package:flutter_online/features/admin/vendors/presentation/bloc/vendor_state.dart';
import 'package:flutter_online/features/decorations/presentation/bloc/admin_decoration_list_bloc.dart';
import 'package:flutter_online/features/admin/presentation/widgets/admin_scaffold.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';

class EditBookingPage extends StatefulWidget {
  final String bookingId;

  const EditBookingPage({super.key, required this.bookingId});

  @override
  State<EditBookingPage> createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _totalAmountController;
  late TextEditingController _advanceAmountController;
  late TextEditingController _noteController;
  
  List<String> _selectedVendorIds = [];
  String? _selectedDecorationId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedStatus;
  String? _initialVendorName;
  String? _initialDecorationName;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _totalAmountController = TextEditingController();
    _advanceAmountController = TextEditingController();
    _noteController = TextEditingController();
    
    // Load vendors and decorations
    context.read<VendorBloc>().add(GetVendorsEvent(bookingId: widget.bookingId));
    context.read<AdminDecorationListBloc>().add(LoadAdminDecorations(size: 100));
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _advanceAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _initializeData(AdminBookingDetailStatus status, var booking) {
    if (status == AdminBookingDetailStatus.success && booking != null && !_isInitialized) {
      _totalAmountController.text = booking.totalAmount.toString();
      _advanceAmountController.text = booking.advanceAmount?.toString() ?? '0';
      _noteController.text = booking.customerNote ?? '';
      
      _selectedVendorIds = booking.assignedVendors.isNotEmpty 
          ? booking.assignedVendors.map((v) => v['id']!).toList().cast<String>()
          : (booking.vendorId != null ? [booking.vendorId!] : []);
      _initialVendorName = booking.vendorName;
      _selectedDecorationId = booking.decorationId;
      _initialDecorationName = booking.decoration;
      _selectedStatus = booking.status;
      
      try {
        _selectedDate = DateFormat('yyyy-MM-dd').parse(booking.eventDate);
      } catch (_) {
        _selectedDate = DateTime.now();
      }
      
      // Time is usually not in the detail entity in current implementation but we'll assume it if it was added
      _selectedTime = const TimeOfDay(hour: 10, minute: 0);
      
      _isInitialized = true;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'vendorIds': _selectedVendorIds,
        'decorationId': _selectedDecorationId ?? "",
        'totalAmount': double.tryParse(_totalAmountController.text),
        'advanceAmount': double.tryParse(_advanceAmountController.text),
        'eventDate': _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
        'eventTime': _selectedTime != null ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00' : null,
        'status': _selectedStatus,
        'note': _noteController.text,
      };

      context.read<AdminBookingDetailBloc>().add(UpdateBookingDetail(widget.bookingId, data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Edit Booking',
      selectedIndex: 2,
      body: BlocConsumer<AdminBookingDetailBloc, AdminBookingDetailState>(
        listener: (context, state) {
          if (state.status == AdminBookingDetailStatus.updateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking updated successfully'), backgroundColor: Colors.green),
            );
            context.pop();
          } else if (state.status == AdminBookingDetailStatus.updateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Update failed'), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state.status == AdminBookingDetailStatus.loading && !_isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state.status == AdminBookingDetailStatus.failure && !_isInitialized) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          _initializeData(state.status, state.booking);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Booking Information'),
                  const SizedBox(height: 16),
                  _buildVendorDropdown(),
                  const SizedBox(height: 16),
                  _buildDecorationDropdown(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Total Amount', _totalAmountController, isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Advance Amount', _advanceAmountController, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPickerField(
                          'Event Date',
                          _selectedDate == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                          Icons.calendar_today,
                          () => _selectDate(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPickerField(
                          'Event Time',
                          _selectedTime == null ? 'Select Time' : _selectedTime!.format(context),
                          Icons.access_time,
                          () => _selectTime(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatusDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField('Note', _noteController, maxLines: 3),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.status == AdminBookingDetailStatus.updating ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: state.status == AdminBookingDetailStatus.updating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headingS.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelM),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPickerField(String label, String value, IconData icon, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelM),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey),
                const SizedBox(width: 12),
                Text(value, style: AppTextStyles.bodyM),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorDropdown() {
    return BlocBuilder<VendorBloc, VendorState>(
      builder: (context, state) {
        if (state is VendorLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<VendorEntity> vendors = [];
        if (state is VendorLoaded) {
          vendors = state.vendors;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Assign Vendors', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                TextButton.icon(
                  onPressed: () => _showMultiVendorSelect(context, vendors),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedVendorIds.isEmpty)
              const Text('No vendors assigned', style: TextStyle(color: Colors.grey, fontSize: 13))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedVendorIds.map((id) {
                  String name = 'Unknown Vendor';
                  if (state is VendorLoaded) {
                    final v = state.vendors.where((v) => v.id == id).firstOrNull;
                    if (v != null) name = v.companyName;
                  } else if (id == _selectedVendorIds.first) {
                    name = _initialVendorName ?? 'Initial Vendor';
                  }

                  return Chip(
                    label: Text(name, style: const TextStyle(fontSize: 12)),
                    onDeleted: () {
                      setState(() {
                        _selectedVendorIds.remove(id);
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  void _showMultiVendorSelect(BuildContext context, List<VendorEntity> vendors) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Vendors'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: vendors.length,
                  itemBuilder: (context, index) {
                    final vendor = vendors[index];
                    final isSelected = _selectedVendorIds.contains(vendor.id);
                    return CheckboxListTile(
                      title: Text(vendor.companyName),
                      subtitle: Text(vendor.city??""),
                      value: isSelected,
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true) {
                            _selectedVendorIds.add(vendor.id);
                          } else {
                            _selectedVendorIds.remove(vendor.id);
                          }

                          // Consistency Rule: If vendors are added to a REQUESTED booking, promote to VENDOR_ASSIGNED
                          if (_selectedVendorIds.isNotEmpty && _selectedStatus?.toUpperCase() == 'REQUESTED') {
                             _selectedStatus = 'VENDOR_ASSIGNED';
                          }
                          // Consistency Rule: If all vendors are removed from a VENDOR_ASSIGNED booking, revert to REQUESTED
                          if (_selectedVendorIds.isEmpty && _selectedStatus?.toUpperCase() == 'VENDOR_ASSIGNED') {
                             _selectedStatus = 'REQUESTED';
                          }
                        });
                        setState(() {}); // Update the main page
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDecorationDropdown() {
    return BlocBuilder<AdminDecorationListBloc, AdminDecorationListState>(
      builder: (context, state) {
        List<DropdownMenuItem<String>> items = [
          const DropdownMenuItem(value: null, child: Text('No Decoration'))
        ];
        
        if (state is AdminDecorationListLoaded) {
          items.addAll(state.response.content.map((d) => DropdownMenuItem(
            value: d.id,
            child: Text(d.name),
          )));
        }

        // Safety check: ensure _selectedDecorationId is in items
        if (_selectedDecorationId != null && !items.any((item) => item.value == _selectedDecorationId)) {
          items.add(DropdownMenuItem(
            value: _selectedDecorationId,
            child: Text(_initialDecorationName ?? 'Current Decoration (Unknown Name)'),
          ));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Decoration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDecorationId,
              items: items,
              onChanged: (val) => setState(() => _selectedDecorationId = val),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusDropdown() {
    final statuses = ['REQUESTED', 'VENDOR_ASSIGNED', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'];
    
    // Ensure the current status is in the list to avoid assertion error
    final currentStatus = _selectedStatus?.toUpperCase();
    if (currentStatus != null && !statuses.contains(currentStatus)) {
      statuses.add(currentStatus);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Booking Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentStatus,
          items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ')))).toList(),
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              // Consistency Rule: Prevent setting REQUESTED if vendors are assigned
              if (val.toUpperCase() == 'REQUESTED' && _selectedVendorIds.isNotEmpty) {
                _selectedStatus = 'VENDOR_ASSIGNED';
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot set status to REQUESTED while vendors are assigned.'), duration: Duration(seconds: 2)),
                );
              } 
              // Consistency Rule: Prevent setting VENDOR_ASSIGNED if no vendors are assigned
              else if (val.toUpperCase() == 'VENDOR_ASSIGNED' && _selectedVendorIds.isEmpty) {
                 _selectedStatus = 'REQUESTED';
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please assign at least one vendor to use VENDOR_ASSIGNED status.'), duration: Duration(seconds: 2)),
                );
              }
              else {
                _selectedStatus = val;
              }
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
