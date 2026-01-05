// lib/views/widgets/todo_item_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/todo_model.dart';
import '../../viewmodels/todo_viewmodel.dart';
import '../../utils/responsive.dart';

/// TODO ITEM VIEW
///
/// Individual todo card with edit/delete functionality
///
/// UI Logic:
/// - Displays todo details (title, description, status)
/// - Provides edit mode with inline editing
/// - Handles completion toggle
/// - Confirmation for destructive actions
/// - Responsive layout (mobile vs desktop)
///
/// Lifecycle:
/// - initState: Initialize controllers with todo data
/// - build: Render view or edit mode
/// - dispose: Clean up controllers
///
/// This uses ConsumerStatefulWidget because:
/// - Needs access to Riverpod providers
/// - Manages local UI state (edit mode, controllers)
/// - Requires lifecycle methods for controller management
class TodoItemView extends ConsumerStatefulWidget {
  final TodoModel todo;

  const TodoItemView({
    super.key,
    required this.todo,
  });

  @override
  ConsumerState<TodoItemView> createState() => _TodoItemViewState();
}

class _TodoItemViewState extends ConsumerState<TodoItemView> {
  // UI State: Edit mode flag
  bool _isEditing = false;

  // UI State: Text controllers for editing
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  /// UI Lifecycle: Initialize controllers with current todo data
  /// Called once when widget is created
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(text: widget.todo.description);
  }

  /// UI Lifecycle: Dispose controllers to prevent memory leaks
  /// CRITICAL: Always dispose controllers
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// UI Logic: Save edited todo
  /// Validates and calls ViewModel
  void _saveEdit() {
    // UI Logic: Validate input
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // UI Logic: Call ViewModel to update todo
    ref.read(todoViewModelProvider.notifier).editTodo(
      widget.todo.id,
      _titleController.text,
      _descriptionController.text,
    );

    // UI Logic: Exit edit mode
    setState(() => _isEditing = false);

    // UI Logic: Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todo updated'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// UI Logic: Cancel editing
  /// Resets controllers to original values
  void _cancelEdit() {
    _titleController.text = widget.todo.title;
    _descriptionController.text = widget.todo.description;
    setState(() => _isEditing = false);
  }

  /// UI Logic: Confirm delete with dialog
  /// Prevents accidental deletion
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${widget.todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // UI Logic: Call ViewModel to delete
              ref.read(todoViewModelProvider.notifier).deleteTodo(widget.todo.id);
              Navigator.pop(context);

              // UI Logic: Show feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Todo deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      // UI Logic: Higher elevation when editing to indicate focus
      elevation: _isEditing ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: _isEditing
            ? _buildEditMode(isMobile)
            : _buildViewMode(isMobile),
      ),
    );
  }

  /// UI Logic: View mode - shows todo details
  Widget _buildViewMode(bool isMobile) {
    return Column(
      children: [
        Row(
          children: [
            // Checkbox for completion toggle
            Checkbox(
              value: widget.todo.isCompleted,
              onChanged: (_) {
                // UI Logic: Call ViewModel to toggle completion
                ref.read(todoViewModelProvider.notifier).toggleTodo(widget.todo.id);
              },
              activeColor: Colors.indigo,
            ),

            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.todo.title,
                    style: TextStyle(
                      fontSize: Responsive.getBodyFontSize(context) + 2,
                      fontWeight: FontWeight.bold,
                      // UI Logic: Strike through if completed
                      decoration: widget.todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: widget.todo.isCompleted
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),

                  // Description (if exists)
                  if (widget.todo.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.todo.description,
                        style: TextStyle(
                          fontSize: Responsive.getBodyFontSize(context),
                          color: widget.todo.isCompleted
                              ? Colors.grey[400]
                              : Colors.grey[700],
                          decoration: widget.todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            // Action buttons (responsive)
            if (isMobile)
            // UI Logic: Mobile - use popup menu to save space
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    setState(() => _isEditing = true);
                  } else if (value == 'delete') {
                    _confirmDelete();
                  }
                },
              )
            else
            // UI Logic: Desktop/Tablet - show icon buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => setState(() => _isEditing = true),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _confirmDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
          ],
        ),

        // Show completion date if completed
        if (widget.todo.isCompleted && widget.todo.completedAt != null)
          Padding(
            padding: const EdgeInsets.only(left: 56, top: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  'Completed ${_formatDate(widget.todo.completedAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// UI Logic: Edit mode - shows input fields
  Widget _buildEditMode(bool isMobile) {
    return Column(
      children: [
        // Title input
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),

        const SizedBox(height: 12),

        // Description input
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),

        const SizedBox(height: 12),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _cancelEdit,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _saveEdit,
              icon: const Icon(Icons.check),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// UI Logic: Format date for display
  /// Shows relative time for recent dates
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}