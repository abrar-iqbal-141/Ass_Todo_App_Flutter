// ============================================================
// Assignment #1 - MAD (Mobile Application Development) 2026
// Szabist University
//
// Group Members:
//   1. Hafiz Abrar Iqbal       - Roll# 2280142
//   2. [Member 2 Name]         - Roll# [ID]
//   3. [Member 3 Name]         - Roll# [ID]
// ============================================================

class Todo {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final String createdAt;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.createdAt,
  });

  /// Convert JSON map → Todo object
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      completed: json['completed'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }

  /// Convert Todo → JSON map (for API POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'completed': completed,
    };
  }

  /// Full JSON including id & createdAt (for local persistence)
  Map<String, dynamic> toJsonFull() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'createdAt': createdAt,
    };
  }

  /// Returns a copy with updated fields
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    String? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
