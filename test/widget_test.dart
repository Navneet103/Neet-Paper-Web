import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neet_paper_test/core/theme/app_theme.dart';
import 'package:neet_paper_test/core/widgets/app_components.dart';

void main() {
  testWidgets('AppBadge renders label and icon correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppBadge(
            text: 'Physics',
            icon: Icons.science,
            backgroundColor: AppColors.primaryLight,
            textColor: AppColors.primary,
          ),
        ),
      ),
    );

    expect(find.text('Physics'), findsOneWidget);
    expect(find.byIcon(Icons.science), findsOneWidget);
  });

  testWidgets('AppMetricCard displays title, value and icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: AppMetricCard(
            title: 'Questions in Bank',
            value: '720',
            subtitle: 'Ready offline',
            icon: Icons.library_books,
          ),
        ),
      ),
    );

    expect(find.text('Questions in Bank'), findsOneWidget);
    expect(find.text('720'), findsOneWidget);
    expect(find.text('Ready offline'), findsOneWidget);
    expect(find.byIcon(Icons.library_books), findsOneWidget);
  });
}
