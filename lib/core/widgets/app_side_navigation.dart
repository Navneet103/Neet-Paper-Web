import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../injection/injection_container.dart';
import '../auth/auth_service.dart';
import '../theme/app_theme.dart';
import 'app_components.dart';

class AppSideNavigation extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AppSideNavigation({
    super.key,
    required this.child,
    required this.currentPath,
  });

  List<_NavItem> _getNavItems(AuthService auth) {
    if (auth.isAdmin) {
      return const [
        _NavItem(route: '/dashboard', label: 'Dashboard', mobileLabel: 'Home', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded),
        _NavItem(route: '/admin', label: 'Admin Console', mobileLabel: 'Admin', icon: Icons.admin_panel_settings_outlined, activeIcon: Icons.admin_panel_settings_rounded),
        _NavItem(route: '/history', label: 'Test Submissions', mobileLabel: 'Submissions', icon: Icons.history_toggle_off_rounded, activeIcon: Icons.history_rounded),
        _NavItem(route: '/analytics', label: 'Analytics', mobileLabel: 'Analytics', icon: Icons.insights_outlined, activeIcon: Icons.insights_rounded),
        _NavItem(route: '/settings', label: 'Settings', mobileLabel: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded),
      ];
    }

    return const [
      _NavItem(route: '/dashboard', label: 'Dashboard', mobileLabel: 'Home', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded),
      _NavItem(route: '/daily-test', label: 'Daily Live Test (9 AM)', mobileLabel: 'Daily Test', icon: Icons.alarm_on_outlined, activeIcon: Icons.alarm_on_rounded),
      _NavItem(route: '/history', label: 'Test History', mobileLabel: 'History', icon: Icons.history_toggle_off_rounded, activeIcon: Icons.history_rounded),
      _NavItem(route: '/analytics', label: 'Analytics', mobileLabel: 'Analytics', icon: Icons.insights_outlined, activeIcon: Icons.insights_rounded),
      _NavItem(route: '/settings', label: 'Settings', mobileLabel: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isExam = currentPath.contains('/exam/');
    if (isExam) return child;

    final auth = sl<AuthService>();

    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        final navItems = _getNavItems(auth);
        final width = MediaQuery.of(context).size.width;
        final isMobile = width < 768; // Standard tablet breakpoint
        final isCompact = width >= 768 && width < 1100;

        if (isMobile) {
          final selectedIndex = navItems.indexWhere((item) => currentPath.startsWith(item.route));
          final safeIndex = selectedIndex >= 0 ? selectedIndex : 0;

          return Scaffold(
            body: child,
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: NavigationBar(
                selectedIndex: safeIndex,
                backgroundColor: Colors.transparent,
                indicatorColor: AppColors.primaryLight,
                elevation: 0,
                height: 62,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: (index) {
                  if (index >= 0 && index < navItems.length) {
                    context.go(navItems[index].route);
                  }
                },
                destinations: navItems.map((item) {
                  return NavigationDestination(
                    icon: Icon(item.icon, size: 22, color: AppColors.textSecondary),
                    selectedIcon: Icon(item.activeIcon, size: 22, color: AppColors.primary),
                    label: item.mobileLabel ?? item.label,
                  );
                }).toList(),
              ),
            ),
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
                        if (!effectivelyCompact)
                          _buildAuthSidebarHeader(context, auth),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: effectivelyCompact ? 5 : 10),
                            itemCount: navItems.length,
                            itemBuilder: (context, index) {
                              final item = navItems[index];
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
                        if (auth.isAuthenticated && !effectivelyCompact)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  await auth.signOut();
                                  if (context.mounted) context.go('/login');
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                                      SizedBox(width: 10),
                                      Text(
                                        'Log Out',
                                        style: TextStyle(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        else if (auth.isAuthenticated && effectivelyCompact)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Center(
                              child: IconButton(
                                icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                                tooltip: 'Log Out',
                                onPressed: () async {
                                  await auth.signOut();
                                  if (context.mounted) context.go('/login');
                                },
                              ),
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
      },
    );
  }

  Widget _buildAuthSidebarHeader(BuildContext context, AuthService auth) {
    if (auth.isAuthenticated) {
      final user = auth.currentUser!;
      return Container(
        margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: user.isAdmin ? const Color(0xFF1E1B4B) : AppColors.primary,
              child: Text(
                user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  Text(
                    user.isAdmin ? 'Admin Console' : 'Student',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: user.isAdmin ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.textMuted),
              tooltip: 'Sign Out',
              onPressed: () => auth.signOut(),
            ),
          ],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      child: ElevatedButton.icon(
        onPressed: () => context.push('/login'),
        icon: const Icon(Icons.login_rounded, size: 16),
        label: const Text('Sign In', style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
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
                child: const AppLogo(size: 38, borderRadius: 10, hasGlow: true),
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
                        'NEET (UG) CBT Exam',
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
              'NEET 2026 Ready',
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
            'Online',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
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
  final String? mobileLabel;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.route,
    required this.label,
    this.mobileLabel,
    required this.icon,
    required this.activeIcon,
  });
}
