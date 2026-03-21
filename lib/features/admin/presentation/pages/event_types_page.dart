import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_bloc.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_event.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_state.dart';
import 'package:flutter_online/features/events/domain/models/event_type_list_item.dart';
import 'package:flutter_online/features/events/domain/usecases/fetch_event_types_usecase.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_sidebar.dart';

const Color _kNavy = Color(0xFF1A1F36);
const Color _kBg = Color(0xFFF5F7FA);
const Color _kFabBlue = Color(0xFF2563EB);
/// Soft active tab (toolbar — not high-contrast navy)
const Color _kTabActiveBg = Color(0xFFE8EEF5);
const Color _kTabActiveFg = Color(0xFF3D4F63);

enum _SortKey { newest, name, status }

class EventTypesPage extends StatefulWidget {
  const EventTypesPage({super.key});

  @override
  State<EventTypesPage> createState() => _EventTypesPageState();
}

class _EventTypesPageState extends State<EventTypesPage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _mobileScaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _searchDebounce;

  final List<String> _statusFilters = ['All', 'Active', 'Inactive'];
  String _selectedStatus = 'All';
  _SortKey _sortKey = _SortKey.newest;

  int? _countAll;
  int? _countActive;
  int? _countInactive;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTabCounts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadTabCounts() async {
    final uc = getIt<FetchEventTypesUsecase>();
    void setIfMounted(void Function() fn) {
      if (mounted) setState(fn);
    }

    final rAll = await uc(page: 0, size: 1, search: null, active: null);
    rAll.fold((_) {}, (r) => setIfMounted(() => _countAll = r.totalElements));

    final rAct = await uc(page: 0, size: 1, search: null, active: true);
    rAct.fold((_) {}, (r) => setIfMounted(() => _countActive = r.totalElements));

    final rInact = await uc(page: 0, size: 1, search: null, active: false);
    rInact.fold((_) {}, (r) => setIfMounted(() => _countInactive = r.totalElements));
  }

  void _onSearchChanged(String value) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
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

  String _tabLabel(String status) {
    switch (status) {
      case 'All':
        return _countAll != null ? 'All ($_countAll)' : 'All';
      case 'Active':
        return _countActive != null ? 'Active ($_countActive)' : 'Active';
      case 'Inactive':
        return _countInactive != null ? 'Inactive ($_countInactive)' : 'Inactive';
      default:
        return status;
    }
  }

  String _sortLabel(_SortKey k) {
    switch (k) {
      case _SortKey.newest:
        return 'Newest';
      case _SortKey.name:
        return 'Name';
      case _SortKey.status:
        return 'Status';
    }
  }

  void _applySort(List<EventTypeListItem> items) {
    int byDate(EventTypeListItem a, EventTypeListItem b) {
      try {
        return DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt));
      } catch (_) {
        return 0;
      }
    }

    switch (_sortKey) {
      case _SortKey.newest:
        items.sort(byDate);
      case _SortKey.name:
        items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case _SortKey.status:
        items.sort((a, b) {
          if (a.active != b.active) return a.active ? -1 : 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
    }
  }

  Widget _fab() {
    return FloatingActionButton(
      onPressed: () => context.go(AppRoutes.adminEventTypesCreate),
      backgroundColor: _kFabBlue,
      elevation: 3,
      child: const Icon(Icons.add, color: Colors.white, size: 26),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    final body = BlocListener<EventTypeBloc, EventTypeState>(
      listener: (context, state) {
        if (state is EventTypeDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green.shade600),
          );
          _loadTabCounts();
        } else if (state is EventTypesListFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red.shade600),
          );
        }
      },
      child: isDesktop
          ? _buildScrollContent(context, horizontalPadding: 40, topPadding: 12)
          : _buildMobileLayout(context),
    );

    if (isDesktop) {
      return AdminScaffold(
        title: 'Event Types',
        selectedIndex: 2,
        floatingActionButton: _fab(),
        body: body,
      );
    }

    return Scaffold(
      key: _mobileScaffoldKey,
      backgroundColor: _kBg,
      drawer: Drawer(
        elevation: 16,
        width: 260,
        child: AdminSidebar(initialIndex: 2, isMobile: true),
      ),
      floatingActionButton: _fab(),
      body: body,
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 10, 6),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _mobileScaffoldKey.currentState?.openDrawer(),
                  icon: const Icon(Icons.menu_rounded, color: _kNavy, size: 24),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
                const Expanded(
                  child: Text(
                    'Event types',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: _kNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700, size: 22),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.person_rounded, color: Colors.blue.shade700, size: 18),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: _buildScrollContent(context, horizontalPadding: 14, topPadding: 0)),
      ],
    );
  }

  Widget _buildScrollContent(BuildContext context,
      {required double horizontalPadding, required double topPadding}) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, topPadding, horizontalPadding, 88),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Event Types',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _kNavy,
                      fontSize: 22,
                      height: 1.15,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Organize and manage your service categories.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              _buildFilterGroupCard(context),
              const SizedBox(height: 12),
              _buildEventList(),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact toolbar: search + tabs + sort (minimal vertical padding).
  Widget _buildFilterGroupCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 34,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 13, color: _kNavy),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                hintText: 'Search event types…',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 520;
              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSegmentedTabs(compact: true),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: Center(child: _buildSortDropdown(alignEnd: false)),
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _buildSegmentedTabs(compact: false)),
                  const SizedBox(width: 8),
                  _buildSortDropdown(alignEnd: true),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs({required bool compact}) {
    final pills = Row(
      children: _statusFilters.map((status) {
        final selected = _selectedStatus == status;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() => _selectedStatus = status);
                  _fetchWithParams(page: 0, active: _getActiveFromStatus(status));
                },
                borderRadius: BorderRadius.circular(7),
                hoverColor: Colors.grey.shade100,
                splashFactory: InkRipple.splashFactory,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: EdgeInsets.symmetric(vertical: compact ? 6 : 7, horizontal: 4),
                  decoration: BoxDecoration(
                    color: selected ? _kTabActiveBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: selected ? const Color(0xFFD0DCE8) : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _tabLabel(status),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 11 : 11.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? _kTabActiveFg : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );

    if (compact) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 320),
          child: pills,
        ),
      );
    }
    return pills;
  }

  Widget _buildSortDropdown({required bool alignEnd}) {
    return _HoverSortButton(
      sortKey: _sortKey,
      label: _sortLabel(_sortKey),
      alignEnd: alignEnd,
      onSelected: (v) => setState(() => _sortKey = v),
    );
  }

  Widget _buildEventList() {
    return BlocBuilder<EventTypeBloc, EventTypeState>(
      builder: (context, state) {
        if (state is EventTypesListLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        if (state is EventTypesListFailure) {
          return _buildError(state.error);
        }

        if (state is EventTypesListLoaded) {
          if (state.content.isEmpty) {
            return _buildEmptyState();
          }

          final items = List<EventTypeListItem>.from(state.content);
          _applySort(items);

          return Column(
            children: [
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DenseEventTypeCard(item: item),
                  )),
              _buildPagination(state),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildError(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 40, color: Colors.red.shade300),
          const SizedBox(height: 8),
          Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          TextButton(onPressed: () => _fetchWithParams(page: 0), child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildPagination(EventTypesListLoaded state) {
    if (state.totalPages <= 1) return const SizedBox(height: 4);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${state.page + 1}/${state.totalPages}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              _PaginationButton(
                icon: Icons.chevron_left,
                onPressed: state.page > 0 ? () => _fetchWithParams(page: state.page - 1) : null,
              ),
              const SizedBox(width: 6),
              _PaginationButton(
                icon: Icons.chevron_right,
                onPressed: !state.last ? () => _fetchWithParams(page: state.page + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(Icons.event_note_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            'No event types yet',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.adminEventTypesCreate),
            style: FilledButton.styleFrom(
              backgroundColor: _kFabBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _HoverSortButton extends StatefulWidget {
  final _SortKey sortKey;
  final String label;
  final bool alignEnd;
  final ValueChanged<_SortKey> onSelected;

  const _HoverSortButton({
    required this.sortKey,
    required this.label,
    required this.alignEnd,
    required this.onSelected,
  });

  @override
  State<_HoverSortButton> createState() => _HoverSortButtonState();
}

class _HoverSortButtonState extends State<_HoverSortButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: _hover ? const Color(0xFFE8EAED) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: PopupMenuButton<_SortKey>(
          tooltip: 'Sort by',
          padding: EdgeInsets.zero,
          offset: const Offset(0, 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onSelected: widget.onSelected,
          itemBuilder: (ctx) => [
            _sortRow(_SortKey.newest, 'Newest'),
            _sortRow(_SortKey.name, 'Name (A–Z)'),
            _sortRow(_SortKey.status, 'Status (active first)'),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  widget.alignEnd ? MainAxisAlignment.end : MainAxisAlignment.center,
              children: [
                Icon(Icons.sort_rounded, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 5),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded, color: Colors.grey.shade600, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<_SortKey> _sortRow(_SortKey key, String text) {
    return PopupMenuItem(
      value: key,
      child: Row(
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
          if (widget.sortKey == key) Icon(Icons.check, size: 18, color: Colors.blue.shade600),
        ],
      ),
    );
  }
}

String _relativeUpdated(String iso) {
  try {
    final d = DateTime.parse(iso);
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays >= 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  } catch (_) {
    return '';
  }
}

class _DenseEventTypeCard extends StatefulWidget {
  final EventTypeListItem item;

  const _DenseEventTypeCard({required this.item});

  @override
  State<_DenseEventTypeCard> createState() => _DenseEventTypeCardState();
}

class _DenseEventTypeCardState extends State<_DenseEventTypeCard> {
  bool _hover = false;

  static final List<({Color bg, IconData icon})> _variants = [
    (bg: const Color(0xFFFFE4E8), icon: Icons.favorite_border_rounded),
    (bg: const Color(0xFFE3F2FD), icon: Icons.apartment_rounded),
    (bg: const Color(0xFFFFF8E1), icon: Icons.cake_outlined),
    (bg: const Color(0xFFE8F5E9), icon: Icons.celebration_outlined),
    (bg: const Color(0xFFF3E5F5), icon: Icons.music_note_rounded),
  ];

  ({Color bg, IconData icon}) _styleForItem() {
    var h = 0;
    for (final c in widget.item.id.codeUnits) {
      h = (h + c) % 997;
    }
    return _variants[h % _variants.length];
  }

  List<Color> _avatarColors() {
    const opts = [Color(0xFF7986CB), Color(0xFF4DB6AC), Color(0xFFFFB74D)];
    final i = widget.item.name.hashCode.abs() % 3;
    return [opts[i], opts[(i + 1) % 3], opts[(i + 2) % 3]];
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isActive = item.active;
    final style = _styleForItem();
    final rel = _relativeUpdated(item.createdAt);
    final desc = (item.description != null && item.description!.trim().isNotEmpty)
        ? item.description!.trim()
        : 'No description — tap to edit.';

    final metaParts = <String>[
      if (item.sortOrder != null) 'Order ${item.sortOrder}',
      if (rel.isNotEmpty) rel,
    ];
    if (metaParts.isEmpty) metaParts.add('Category');

    Widget card = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _hover ? const Color(0xFFF9FAFB) : Colors.white,
          border: Border.all(color: _hover ? Colors.grey.shade300 : Colors.grey.shade200),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: kIsWeb ? 0.09 : 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(AppRoutes.adminEventTypesDetailPath(item.id)),
            borderRadius: BorderRadius.circular(12),
            hoverColor: Colors.grey.shade100.withValues(alpha: 0.35),
            splashColor: Colors.blue.shade50.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconTile(bg: style.bg, icon: style.icon, iconUrl: item.iconUrl),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: _kNavy,
                            height: 1.2,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          desc,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade500,
                            height: 1.32,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          metaParts.join(' · '),
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.2,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StatusPill(isActive: isActive),
                          const SizedBox(width: 6),
                          _ActionCluster(item: item),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: 'Usage count (coming soon)',
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                '0',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _MiniAvatars(colors: _avatarColors()),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return card;
  }
}

class _StatusPill extends StatelessWidget {
  final bool isActive;

  const _StatusPill({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive ? const Color(0xFFC8E6C9) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.35,
          color: isActive ? const Color(0xFF1B5E20) : Colors.grey.shade700,
        ),
      ),
    );
  }
}

class _ActionCluster extends StatelessWidget {
  final EventTypeListItem item;

  const _ActionCluster({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => context.push(AppRoutes.adminEventTypesEditPath(item.id), extra: item),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
              hoverColor: Colors.grey.shade200,
              splashColor: Colors.blue.shade50,
              child: SizedBox(
                width: 34,
                height: 32,
                child: Icon(Icons.edit_outlined, color: Colors.grey.shade700, size: 18),
              ),
            ),
            Container(height: 1, color: Colors.grey.shade200),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              offset: const Offset(0, 28),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              splashRadius: 18,
              child: SizedBox(
                width: 34,
                height: 32,
                child: Icon(Icons.more_horiz_rounded, color: Colors.grey.shade600, size: 18),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete event type'),
                      content: Text('Delete "${item.name}"?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            context.read<EventTypeBloc>().add(DeleteEventType(item));
                            Navigator.pop(ctx);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  final Color bg;
  final IconData icon;
  final String? iconUrl;

  const _IconTile({required this.bg, required this.icon, this.iconUrl});

  @override
  Widget build(BuildContext context) {
    final url = iconUrl?.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44,
        height: 44,
        color: bg,
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(icon, color: Colors.grey.shade700, size: 22),
              )
            : Icon(icon, color: Colors.grey.shade800, size: 22),
      ),
    );
  }
}

class _MiniAvatars extends StatelessWidget {
  final List<Color> colors;

  const _MiniAvatars({required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < 3; i++)
            Positioned(
              left: i * 13.0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: colors[i % colors.length],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
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
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: onPressed != null ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
      ),
    );
  }
}
