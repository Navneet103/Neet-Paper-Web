import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../injection/injection_container.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = sl<AuthService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('App Preferences & Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        child: AppPageContainer(
          maxWidth: 780,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(
                title: 'Application Preferences',
                subtitle: 'Configure examination rules, aspirant profile, and display options',
              ),
              const SizedBox(height: 8),

              // Section 1: Candidate Profile Info
              _buildSettingsCard(
                title: 'Aspirant Profile',
                icon: Icons.person_outline_rounded,
                iconColor: AppColors.primary,
                children: [
                  _settingsTile(
                    title: auth.isAuthenticated ? auth.currentUser!.displayName : 'Guest Aspirant',
                    subtitle: auth.isAuthenticated
                        ? (auth.currentUser!.phone != null && auth.currentUser!.phone!.isNotEmpty
                            ? '${auth.currentUser!.email} • +91 ${auth.currentUser!.phone}'
                            : auth.currentUser!.email)
                        : 'Log in to sync cloud submissions & test history',
                    trailing: OutlinedButton(
                      onPressed: () {
                        if (auth.isAuthenticated) {
                          auth.signOut();
                        } else {
                          context.push('/login');
                        }
                      },
                      child: Text(auth.isAuthenticated ? 'Sign Out' : 'Sign In'),
                    ),
                  ),
                  const Divider(height: 1),
                  _settingsTile(
                    title: 'Account Role',
                    subtitle: auth.isAdmin ? 'Administrator (Full Access)' : 'Student Aspirant (NEET 2026)',
                    trailing: AppBadge(
                      text: auth.isAdmin ? 'Admin' : 'Student',
                      backgroundColor: auth.isAdmin ? const Color(0xFF1E1B4B) : AppColors.primaryLight,
                      textColor: auth.isAdmin ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 2: Examination Environment
              _buildSettingsCard(
                title: 'Examination & Practice Mode',
                icon: Icons.speed_rounded,
                iconColor: const Color(0xFF8B5CF6),
                children: [
                  _settingsTile(
                    title: 'Marking Standard',
                    subtitle: 'Official NTA: +4 marks for correct, -1 penalty for incorrect',
                    trailing: const AppBadge(
                      text: '+4 / -1 Active',
                      backgroundColor: AppColors.successLight,
                      textColor: AppColors.success,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  const Divider(height: 1),
                  _settingsTile(
                    title: 'Timer Warning Alerts',
                    subtitle: 'Visual amber alert at 10m and red warning at 5m remaining',
                    trailing: const AppBadge(
                      text: 'Enabled',
                      backgroundColor: AppColors.surfaceSubtle,
                      textColor: AppColors.textSecondary,
                    ),
                  ),
                  const Divider(height: 1),
                  _settingsTile(
                    title: 'Question Palette Grid',
                    subtitle: 'Instant jumping, review later marking, and color-coded status',
                    trailing: const AppBadge(
                      text: 'Interactive',
                      backgroundColor: AppColors.surfaceSubtle,
                      textColor: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 3: App Information
              _buildSettingsCard(
                title: 'About NEET Master',
                icon: Icons.info_outline_rounded,
                iconColor: const Color(0xFF10B981),
                children: [
                  _settingsTile(
                    title: 'System Release',
                    subtitle: 'Modern NTA CBT Mock Test Engine with Cloud Sync',
                    trailing: const Text(
                      'v1.0.0 Ready',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                  ),
                  const Divider(height: 1),
                  _settingsTile(
                    title: 'Live Exam Schedule',
                    subtitle: 'Fresh question paper published every day at 09:00 AM IST',
                    trailing: const AppBadge(
                      text: '09:00 AM Daily',
                      backgroundColor: AppColors.primaryLight,
                      textColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 4: Admin-Only Tools & Danger Zone
              if (auth.isAdmin) ...[
                _buildSettingsCard(
                  title: 'Admin Database Tools',
                  icon: Icons.admin_panel_settings_rounded,
                  iconColor: const Color(0xFF1E1B4B),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.upload_file_rounded, color: AppColors.primary),
                      title: const Text('Upload New Question Bank', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Import XLSX spreadsheets with MCQs, subjects, and topics', style: TextStyle(fontSize: 12.5)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/import'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.cloud_upload_rounded, color: AppColors.primary),
                      title: const Text('Publish Daily 9 AM Paper', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Schedule today\'s 180 questions directly to Firebase', style: TextStyle(fontSize: 12.5)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/publish-daily-test'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.errorBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
                        child: Row(
                          children: [
                            Icon(Icons.warning_rounded, color: AppColors.error, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Danger Zone (Admin Only)',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFB91C1C)),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.errorBorder),
                      ListTile(
                        title: const Text(
                          'Reset Entire Database',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.error),
                        ),
                        subtitle: const Text(
                          'Permanently delete all imported questions, completed tests, and analytics history',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF991B1B)),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          onPressed: () => _confirmReset(context),
                          child: const Text('RESET DATA', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _settingsTile({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          trailing,
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            SizedBox(width: 10),
            Text('Reset Entire Database?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: const Text(
          'This will permanently delete all imported questions, your exam history, test papers, and accuracy analytics. This action is irreversible.\n\nAre you sure you want to proceed?',
          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await sl<AppDatabase>().clearAllData();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/dashboard');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Database cleared successfully. All records reset.')),
                );
              }
            },
            child: const Text('CLEAR ALL DATA'),
          ),
        ],
      ),
    );
  }
}
