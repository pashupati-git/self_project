// lib/providers/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/hive_service.dart';
import '../data/remote/api_service.dart';
import '../repositories/todo_repository.dart';

/// PROVIDERS
///
/// Central location for all Riverpod providers
/// Defines dependency injection and provider hierarchy
///
/// Provider Types:
/// - Provider: For services and repositories (singletons)
/// - NotifierProvider: For ViewModels (defined in viewmodel files)

// ==================== SERVICE PROVIDERS ====================

/// HiveService Provider (Singleton)
/// Provides local storage service instance
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

/// ApiService Provider (Singleton)
/// Provides API service instance for remote data access
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// ==================== REPOSITORY PROVIDER ====================

/// TodoRepository Provider (Business Logic Layer)
///
/// Dependencies:
/// - HiveService: For local data operations
/// - ApiService: For remote data operations
///
/// This provider coordinates data flow between services
/// and provides a single source of truth for data access
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository(
    hiveService: ref.read(hiveServiceProvider),
    apiService: ref.read(apiServiceProvider),
  );
});

// Note: ViewModel providers are defined in their respective viewmodel files
// This keeps each viewmodel file self-contained with its provider