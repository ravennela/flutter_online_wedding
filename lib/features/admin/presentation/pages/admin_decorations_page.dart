import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/decorations/domain/models/decoration_list_response.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../../../core/routes/app_routes.dart';
import '../../../../di/service_locator.dart';
import '../../../../features/decorations/presentation/bloc/admin_decoration_list_cubit.dart';
import '../../../../features/decorations/presentation/bloc/admin_decoration_list_state.dart';
import '../../../../features/events/bloc/event_type/event_type_bloc.dart';
import '../../../../features/events/bloc/event_type/event_type_event.dart';
import '../../../../features/events/bloc/event_type/event_type_state.dart';
import '../../../decorations/domain/models/decoration_list_item.dart';
import '../widgets/admin_scaffold.dart';

class AdminDecorationsPage extends StatelessWidget {
  const AdminDecorationsPage({super.key});

  @override

  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AdminDecorationListCubit>()..loadDecorations(),
        ),
        BlocProvider(
          create: (_) => getIt<EventTypeBloc>()..add(const FetchEventTypes(page: 0, size: 100)),
        ),
      ],
      child: const _AdminDecorationsContentWrapper(),
    );
  }

}

class _AdminDecorationsContentWrapper extends StatelessWidget {
  const _AdminDecorationsContentWrapper();

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Decorations',
      selectedIndex: 3,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.adminDecorationsCreate),
        backgroundColor: Colors.blue.shade600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 1000;
          return _DecorationsContent(isMobile: isMobile);
        },
      ),
    );
  }
}

class _DecorationsContent extends StatefulWidget {
  final bool isMobile;

  const _DecorationsContent({
    this.isMobile = false,
  });

  @override
  State<_DecorationsContent> createState() => _DecorationsContentState();
}

class _DecorationsContentState extends State<_DecorationsContent> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _selectedEventTypeId;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadDecorations();
    });
  }

  void _loadDecorations({int page = 0}) {
    context.read<AdminDecorationListCubit>().loadDecorations(
      page: page,
      search: _searchController.text,
      eventTypeId: _selectedEventTypeId,
    );
  }

  void _onEventTypeSelected(String? id) {
    setState(() {
      _selectedEventTypeId = id;
    });
    _loadDecorations();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = !widget.isMobile;
    final horizontalPadding = isDesktop ? 32.0 : 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, widget.isMobile ? 16 : 32, horizontalPadding, 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop) _buildDesktopHeader(context),
              if (isDesktop) const SizedBox(height: 32),
              _buildSearchAndFilters(context, isDesktop),
              const SizedBox(height: 24),
              _buildDecorationList(context),
            ],
          ),
        ),
      ),
    );
  }
  
  // ... existing headers ...

  Widget _buildDesktopHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Decorations',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1F36),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage all decoration packages',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDecorationList(BuildContext context) {
    return BlocBuilder<AdminDecorationListCubit, AdminDecorationListState>(
      builder: (context, state) {
        if (state is AdminDecorationListLoading) {
          return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
        } else if (state is AdminDecorationListError) {
          return Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(state.message, style: const TextStyle(color: Colors.red))));
        } else if (state is AdminDecorationListLoaded) {
          final items = state.response.content;
          if (items.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return widget.isMobile
                      ? _DecorationMobileCard(item: items[index])
                      : _DecorationDesktopCard(item: items[index]);
                },
              ),
              const SizedBox(height: 24),
              _buildPagination(context, state.response),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPagination(BuildContext context, DecorationListResponse response) {
    if (response.totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: response.page > 0
              ? () => context.read<AdminDecorationListCubit>().loadDecorations(
                    page: response.page - 1,
                    search: _searchController.text,
                    eventTypeId: _selectedEventTypeId,
                  )
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('Page ${response.page + 1} of ${response.totalPages}'),
        IconButton(
          onPressed: !response.last
              ? () => context.read<AdminDecorationListCubit>().loadDecorations(
                    page: response.page + 1,
                    search: _searchController.text,
                    eventTypeId: _selectedEventTypeId,
                  )
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
    

  Widget _buildSearchAndFilters(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search decorations...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
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
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                           color: Colors.white,
                           shape: BoxShape.circle,
                           border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Icon(Icons.tune, size: 16, color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => _loadDecorations(),
                  icon: Icon(Icons.refresh, color: Colors.grey.shade600, size: 22),
                  tooltip: 'Refresh',
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<EventTypeBloc, EventTypeState>(
            builder: (context, state) {
              if (state is EventTypesListLoaded) {
                 return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: _selectedEventTypeId == null,
                      onTap: () => _onEventTypeSelected(null),
                    ),
                    ...state.content.map((type) => _FilterChip(
                      label: type.name,
                      isSelected: _selectedEventTypeId == type.id,
                      onTap: () => _onEventTypeSelected(type.id),
                    )),
                  ],
                );
              }
              // Fallback or loading state for filters filter chips
               return Wrap(
                spacing: 8,
                children: [
                   _FilterChip(label: 'All', isSelected: true, onTap: () {}),
                   // Optional: Skeleton or shimmer here
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          children: [
            Icon(Icons.local_florist_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No decorations found',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.adminDecorationsCreate),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create Decoration'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorationDesktopCard extends StatefulWidget {
  final DecorationListItem item;

  const _DecorationDesktopCard({required this.item});

  @override
  State<_DecorationDesktopCard> createState() => _DecorationDesktopCardState();
}

class _DecorationDesktopCardState extends State<_DecorationDesktopCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFFF9FAFB) : Colors.white,
          borderRadius: BorderRadius.circular(14),
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
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: _isHovered
              ? Border.all(color: Colors.blue.shade200.withOpacity(0.5), width: 1)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.image_outlined, color: Colors.blue.shade200, size: 40),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.eventTypeName.isNotEmpty)
                    Text(
                      item.eventTypeName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A1F36),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.cityName.isNotEmpty)
                  Text(
                    item.cityName,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BASE PRICE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormatter.format(item.basePrice),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            _StatusBadge(isActive: item.active),
            const SizedBox(width: 16),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade600, size: 22),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'disable', child: Text('Disable')),
              ],
              onSelected: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorationMobileCard extends StatelessWidget {
  final DecorationListItem item;

  const _DecorationMobileCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                 child: Icon(Icons.image_outlined, color: Colors.blue.shade200, size: 50),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _StatusBadge(isActive: item.active),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.eventTypeName.isNotEmpty)
                  Text(
                    item.eventTypeName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Colors.blue.shade600,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A1F36),
                  ),
                ),
                if (item.cityName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        item.cityName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormatter.format(item.basePrice),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? Colors.green.shade500 : Colors.red.shade500,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.shade600.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
