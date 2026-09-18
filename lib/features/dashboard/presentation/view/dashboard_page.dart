import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../injection/injection_container.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Test? _ongoingTest;
  int _totalQuestions = 0;
  int _totalTests = 0;
  int _completedTests = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final db = sl<AppDatabase>();
    try {
      final ongoing = await (db.select(db.tests)..where((t) => t.status.equals('ongoing'))..limit(1)).getSingleOrNull();
      final allQuestions = await db.select(db.questions).get();
      final allTests = await db.select(db.tests).get();
      final completed = allTests.where((t) => t.status == 'completed').length;

      if (mounted) {
        setState(() {
          _ongoingTest = ongoing;
          _totalQuestions = allQuestions.length;
          _totalTests = allTests.length;
          _completedTests = completed;
          _isLoadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // Match global breakpoint

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings').then((_) => _loadDashboardData()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: AppPageContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Hero
              _buildHeroSection(isMobile),
              const SizedBox(height: 32),

              // Ongoing Test Banner (if any)
              if (_ongoingTest != null) ...[
                _buildOngoingBanner(isMobile),
                const SizedBox(height: 32),
              ],

              // KPI Metrics
              const Text(
                'Performance Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.4),
              ),
              const SizedBox(height: 16),
              _buildMetricsRow(screenWidth),
              const SizedBox(height: 40),

              // Section Header
              const AppSectionHeader(
                title: 'Quick Access Modules',
                subtitle: 'Practice, generate exams, or inspect detailed analytics',
              ),

              // Navigation Cards Grid
              _buildModuleGrid(screenWidth),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3730A3), Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 16),
                SizedBox(width: 6),
                Text(
                  'NEET 2026 Ready',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Doctor Aspirant Practice Hub',
            style: TextStyle(
              fontSize: isMobile ? 26 : 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.0,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Simulate standard NTA NEET paper conditions with negative marking, timers, and offline local storage.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: isMobile ? double.infinity : null,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/create-test').then((_) => _loadDashboardData()),
              icon: const Icon(Icons.add_task_rounded, size: 20),
              label: const Text('START NEW MOCK TEST'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOngoingBanner(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warningBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer_outlined, color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Exam in Progress',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF92400E)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _ongoingTest!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Color(0xFFB45309), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              if (!isMobile)
                ElevatedButton(
                  onPressed: () => context.push('/exam/${_ongoingTest!.id}').then((_) => _loadDashboardData()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: const Text('RESUME EXAM'),
                ),
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/exam/${_ongoingTest!.id}').then((_) => _loadDashboardData()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('RESUME EXAM'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsRow(double screenWidth) {
    final metrics = [
      AppMetricCard(
        title: 'Question Bank',
        value: _isLoadingStats ? '...' : '$_totalQuestions',
        subtitle: 'Questions indexed',
        icon: Icons.library_books_rounded,
        color: AppColors.primary,
        onTap: () => context.push('/bank').then((_) => _loadDashboardData()),
      ),
      AppMetricCard(
        title: 'Tests Generated',
        value: _isLoadingStats ? '...' : '$_totalTests',
        subtitle: 'Mock papers ready',
        icon: Icons.assignment_rounded,
        color: const Color(0xFF8B5CF6),
        onTap: () => context.push('/create-test').then((_) => _loadDashboardData()),
      ),
      AppMetricCard(
        title: 'Completed',
        value: _isLoadingStats ? '...' : '$_completedTests',
        subtitle: 'Results recorded',
        icon: Icons.task_alt_rounded,
        color: AppColors.success,
        onTap: () => context.push('/history').then((_) => _loadDashboardData()),
      ),
      AppMetricCard(
        title: 'System Status',
        value: 'Ready',
        subtitle: 'SQLite Engine Active',
        icon: Icons.cloud_done_rounded,
        color: AppColors.secondary,
        onTap: () => context.push('/settings'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 1100 ? 4 : (screenWidth > 650 ? 2 : 1),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        // Using fixed extent ensures text never overflows vertically regardless of width
        mainAxisExtent: 130, 
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) => metrics[index],
    );
  }

  Widget _buildModuleGrid(double screenWidth) {
    final modules = [
      _ModuleItem(
        title: 'Question Bank',
        description: 'Browse, search, and filter MCQs across subjects with answer keys.',
        icon: Icons.library_books_rounded,
        color: AppColors.primary,
        route: '/bank',
      ),
      _ModuleItem(
        title: 'Mock Tests',
        description: 'Generate customized mock tests with timers and negative marking.',
        icon: Icons.add_task_rounded,
        color: const Color(0xFF8B5CF6),
        route: '/create-test',
      ),
      _ModuleItem(
        title: 'Bulk Import',
        description: 'Upload MCQ papers via Excel (.xlsx) or CSV with auto-validation.',
        icon: Icons.upload_file_rounded,
        color: AppColors.secondary,
        route: '/import',
      ),
      _ModuleItem(
        title: 'Test History',
        description: 'Review your past test scores, answer transcripts, and analytics.',
        icon: Icons.history_rounded,
        color: AppColors.warning,
        route: '/history',
      ),
      _ModuleItem(
        title: 'Analytics',
        description: 'Track subject-wise breakdown, weak topics, and score trends.',
        icon: Icons.insights_rounded,
        color: AppColors.success,
        route: '/analytics',
      ),
      _ModuleItem(
        title: 'Settings',
        description: 'Manage local database storage, runtime, and system records.',
        icon: Icons.settings_rounded,
        color: AppColors.textSecondary,
        route: '/settings',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 1100 ? 3 : (screenWidth > 600 ? 2 : 1),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        // Increased extent to accommodate 2 lines of description + title + icon
        mainAxisExtent: 160, 
      ),
      itemBuilder: (context, index) {
        final mod = modules[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.shadowSm,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => context.push(mod.route).then((_) => _loadDashboardData()),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mod.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(mod.icon, color: mod.color, size: 26),
                        ),
                        const Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.textMuted),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      mod.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        mod.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ModuleItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  _ModuleItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
