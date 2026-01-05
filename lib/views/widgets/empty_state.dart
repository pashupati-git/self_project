// lib/views/widgets/empty_state.dart

import 'package:flutter/material.dart';

import '../../model/todo_model.dart';
import '../../utils/responsive.dart';

/// EMPTY STATE COMPONENT
///
/// Displays context-aware empty state messages
///
/// UI Logic:
/// - Shows different message based on current filter
/// - Provides visual feedback with icon
/// - Helps user understand why list is empty
///
/// Responsibilities:
/// - Render empty state UI
/// - Provide context-specific messaging
/// - Guide user on next action
///
/// This improves UX by:
/// - Avoiding blank screens
/// - Explaining the current state
/// - Encouraging user action
class EmptyState extends StatelessWidget {
  final TodoFilter filter;

  const EmptyState({
    super.key,
    required this.filter,
  });

  /// UI Logic: Get context-appropriate message based on filter
  String _getMessage() {
    switch (filter) {
      case TodoFilter.active:
        return 'No active todos!\nAll tasks completed 🎉';
      case TodoFilter.completed:
        return 'No completed todos yet.\nStart checking off tasks!';
      case TodoFilter.all:
      default:
        return 'No todos yet.\nAdd your first task above!';
    }
  }

  /// UI Logic: Get context-appropriate icon based on filter
  IconData _getIcon() {
    switch (filter) {
      case TodoFilter.active:
        return Icons.check_circle_outline; // All done icon
      case TodoFilter.completed:
        return Icons.pending_actions; // Waiting for completion
      case TodoFilter.all:
      default:
        return Icons.inbox; // Empty inbox
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // UI Logic: Large icon for visual feedback
          Icon(
            _getIcon(),
            size: 80,
            color: Colors.grey[400],
          ),

          const SizedBox(height: 16),

          // UI Logic: Context-specific message
          Text(
            _getMessage(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Responsive.getBodyFontSize(context) + 2,
              color: Colors.grey[600],
              height: 1.5, // Line height for readability
            ),
          ),
        ],
      ),
    );
  }
}