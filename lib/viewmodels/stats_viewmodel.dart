// lib/viewmodels/stats_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/todo_model.dart';
import 'todo_viewmodel.dart';

/// STATS VIEW MODEL
///
/// UI Logic: Provides computed statistics for UI display
///
/// This is DERIVED/COMPUTED state from TodoViewModel
///
/// Responsibilities:
/// - Watch todo list
/// - Calculate statistics (total, active, completed counts)
/// - Automatically update when todos change
/// - Provide stats in UI-friendly format
///
/// Statistics Provided:
/// - total: Total number of todos
/// - active: Number of incomplete todos
/// - completed: Number of completed todos
///
/// Benefits:
/// - Real-time stats updates
/// - No manual counting needed
/// - Automatically recomputes on todo changes
class StatsViewModel extends Notifier<TodoStats> {
  @override
  TodoStats build() {
    // UI Logic: Watch todos for reactive stats calculation
    final todosAsync = ref.watch(todoViewModelProvider);

    return todosAsync.when(
      // When data is available, calculate stats
      data: (todos) {
        // UI Logic: Calculate stats for display
        final activeCount = todos.where((todo) => !todo.isCompleted).length;
        final completedCount = todos.where((todo) => todo.isCompleted).length;

        return TodoStats(
          total: todos.length,
          active: activeCount,
          completed: completedCount,
        );
      },
      // While loading, return zero stats
      loading: () => TodoStats(total: 0, active: 0, completed: 0),
      // On error, return zero stats
      error: (_, __) => TodoStats(total: 0, active: 0, completed: 0),
    );
  }
}

/// StatsViewModel Provider
/// Provides todo statistics to UI
final statsViewModelProvider =
NotifierProvider<StatsViewModel, TodoStats>(() {
  return StatsViewModel();
});