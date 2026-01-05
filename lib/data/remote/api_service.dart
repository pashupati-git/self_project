// lib/data/remote/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../model/todo_model.dart';


/// REMOTE DATA SOURCE - ApiService
///
/// Handles all API calls to JSONPlaceholder dummy API
///
/// Responsibilities:
/// - Fetch todos from remote server
/// - Handle HTTP requests/responses
/// - Error handling for network operations
/// - JSON serialization/deserialization
///
/// API: https://jsonplaceholder.typicode.com
/// This is a free fake REST API for testing and prototyping
class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  /// Fetch todos from API
  ///
  /// Business Logic:
  /// - Fetches only first 10 todos for demo purposes
  /// - Converts JSON response to TodoModel objects
  /// - Throws exception on network errors
  ///
  /// Returns: List of TodoModel from JSON response
  Future<List<TodoModel>> fetchTodos() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/todos'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // Convert JSON to TodoModel objects (only first 10 for demo)
        return jsonData
            .take(10)
            .map((json) => TodoModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Create new todo via API
  ///
  /// Note: JSONPlaceholder is a fake API, so the todo won't actually
  /// be saved on the server, but it simulates a successful POST request
  ///
  /// Returns: Created TodoModel from API response
  Future<TodoModel> createTodo(TodoModel todo) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/todos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(todo.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return TodoModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create todo');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update todo via API
  ///
  /// JSONPlaceholder simulates PUT request
  /// Returns: Updated TodoModel from API response
  Future<TodoModel> updateTodo(TodoModel todo) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/todos/${todo.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(todo.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return TodoModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update todo');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Delete todo via API
  ///
  /// JSONPlaceholder simulates DELETE request
  Future<void> deleteTodo(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/todos/$id'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete todo');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}