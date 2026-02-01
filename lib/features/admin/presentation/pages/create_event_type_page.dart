import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_event.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_state.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../events/bloc/event_type/event_type_bloc.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';

class CreateEventTypePage extends StatefulWidget {
  const CreateEventTypePage({super.key});

  @override
  State<CreateEventTypePage> createState() => _CreateEventTypePageState();
}

class _CreateEventTypePageState extends State<CreateEventTypePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _statusActive = true; // Active (default) / Inactive
  Uint8List? _coverImageBytes;
  String? _coverImageUrl; // URL after upload (if API supports upload)

  static const double _formMaxWidth = 720;

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
    if (xFile != null) {
      final bytes = await xFile.readAsBytes();
      setState(() {
        _coverImageBytes = bytes;
        // TODO: If API has image upload endpoint, upload here and set _coverImageUrl
        _coverImageUrl = null;
      });
    }
  }

  void _removeCoverImage() {
    setState(() {
      _coverImageBytes = null;
      _coverImageUrl = null;
    });
  }

  void _onSave(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();
    // Use URL if available (from upload); otherwise empty string
    final iconUrl = _coverImageUrl ?? '';

    context.read<EventTypeBloc>().add(
          SubmitCreateEventType(
            name: name,
            description: description,
            iconUrl: iconUrl.isEmpty ? null : iconUrl,
            //active: _statusActive,
            sortOrder: 1,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventTypeBloc, EventTypeState>(
      listener: (context, state) {
        if (state is CreateEventTypeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Event type "${state.message}" created successfully'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go(AppRoutes.adminEventTypes);
        } else if (state is CreateEventTypeFailure) {
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
        final isSaving = state is CreateEventTypeLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AdminSidebar(initialIndex: 2),
              Expanded(
                child: Column(
                  children: [
                    const AdminTopBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 48,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: _formMaxWidth,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _CreateEventHeader(
                                  onBack: () =>
                                      context.go(AppRoutes.adminEventTypes),
                                ),
                                const SizedBox(height: 32),
                                _EventTypeDetailsCard(
                                  formKey: _formKey,
                                  nameController: _nameController,
                                  descriptionController: _descriptionController,
                                  statusActive: _statusActive,
                                  onStatusChanged: (active) =>
                                      setState(() => _statusActive = active),
                                  coverImageBytes: _coverImageBytes,
                                  onPickCoverImage: _pickCoverImage,
                                  onRemoveCoverImage: _removeCoverImage,
                                  onCancel: () =>
                                      context.go(AppRoutes.adminEventTypes),
                                  onSave: () => _onSave(context),
                                  isSaving: isSaving,
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
          ),
        );
      },
    );
  }
}

class _CreateEventHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _CreateEventHeader({required this.onBack});

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
                'Create Event',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1F36),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'ADMIN / EVENT TYPES / CREATE',
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
        TextButton(
          onPressed: () {},
          child: Text(
            'Help',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _EventTypeDetailsCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final bool statusActive;
  final ValueChanged<bool> onStatusChanged;
  final Uint8List? coverImageBytes;
  final VoidCallback onPickCoverImage;
  final VoidCallback onRemoveCoverImage;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isSaving;

  const _EventTypeDetailsCard({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.statusActive,
    required this.onStatusChanged,
    required this.coverImageBytes,
    required this.onPickCoverImage,
    required this.onRemoveCoverImage,
    required this.onCancel,
    required this.onSave,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Type Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1F36),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Define the core characteristics of your new package.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 28),

              // Event Type Name (required)
              Text(
                'Event Type Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1F36),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Luxury Wedding Package',
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Event type name is required';
                  }
                  if (v.trim().length > 100) {
                    return 'Name must be 100 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Description (optional)
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1F36),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Describe the details of this event type, including inclusions and standard protocols...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  alignLabelWithHint: true,
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
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),

              // Cover Image
              Text(
                'Cover Image',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1F36),
                ),
              ),
              const SizedBox(height: 8),
              _CoverImageUpload(
                coverImageBytes: coverImageBytes,
                onPick: onPickCoverImage,
                onRemove: onRemoveCoverImage,
              ),
              const SizedBox(height: 24),

              // Status
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1F36),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatusSegment(
                      label: 'Active',
                      isSelected: statusActive,
                      onTap: () => onStatusChanged(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatusSegment(
                      label: 'Inactive',
                      isSelected: !statusActive,
                      onTap: () => onStatusChanged(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Visibility note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Visibility Note: By default, new event types are only visible to administrators until set to "Active" and assigned to a public venue portal.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Footer: Cancel + Save
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSaving ? null : onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: isSaving ? null : onSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 20),
                    label: Text(isSaving ? 'Saving...' : 'Save Event Type'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverImageUpload extends StatelessWidget {
  final Uint8List? coverImageBytes;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _CoverImageUpload({
    required this.coverImageBytes,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (coverImageBytes != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              coverImageBytes!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
              child: IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(36, 36),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: Colors.grey.shade400,
              strokeWidth: 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to upload cover photo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PNG, JPG or WEBP (Max. 5MB)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DashedBorderPainter({required this.color, this.strokeWidth = 2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );
    _drawDashedPath(canvas, path, paint, dashWidth, dashSpace);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          nextDistance > metric.length ? metric.length : nextDistance,
        );
        canvas.drawPath(extractPath, paint);
        distance = nextDistance + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatusSegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusSegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
