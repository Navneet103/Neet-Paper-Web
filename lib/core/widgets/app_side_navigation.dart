import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSideNavigation extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AppSideNavigation({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    // Hide navigation rail during an active examination
    final bool isExam = currentPath.contains('/exam/');

    if (isExam) return child;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 1200,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.upload_file_outlined),
                selectedIcon: Icon(Icons.upload_file),
                label: Text('Import'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.library_books_outlined),
                selectedIcon: Icon(Icons.library_books),
                label: Text('Question Bank'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_task_outlined),
                selectedIcon: Icon(Icons.add_task),
                label: Text('Create Test'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: Text('History'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
            selectedIndex: _getSelectedIndex(currentPath),
            onDestinationSelected: (index) {
              final routes = [
                '/dashboard',
                '/import',
                '/bank',
                '/create-test',
                '/history',
                '/analytics',
                '/settings'
              ];
              context.go(routes[index]);
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _getSelectedIndex(String path) {
    if (path.startsWith('/dashboard')) return 0;
    if (path.startsWith('/import')) return 1;
    if (path.startsWith('/bank')) return 2;
    if (path.startsWith('/create-test')) return 3;
    if (path.startsWith('/history')) return 4;
    if (path.startsWith('/analytics')) return 5;
    if (path.startsWith('/settings')) return 6;
    return 0;
  }
}
