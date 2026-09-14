import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_side_navigation.dart';

// Feature Views
import '../../features/dashboard/presentation/view/dashboard_page.dart';
import '../../features/question_import/presentation/view/question_import_page.dart';
import '../../features/question_bank/presentation/view/question_bank_page.dart';
import '../../features/test_generation/presentation/view/test_generation_page.dart';
import '../../features/test_generation/presentation/view/paper_preview_page.dart';
import '../../features/examination/presentation/view/examination_page.dart';
import '../../features/result/presentation/view/result_page.dart';
import '../../features/test_history/presentation/view/test_history_page.dart';
import '../../features/analytics/presentation/view/analytics_page.dart';
import '../../features/settings/presentation/view/settings_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      // Immersive screens (No Sidebar)
      GoRoute(
        path: '/exam/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final questions = state.extra as List<dynamic>?;
          return ExaminationPage(
            testId: id,
            questions: questions?.cast() ?? [],
          );
        },
      ),
      GoRoute(
        path: '/preview-test/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PaperPreviewPage(testId: id);
        },
      ),
      GoRoute(
        path: '/result/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ResultPage(testId: id);
        },
      ),

      // Standard App Shell (With Sidebar)
      ShellRoute(
        builder: (context, state, child) {
          return AppSideNavigation(
            currentPath: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/import',
            builder: (context, state) => const QuestionImportPage(),
          ),
          GoRoute(
            path: '/bank',
            builder: (context, state) => const QuestionBankPage(),
          ),
          GoRoute(
            path: '/create-test',
            builder: (context, state) => const TestGenerationPage(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const TestHistoryPage(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
