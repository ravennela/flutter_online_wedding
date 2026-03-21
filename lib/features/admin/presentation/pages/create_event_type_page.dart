import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_event.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_state.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/upload/file_upload_data_source.dart';
import '../../../../core/upload/upload_folder.dart';
import '../../../../di/service_locator.dart';
import '../../../events/bloc/event_type/event_type_bloc.dart';
import '../../../events/domain/models/event_type_list_item.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';

class CreateEventTypePage extends StatefulWidget {
  final String? id;
  final EventTypeListItem? initialData;
  const CreateEventTypePage({super.key, this.id, this.initialData});

  @override
  State<CreateEventTypePage> createState() => _CreateEventTypePageState();
}

class _CreateEventTypePageState extends State<CreateEventTypePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _statusActive = true; // Active (default) / Inactive
  Uint8List? _coverImageBytes;
  String? _coverImageUrl; // URL from catalog upload (Cloudinary)
  String? _coverImagePublicId; // publicId from catalog upload, stored in DB
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _populateFields(widget.initialData!);
    }
    if (widget.id != null) {
      context.read<EventTypeBloc>().add(GetEventTypeByIdEvent(widget.id!));
    }
  }

  void _populateFields(EventTypeListItem item) {
    _nameController.text = item.name;
    _descriptionController.text = item.description ?? '';
    setState(() {
      _statusActive = item.active;
      _coverImageUrl = item.iconUrl;
      _coverImagePublicId = item.iconPublicId;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    setState(() {
      _coverImageBytes = bytes;
      _isUploadingImage = true;
    });
    try {
      final uploadDataSource = getIt<FileUploadDataSource>();
      final result = await uploadDataSource.upload(
        fileBytes: bytes,
        filename: xFile.name,
        folder: UploadFolder.events,
      );
      if (mounted) {
        setState(() {
          _coverImageUrl = result.url;
          _coverImagePublicId = result.publicId;
          _isUploadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload failed: ${e.toString()}'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  void _removeCoverImage() {
    setState(() {
      _coverImageBytes = null;
      _coverImageUrl = null;
      _coverImagePublicId = null;
    });
  }

  void _onSave(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();
    final iconUrl = _coverImageUrl?.trim().isEmpty ?? true ? null : _coverImageUrl;
    final iconPublicId = _coverImagePublicId?.trim().isEmpty ?? true ? null : _coverImagePublicId;

    if (widget.id != null) {
      context.read<EventTypeBloc>().add(
            UpdateEventType(
              id: widget.id!,
              name: name,
              description: description,
              iconUrl: iconUrl,
              iconPublicId: iconPublicId,
              active: _statusActive,
              sortOrder: 1,
            ),
          );
    } else {
      context.read<EventTypeBloc>().add(
            SubmitCreateEventType(
              name: name,
              description: description,
              iconUrl: iconUrl,
              iconPublicId: iconPublicId,
              sortOrder: 1,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventTypeBloc, EventTypeState>(
      listener: (context, state) {
        if (state is CreateEventTypeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Event type "${state.message}" created successfully'),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go(AppRoutes.adminEventTypes);
        } else if (state is UpdateEventTypeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.message}'),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go(AppRoutes.adminEventTypes);
        } else if (state is CreateEventTypeFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is UpdateEventTypeFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is EventTypeDetailLoaded) {
          _populateFields(state.eventType);
        } else if (state is EventTypeDetailFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not refresh data: ${state.error}'),
              backgroundColor: const Color(0xFF64748B), // Slate/Grey for "soft" warning
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is CreateEventTypeLoading || state is UpdateEventTypeLoading;
        final isLoading = state is EventTypeDetailLoading;
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 900;

        if (isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8FAFC),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: isDesktop
              ? _buildDesktopLayout(context, isSaving: isSaving)
              : _buildMobileLayout(context, isSaving: isSaving),
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, {required bool isSaving}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSidebar(initialIndex: 2),
        Expanded(
          child: Column(
            children: [
              const AdminTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _DesktopHeader(
                            onBack: () => context.go(AppRoutes.adminEventTypes),
                            isEdit: widget.id != null,
                          ),
                          const SizedBox(height: 32),
                          _EventForm(
                            formKey: _formKey,
                            nameController: _nameController,
                            descriptionController: _descriptionController,
                            statusActive: _statusActive,
                            onStatusChanged: (v) => setState(() => _statusActive = v),
                            coverImageBytes: _coverImageBytes,
                            coverImageUrl: _coverImageUrl,
                            isUploadingImage: _isUploadingImage,
                            onPickCoverImage: _pickCoverImage,
                            onRemoveCoverImage: _removeCoverImage,
                            onCancel: () => context.go(AppRoutes.adminEventTypes),
                            onSave: () => _onSave(context),
                            isSaving: isSaving,
                            isEdit: widget.id != null,
                          ),
                        ],
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

  Widget _buildMobileLayout(BuildContext context, {required bool isSaving}) {
    return SafeArea(
      child: Column(
        children: [
          _MobileHeader(
            onBack: () => context.go(AppRoutes.adminEventTypes),
            isEdit: widget.id != null,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _EventForm(
                formKey: _formKey,
                nameController: _nameController,
                descriptionController: _descriptionController,
                statusActive: _statusActive,
                onStatusChanged: (v) => setState(() => _statusActive = v),
                coverImageBytes: _coverImageBytes,
                coverImageUrl: _coverImageUrl,
                isUploadingImage: _isUploadingImage,
                onPickCoverImage: _pickCoverImage,
                onRemoveCoverImage: _removeCoverImage,
                onCancel: () => context.go(AppRoutes.adminEventTypes),
                onSave: () => _onSave(context),
                isSaving: isSaving,
                isEdit: widget.id != null,
                isMobile: true,
              ),
            ),
          ),
          _MobileActions(
            onCancel: () => context.go(AppRoutes.adminEventTypes),
            onSave: () => _onSave(context),
            isSaving: isSaving,
            isEdit: widget.id != null,
          ),
        ],
      ),
    );
  }
}

class _EventForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final bool statusActive;
  final ValueChanged<bool> onStatusChanged;
  final Uint8List? coverImageBytes;
  final String? coverImageUrl;
  final bool isUploadingImage;
  final VoidCallback onPickCoverImage;
  final VoidCallback onRemoveCoverImage;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isSaving;
  final bool isEdit;
  final bool isMobile;

  const _EventForm({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.statusActive,
    required this.onStatusChanged,
    required this.coverImageBytes,
    this.coverImageUrl,
    required this.isUploadingImage,
    required this.onPickCoverImage,
    required this.onRemoveCoverImage,
    required this.onCancel,
    required this.onSave,
    required this.isSaving,
    required this.isEdit,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionCard(
            title: 'General Information',
            icon: Icons.category_outlined,
            subtitle: 'Basic details for the event type',
            children: [
              _Label('Event Type Name', required: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                decoration: _inputDecoration(
                  'e.g. Traditional Wedding',
                  prefixIcon: Icons.category_rounded,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
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
                  'Describe the style and theme of this event type...',
                  maxLines: 4,
                  prefixIcon: Icons.description_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Visual Identity',
            icon: Icons.image_outlined,
            subtitle: 'Cover image that represents this event type',
            children: [
              _CoverImageUpload(
                coverImageBytes: coverImageBytes,
                coverImageUrl: coverImageUrl,
                isUploadingImage: isUploadingImage,
                onPick: onPickCoverImage,
                onRemove: onRemoveCoverImage,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Visibility & Status',
            icon: Icons.visibility_outlined,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusActive ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusActive ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusActive ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        statusActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                        color: statusActive ? const Color(0xFF047857) : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusActive ? 'Event Type is Live' : 'Event Type is Paused',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: statusActive ? const Color(0xFF064E3B) : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            statusActive
                                ? 'Visible to customers and available for booking'
                                : 'Hidden from customers until activated',
                            style: TextStyle(
                              fontSize: 13,
                              color: statusActive ? const Color(0xFF047857) : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: statusActive,
                      onChanged: onStatusChanged,
                      activeTrackColor: const Color(0xFFA7F3D0),
                      activeColor: const Color(0xFF059669),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF2563EB)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Admins can always see and manage paused event types.',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF1E40AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
              onSave: onSave,
              isSaving: isSaving,
              isEdit: isEdit,
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
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF64748B), size: 22) : null,
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
  final bool isEdit;

  const _DesktopHeader({required this.onBack, required this.isEdit});

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
                isEdit ? 'Edit Event Type' : 'Create Event Type',
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
                  _BreadcrumbItem('EVENT TYPES'),
                  _BreadcrumbSeparator(),
                  _BreadcrumbItem(isEdit ? 'EDIT' : 'CREATE', isActive: true),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileHeader extends StatelessWidget {
  final VoidCallback onBack;
  final bool isEdit;

  const _MobileHeader({required this.onBack, required this.isEdit});

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
              isEdit ? 'Edit Event Type' : 'Create Event Type',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _MobileActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isSaving;
  final bool isEdit;

  const _MobileActions({
    required this.onCancel,
    required this.onSave,
    required this.isSaving,
    required this.isEdit,
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
                    colors: [const Color(0xFF1D4ED8), const Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDBEAFE),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isSaving ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isEdit ? 'Save Changes' : 'Create Event Type',
                          style: const TextStyle(
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
              onPressed: isSaving ? null : onCancel,
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

class _DesktopActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isSaving;
  final bool isEdit;

  const _DesktopActions({
    required this.onCancel,
    required this.onSave,
    required this.isSaving,
    required this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSaving ? null : onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              foregroundColor: const Color(0xFF475569),
            ),
            child: const Text('Cancel & Go Back', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1D4ED8), const Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDBEAFE),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isEdit ? 'Save Event Type Changes' : 'Create Event Type',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.5),
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

  const _SectionCard({required this.title, this.icon, this.subtitle, this.trailing, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
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
                      Text(subtitle!, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
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

class _CoverImageUpload extends StatelessWidget {
  final Uint8List? coverImageBytes;
  final String? coverImageUrl;
  final bool isUploadingImage;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _CoverImageUpload({required this.coverImageBytes, this.coverImageUrl, required this.isUploadingImage, required this.onPick, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (coverImageBytes != null || (coverImageUrl != null && coverImageUrl!.isNotEmpty)) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: coverImageBytes != null
                  ? Image.memory(coverImageBytes!, fit: BoxFit.cover)
                  : Image.network(
                      coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, size: 48)),
                    ),
            ),
          ),
          if (isUploadingImage)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(20)),
                child: const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            ),
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: const Color(0xFFF43F5E),
              elevation: 4,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: isUploadingImage ? null : onRemove,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined, color: Color(0xFF64748B), size: 40),
            const SizedBox(height: 12),
            const Text(
              'Upload Cover Image',
              style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Recommended: 1200 x 800px',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155), letterSpacing: 0.2),
        ),
        if (required) const Text(' *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF43F5E))),
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
        color: isActive ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
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
