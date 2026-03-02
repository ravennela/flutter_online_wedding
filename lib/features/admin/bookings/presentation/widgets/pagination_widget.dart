import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalItems;
  final Function(int) onPageChanged;
  final Function(int) onPageSizeChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalItems,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: isMobile ? _buildMobilePagination() : _buildDesktopPagination(),
        );
      }
    );
  }

  Widget _buildDesktopPagination() {
    final startItem = totalItems == 0 ? 0 : (currentPage - 1) * pageSize + 1;
    final endItem = (currentPage * pageSize) > totalItems ? totalItems : (currentPage * pageSize);

    return Row(
      children: [
        Text(
          'Showing $startItem–$endItem of $totalItems bookings',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const Spacer(),
        _buildPageSizeDropdown(),
        const SizedBox(width: 24),
        _buildPageNumbers(),
      ],
    );
  }

  Widget _buildMobilePagination() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPageSizeDropdown(),
            Text(
              'Page $currentPage of $totalPages',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             _buildNavButton(Icons.chevron_left, currentPage > 1, () => onPageChanged(currentPage - 1)),
             const SizedBox(width: 16),
             _buildNavButton(Icons.chevron_right, currentPage < totalPages, () => onPageChanged(currentPage + 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildPageSizeDropdown() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Items per page: ', style: TextStyle(fontSize: 13)),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: pageSize,
          underline: const SizedBox(),
          items: [10, 20, 50].map((size) => DropdownMenuItem(
            value: size,
            child: Text('$size', style: const TextStyle(fontSize: 13)),
          )).toList(),
          onChanged: (val) => val != null ? onPageSizeChanged(val) : null,
        ),
      ],
    );
  }

  Widget _buildPageNumbers() {
    return Row(
      children: [
        _buildNavButton(Icons.chevron_left, currentPage > 1, () => onPageChanged(currentPage - 1)),
        const SizedBox(width: 8),
        ...List.generate(totalPages, (index) {
          final pageNum = index + 1;
          final isSelected = pageNum == currentPage;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onPageChanged(pageNum),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$pageNum',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        _buildNavButton(Icons.chevron_right, currentPage < totalPages, () => onPageChanged(currentPage + 1)),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, bool enabled, VoidCallback onTap) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? Colors.black87 : Colors.grey.shade300,
        ),
      ),
    );
  }
}
