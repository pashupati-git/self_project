// lib/views/widgets/add_todo_section.dart

import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

/// ADD TODO SECTION COMPONENT
///
/// Responsive form for adding new todos
///
/// UI Logic:
/// - Displays input fields for title and description
/// - Adapts layout based on screen size
/// - Handles user input and submit actions
///
/// Responsibilities:
/// - Render input form
/// - Handle text submission
/// - Provide visual feedback
///
/// This is a stateless widget because:
/// - State is managed by parent (text controllers)
/// - No internal state to manage
/// - Pure presentation component
class AddTodoSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final VoidCallback onAdd;

  const AddTodoSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    // UI Logic: Responsive layout - check device type
    final isMobile = Responsive.isMobile(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title input field
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter todo title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              // UI Logic: Move to next field on enter
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 12),

            // Description input field
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter todo description (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              // UI Logic: Responsive multi-line
              // Mobile: 2 lines, Larger screens: 3 lines
              maxLines: isMobile ? 2 : 3,
              // UI Logic: Submit on enter
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onAdd(),
            ),

            const SizedBox(height: 12),

            // Add button
            // UI Logic: Full width on mobile, auto width on larger screens
            SizedBox(
              width: isMobile ? double.infinity : null,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add Todo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: Responsive.getButtonPadding(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}