import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
                subtitle: 'Essential for scheduling delivery and event logistics support.',
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
                hintText: 'Enter 10-digit number',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Phone number is required';
                  if (value.length < 10) return 'Enter a valid 10-digit number';
                  return null;
                },
              ),
              const SizedBox(height: 48),

              // Address Details
              const SectionHeader(
                icon: Icons.location_on_outlined,
                title: 'Address Details',
                subtitle: 'Specify the precise location for venue styling and installations.',
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _address1Controller,
                label: 'House / Office Number',
                hintText: 'Unit number, building name',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Building info is required';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _address2Controller,
                label: 'Street & Area',
                hintText: 'Locality or prominent street name',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Area is required';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _landmarkController,
                label: 'Landmark',
                hintText: 'e.g. Near Rose Garden park',
                isOptional: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      label: 'City',
                      hintText: 'City name',
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
                      hintText: 'State name',
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
                      label: 'Pincode',
                      hintText: '6-digit code',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (value.length < 6) return 'Invalid pincode';
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
              const SizedBox(height: 48),

              // Options
              const SectionHeader(
                icon: Icons.bookmark_border_rounded,
                title: 'Label & Preference',
              ),
              const SizedBox(height: 24),
              Text(
                'SAVE AS',
                style: AppTextStyles.labelS.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
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
                    selectedColor: AppColors.accentRose.withOpacity(0.35),
                    backgroundColor: AppColors.surface,
                    labelStyle: AppTextStyles.labelM.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Use as primary address',
                    style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Switch.adaptive(
                    value: _isDefault,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setState(() => _isDefault = value),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'This address will be selected by default for your new bookings.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
              ),
              const SizedBox(height: 48),

              // Buttons (Web style - aligned right inside card)
              if (MediaQuery.of(context).size.width > 900)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'DISCARD',
                        style: AppTextStyles.labelM.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2),
                      ),
                    ),
                    const SizedBox(width: 20),
                    PrimaryButton(
                      text: 'SAVE EXPERIENCE LOCATION',
                      width: 280,
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
