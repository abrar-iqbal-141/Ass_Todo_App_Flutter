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
import 'package:flutter_test/flutter_test.dart';
import 'package:ass_todo_app/main.dart';

void main() {
  testWidgets('App launches and shows TaskFlow title',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    expect(find.text('TaskFlow'), findsOneWidget);
  });
}
