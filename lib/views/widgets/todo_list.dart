// lib/views/widgets/todo_list.dart

import 'package:flutter/material.dart';
import '../../model/todo_model.dart';

import 'todo_item_view.dart';

/// TODO LIST COMPONENT
///
/// Displays list of todos using ListView
///
/// UI Logic:
/// - Renders scrollable list of todos
/// - Optimizes performance with ListView.builder
/// - Adds bottom padding for FAB clearance
///
/// Responsibilities:
/// - Render list efficiently
/// - Handle scrolling
/// - Pass todos to item widgets
///
/// Performance:
/// - ListView.builder creates items on-demand (lazy loading)
/// - Only renders visible items
/// - Scrolls smoothly even with many items
class TodoList extends StatelessWidget {
  final List<TodoModel> todos;

  const TodoList({
    super.key,
    required this.todos,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // UI Logic: Add bottom padding so FAB doesn't cover last item
      padding: const EdgeInsets.only(bottom: 80),
      // Performance: Only build visible items
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return TodoItemView(todo: todos[index]);
      },
    );
  }
}