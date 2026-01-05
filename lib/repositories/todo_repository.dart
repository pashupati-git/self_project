// lib/repositories/todo_repository.dart

import '../data/local/hive_service.dart';
import '../data/remote/api_service.dart';
import '../model/todo_model.dart';


/// REPOSITORY LAYER - TodoRepository
///
/// Business Logic: Data management and synchronization
///
/// Responsibilities:
/// 1. Coordinate between local (Hive) and remote (API) data sources
/// 2. Implement caching strategy: fetch from API, save to local
/// 3. Provide single source of truth for data access
/// 4. Handle data synchronization between local and remote
/// 5. Abstract data sources from ViewModels
///
/// Business Rules:
/// - Always try to load from local storage first (offline-first approach)
/// - Fetch from API only if local storage is empty or on manual refresh
/// - All changes are saved locally immediately for instant UI updates
/// - API calls are optional (app works offline)
///
/// Strategy Pattern:
/// - Local-first: Check local storage before API
/// - Optimistic updates: Update local immediately, sync API in background
/// - Graceful degradation: Continue working even if API fails
class TodoRepository {
  final HiveService _hiveService;
  final ApiService _apiService;

  TodoRepository({
    required HiveService hiveService,
    required ApiService apiService,
  })  : _hiveService = hiveService,
        _apiService = apiService;

  /// BUSINESS LOGIC: Initialize repository
  /// Ensures Hive is ready before any operations
  /// Must be called before using the repository
  Future<void> initialize() async {
    await _hiveService.init();
  }

  /// BUSINESS LOGIC: Get all todos with offline-first strategy
  ///
  /// Strategy:
  /// 1. First check local storage (fast, works offline)
  /// 2. If empty, fetch from API and cache locally
  /// 3. Return cached data for offline access
  ///
  /// This ensures:
  /// - Fast initial load from cache
  /// - Works offline after first load
  /// - Auto-sync when cache is empty
  Future<List<TodoModel>> getAllTodos() async {
    // Try to get from local storage first (offline-first)
    final localTodos = _hiveService.getAllTodos();

    if (localTodos.isNotEmpty) {
      // Return cached data immediately
      return localTodos;
    }

    // If local storage is empty, fetch from API
    try {
      final remoteTodos = await _apiService.fetchTodos();

      // Cache the fetched todos locally for future offline access
      await _hiveService.saveAllTodos(remoteTodos);

      return remoteTodos;
    } catch (e) {
      // If API fails, return empty list (app still works offline)
      // This allows the app to function even without internet
      return [];
    }
  }

  /// BUSINESS LOGIC: Refresh todos from API
  ///
  /// Used for pull-to-refresh functionality
  /// Replaces local cache with fresh API data
  ///
  /// Strategy:
  /// - Always fetch from API (forced refresh)
  /// - Clear old cache and save new data
  /// - If API fails, keep existing local data
  Future<List<TodoModel>> refreshTodos() async {
    try {
      final remoteTodos = await _apiService.fetchTodos();

      // Clear old cache and save new data
      await _hiveService.clearAllTodos();
      await _hiveService.saveAllTodos(remoteTodos);

      return remoteTodos;
    } catch (e) {
      // If refresh fails, return current local data
      // User can still see cached data
      return _hiveService.getAllTodos();
    }
  }

  /// BUSINESS LOGIC: Add new todo
  ///
  /// Optimistic Update Strategy:
  /// 1. Save locally first (instant UI update, no network delay)
  /// 2. Try to sync with API in background
  /// 3. Even if API fails, local data is persisted
  ///
  /// Benefits:
  /// - Instant UI feedback
  /// - Works offline
  /// - Better user experience
  Future<void> addTodo(TodoModel todo) async {
    // Save to local storage immediately (optimistic update)
    await _hiveService.saveTodo(todo);

    // Try to sync with API (optional, non-blocking)
    try {
      await _apiService.createTodo(todo);
      // API sync successful
    } catch (e) {
      // API sync failed, but local save succeeded
      // App continues to work offline
      // In production, you might queue this for retry
    }
  }

  /// BUSINESS LOGIC: Update existing todo
  ///
  /// Same offline-first strategy as addTodo
  /// - Update local immediately for instant UI
  /// - Sync with API in background
  Future<void> updateTodo(TodoModel todo) async {
    // Update local storage immediately
    await _hiveService.updateTodo(todo);

    // Try to sync with API (background operation)
    try {
      await _apiService.updateTodo(todo);
    } catch (e) {
      // Continue even if API sync fails
      // Local update is what matters for UX
    }
  }

  /// BUSINESS LOGIC: Delete todo
  ///
  /// Remove from local storage and attempt API sync
  /// - Delete locally for instant UI update
  /// - Sync deletion with API in background
  Future<void> deleteTodo(String id) async {
    // Delete from local storage immediately
    await _hiveService.deleteTodo(id);

    // Try to sync with API
    try {
      await _apiService.deleteTodo(id);
    } catch (e) {
      // Continue even if API sync fails
    }
  }

  /// BUSINESS LOGIC: Clear completed todos
  ///
  /// Business rule: Only remove completed items
  /// This is a batch operation that deletes multiple todos
  Future<void> clearCompleted() async {
    final allTodos = _hiveService.getAllTodos();
    final completedTodos = allTodos.where((todo) => todo.isCompleted);

    // Delete each completed todo
    for (var todo in completedTodos) {
      await deleteTodo(todo.id);
    }
  }

  /// Get local todo count (for quick stats)
  /// No network call, instant response
  int getTodoCount() {
    return _hiveService.getTodoCount();
  }
}