import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/features/decorations/domain/models/decoration_list_response.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../di/service_locator.dart';
import '../../../../features/decorations/presentation/bloc/admin_decoration_list_bloc.dart';
import '../../../../features/events/bloc/event_type/event_type_bloc.dart';
import '../../../../features/events/bloc/event_type/event_type_event.dart';
import '../../../../features/events/bloc/event_type/event_type_state.dart';
import '../../../../features/events/domain/models/event_type_list_item.dart';
import '../../../decorations/domain/models/decoration_list_item.dart';
import '../widgets/admin_scaffold.dart';

const Color _kNavy = Color(0xFF1A1F36);
const Color _kFab = Color(0xFF2563EB);
const Color _kTabActiveBg = Color(0xFFE8EEF5);
const Color _kTabActiveFg = Color(0xFF3D4F63);
const Color _kRose = Color(0xFFFCE7F3);

enum _SortMode { newest, price, name }

class AdminDecorationsPage extends StatelessWidget {
  const AdminDecorationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<AdminDecorationListBloc>()..add(LoadAdminDecorations()),
        ),
        BlocProvider(
          create: (_) =>
              getIt<EventTypeBloc>()
                ..add(const FetchEventTypes(page: 0, size: 100)),
        ),
      ],
      child: AdminScaffold(
        title: 'Decorations',
        selectedIndex: 3,
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go(AppRoutes.adminDecorationsCreate),
          backgroundColor: _kFab,
          elevation: kIsWeb ? 4 : 3,
          child: const Icon(Icons.add, color: Colors.white, size: 26),
        ),
        body: const _DecorationsBody(),
      ),
    );
  }
}

class _DecorationsBody extends StatefulWidget {
  const _DecorationsBody();

  @override
  State<_DecorationsBody> createState() => _DecorationsBodyState();
}

class _DecorationsBodyState extends State<_DecorationsBody>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _selectedEventTypeId;
  _SortMode _sortMode = _SortMode.newest;
  bool? _statusFilter;
  TabController? _tabController;
  List<EventTypeListItem> _eventTypes = [];
  bool _categoriesReady = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _tabController?.dispose();
    super.dispose();
  }

  void _ensureTabController(List<EventTypeListItem> types) {
    final len = 1 + types.length;
    var idx = 0;
    if (_selectedEventTypeId != null) {
      final i = types.indexWhere((e) => e.id == _selectedEventTypeId);
      if (i >= 0) idx = i + 1;
    }
    idx = idx.clamp(0, len - 1);

    if (_tabController == null || _tabController!.length != len) {
      _tabController?.dispose();
      _tabController = TabController(length: len, vsync: this, initialIndex: idx);
      _tabController!.addListener(_onTab);
    } else if (_tabController!.index != idx) {
      _tabController!.index = idx;
    }
  }

  void _onTab() {
    if (_tabController == null || _tabController!.indexIsChanging) return;
    final i = _tabController!.index;
    final id = i == 0 ? null : _eventTypes[i - 1].id;
    if (id != _selectedEventTypeId) {
      setState(() => _selectedEventTypeId = id);
      _loadDecorations();
    }
  }

  ({String? sortBy, String? sortDir}) _sortParams() {
    switch (_sortMode) {
      case _SortMode.newest:
        return (sortBy: 'createdAt', sortDir: 'desc');
      case _SortMode.price:
        return (sortBy: 'basePrice', sortDir: 'desc');
      case _SortMode.name:
        return (sortBy: 'name', sortDir: 'asc');
    }
  }

  void _loadDecorations({int page = 0}) {
    final s = _sortParams();
    context.read<AdminDecorationListBloc>().add(
          LoadAdminDecorations(
            page: page,
            search: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
            eventTypeId: _selectedEventTypeId,
            active: _statusFilter,
            sortBy: s.sortBy,
            sortDir: s.sortDir,
          ),
        );
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Catalog visibility', style: TextStyle(fontWeight: FontWeight.w800, color: _kNavy, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('All'),
              trailing: _statusFilter == null ? Icon(Icons.check, color: _kFab, size: 20) : null,
              onTap: () {
                setState(() => _statusFilter = null);
                Navigator.pop(ctx);
                _loadDecorations();
              },
            ),
            ListTile(
              title: const Text('Active only'),
              trailing: _statusFilter == true ? Icon(Icons.check, color: _kFab, size: 20) : null,
              onTap: () {
                setState(() => _statusFilter = true);
                Navigator.pop(ctx);
                _loadDecorations();
              },
            ),
            ListTile(
              title: const Text('Inactive only'),
              trailing: _statusFilter == false ? Icon(Icons.check, color: _kFab, size: 20) : null,
              onTap: () {
                setState(() => _statusFilter = false);
                Navigator.pop(ctx);
                _loadDecorations();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final desktop = w >= 1000;
    final padH = desktop ? 40.0 : 14.0;

    return BlocListener<EventTypeBloc, EventTypeState>(
      listener: (context, state) {
        if (state is EventTypesListLoaded) {
          setState(() {
            _eventTypes = state.content;
            _ensureTabController(_eventTypes);
            _categoriesReady = true;
          });
        } else if (state is EventTypesListFailure) {
          setState(() {
            _eventTypes = [];
            _ensureTabController([]);
            _categoriesReady = true;
          });
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, 12, padH, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Decorations',
                  style: TextStyle(
                    fontSize: desktop ? 22 : 20,
                    fontWeight: FontWeight.w800,
                    color: _kNavy,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage packages by category — Stripe-style dashboard.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                _Toolbar(
                  searchController: _searchController,
                  onSearch: _onSearchChanged,
                  categoriesReady: _categoriesReady,
                  tabController: _tabController,
                  eventTypes: _eventTypes,
                  sortMode: _sortMode,
                  onSort: (m) {
                    setState(() => _sortMode = m);
                    _loadDecorations();
                  },
                  onFilterTap: _openFilterSheet,
                ),
                const SizedBox(height: 12),
                BlocListener<AdminDecorationListBloc, AdminDecorationListState>(
                  listener: (context, state) {
                    if (state is AdminDecorationDeleteSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green.shade600,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<AdminDecorationListBloc, AdminDecorationListState>(
                    builder: (context, state) {
                      if (state is AdminDecorationListLoading ||
                          state is AdminDecorationDeleteSuccess) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      if (state is AdminDecorationListError) {
                        return _ErrorBlock(msg: state.message, onRetry: _loadDecorations);
                      }
                      if (state is AdminDecorationListLoaded) {
                        final items = state.response.content;
                        if (items.isEmpty) {
                          return _EmptyState(onCreate: () => context.go(AppRoutes.adminDecorationsCreate));
                        }
                        return Column(
                          children: [
                            ...items.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _DecorationCard(item: e),
                              ),
                            ),
                            _PaginationRow(
                              response: state.response,
                              onPrev: state.response.page > 0
                                  ? () => _loadDecorations(page: state.response.page - 1)
                                  : null,
                              onNext: !state.response.last
                                  ? () => _loadDecorations(page: state.response.page + 1)
                                  : null,
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String _) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _loadDecorations);
  }
}

class _Toolbar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final bool categoriesReady;
  final TabController? tabController;
  final List<EventTypeListItem> eventTypes;
  final _SortMode sortMode;
  final ValueChanged<_SortMode> onSort;
  final VoidCallback onFilterTap;

  const _Toolbar({
    required this.searchController,
    required this.onSearch,
    required this.categoriesReady,
    required this.tabController,
    required this.eventTypes,
    required this.sortMode,
    required this.onSort,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 700;
        return Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: wide ? _rowWide(context) : _colNarrow(context),
        );
      },
    );
  }

  Widget _searchField({String hint = 'Search…'}) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: searchController,
        onChanged: onSearch,
        style: const TextStyle(fontSize: 13, color: _kNavy),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, size: 18, color: Colors.grey.shade400),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _tabBar() {
    if (!categoriesReady || tabController == null) {
      return SizedBox(
        height: 36,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Loading categories…', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ),
      );
    }
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 36,
        child: TabBar(
          controller: tabController!,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          indicator: BoxDecoration(
            color: _kTabActiveBg,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: const Color(0xFFD0DCE8)),
          ),
          labelColor: _kTabActiveFg,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
          tabs: [
            const Tab(text: 'All'),
            ...eventTypes.map((e) => Tab(text: e.name)),
          ],
        ),
      ),
    );
  }

  Widget _sortBtn() {
    return _SortDropdown(mode: sortMode, onChanged: onSort);
  }

  Widget _filterBtn() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onFilterTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.grey.shade100,
        splashColor: _kRose.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(Icons.tune_rounded, size: 20, color: Colors.grey.shade700),
        ),
      ),
    );
  }

  Widget _rowWide(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 200, child: _searchField()),
        const SizedBox(width: 8),
        Expanded(child: _tabBar()),
        const SizedBox(width: 6),
        _sortBtn(),
        _filterBtn(),
      ],
    );
  }

  Widget _colNarrow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _searchField(hint: 'Search decorations…'),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _tabBar()),
            const SizedBox(width: 6),
            _sortBtn(),
            _filterBtn(),
          ],
        ),
      ],
    );
  }
}

class _SortDropdown extends StatefulWidget {
  final _SortMode mode;
  final ValueChanged<_SortMode> onChanged;

  const _SortDropdown({required this.mode, required this.onChanged});

  @override
  State<_SortDropdown> createState() => _SortDropdownState();
}

class _SortDropdownState extends State<_SortDropdown> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    String label(_SortMode m) {
      switch (m) {
        case _SortMode.newest:
          return 'Newest';
        case _SortMode.price:
          return 'Price';
        case _SortMode.name:
          return 'Name';
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: _hover ? const Color(0xFFE8EAED) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: PopupMenuButton<_SortMode>(
          tooltip: 'Sort list',
          padding: EdgeInsets.zero,
          offset: const Offset(0, 30),
          onSelected: widget.onChanged,
          itemBuilder: (ctx) => [
            _item(_SortMode.newest, 'Newest'),
            _item(_SortMode.price, 'Price'),
            _item(_SortMode.name, 'Name (A–Z)'),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sort_rounded, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 4),
                Text(
                  label(widget.mode),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                ),
                Icon(Icons.arrow_drop_down_rounded, size: 20, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<_SortMode> _item(_SortMode m, String t) {
    return PopupMenuItem(
      value: m,
      child: Row(
        children: [
          Expanded(child: Text(t)),
          if (widget.mode == m) Icon(Icons.check, size: 18, color: _kFab),
        ],
      ),
    );
  }
}

String _formatPriceRupee(double basePriceMinor) {
  final rupees = basePriceMinor / 100.0;
  if (rupees >= 100000) {
    return '₹${NumberFormat.compactCurrency(symbol: '', decimalDigits: 0).format(rupees)}';
  }
  return '₹${NumberFormat('#,###', 'en_IN').format(rupees.round())}';
}

class _DecorationCard extends StatefulWidget {
  final DecorationListItem item;

  const _DecorationCard({required this.item});

  @override
  State<_DecorationCard> createState() => _DecorationCardState();
}

class _DecorationCardState extends State<_DecorationCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final thumb = item.thumbnailUrl;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hover ? const Color(0xFFFAFBFC) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _hover ? Colors.grey.shade300 : Colors.grey.shade200),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: kIsWeb ? 0.08 : 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(AppRoutes.adminDecorationsDetailPath(item.id)),
            borderRadius: BorderRadius.circular(14),
            hoverColor: _kRose.withValues(alpha: 0.15),
            splashColor: _kRose.withValues(alpha: 0.25),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 56,
                          height: 56,
                          color: _kRose,
                          child: thumb != null
                              ? Image.network(
                                  thumb,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(Icons.spa_rounded, color: _kGoldMuted, size: 26),
                                )
                              : Icon(Icons.spa_rounded, color: _kGoldMuted, size: 26),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: _kNavy,
                                height: 1.2,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.eventTypeName.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                item.eventTypeName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.place_outlined, size: 13, color: Colors.grey.shade400),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    item.cityName.isEmpty ? '—' : item.cityName,
                                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatPriceRupee(item.basePrice),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _StatusPill(active: item.active),
                          const SizedBox(height: 6),
                          Material(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                            child: PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              offset: const Offset(0, 28),
                              icon: Icon(Icons.more_horiz_rounded, size: 20, color: Colors.grey.shade700),
                              splashRadius: 20,
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                              onSelected: (v) {
                                if (v == 'edit') {
                                  context.push(AppRoutes.editDeceorationPath(item.id));
                                } else if (v == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (ctx2) => AlertDialog(
                                      title: const Text('Delete decoration'),
                                      content: const Text('Remove this package from the catalog?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Cancel')),
                                        TextButton(
                                          onPressed: () {
                                            context.read<AdminDecorationListBloc>().add(DeleteAdminDecoration(item.id));
                                            Navigator.pop(ctx2);
                                          },
                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.photo_library_outlined, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 6),
                        Text(
                          '${item.imageUrls.length} image${item.imageUrls.length == 1 ? '' : 's'}',
                          style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                        ),
                        Text(' · ', style: TextStyle(color: Colors.grey.shade300)),
                        Text(
                          '0 bookings',
                          style: TextStyle(fontSize: 10.5, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const Color _kGoldMuted = Color(0xFFC5A572);

class _StatusPill extends StatelessWidget {
  final bool active;

  const _StatusPill({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE8F5E9) : const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? const Color(0xFFC8E6C9) : Colors.grey.shade300),
      ),
      child: Text(
        active ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.35,
          color: active ? const Color(0xFF1B5E20) : Colors.grey.shade700,
        ),
      ),
    );
  }
}

class _PaginationRow extends StatelessWidget {
  final DecorationListResponse response;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationRow({required this.response, this.onPrev, this.onNext});

  @override
  Widget build(BuildContext context) {
    if (response.totalPages <= 1) return const SizedBox(height: 4);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${response.page + 1} / ${response.totalPages}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              _PgBtn(icon: Icons.chevron_left, onTap: onPrev),
              const SizedBox(width: 6),
              _PgBtn(icon: Icons.chevron_right, onTap: onNext),
            ],
          ),
        ],
      ),
    );
  }
}

class _PgBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _PgBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        hoverColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: onTap != null ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _kRose,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: _kGoldMuted.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8)),
              ],
            ),
            child: Icon(Icons.auto_awesome_outlined, size: 48, color: _kGoldMuted.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 20),
          Text(
            'No Decorations Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _kNavy),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first decoration package to appear in the catalog.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onCreate,
            style: FilledButton.styleFrom(
              backgroundColor: _kFab,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Create Decoration', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;

  const _ErrorBlock({required this.msg, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, size: 40, color: Colors.red.shade300),
          const SizedBox(height: 10),
          Text(msg, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
