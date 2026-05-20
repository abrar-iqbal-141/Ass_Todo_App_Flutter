// ============================================================
// Assignment #1 - MAD (Mobile Application Development) 2026
// Szabist University
//
// Group Members:
//   1. Hafiz Abrar Iqbal       - Roll# 2280142
//   2. [Member 2 Name]         - Roll# [ID]
//   3. [Member 3 Name]         - Roll# [ID]
// ============================================================

import 'package:flutter/material.dart';
import 'pages/todo_page.dart';

void main() {
  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow – Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const TodoPage(),
    );
  }
}
