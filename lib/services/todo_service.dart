// ============================================================
// Assignment #1 - MAD (Mobile Application Development) 2026
// Szabist University
//
// Group Members:
//   1. Hafiz Abrar Iqbal       - Roll# 2280142
//   2. [Member 2 Name]         - Roll# [ID]
//   3. [Member 3 Name]         - Roll# [ID]
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo_model.dart';

class TodoService {
  // JSONPlaceholder – free fake API for testing & prototyping
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/todos';

  /// Fetch a paginated list of todos (10 per page)
  Future<List<Todo>> getTodos(int page) async {
    final int start = (page - 1) * 10;
    final url = Uri.parse('$_baseUrl?_start=$start&_limit=10');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((item) => _mapPlaceholder(item)).toList();
    } else {
      throw Exception('Failed to load todos (${response.statusCode})');
    }
  }

  /// Add a new todo via POST
  Future<Todo> addTodo(String title, String description) async {
    final url = Uri.parse(_baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'body': description,
        'completed': false,
        'userId': 1,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // JSONPlaceholder returns id 201 for new items; use a unique local id
      return Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        completed: false,
        createdAt: DateTime.now().toIso8601String(),
      );
    } else {
      throw Exception('Failed to add todo (${response.statusCode})');
    }
  }

  /// Toggle a todo's completed status via PUT
  Future<Todo> updateTodo(Todo todo) async {
    final url = Uri.parse('$_baseUrl/${todo.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': int.tryParse(todo.id) ?? 0,
        'title': todo.title,
        'body': todo.description,
        'completed': !todo.completed,
        'userId': 1,
      }),
    );

    if (response.statusCode == 200) {
      // Return a locally-updated copy (JSONPlaceholder does not persist state)
      return todo.copyWith(completed: !todo.completed);
    } else {
      throw Exception('Failed to update todo (${response.statusCode})');
    }
  }

  /// Delete a todo via DELETE
  Future<void> deleteTodo(String id) async {
    final url = Uri.parse('$_baseUrl/$id');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo (${response.statusCode})');
    }
  }

  // ─── Private helpers ────────────────────────────────────────────────────────

  /// Map a JSONPlaceholder item to our Todo model
  Todo _mapPlaceholder(Map<String, dynamic> json) {
    return Todo(
      id: json['id'].toString(),
      title: (json['title'] as String? ?? '').capitalize(),
      description:
          (json['title'] as String? ?? '').capitalize(), // placeholder has no body
      completed: json['completed'] ?? false,
      createdAt: '',
    );
  }
}

extension _StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
