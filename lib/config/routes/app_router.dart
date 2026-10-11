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
import '../../features/daily_test/presentation/view/daily_test_page.dart';
import '../../features/daily_test/presentation/view/publish_daily_test_page.dart';
import '../../features/auth/presentation/view/login_page.dart';
import '../../features/admin/presentation/view/admin_dashboard_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      // Auth screen (Public, No Sidebar)
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          return LoginPage(initialTab: tab);
        },
      ),
      // Admin Console (Dedicated full view)
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),

      // Immersive screens (No Sidebar)
      GoRoute(
        path: '/exam/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          List<dynamic>? questions;
          String? testDocId;

          if (state.extra is Map<String, dynamic>) {
            final extraMap = state.extra as Map<String, dynamic>;
            questions = extraMap['questions'] as List<dynamic>?;
            testDocId = extraMap['testDocId'] as String?;
          } else if (state.extra is List<dynamic>) {
            questions = state.extra as List<dynamic>?;
          }

          return ExaminationPage(
            testId: id,
            questions: questions?.cast() ?? [],
            testDocId: testDocId,
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
            path: '/daily-test',
            builder: (context, state) => const DailyTestPage(),
          ),
          GoRoute(
            path: '/publish-daily-test',
            builder: (context, state) => const PublishDailyTestPage(),
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
