// lib/models/todo_model.dart

import 'package:hive/hive.dart';

part 'todo_model.g.dart'; // Generated file for Hive TypeAdapter

/// TodoModel - Main data model for a todo item
///
/// This model is annotated with Hive annotations for local storage
/// and includes JSON serialization for API communication
@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? completedAt;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  /// Factory constructor from JSON (for API responses)
  /// JSONPlaceholder API uses 'body' field instead of 'description'
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['body'] ?? '', // JSONPlaceholder uses 'body'
      isCompleted: json['completed'] ?? false,
      createdAt: DateTime.now(),
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': description,
      'completed': isCompleted,
    };
  }

  /// Copy with method for immutable updates
  /// Used when updating specific fields while keeping others unchanged
  TodoModel copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return TodoModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Filter enum for todo filtering in UI
enum TodoFilter { all, active, completed }

/// Stats model for displaying todo statistics in UI
class TodoStats {
  final int total;
  final int active;
  final int completed;

  TodoStats({
    required this.total,
    required this.active,
    required this.completed,
  });
}