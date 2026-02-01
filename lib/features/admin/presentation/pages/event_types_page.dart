import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_bloc.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_event.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_state.dart';
import 'package:flutter_online/features/events/domain/models/event_type_list_item.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../widgets/admin_scaffold.dart';

class EventTypesPage extends StatefulWidget {
  const EventTypesPage({super.key});

  @override
  State<EventTypesPage> createState() => _EventTypesPageState();
}

class _EventTypesPageState extends State<EventTypesPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _statusFilters = ['All', 'Active', 'Inactive'];
  String _selectedStatus = 'All';
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchWithParams(search: value, page: 0);
    });
  }

  void _fetchWithParams({
    int? page,
    String? search,
    bool? active,
  }) {
    context.read<EventTypeBloc>().add(FetchEventTypes(
          page: page ?? 0,
          size: 10,
          search: search ?? _searchController.text,
          active: active ?? _getActiveFromStatus(_selectedStatus),
        ));
  }

  bool? _getActiveFromStatus(String status) {
    if (status == 'All') return null;
    if (status == 'Active') return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Event Types',
      selectedIndex: 2,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 1000;
          final horizontalPadding = isMobile ? 16.0 : 48.0;
          
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 32, horizontalPadding, 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMobile) ...[
                      _buildHeader(context),
                      const SizedBox(height: 48),
                    ],
                    _buildFilterBar(context),
                    const SizedBox(height: 24),
                    _buildEventList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Event Types",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1F36),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "ADMIN / MANAGEMENT",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => context.go(AppRoutes.adminEventTypesCreate),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: Colors.blue.shade200,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            "Create Event Type",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;
          if (isNarrow) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchField(),
                const SizedBox(height: 12),
                _buildStatusFilters(),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                flex: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: _buildSearchField(),
                ),
              ),
              const SizedBox(width: 16),
              _buildStatusFilters(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: "Search event types...",
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.grey.shade400,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue.shade400),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        isDense: true,
      ),
    );
  }

  Widget _buildStatusFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _statusFilters.map((status) {
        final isSelected = _selectedStatus == status;
        return InkWell(
          onTap: () {
            setState(() => _selectedStatus = status);
            _fetchWithParams(page: 0, active: _getActiveFromStatus(status));
          },
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1A1F36) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? null : Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEventList() {
    return BlocBuilder<EventTypeBloc, EventTypeState>(
      builder: (context, state) {
        if (state is EventTypesListLoading) {
           // Show a loading indicator but don't destroy the whole layout above
           return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()));
        }
        if (state is EventTypesListFailure) {
          return Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.error),
                ElevatedButton(
                  onPressed: () => _fetchWithParams(page: 0),
                  child: const Text('Retry'),
                )
              ],
            ),
          );
        }

        if (state is EventTypesListLoaded) {
          if (state.content.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.content.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _EventTypeRowCard(item: state.content[index]);
                },
              ),
              const SizedBox(height: 32),
              _buildPagination(state),
            ],
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPagination(EventTypesListLoaded state) {
    if (state.totalPages <= 1) return const SizedBox.shrink();

     final total = state.totalElements;
     final count = state.content.length;
     final page = state.page;
     final last = state.last;

      return Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            "Showing $count of $total event types",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PaginationButton(
                icon: Icons.chevron_left,
                onPressed: page > 0 ? () => _fetchWithParams(page: page - 1) : null,
              ),
              const SizedBox(width: 8),
              _PaginationButton(
                icon: Icons.chevron_right,
                onPressed: !last ? () => _fetchWithParams(page: page + 1) : null,
              ),
            ],
          ),
        ],
      );
  }

  Widget _buildEmptyState() {
     return Center(
      child: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "No event types created yet",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.adminEventTypesCreate),
              child: const Text("Create Event Type"),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventTypeRowCard extends StatefulWidget {
  final EventTypeListItem item;

  const _EventTypeRowCard({required this.item});

  @override
  State<_EventTypeRowCard> createState() => _EventTypeRowCardState();
}

class _EventTypeRowCardState extends State<_EventTypeRowCard> {
  bool _isHovered = false;

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${_month(dt.month)} ${dt.day}, ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.item.active;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: _isHovered
              ? const Color(0xFFF9FAFB)
              : Colors.white, // Subtle grey on hover
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: _isHovered
              ? Border.all(
                  color: Colors.blue.shade200.withOpacity(0.5),
                  width: 1.0,
                )
              : Border.all(color: Colors.transparent, width: 1.0),
        ),
        child: Row(
          children: [
            // 1. Thumbnail placeholder (API has no image)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade50,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.event_note,
                color: Colors.blue.shade300,
                size: 28,
              ),
            ),
            const SizedBox(width: 24),

            // 2. Name & Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A1F36),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.description ?? _formatDate(widget.item.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 3. Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? Colors.green.shade100
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                isActive ? 'ACTIVE' : 'INACTIVE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isActive
                      ? Colors.green.shade700
                      : Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 24),

            // 4. Actions
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.edit_outlined,
                color: Colors.grey.shade600,
                size: 20,
              ),
              tooltip: "Edit",
              splashRadius: 20,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey.shade400,
                size: 20,
              ),
              tooltip: "More",
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PaginationButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: onPressed != null ? Colors.grey.shade600 : Colors.grey.shade400,
          size: 20,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
