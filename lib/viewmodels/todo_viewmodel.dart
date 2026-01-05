// lib/viewmodels/todo_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/todo_model.dart';
import '../repositories/todo_repository.dart';
import '../providers/providers.dart';

/// TODO VIEW MODEL
///
/// UI Logic: State management and user interaction handling
///
/// Responsibilities:
/// 1. Manage todo list state (AsyncValue<List<TodoModel>>)
/// 2. Handle user actions (add, edit, delete, toggle)
/// 3. Provide computed states (filtered lists, stats)
/// 4. Coordinate with repository for data operations
/// 5. Expose UI-friendly methods
///
/// UI Logic:
/// - Validates user input before operations
/// - Manages loading states for async operations
/// - Provides filtered views of data for UI
/// - Handles error states and user feedback
///
/// State Type:
/// AsyncValue<List<TodoModel>> provides:
/// - loading: Shows loading indicator
/// - error: Shows error message
/// - data: Shows actual todo list
class TodoViewModel extends Notifier<AsyncValue<List<TodoModel>>> {
  late final TodoRepository _repository;

  @override
  AsyncValue<List<TodoModel>> build() {
    _repository = ref.read(todoRepositoryProvider);

    // UI Logic: Show loading state initially
    // Load todos when ViewModel is first created
    // This is equivalent to initState in StatefulWidget
    _loadTodos();

    return const AsyncValue.loading();
  }

  /// UI Logic: Load todos with loading/error/success states
  ///
  /// Lifecycle: Called on widget initialization
  /// Handles async state transitions:
  /// loading → data (success) or error (failure)
  Future<void> _loadTodos() async {
    // UI Logic: Set loading state (shows loading indicator)
    state = const AsyncValue.loading();

    try {
      // Business Logic: Initialize repository first
      await _repository.initialize();

      // Business Logic: Fetch todos (offline-first from repository)
      final todos = await _repository.getAllTodos();

      // UI Logic: Set success state with data
      state = AsyncValue.data(todos);
    } catch (e, stack) {
      // UI Logic: Set error state for UI to display
      state = AsyncValue.error(e, stack);
    }
  }

  /// UI Logic: Refresh todos (pull-to-refresh)
  ///
  /// Forces API fetch and updates UI with new data
  /// Used by RefreshIndicator widget
  Future<void> refreshTodos() async {
    state = const AsyncValue.loading();

    try {
      final todos = await _repository.refreshTodos();
      state = AsyncValue.data(todos);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// UI Logic: Add new todo with input validation
  ///
  /// Validation Rules:
  /// - Title must not be empty (after trimming)
  ///
  /// Optimistic Update:
  /// - Adds to UI immediately
  /// - Persists to repository in background
  void addTodo(String title, String description) {
    // UI Logic: Validate input
    if (title.trim().isEmpty) {
      return; // Don't add empty todos
    }

    final newTodo = TodoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      createdAt: DateTime.now(),
    );

    // UI Logic: Optimistic update - add to UI immediately
    state.whenData((todos) {
      state = AsyncValue.data([...todos, newTodo]);
    });

    // Business Logic: Persist to storage (background)
    _repository.addTodo(newTodo);
  }

  /// UI Logic: Toggle todo completion status
  ///
  /// Updates:
  /// - isCompleted: Toggles true/false
  /// - completedAt: Sets timestamp when completed
  ///
  /// Updates UI immediately for smooth UX
  void toggleTodo(String id) {
    state.whenData((todos) {
      final updatedTodos = todos.map((todo) {
        if (todo.id == id) {
          final updated = todo.copyWith(
            isCompleted: !todo.isCompleted,
            completedAt: !todo.isCompleted ? DateTime.now() : null,
          );

          // Business Logic: Persist change
          _repository.updateTodo(updated);

          return updated;
        }
        return todo;
      }).toList();

      // UI Logic: Update state for UI rebuild
      state = AsyncValue.data(updatedTodos);
    });
  }

  /// UI Logic: Edit existing todo with validation
  ///
  /// Validation: Title must not be empty
  /// Updates both title and description
  void editTodo(String id, String newTitle, String newDescription) {
    // UI Logic: Validate input
    if (newTitle.trim().isEmpty) {
      return;
    }

    state.whenData((todos) {
      final updatedTodos = todos.map((todo) {
        if (todo.id == id) {
          final updated = todo.copyWith(
            title: newTitle.trim(),
            description: newDescription.trim(),
          );

          // Business Logic: Persist change
          _repository.updateTodo(updated);

          return updated;
        }
        return todo;
      }).toList();

      // UI Logic: Update state
      state = AsyncValue.data(updatedTodos);
    });
  }

  /// UI Logic: Delete todo with immediate UI update
  ///
  /// Optimistic delete:
  /// - Removes from UI immediately
  /// - Deletes from storage in background
  void deleteTodo(String id) {
    state.whenData((todos) {
      // UI Logic: Remove from UI immediately
      final updatedTodos = todos.where((todo) => todo.id != id).toList();
      state = AsyncValue.data(updatedTodos);
    });

    // Business Logic: Delete from storage
    _repository.deleteTodo(id);
  }

  /// UI Logic: Clear all completed todos
  ///
  /// Provides batch operation for better UX
  /// Removes all todos where isCompleted == true
  void clearCompleted() {
    state.whenData((todos) {
      // UI Logic: Filter out completed todos from UI
      final activeTodos = todos.where((todo) => !todo.isCompleted).toList();
      state = AsyncValue.data(activeTodos);
    });

    // Business Logic: Batch delete from storage
    _repository.clearCompleted();
  }

  /// UI Logic: Toggle all todos at once
  ///
  /// Bulk operation for user convenience
  /// - If all completed: Mark all as active
  /// - If any active: Mark all as completed
  void toggleAll() {
    state.whenData((todos) {
      // UI Logic: Check if all are completed
      final allCompleted = todos.every((todo) => todo.isCompleted);

      // UI Logic: Toggle all to opposite state
      final updatedTodos = todos.map((todo) {
        final updated = todo.copyWith(
          isCompleted: !allCompleted,
          completedAt: !allCompleted ? DateTime.now() : null,
        );

        // Business Logic: Persist each change
        _repository.updateTodo(updated);

        return updated;
      }).toList();

      // UI Logic: Update state
      state = AsyncValue.data(updatedTodos);
    });
  }
}

/// TodoViewModel Provider
/// Exposes the ViewModel to the UI layer
final todoViewModelProvider =
NotifierProvider<TodoViewModel, AsyncValue<List<TodoModel>>>(() {
  return TodoViewModel();
});