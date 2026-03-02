import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/decorations/presentation/bloc/admin_decoration_list_bloc.dart';
import 'package:flutter_online/features/decorations/presentation/bloc/events/create_decoration_event.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../decorations/domain/models/city_list_item.dart';
import '../../../decorations/domain/models/decoration_detail.dart';
import '../../../decorations/presentation/bloc/create_decoration_bloc.dart';
import '../../../decorations/presentation/bloc/decoration_detail_bloc.dart';
import '../../../decorations/presentation/bloc/events/update_decoration_event.dart';
import '../../../decorations/presentation/bloc/update_decoration_bloc.dart';
import '../../../decorations/presentation/bloc/states/create_decoration_state.dart';
import '../../../decorations/presentation/bloc/states/update_decoration_state.dart';
import '../../../events/domain/models/event_type_list_item.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';

const int _maxImages = 6;

class EditDecerationPage extends StatefulWidget {
  final String decorationId;

  const EditDecerationPage({super.key, required this.decorationId});

  @override
  State<EditDecerationPage> createState() => _EditDecerationPageState();
}

class _EditDecerationPageState extends State<EditDecerationPage> {
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
  final List<TextEditingController> _imageUrlControllers = [
    TextEditingController(),
  ];
  bool _isActive = true;
  bool _hasPopulatedFromDetail = false;

  @override
  void dispose() {
    _decorationNameController.dispose();
    _basePriceController.dispose();
    _descriptionController.dispose();
    _inclusionsController.dispose();
    _exclusionsController.dispose();
    for (final c in _imageUrlControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addImageUrl() {
    if (_imageUrlControllers.length >= _maxImages) return;
    setState(() => _imageUrlControllers.add(TextEditingController()));
  }

  void _removeImageUrl(int index) {
    if (_imageUrlControllers.length <= 1) return;
    _imageUrlControllers[index].dispose();
    setState(() => _imageUrlControllers.removeAt(index));
  }

  void _populateFromDetail(DecorationDetail detail, List<EventTypeListItem> eventTypes, List<CityListItem> cities) {
    if (_hasPopulatedFromDetail) return;
    _hasPopulatedFromDetail = true;

    _decorationNameController.text = detail.title;
    _basePriceController.text = detail.basePriceRaw != null
        ? (detail.basePriceRaw! / 100).toStringAsFixed(2)
        : _parsePriceForDisplay(detail.price);
    _descriptionController.text = detail.description;
    _inclusionsController.text = detail.inclusions;
    _exclusionsController.text = detail.exclusions;
    _isActive = detail.active;

    _selectedEventTypeId = detail.eventTypeId;
    _selectedEventTypeName = eventTypes
        .where((e) => e.id == detail.eventTypeId)
        .map((e) => e.name)
        .firstOrNull ??
        (detail.tags.isNotEmpty ? detail.tags.first : null);

    _selectedCityId = detail.cityId;
    _selectedCityName = detail.providerName;

    for (final c in _imageUrlControllers) {
      c.dispose();
    }
    _imageUrlControllers.clear();
    final urls = detail.images.where((u) => u.isNotEmpty).toList();
    if (urls.isEmpty) {
      _imageUrlControllers.add(TextEditingController());
    } else {
      for (final url in urls) {
        _imageUrlControllers.add(TextEditingController(text: url));
      }
    }
    setState(() {});
  }

  String _parsePriceForDisplay(String price) {
    final match = RegExp(r'[\d.]+').firstMatch(price);
    if (match == null) return '0.00';
    final numPart = double.tryParse(match.group(0) ?? '0') ?? 0;
    return numPart >= 10000 ? (numPart / 100).toStringAsFixed(2) : numPart.toStringAsFixed(2);
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
    final basePrice = (basePriceDouble * 100).round();

    context.read<UpdateDecorationBloc>().add(
          SubmitUpdateDecoration(
            id: widget.decorationId,
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
            active: _isActive,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DecorationDetailBloc, DecorationDetailState>(
      listener: (context, detailState) {
        if (detailState is DecorationDetailLoaded) {
          final createState = context.read<CreateDecorationBloc>().state;
          if (createState is CreateDecorationFormReady) {
            _populateFromDetail(
              detailState.detail,
              createState.eventTypes,
              createState.cities,
            );
          }
        }
      },
      child: BlocListener<UpdateDecorationBloc, UpdateDecorationState>(
        listener: (context, updateState) {
          if (updateState is UpdateDecorationSuccess) {
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Decoration "${updateState.message}" updated successfully'),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
           context.pop();

             getIt<AdminDecorationListBloc>().add(LoadAdminDecorations());
          } else if (updateState is UpdateDecorationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(updateState.error),
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
        child: BlocConsumer<CreateDecorationBloc, CreateDecorationState>(
          listener: (context, state) {
            if (state is CreateDecorationFormReady) {
              final detailState = context.read<DecorationDetailBloc>().state;
              if (detailState is DecorationDetailLoaded && !_hasPopulatedFromDetail) {
                _populateFromDetail(
                  detailState.detail,
                  state.eventTypes,
                  state.cities,
                );
              }
            }
          },
          builder: (context, state) {
            final detailState = context.watch<DecorationDetailBloc>().state;
            final updateState = context.watch<UpdateDecorationBloc>().state;
            final screenWidth = MediaQuery.of(context).size.width;
            final isDesktop = screenWidth >= 900;
            final isSubmitting = updateState is UpdateDecorationSubmitting;

          final isLoading = state is CreateDecorationLoading ||
              state is CreateDecorationInitial ||
              detailState is DecorationDetailLoading ||
              detailState is DecorationDetailInitial;

          if (detailState is DecorationDetailError) {
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
                        detailState.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context
                            .read<DecorationDetailBloc>()
                            .add(LoadDecorationDetail(widget.decorationId)),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
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

          if (isLoading) {
            return Scaffold(
              backgroundColor: const Color(0xFFF5F7FA),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final formReady = state is CreateDecorationFormReady;
          final eventTypes = formReady ? state.eventTypes : <EventTypeListItem>[];
          final cities = formReady ? state.cities : <CityListItem>[];

            return Scaffold(
              backgroundColor: const Color(0xFFF5F7FA),
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
        ),
      ),
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
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: _EditDecorationForm(
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
                        imageUrlControllers: _imageUrlControllers,
                        onAddImage: _addImageUrl,
                        onRemoveImage: _removeImageUrl,
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
          _EditMobileHeader(onBack: () => context.go(AppRoutes.adminDecorations)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _EditDecorationForm(
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
                imageUrlControllers: _imageUrlControllers,
                onAddImage: _addImageUrl,
                onRemoveImage: _removeImageUrl,
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
          _EditMobileActions(
            onCancel: _onCancel,
            onSubmit: () => _onSubmit(context),
            isSubmitting: isSubmitting,
          ),
        ],
      ),
    );
  }
}

class _EditMobileHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _EditMobileHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1F36)),
          ),
          Expanded(
            child: Text(
              'Edit Decoration',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1F36),
                  ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _EditMobileActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const _EditMobileActions({
    required this.onCancel,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
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
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  shadowColor: Colors.blue.shade200,
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
                        'Update Decoration',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: isSubmitting ? null : onCancel,
              child: Text(
                'Cancel & Go Back',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditDecorationForm extends StatelessWidget {
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
  final List<TextEditingController> imageUrlControllers;
  final VoidCallback onAddImage;
  final void Function(int) onRemoveImage;
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final VoidCallback onBack;
  final bool isMobile;

  const _EditDecorationForm({
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
    required this.imageUrlControllers,
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
          if (!isMobile) _EditDesktopHeader(onBack: onBack),
          if (!isMobile) const SizedBox(height: 32),
          _EditSectionCard(
            title: 'General Information',
            subtitle: 'Basic details for the decoration package',
            children: [
              _EditLabel('Event Type', required: true),
              const SizedBox(height: 8),
              _EditSearchableDropdown(
                displayValue: selectedEventTypeName,
                hint: 'Search and select event type',
                options: eventTypes.map((e) => (e.id, e.name)).toList(),
                onChanged: (id, name) => onEventTypeChanged(id, name),
              ),
              const SizedBox(height: 20),
              _EditLabel('City', required: true),
              const SizedBox(height: 8),
              _EditSearchableDropdown(
                displayValue: selectedCityName,
                hint: 'Search and select city',
                options: cities.map((c) => (c.id, c.name)).toList(),
                onChanged: (id, name) => onCityChanged(id, name),
              ),
              const SizedBox(height: 20),
              _EditLabel('Decoration Name', required: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: decorationNameController,
                decoration: _inputDecoration('e.g. Royal Marigold Entrance'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Decoration name is required';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _EditLabel('Base Price', required: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: basePriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Base price is required';
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 0) return 'Enter a valid price';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _EditLabel('Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: _inputDecoration(
                  'Describe the decoration style, theme, and overall look...',
                  maxLines: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _EditSectionCard(
            title: 'Package Details',
            subtitle: null,
            children: [
              _EditLabel('Inclusions'),
              const SizedBox(height: 8),
              TextFormField(
                controller: inclusionsController,
                maxLines: 3,
                decoration: _inputDecoration(
                  'What is included? (e.g. Fresh flowers, LED lighting)',
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 20),
              _EditLabel('Exclusions'),
              const SizedBox(height: 8),
              TextFormField(
                controller: exclusionsController,
                maxLines: 3,
                decoration: _inputDecoration(
                  'What is not included? (e.g. Extra seating, Generator)',
                  maxLines: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _EditSectionCard(
            title: 'Visual Gallery',
            subtitle: 'Add external links to high-resolution images',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'max $_maxImages images',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            children: [
              ...List.generate(imageUrlControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EditImageThumbnail(controller: imageUrlControllers[index]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: imageUrlControllers[index],
                          decoration: _inputDecoration('https://image-url.com/photo'),
                          validator: (v) => null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: imageUrlControllers.length > 1
                            ? () => onRemoveImage(index)
                            : null,
                        icon: Icon(
                          Icons.delete_outline,
                          color: imageUrlControllers.length > 1
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: imageUrlControllers.length >= _maxImages ? null : onAddImage,
                icon: Icon(Icons.add, color: Colors.blue.shade600, size: 20),
                label: Text(
                  'Add another image',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _EditSectionCard(
            title: 'Package Status',
            subtitle: 'Visibility on client platform',
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1F36),
                    ),
                  ),
                  Switch.adaptive(
                    value: isActive,
                    onChanged: onActiveChanged,
                    activeTrackColor: Colors.blue.shade200,
                    activeThumbColor: Colors.blue.shade600,
                  ),
                ],
              ),
            ],
          ),
          if (!isMobile) ...[
            const SizedBox(height: 32),
            _EditDesktopActions(
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

  InputDecoration _inputDecoration(String hint, {int maxLines = 1}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      alignLabelWithHint: maxLines > 1,
    );
  }
}

class _EditDesktopHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _EditDesktopHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF1A1F36),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Decoration',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1F36),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'ADMIN / DECORATIONS / EDIT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditDesktopActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const _EditDesktopActions({
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Text(
              'Cancel & Go Back',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              shadowColor: Colors.blue.shade200,
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
                    'Update Decoration',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _EditSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;

  const _EditSectionCard({
    required this.title,
    this.subtitle,
    this.trailing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1F36),
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _EditImageThumbnail extends StatefulWidget {
  final TextEditingController controller;

  const _EditImageThumbnail({required this.controller});

  @override
  State<_EditImageThumbnail> createState() => _EditImageThumbnailState();
}

class _EditImageThumbnailState extends State<_EditImageThumbnail> {
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

class _EditLabel extends StatelessWidget {
  final String text;
  final bool required;

  const _EditLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1F36),
          ),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
      ],
    );
  }
}

class _EditSearchableDropdown extends StatefulWidget {
  final String? displayValue;
  final String hint;
  final List<(String id, String name)> options;
  final void Function(String? id, String? name) onChanged;

  const _EditSearchableDropdown({
    required this.displayValue,
    required this.hint,
    required this.options,
    required this.onChanged,
  });

  @override
  State<_EditSearchableDropdown> createState() => _EditSearchableDropdownState();
}

class _EditSearchableDropdownState extends State<_EditSearchableDropdown> {
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
      builder: (ctx) => _EditSearchableDropdownSheet(
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
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        child: Text(
          widget.displayValue ?? '',
          style: widget.displayValue != null && widget.displayValue!.isNotEmpty
              ? const TextStyle(color: Color(0xFF1A1F36), fontSize: 16)
              : TextStyle(color: Colors.grey.shade400, fontSize: 16),
        ),
      ),
    );
  }
}

class _EditSearchableDropdownSheet extends StatefulWidget {
  final List<(String id, String name)> options;
  final TextEditingController searchController;

  const _EditSearchableDropdownSheet({
    required this.options,
    required this.searchController,
  });

  @override
  State<_EditSearchableDropdownSheet> createState() =>
      _EditSearchableDropdownSheetState();
}

class _EditSearchableDropdownSheetState extends State<_EditSearchableDropdownSheet> {
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
