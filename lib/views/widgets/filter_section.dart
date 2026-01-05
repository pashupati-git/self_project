// lib/views/widgets/filter_section.dart

import 'package:flutter/material.dart';

import '../../model/todo_model.dart';
import '../../utils/responsive.dart';

/// FILTER SECTION COMPONENT
///
/// Responsive filter tabs with statistics
///
/// UI Logic:
/// - Displays filter chips for All/Active/Completed
/// - Shows count for each filter
/// - Highlights current selection
/// - Responsive spacing based on screen size
///
/// Responsibilities:
/// - Render filter options
/// - Show current filter state
/// - Handle filter selection
/// - Display statistics
class FilterSection extends StatelessWidget {
  final TodoFilter currentFilter;
  final TodoStats stats;
  final Function(TodoFilter) onFilterChanged;

  const FilterSection({
    super.key,
    required this.currentFilter,
    required this.stats,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    // UI Logic: Adjust spacing for mobile devices
    final isMobile = Responsive.isMobile(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: isMobile ? 4 : 8, // Tighter spacing on mobile
          runSpacing: 8,
          children: [
            FilterChipWidget(
              label: 'All (${stats.total})',
              selected: currentFilter == TodoFilter.all,
              onSelected: () => onFilterChanged(TodoFilter.all),
            ),
            FilterChipWidget(
              label: 'Active (${stats.active})',
              selected: currentFilter == TodoFilter.active,
              onSelected: () => onFilterChanged(TodoFilter.active),
            ),
            FilterChipWidget(
              label: 'Completed (${stats.completed})',
              selected: currentFilter == TodoFilter.completed,
              onSelected: () => onFilterChanged(TodoFilter.completed),
            ),
          ],
        ),
      ),
    );
  }
}

/// FILTER CHIP WIDGET
///
/// Individual filter chip component
///
/// UI Logic:
/// - Visual indication of selection state
/// - Color change on selection
/// - Tap handling
class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.indigo,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        // UI Logic: White text when selected, dark when not
        color: selected ? Colors.white : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}