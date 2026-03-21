import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_bloc.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_event.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_state.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_online/core/routes/app_routes.dart';

// --- Theme Constants ---
const Color _kNavy = Color(0xFF1A1F36);
const Color _kSlate400 = Color(0xFF94A3B8);
const Color _kSlate500 = Color(0xFF64748B);
const Color _kSlate600 = Color(0xFF475569);
const Color _kSlate800 = Color(0xFF1E293B);
const Color _kBlue600 = Color(0xFF2563EB);
const Color _kBlue50 = Color(0xFFEFF6FF);

class EventTypeDetailPage extends StatefulWidget {
  final String id;
  const EventTypeDetailPage({super.key, required this.id});

  @override
  State<EventTypeDetailPage> createState() => _EventTypeDetailPageState();
}

class _EventTypeDetailPageState extends State<EventTypeDetailPage> {
  late EventTypeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<EventTypeBloc>();
    _bloc.add(GetEventTypeByIdEvent(widget.id));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isDesktop = w >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocProvider.value(
        value: _bloc,
        child: BlocConsumer<EventTypeBloc, EventTypeState>(
          listener: (context, state) {
            debugPrint("EventTypeDetailPage State: $state");
          },
          builder: (context, state) {
            if (state is EventTypeDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EventTypeDetailFailure) {
              return _buildErrorState(state.error);
            } else if (state is EventTypeDetailLoaded) {
              final event = state.eventType;
              return isDesktop 
                  ? _buildDesktopLayout(context, event) 
                  : _buildMobileLayout(context, event);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
            child: Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade600),
          ),
          const SizedBox(height: 24),
          const Text("Failed to load event type", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _kNavy)),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center, style: const TextStyle(color: _kSlate500)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _bloc.add(GetEventTypeByIdEvent(widget.id)),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Retry Connection"),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kBlue600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, dynamic event) {
    return Column(
      children: [
        _DesktopHeader(
          id: widget.id, 
          onRefresh: () => _bloc.add(GetEventTypeByIdEvent(widget.id)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _SectionCard(
                                title: "General Information",
                                icon: Icons.info_outline,
                                children: [
                                  _DetailItem(label: "Name", value: event.name, isTitle: true),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(child: _DetailItem(label: "Sort Order", value: event.sortOrder?.toString() ?? "Not set")),
                                      Expanded(child: _DetailItem(label: "Internal ID", value: event.id, isCopyable: true)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _SectionCard(
                                title: "Description",
                                icon: Icons.description_outlined,
                                children: [
                                  Text(
                                    event.description ?? "No description provided for this event type.",
                                    style: const TextStyle(fontSize: 15, color: _kSlate600, height: 1.6),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _VisibilityCard(active: event.active),
                              const SizedBox(height: 24),
                              _SectionCard(
                                title: "Cover Image",
                                icon: Icons.image_outlined,
                                padding: EdgeInsets.zero,
                                children: [
                                  if (event.iconUrl != null && event.iconUrl!.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: Image.network(
                                          event.iconUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _EmptyImage(size: 80),
                                        ),
                                      ),
                                    )
                                  else
                                    const Padding(
                                      padding: EdgeInsets.all(40),
                                      child: _EmptyImage(size: 60),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, dynamic event) {
    return Column(
      children: [
        _MobileHeader(
          id: widget.id,
          onRefresh: () => _bloc.add(GetEventTypeByIdEvent(widget.id)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _VisibilityCard(active: event.active),
                const SizedBox(height: 16),
                _SectionCard(
                  title: "Details",
                  icon: Icons.info_outline,
                  children: [
                    _DetailItem(label: "Name", value: event.name, isTitle: true),
                    const SizedBox(height: 16),
                    _DetailItem(label: "Sort Order", value: event.sortOrder?.toString() ?? "N/A"),
                    const SizedBox(height: 16),
                    _DetailItem(label: "Description", value: event.description ?? "No description"),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: "Media",
                  icon: Icons.image_outlined,
                  padding: EdgeInsets.zero,
                  children: [
                    if (event.iconUrl != null && event.iconUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                        child: Image.network(
                          event.iconUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _EmptyImage(size: 60),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: _EmptyImage(size: 50),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailItem(label: "Reference ID", value: event.id, isSmall: true),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- Composite Widgets ---

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;
  final EdgeInsets? padding;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: _kBlue600),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kNavy),
                ),
                if (trailing != null) ...[const Spacer(), trailing!],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isTitle;
  final bool isCopyable;
  final bool isSmall;

  const _DetailItem({
    required this.label, 
    required this.value, 
    this.isTitle = false, 
    this.isCopyable = false,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: isSmall ? 10 : 11,
            fontWeight: FontWeight.bold,
            color: _kSlate400,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isTitle ? 20 : (isSmall ? 13 : 15),
                  fontWeight: isTitle ? FontWeight.w800 : FontWeight.w500,
                  color: isTitle ? _kNavy : _kSlate800,
                ),
              ),
            ),
            if (isCopyable)
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 16, color: _kSlate400),
                onPressed: () {
                  // copy to clipboard logic could go here
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _VisibilityCard extends StatelessWidget {
  final bool active;
  const _VisibilityCard({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final bg = active ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Icon(
              active ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active ? "Status: Live" : "Status: Paused",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  active ? "Searchable and visible to customers" : "Hidden from search and not bookable",
                  style: TextStyle(fontSize: 13, color: color.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyImage extends StatelessWidget {
  final double size;
  const _EmptyImage({required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_not_supported_outlined, size: size, color: const Color(0xFFCBD5E1)),
        const SizedBox(height: 8),
        const Text("No Asset Found", style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
      ],
    );
  }
}

// --- Header Widgets ---

class _DesktopHeader extends StatelessWidget {
  final String id;
  final VoidCallback onRefresh;

  const _DesktopHeader({required this.id, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      color: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, size: 20, color: _kNavy),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _BreadcrumbItem(label: 'ADMIN'),
                      _BreadcrumbSeparator(),
                      _BreadcrumbItem(label: 'EVENT TYPES', onTap: () => context.push(AppRoutes.adminEventTypes)),
                      _BreadcrumbSeparator(),
                      const _BreadcrumbItem(label: 'DETAIL', isActive: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Event Type Information',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _kNavy, letterSpacing: -0.5),
                  ),
                ],
              ),
            ],
          ),
          IntrinsicWidth(
            child: OutlinedButton.icon(
              onPressed: () {
                context.push(AppRoutes.adminEventTypesEditPath(id)).then((_) => onRefresh());
              },
              icon: const Icon(Icons.edit_note_rounded, size: 20),
              label: const Text('Edit Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kBlue600,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class _MobileHeader extends StatelessWidget {
  final String id;
  final VoidCallback onRefresh;

  const _MobileHeader({required this.id, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 48, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: _kNavy),
          ),
          const Expanded(
            child: Text(
              'Event Type Details',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kNavy),
            ),
          ),
          IconButton(
            onPressed: () {
              context.push(AppRoutes.adminEventTypesEditPath(id)).then((_) => onRefresh());
            },
            icon: const Icon(Icons.edit_rounded, color: _kBlue600),
          ),
        ],
      ),
    );
  }
}

class _BreadcrumbItem extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const _BreadcrumbItem({required this.label, this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isActive ? _kBlue600 : _kSlate400,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _BreadcrumbSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey.shade300),
    );
  }
}

