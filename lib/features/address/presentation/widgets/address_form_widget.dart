import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../cubit/add_address_cubit.dart';
import '../cubit/add_address_state.dart';
import '../../domain/models/address_entity.dart';

class AddressFormWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const AddressFormWidget({super.key, required this.formKey});

  @override
  State<AddressFormWidget> createState() => AddressFormWidgetState();
}

class AddressFormWidgetState extends State<AddressFormWidget> {
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');

  String _selectedAddressType = 'Home';
  bool _isDefault = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void submit() {
    if (widget.formKey.currentState!.validate()) {
      context.read<AddAddressCubit>().createAddress(
        AddressEntity(
          fullName: _nameController.text,
          mobileNumber: _phoneController.text,
          houseNo: _address1Controller.text,
          area: _address2Controller.text.isNotEmpty ? _address2Controller.text : 'N/A',
          landmark: _landmarkController.text,
          city: _cityController.text,
          state: _stateController.text,
          pincode: _pincodeController.text,
          addressType: _selectedAddressType.toUpperCase(),
          isDefault: _isDefault,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddAddressCubit, AddAddressState>(
      builder: (context, state) {
        return Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Information
              const SectionHeader(
                icon: Icons.person_outline,
                title: 'Contact Information',
                subtitle: 'Who should we contact for delivery and setup?',
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hintText: 'e.g. Alexandra Sterling',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Full name is required';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hintText: '+1 (555) 000-0000',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Phone number is required';
                  if (value.length < 10) return 'Enter a valid 10-digit number';
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Address Details
              const SectionHeader(
                icon: Icons.location_on_outlined,
                title: 'Address Details',
                subtitle: 'Provide the exact location for the venue.',
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _address1Controller,
                label: 'Street Address',
                hintText: '123 Elegance Avenue',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Address is required';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _address2Controller,
                label: 'Address Line 2',
                hintText: 'Apt, Suite, Floor',
                isOptional: true,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _landmarkController,
                label: 'Landmark',
                hintText: 'Nearby famous building',
                isOptional: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      label: 'City',
                      hintText: 'Los Angeles',
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      label: 'State',
                      hintText: 'California',
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _pincodeController,
                      label: 'Zip Code',
                      hintText: '90001',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (value.length < 5) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _countryController,
                      label: 'Country',
                      hintText: 'India',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Options
              const SectionHeader(
                icon: Icons.settings_outlined,
                title: 'Options',
              ),
              const SizedBox(height: 20),
              const Text(
                'ADDRESS TYPE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: ['Home', 'Work', 'Other'].map((type) {
                  final isSelected = _selectedAddressType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedAddressType = type);
                      }
                    },
                    selectedColor: const Color(0xFFEFF6FF),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Set as Default Address',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Switch.adaptive(
                    value: _isDefault,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (value) => setState(() => _isDefault = value),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Buttons (Web style - aligned right inside card)
              if (MediaQuery.of(context).size.width > 900)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    PrimaryButton(
                      text: 'Save Address',
                      width: 200,
                      onPressed: state is AddAddressLoading ? null : submit,
                      isLoading: state is AddAddressLoading,
                    ),
                  ],
                ),
                
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
