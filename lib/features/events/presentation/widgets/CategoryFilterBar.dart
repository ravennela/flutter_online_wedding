
import 'package:flutter/material.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All Events',
      'Birthdays',
      'Saree Functions',
      'Anniversaries',
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final selected = index == 0;
          return ChoiceChip(
            label: Text(categories[index]),
            selected: selected,
            onSelected: (_) {},
          );
        },
      ),
    );
  }
}
