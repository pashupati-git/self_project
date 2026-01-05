// lib/views/todo_home_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/todo_viewmodel.dart';
import '../viewmodels/filter_viewmodel.dart';
import '../viewmodels/filtered_todos_viewmodel.dart';
import '../viewmodels/stats_viewmodel.dart';
import '../utils/responsive.dart';
import 'widgets/add_todo_section.dart';
import 'widgets/filter_section.dart';
import 'widgets/empty_state.dart';
import 'widgets/todo_list.dart';

/// TODO HOME VIEW
///
/// Main screen of the application
///
/// UI Logic Lifecycle:
/// 1. initState: Widget is created, controllers initialized
/// 2. build: UI rendered based on ViewModel state
/// 3. User interactions trigger ViewModel methods
/// 4. ViewModel state changes trigger UI rebuilds (via ref.watch)
/// 5. dispose: Clean up resources (controllers)
///
/// This widget uses ConsumerStatefulWidget to:
/// - Have access to Riverpod ref (for watching providers)
/// - Manage local UI state (text controllers, editing mode)
/// - Handle lifecycle methods (initState, dispose)
class TodoHomeView extends ConsumerStatefulWidget {
  const TodoHomeView({super.key});

  @override
  ConsumerState<TodoHomeView> createState() => _TodoHomeViewState();
}

class _TodoHomeViewState extends ConsumerState<TodoHomeView> {
  // UI State: Text controllers for input fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  /// UI Lifecycle: Called once when widget is inserted into tree
  ///
  /// Equivalent to ComponentDidMount in React
  /// Used for one-time initialization
  @override
  void initState() {
    super.initState();
    // UI Logic: Any initialization can be done here
    // ViewModel initialization happens automatically via provider
    // Controllers are already created above
  }

  /// UI Lifecycle: Called when widget is removed from tree
  ///
  /// Equivalent to ComponentWillUnmount in React
  /// CRITICAL: Must clean up resources to prevent memory leaks
  @override
  void dispose() {
    // UI Logic: Clean up controllers to prevent memory leaks
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// UI Logic: Handle add todo action
  ///
  /// Validates input and calls ViewModel
  /// Provides user feedback via SnackBar
  void _addTodo() {
    // UI Logic: Input validation
    if (_titleController.text.trim().isEmpty) {
      // Show error feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // UI Logic: Call ViewModel to add todo
    ref.read(todoViewModelProvider.notifier).addTodo(
      _titleController.text,
      _descriptionController.text,
    );

    // UI Logic: Clear input fields after adding
    _titleController.clear();
    _descriptionController.clear();

    // UI Logic: Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todo added successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// UI Logic: Handle pull-to-refresh
  ///
  /// Called by RefreshIndicator widget
  /// Fetches fresh data from API
  Future<void> _onRefresh() async {
    await ref.read(todoViewModelProvider.notifier).refreshTodos();
  }

  /// UI Logic: Show confirmation dialog before clearing completed
  void _showClearCompletedDialog() {
    final stats = ref.read(statsViewModelProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed'),
        content: Text('Remove ${stats.completed} completed todos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(todoViewModelProvider.notifier).clearCompleted();
              Navigator.pop(context);

              // Show feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Completed todos cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // UI Logic: Watch ViewModel states for reactive UI updates
    // ref.watch causes rebuild when provider state changes
    final todosAsync = ref.watch(todoViewModelProvider);
    final filteredTodos = ref.watch(filteredTodosViewModelProvider);
    final stats = ref.watch(statsViewModelProvider);
    final currentFilter = ref.watch(filterViewModelProvider);

    // UI Logic: Responsive layout using custom utility
    final contentWidth = Responsive.getContentWidth(context);
    final pagePadding = Responsive.getPagePadding(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        title: Text(
          'Todo App - MVVM + Hive',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Responsive.getTitleFontSize(context),
            color: Colors.white,
          ),
        ),
        actions: [
          // UI Logic: Show clear button only if there are completed todos
          if (stats.completed > 0)
            IconButton(
              onPressed: _showClearCompletedDialog,
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              tooltip: 'Clear completed todos',
            ),
          // UI Logic: Refresh button
          IconButton(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh from API',
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: contentWidth,
          padding: pagePadding,
          child: Column(
            children: [
              // UI Component: Add todo section
              AddTodoSection(
                titleController: _titleController,
                descriptionController: _descriptionController,
                onAdd: _addTodo,
              ),

              const SizedBox(height: 16),

              // UI Component: Filter tabs
              FilterSection(
                currentFilter: currentFilter,
                stats: stats,
                onFilterChanged: (filter) {
                  ref.read(filterViewModelProvider.notifier).setFilter(filter);
                },
              ),

              const SizedBox(height: 16),

              // UI Logic: Handle different async states
              Expanded(
                child: todosAsync.when(
                  // UI Logic: Loading state - show loading indicator
                  loading: () => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading todos...'),
                      ],
                    ),
                  ),
                  // UI Logic: Error state - show error message with retry
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _onRefresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  // UI Logic: Success state with data
                  data: (_) {
                    // UI Logic: Show empty state if no filtered todos
                    if (filteredTodos.isEmpty) {
                      return EmptyState(filter: currentFilter);
                    }

                    // UI Logic: Show todo list with pull-to-refresh
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: TodoList(todos: filteredTodos),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // UI Logic: Show FAB only if there are multiple todos
      floatingActionButton: stats.total > 1
          ? FloatingActionButton.extended(
        onPressed: () {
          ref.read(todoViewModelProvider.notifier).toggleAll();
        },
        icon: const Icon(Icons.done_all),
        label: const Text('Toggle All'),
        backgroundColor: Colors.indigo,
      )
          : null,
    );
  }
}