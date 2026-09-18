import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class AppSideNavigation extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AppSideNavigation({
    super.key,
    required this.child,
    required this.currentPath,
  });

  static const List<_NavItem> _navItems = [
    _NavItem(route: '/dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded),
    _NavItem(route: '/bank', label: 'Question Bank', icon: Icons.library_books_outlined, activeIcon: Icons.library_books_rounded),
    _NavItem(route: '/import', label: 'Import Questions', icon: Icons.upload_file_outlined, activeIcon: Icons.upload_file_rounded),
    _NavItem(route: '/create-test', label: 'Create Test', icon: Icons.add_task_outlined, activeIcon: Icons.add_task_rounded),
    _NavItem(route: '/history', label: 'Test History', icon: Icons.history_toggle_off_rounded, activeIcon: Icons.history_rounded),
    _NavItem(route: '/analytics', label: 'Analytics', icon: Icons.insights_outlined, activeIcon: Icons.insights_rounded),
    _NavItem(route: '/settings', label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isExam = currentPath.contains('/exam/');
    if (isExam) return child;

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768; // Standard tablet breakpoint
    final isCompact = width >= 768 && width < 1100;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_getPageTitle(currentPath)),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: AppColors.surface,
          child: Column(
            children: [
              _buildBrandHeader(context, false),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemCount: _navItems.length,
                  itemBuilder: (context, index) {
                    final item = _navItems[index];
                    final isSelected = currentPath.startsWith(item.route);
                    return _buildNavItem(
                      context: context,
                      item: item,
                      isSelected: isSelected,
                      isCompact: false,
                      onTap: () {
                        context.go(item.route);
                        Navigator.pop(context); // Close drawer
                      },
                    );
                  },
                ),
              ),
              _buildFooter(context, false),
            ],
          ),
        ),
        body: child,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isCompact ? 72 : 240,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(right: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool effectivelyCompact = constraints.maxWidth < 160;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandHeader(context, effectivelyCompact),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: effectivelyCompact ? 5 : 10),
                        itemCount: _navItems.length,
                        itemBuilder: (context, index) {
                          final item = _navItems[index];
                          final isSelected = currentPath.startsWith(item.route);
                          return _buildNavItem(
                            context: context,
                            item: item,
                            isSelected: isSelected,
                            isCompact: effectivelyCompact,
                            onTap: () => context.go(item.route),
                          );
                        },
                      ),
                    ),
                    _buildFooter(context, effectivelyCompact),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(String path) {
    for (var item in _navItems) {
      if (path.startsWith(item.route)) return item.label;
    }
    return 'NEET Master';
  }

  Widget _buildBrandHeader(BuildContext context, bool isCompact) {
    return InkWell(
      onTap: () => context.go('/dashboard'),
      child: Container(
        height: 68,
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 0 : 18),
        child: Row(
          mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            SizedBox(
              width: isCompact ? 71 : 38, // Reduced from 72 to 71 to account for 1px border
              child: Center(
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
            if (!isCompact) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'NEET Master',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Enterprise Offline',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required _NavItem item,
    required bool isSelected,
    required bool isCompact,
    required VoidCallback onTap,
  }) {
    final tile = Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: isSelected ? AppColors.primaryLight : AppColors.surfaceSubtle,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 0 : 14,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: isCompact ? 60 : 20,
                  child: Center(
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (isCompact) {
      return Tooltip(
        message: item.label,
        waitDuration: const Duration(milliseconds: 300),
        child: tile,
      );
    }
    return tile;
  }

  Widget _buildFooter(BuildContext context, bool isCompact) {
    if (isCompact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Offline Database',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Text(
            'SQLite',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String route;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
