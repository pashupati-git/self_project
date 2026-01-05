// lib/viewmodels/filter_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/todo_model.dart';


/// FILTER VIEW MODEL
///
/// UI Logic: Manages filter selection state
///
/// Responsibilities:
/// - Store current filter selection (All/Active/Completed)
/// - Provide method to update filter
/// - Notify listeners when filter changes
///
/// This is a simple state management ViewModel
/// that controls which todos are displayed in the UI
class FilterViewModel extends Notifier<TodoFilter> {
  @override
  TodoFilter build() {
    // Initial state: Show all todos
    return TodoFilter.all;
  }

  /// UI Logic: Update filter selection
  ///
  /// Called when user taps on filter chips
  /// Triggers UI rebuild to show filtered todos
  void setFilter(TodoFilter filter) {
    state = filter;
  }
}

/// FilterViewModel Provider
/// Exposes the filter state to the UI
final filterViewModelProvider =
NotifierProvider<FilterViewModel, TodoFilter>(() {
  return FilterViewModel();
});