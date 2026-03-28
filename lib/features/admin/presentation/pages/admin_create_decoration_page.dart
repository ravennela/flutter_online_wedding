import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/upload/file_upload_data_source.dart';
import '../../../../core/upload/upload_folder.dart';
import '../../../../di/service_locator.dart';
import '../../../decorations/domain/models/city_list_item.dart';
import '../../../decorations/domain/models/decoration_image_payload.dart';
import '../../../decorations/presentation/bloc/create_decoration_bloc.dart';
import '../../../decorations/presentation/bloc/events/create_decoration_event.dart';
import '../../../decorations/presentation/bloc/states/create_decoration_state.dart';
import '../../../events/domain/models/event_type_list_item.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';

const int _maxImages = 6;

class AdminCreateDecorationPage extends StatefulWidget {
  const AdminCreateDecorationPage({super.key});

  @override
  State<AdminCreateDecorationPage> createState() => _AdminCreateDecorationPageState();
}

class _AdminCreateDecorationPageState extends State<AdminCreateDecorationPage> {
  final _formKey = GlobalKey<FormState>();
  final _decorationNameController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _inclusionsController = TextEditingController();
  final _exclusionsController = TextEditingController();

  String? _selectedEventTypeId;
  String? _selectedEventTypeName;
  String? _selectedCityId;
  String? _selectedCityName;
  final List<DecorationImagePayload> _uploadedImages = [];
  bool _isUploadingImage = false;
  bool _isActive = true;

  @override
  void dispose() {
    _decorationNameController.dispose();
    _basePriceController.dispose();
    _descriptionController.dispose();
    _inclusionsController.dispose();
    _exclusionsController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImages() async {
    if (_uploadedImages.length >= _maxImages) return;
    final picker = ImagePicker();
    final xFiles = await picker.pickMultiImage(
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (xFiles.isEmpty) return;
    setState(() => _isUploadingImage = true);
    final uploadDataSource = getIt<FileUploadDataSource>();
    for (final xFile in xFiles) {
      if (_uploadedImages.length >= _maxImages) break;
      try {
        final bytes = await xFile.readAsBytes();
        final result = await uploadDataSource.upload(
          fileBytes: bytes,
          filename: xFile.name,
          folder: UploadFolder.decorations,
        );
        if (mounted) {
          setState(() {
            _uploadedImages.add(DecorationImagePayload(
              url: result.url,
              publicId: result.publicId,
            ));
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: ${e.toString()}'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      }
    }
    if (mounted) setState(() => _isUploadingImage = false);
  }

  void _removeImage(int index) {
    setState(() => _uploadedImages.removeAt(index));
  }

  void _onCancel() {
    context.go(AppRoutes.adminDecorations);
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEventTypeId == null || _selectedEventTypeId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an event type'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_selectedCityId == null || _selectedCityId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a city'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final basePriceText = _basePriceController.text.trim();
    final basePriceDouble = double.tryParse(basePriceText);
    if (basePriceDouble == null || basePriceDouble < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter a valid base price'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // API expects basePrice in Rupees directly
    final basePrice = basePriceDouble.round();

    context.read<CreateDecorationBloc>().add(
          SubmitCreateDecoration(
            eventTypeId: _selectedEventTypeId!,
            cityId: _selectedCityId!,
            name: _decorationNameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            inclusions: _inclusionsController.text.trim().isEmpty
                ? null
                : _inclusionsController.text.trim(),
            exclusions: _exclusionsController.text.trim().isEmpty
                ? null
                : _exclusionsController.text.trim(),
            basePrice: basePrice,
            images: _uploadedImages,
            active: _isActive,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateDecorationBloc, CreateDecorationState>(
      listener: (context, state) {
        if (state is CreateDecorationSubmitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Decoration "${state.message}" created successfully'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go(AppRoutes.adminDecorations);
        } else if (state is CreateDecorationSubmitFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 900;
        final isSubmitting = state is CreateDecorationSubmitting;

        if (state is CreateDecorationLoading || state is CreateDecorationInitial) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CreateDecorationLoadFailure) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<CreateDecorationBloc>()
                          .add(const LoadEventTypesAndCities()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final formReady = state is CreateDecorationFormReady;
        final eventTypes = formReady ? state.eventTypes : <EventTypeListItem>[];
        final cities = formReady ? state.cities : <CityListItem>[];

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC), // Brighter, more modern background
          body: isDesktop
              ? _buildDesktopLayout(
                  context,
                  eventTypes: eventTypes,
                  cities: cities,
                  isSubmitting: isSubmitting,
                )
              : _buildMobileLayout(
                  context,
                  eventTypes: eventTypes,
                  cities: cities,
                  isSubmitting: isSubmitting,
                ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context, {
    required List<EventTypeListItem> eventTypes,
    required List<CityListItem> cities,
    required bool isSubmitting,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSidebar(initialIndex: 3),
        Expanded(
          child: Column(
            children: [
              const AdminTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 840), // Increased width for 2-column layout
                      child: _CreateDecorationForm(
                        formKey: _formKey,
                        eventTypes: eventTypes,
                        cities: cities,
                        selectedEventTypeId: _selectedEventTypeId,
                        selectedEventTypeName: _selectedEventTypeName,
                        onEventTypeChanged: (id, name) => setState(() {
                          _selectedEventTypeId = id;
                          _selectedEventTypeName = name;
                        }),
                        selectedCityId: _selectedCityId,
                        selectedCityName: _selectedCityName,
                        onCityChanged: (id, name) => setState(() {
                          _selectedCityId = id;
                          _selectedCityName = name;
                        }),
                        decorationNameController: _decorationNameController,
                        basePriceController: _basePriceController,
                        descriptionController: _descriptionController,
                        inclusionsController: _inclusionsController,
                        exclusionsController: _exclusionsController,
                        uploadedImages: _uploadedImages,
                        isUploadingImage: _isUploadingImage,
                        onAddImage: _pickAndUploadImages,
                        onRemoveImage: _removeImage,
                        isActive: _isActive,
                        onActiveChanged: (v) => setState(() => _isActive = v),
                        onCancel: _onCancel,
                        onSubmit: () => _onSubmit(context),
                        isSubmitting: isSubmitting,
                        onBack: () => context.go(AppRoutes.adminDecorations),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context, {
    required List<EventTypeListItem> eventTypes,
    required List<CityListItem> cities,
    required bool isSubmitting,
  }) {
    return SafeArea(
      child: Column(
        children: [
          _MobileHeader(onBack: () => context.go(AppRoutes.adminDecorations)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _CreateDecorationForm(
                formKey: _formKey,
                eventTypes: eventTypes,
                cities: cities,
                selectedEventTypeId: _selectedEventTypeId,
                selectedEventTypeName: _selectedEventTypeName,
                onEventTypeChanged: (id, name) => setState(() {
                  _selectedEventTypeId = id;
                  _selectedEventTypeName = name;
                }),
                selectedCityId: _selectedCityId,
                selectedCityName: _selectedCityName,
                onCityChanged: (id, name) => setState(() {
                  _selectedCityId = id;
                  _selectedCityName = name;
                }),
                decorationNameController: _decorationNameController,
                basePriceController: _basePriceController,
                descriptionController: _descriptionController,
                inclusionsController: _inclusionsController,
                exclusionsController: _exclusionsController,
                uploadedImages: _uploadedImages,
                isUploadingImage: _isUploadingImage,
                onAddImage: _pickAndUploadImages,
                onRemoveImage: _removeImage,
                isActive: _isActive,
                onActiveChanged: (v) => setState(() => _isActive = v),
                onCancel: _onCancel,
                onSubmit: () => _onSubmit(context),
                isSubmitting: isSubmitting,
                onBack: () => context.go(AppRoutes.adminDecorations),
                isMobile: true,
              ),
            ),
          ),
          _MobileActions(
            onCancel: _onCancel,
            onSubmit: () => _onSubmit(context),
            isSubmitting: isSubmitting,
          ),
        ],
      ),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _MobileHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          ),
          Expanded(
            child: Text(
              'Create Decoration',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
            ),
          ),
          const SizedBox(width: 48), // Spacer for balance
        ],
      ),
    );
  }
}

class _MobileActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const _MobileActions({
    required this.onCancel,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade500],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Decoration',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: isSubmitting ? null : onCancel,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Cancel & Go Back',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateDecorationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<EventTypeListItem> eventTypes;
  final List<CityListItem> cities;
  final String? selectedEventTypeId;
  final String? selectedEventTypeName;
  final void Function(String? id, String? name) onEventTypeChanged;
  final String? selectedCityId;
  final String? selectedCityName;
  final void Function(String? id, String? name) onCityChanged;
  final TextEditingController decorationNameController;
  final TextEditingController basePriceController;
  final TextEditingController descriptionController;
  final TextEditingController inclusionsController;
  final TextEditingController exclusionsController;
  final List<DecorationImagePayload> uploadedImages;
  final bool isUploadingImage;
  final VoidCallback onAddImage;
  final void Function(int) onRemoveImage;
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final VoidCallback onBack;
  final bool isMobile;

  const _CreateDecorationForm({
    required this.formKey,
    required this.eventTypes,
    required this.cities,
    required this.selectedEventTypeId,
    required this.selectedEventTypeName,
    required this.onEventTypeChanged,
    required this.selectedCityId,
    required this.selectedCityName,
    required this.onCityChanged,
    required this.decorationNameController,
    required this.basePriceController,
    required this.descriptionController,
    required this.inclusionsController,
    required this.exclusionsController,
    required this.uploadedImages,
    this.isUploadingImage = false,
    required this.onAddImage,
    required this.onRemoveImage,
    required this.isActive,
    required this.onActiveChanged,
    required this.onCancel,
    required this.onSubmit,
    required this.isSubmitting,
    required this.onBack,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isMobile) _DesktopHeader(onBack: onBack),
          if (!isMobile) const SizedBox(height: 32),
          _SectionCard(
            title: 'General Information',
            icon: Icons.info_outline_rounded,
            subtitle: 'Basic details for the decoration package',
            children: [
              _Label('Decoration Name', required: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: decorationNameController,
                decoration: _inputDecoration(
                  'e.g. Royal Marigold Entrance',
                  prefixIcon: Icons.drive_file_rename_outline_rounded,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Decoration name is required';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (!isMobile)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Event Type', required: true),
                          const SizedBox(height: 8),
                          _SearchableDropdownWithIds(
                            displayValue: selectedEventTypeName,
                            hint: 'Select event type',
                            options: eventTypes.map((e) => (e.id, e.name)).toList(),
                            onChanged: (id, name) => onEventTypeChanged(id, name),
                            prefixIcon: Icons.category_outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('City', required: true),
                          const SizedBox(height: 8),
                          _SearchableDropdownWithIds(
                            displayValue: selectedCityName,
                            hint: 'Select city',
                            options: cities.map((c) => (c.id, c.name)).toList(),
                            onChanged: (id, name) => onCityChanged(id, name),
                            prefixIcon: Icons.location_on_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _Label('Event Type', required: true),
                const SizedBox(height: 8),
                _SearchableDropdownWithIds(
                  displayValue: selectedEventTypeName,
                  hint: 'Select event type',
                  options: eventTypes.map((e) => (e.id, e.name)).toList(),
                  onChanged: (id, name) => onEventTypeChanged(id, name),
                  prefixIcon: Icons.category_outlined,
                ),
                const SizedBox(height: 20),
                _Label('City', required: true),
                const SizedBox(height: 8),
                _SearchableDropdownWithIds(
                  displayValue: selectedCityName,
                  hint: 'Select city',
                  options: cities.map((c) => (c.id, c.name)).toList(),
                  onChanged: (id, name) => onCityChanged(id, name),
                  prefixIcon: Icons.location_on_outlined,
                ),
              ],
              const SizedBox(height: 24),
              _Label('Base Price', required: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: basePriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.normal),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Text(
                      '₹',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Base price is required';
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 0) return 'Enter a valid price';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _Label('Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: _inputDecoration(
                  'Describe the decoration style, theme, and overall look...',
                  maxLines: 4,
                  prefixIcon: Icons.description_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Package Details',
            icon: Icons.list_alt_rounded,
            children: [
              _Label('Inclusions'),
              const SizedBox(height: 8),
              TextFormField(
                controller: inclusionsController,
                maxLines: 3,
                decoration: _inputDecoration(
                  'What is included? (e.g. Fresh flowers, LED lighting)',
                  maxLines: 3,
                  prefixIcon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(height: 24),
              _Label('Exclusions'),
              const SizedBox(height: 8),
              TextFormField(
                controller: exclusionsController,
                maxLines: 3,
                decoration: _inputDecoration(
                  'What is not included? (e.g. Extra seating, Generator)',
                  maxLines: 3,
                  prefixIcon: Icons.cancel_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Visual Gallery',
            icon: Icons.auto_awesome_motion_rounded,
            subtitle: 'Recommended size: 1200x800px. Max $_maxImages images.',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '${uploadedImages.length} / $_maxImages',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 3 : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: (uploadedImages.length < _maxImages)
                    ? uploadedImages.length + 1
                    : uploadedImages.length,
                itemBuilder: (context, index) {
                  if (index < uploadedImages.length) {
                    return _DecorationImageChip(
                      payload: uploadedImages[index],
                      onRemove: () => onRemoveImage(index),
                    );
                  } else {
                    return _AddImageSlot(
                      onTap: onAddImage,
                      isUploading: isUploadingImage,
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Package Visibility',
            icon: Icons.visibility_outlined,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                        color: isActive ? const Color(0xFF047857) : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isActive ? 'Package is Live' : 'Package is Paused',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isActive ? const Color(0xFF064E3B) : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            isActive
                                ? 'Visible to all customers on the platform'
                                : 'Hidden from customers until activated',
                            style: TextStyle(
                              fontSize: 13,
                              color: isActive ? const Color(0xFF047857) : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isActive,
                      onChanged: onActiveChanged,
                      activeTrackColor: const Color(0xFFA7F3D0),
                      activeColor: const Color(0xFF059669),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isMobile) ...[
            const SizedBox(height: 32),
            _DesktopActions(
              onCancel: onCancel,
              onSubmit: onSubmit,
              isSubmitting: isSubmitting,
            ),
          ],
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {int maxLines = 1, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFF64748B), size: 22)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      alignLabelWithHint: maxLines > 1,
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _DesktopHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          iconSize: 20,
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF1E293B),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            side: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create Decoration',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                      letterSpacing: -1,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _BreadcrumbItem('ADMIN'),
                  _BreadcrumbSeparator(),
                  _BreadcrumbItem('DECORATIONS'),
                  _BreadcrumbSeparator(),
                  _BreadcrumbItem('CREATE', isActive: true),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BreadcrumbItem extends StatelessWidget {
  final String label;
  final bool isActive;

  const _BreadcrumbItem(this.label, {this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
        letterSpacing: 1.2,
        color: isActive ? Colors.blue.shade600 : const Color(0xFF94A3B8),
      ),
    );
  }
}

class _BreadcrumbSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFFCBD5E1)),
    );
  }
}

class _DesktopActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const _DesktopActions({
    required this.onCancel,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              foregroundColor: const Color(0xFF475569),
            ),
            child: const Text(
              'Cancel & Go Back',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Create Decoration Package',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
    final String title;
    final IconData? icon;
    final String? subtitle;
    final Widget? trailing;
    final List<Widget> children;

    const _SectionCard({
      required this.title,
      this.icon,
      this.subtitle,
      this.trailing,
      required this.children,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(32), // More breathing room
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: const Color(0xFF64748B), size: 24),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 32),
            ...children,
          ],
        ),
      );
    }
}

class _AddImageSlot extends StatelessWidget {
  final VoidCallback onTap;
  final bool isUploading;

  const _AddImageSlot({required this.onTap, required this.isUploading});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUploading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUploading)
              const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else ...[
              const Icon(Icons.add_a_photo_outlined, color: Color(0xFF64748B), size: 28),
              const SizedBox(height: 8),
              const Text(
                'Add Image',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DecorationImageChip extends StatelessWidget {
  final DecorationImagePayload payload;
  final VoidCallback onRemove;

  const _DecorationImageChip({
    required this.payload,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF1A1F36),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: payload.url.isEmpty
                ? const Center(child: Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 32))
                : Image.network(
                    payload.url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_outlined, color: Color(0xFF94A3B8), size: 32),
                    ),
                  ),
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: Material(
            color: const Color(0xFFF43F5E), // Rose color for better aesthetic
            elevation: 4,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageThumbnail extends StatefulWidget {
  final TextEditingController controller;

  const _ImageThumbnail({required this.controller});

  @override
  State<_ImageThumbnail> createState() => _ImageThumbnailState();
}

class _ImageThumbnailState extends State<_ImageThumbnail> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final url = widget.controller.text.trim();
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: url.isEmpty
            ? Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 32)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey.shade400,
                  size: 32,
                ),
              ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final bool required;

  const _Label(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
            letterSpacing: 0.2,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF43F5E),
            ),
          ),
      ],
    );
  }
}

class _SearchableDropdownWithIds extends StatefulWidget {
  final String? displayValue;
  final String hint;
  final List<(String id, String name)> options;
  final void Function(String? id, String? name) onChanged;
  final IconData? prefixIcon;

  const _SearchableDropdownWithIds({
    required this.displayValue,
    required this.hint,
    required this.options,
    required this.onChanged,
    this.prefixIcon,
  });

  @override
  State<_SearchableDropdownWithIds> createState() =>
      _SearchableDropdownWithIdsState();
}

class _SearchableDropdownWithIdsState extends State<_SearchableDropdownWithIds> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showOptions(BuildContext context) async {
    _searchController.clear();
    final selected = await showModalBottomSheet<(String, String)?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SearchableDropdownSheetWithIds(
        options: widget.options,
        searchController: _searchController,
      ),
    );
    if (selected != null) {
      widget.onChanged(selected.$1, selected.$2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showOptions(context),
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: const Color(0xFF64748B), size: 22)
              : null,
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        child: Text(
          widget.displayValue ?? '',
          style: widget.displayValue != null && widget.displayValue!.isNotEmpty
              ? const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.normal)
              : const TextStyle(color: Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}

class _SearchableDropdownSheetWithIds extends StatefulWidget {
  final List<(String id, String name)> options;
  final TextEditingController searchController;

  const _SearchableDropdownSheetWithIds({
    required this.options,
    required this.searchController,
  });

  @override
  State<_SearchableDropdownSheetWithIds> createState() =>
      _SearchableDropdownSheetWithIdsState();
}

class _SearchableDropdownSheetWithIdsState
    extends State<_SearchableDropdownSheetWithIds> {
  late List<(String id, String name)> _filteredOptions;

  @override
  void initState() {
    super.initState();
    _filteredOptions = List.from(widget.options);
    widget.searchController.addListener(_filter);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_filter);
    super.dispose();
  }

  void _filter() {
    setState(() {
      final q = widget.searchController.text.toLowerCase();
      _filteredOptions = widget.options
          .where((o) => o.$2.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: widget.searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (_) => _filter(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredOptions.length,
              itemBuilder: (context, index) {
                final option = _filteredOptions[index];
                return ListTile(
                  title: Text(option.$2),
                  onTap: () => Navigator.pop(context, option),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
