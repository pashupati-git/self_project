// lib/viewmodels/filtered_todos_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/todo_model.dart';
import 'todo_viewmodel.dart';
import 'filter_viewmodel.dart';

/// FILTERED TODOS VIEW MODEL
///
/// UI Logic: Provides filtered list based on current filter
///
/// This is a DERIVED/COMPUTED state from:
/// 1. All todos (from TodoViewModel)
/// 2. Current filter (from FilterViewModel)
///
/// Responsibilities:
/// - Watch both todos and filter state
/// - Automatically recompute when either changes
/// - Return filtered list for UI display
///
/// Benefits:
/// - Single source of truth (computed from other states)
/// - Automatic updates when dependencies change
/// - No manual synchronization needed
/// - Clean separation of concerns
class FilteredTodosViewModel extends Notifier<List<TodoModel>> {
  @override
  List<TodoModel> build() {
    // UI Logic: Watch both todos and filter for reactive updates
    final todosAsync = ref.watch(todoViewModelProvider);
    final filter = ref.watch(filterViewModelProvider);

    // UI Logic: Return filtered list based on current filter
    return todosAsync.when(
      // When data is available, apply filter
      data: (todos) {
        switch (filter) {
          case TodoFilter.active:
          // Show only incomplete todos
            return todos.where((todo) => !todo.isCompleted).toList();

          case TodoFilter.completed:
          // Show only completed todos
            return todos.where((todo) => todo.isCompleted).toList();

          case TodoFilter.all:
          default:
          // Show all todos
            return todos;
        }
      },
      // While loading, return empty list
      loading: () => [],
      // On error, return empty list
      error: (_, __) => [],
    );
  }
}

/// FilteredTodosViewModel Provider
/// Provides the filtered todo list to UI
final filteredTodosViewModelProvider =
NotifierProvider<FilteredTodosViewModel, List<TodoModel>>(() {
  return FilteredTodosViewModel();
});