import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../core/widgets/candidate_analysis_dialog.dart';
import '../../../../core/firebase/firebase_test_service.dart';
import '../../../../injection/injection_container.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Test? _ongoingTest;
  int _totalTests = 0;
  bool _isLoadingStats = true;
  String _studentSearchQuery = '';

  late final Stream<FirebaseDailyTest?> _todayTestStream;
  late final Stream<List<Map<String, dynamic>>> _studentsStream;
  late final Stream<List<TestSubmission>> _submissionsStream;
  late final Stream<List<FirebaseDailyTest>> _recentTestsStream;

  @override
  void initState() {
    super.initState();
    final firebaseService = sl<FirebaseTestService>();
    _todayTestStream = firebaseService.streamTodayTest();
    _studentsStream = firebaseService.streamAllStudents();
    _submissionsStream = firebaseService.streamAllSubmissions();
    _recentTestsStream = firebaseService.streamRecentTests();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final db = sl<AppDatabase>();
    try {
      final ongoing = await (db.select(db.tests)..where((t) => t.status.equals('ongoing'))..limit(1)).getSingleOrNull();
      final allTests = await db.select(db.tests).get();

      if (mounted) {
        setState(() {
          _ongoingTest = ongoing;
          _totalTests = allTests.length;
          _isLoadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = sl<AuthService>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(auth.isAdmin ? 'Admin Dashboard' : 'Dashboard'),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: 'Admin Console',
              onPressed: () => context.push('/admin'),
            ),
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
              // Hero Section (Role-based)
              _buildHeroSection(isMobile, auth.isAdmin),
              const SizedBox(height: 24),

              if (auth.isAdmin) ...[
                // Admin KPIs & Platform Overview
                const Text(
                  'Platform Key Metrics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.4),
                ),
                const SizedBox(height: 14),
                _buildAdminKpis(screenWidth),
                const SizedBox(height: 36),

                // Registered Candidates & Live Performance Section
                _buildRegisteredStudentsSection(isMobile),
                const SizedBox(height: 40),

                // Cleaned Admin Modules (Only 1 unified Paper Management module, no duplicate upload/create cards)
                const AppSectionHeader(
                  title: 'Administrative Control Center',
                  subtitle: 'Central hub for examination papers, analytics, and records',
                ),
                const SizedBox(height: 16),
                _buildAdminModuleGrid(screenWidth),
                const SizedBox(height: 40),
              ] else ...[
                // Student Flow
                _buildDailyLiveTestSection(isMobile),
                const SizedBox(height: 28),

                if (_ongoingTest != null) ...[
                  _buildOngoingBanner(isMobile),
                  const SizedBox(height: 32),
                ],

                const Text(
                  'Performance Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.4),
                ),
                const SizedBox(height: 16),
                _buildStudentMetricsRow(screenWidth),
                const SizedBox(height: 40),

                const AppSectionHeader(
                  title: 'Quick Access Modules',
                  subtitle: 'Practice, attempt live exams, or inspect detailed analytics',
                ),
                const SizedBox(height: 16),
                _buildStudentModuleGrid(screenWidth),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- HERO SECTION ---
  Widget _buildHeroSection(bool isMobile, bool isAdmin) {
    if (isAdmin) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 24 : 36),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E1B4B).withValues(alpha: 0.3),
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
                  Icon(Icons.shield_rounded, color: Colors.amberAccent, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'ADMINISTRATOR COMMAND HUB',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Examination Portal Management',
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
              'Review registered candidates, analyze student test scores, and manage daily exam papers from one unified place.',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('/admin'),
                  icon: const Icon(Icons.admin_panel_settings_rounded, size: 20),
                  label: const Text('OPEN ADMIN CONSOLE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E1B4B),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/publish-daily-test'),
                  icon: const Icon(Icons.upload_file_rounded, size: 20, color: Colors.white),
                  label: const Text('UPLOAD PAPER (EXCEL)', style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Student Hero
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
              onPressed: () => context.push('/daily-test').then((_) => _loadDashboardData()),
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text('ATTEMPT TODAY\'S LIVE TEST'),
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

  // --- ADMIN KPIS ---
  Widget _buildAdminKpis(double screenWidth) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _studentsStream,
      builder: (context, studentSnap) {
        final students = studentSnap.data ?? [];

        return StreamBuilder<List<TestSubmission>>(
          stream: _submissionsStream,
          builder: (context, subSnap) {
            final submissions = subSnap.data ?? [];

            return StreamBuilder<List<FirebaseDailyTest>>(
              stream: _recentTestsStream,
              builder: (context, testSnap) {
                final tests = testSnap.data ?? [];

                final double avgScore = submissions.isEmpty
                    ? 0.0
                    : (submissions.fold<double>(0.0, (sum, s) => sum + s.score) / submissions.length);

                final double avgAccuracy = submissions.isEmpty
                    ? 0.0
                    : (submissions.fold<double>(0.0, (sum, s) => sum + s.accuracy) / submissions.length);

                final metrics = [
                  AppMetricCard(
                    title: 'Registered Aspirants',
                    value: '${students.length}',
                    subtitle: 'Candidate accounts',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.primary,
                  ),
                  AppMetricCard(
                    title: 'Test Submissions',
                    value: '${submissions.length}',
                    subtitle: 'Completed attempts',
                    icon: Icons.assignment_turned_in_rounded,
                    color: AppColors.success,
                  ),
                  AppMetricCard(
                    title: 'Exam Papers',
                    value: '${tests.length}',
                    subtitle: 'In Cloud Repository',
                    icon: Icons.quiz_rounded,
                    color: const Color(0xFF8B5CF6),
                  ),
                  AppMetricCard(
                    title: 'Platform Avg Score',
                    value: submissions.isEmpty ? '--' : '${avgScore.toInt()} / 720',
                    subtitle: submissions.isEmpty ? 'No data' : '${avgAccuracy.toStringAsFixed(1)}% Accuracy',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ];

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 1100 ? 4 : (screenWidth > 650 ? 2 : 1),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 130,
                  ),
                  itemCount: metrics.length,
                  itemBuilder: (context, index) => metrics[index],
                );
              },
            );
          },
        );
      },
    );
  }

  // --- ADMIN REGISTERED STUDENTS SECTION ---
  Widget _buildRegisteredStudentsSection(bool isMobile) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _studentsStream,
      builder: (context, studentSnap) {
        if (!studentSnap.hasData && studentSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
        }

        final students = studentSnap.data ?? [];

        return StreamBuilder<List<TestSubmission>>(
          stream: _submissionsStream,
          builder: (context, subSnap) {
            final submissions = subSnap.data ?? [];

            final filteredStudents = _studentSearchQuery.isEmpty
                ? students
                : students.where((s) {
                    final name = (s['displayName'] ?? '').toString().toLowerCase();
                    final email = (s['email'] ?? '').toString().toLowerCase();
                    final phone = (s['phone'] ?? '').toString().toLowerCase();
                    final query = _studentSearchQuery.toLowerCase();
                    return name.contains(query) || email.contains(query) || phone.contains(query);
                  }).toList();

            return Container(
              padding: EdgeInsets.all(isMobile ? 18 : 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.shadowSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registered Aspirants & Live Performance (${students.length})',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Track student progress, accuracy, test attempts, and scores',
                                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Search input
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search aspirant by name, email, or mobile number...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _studentSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () => setState(() => _studentSearchQuery = ''),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) => setState(() => _studentSearchQuery = val),
                  ),
                  const SizedBox(height: 16),

                  if (filteredStudents.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Icon(Icons.person_search_rounded, size: 44, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            _studentSearchQuery.isEmpty
                                ? 'No registered students found yet.'
                                : 'No aspirants match "$_studentSearchQuery".',
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredStudents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        final name = student['displayName'] ?? 'Aspirant';
                        final email = student['email'] ?? 'No email';
                        final phone = student['phone'] ?? 'N/A';
                        final uid = student['uid'] ?? '';

                        final matchingSubs = submissions.where((sub) {
                          if (uid.isNotEmpty && sub.studentUid != null && sub.studentUid == uid) return true;
                          if (sub.studentEmail != null && sub.studentEmail!.toLowerCase() == email.toString().toLowerCase()) return true;
                          if (sub.studentName.trim().toLowerCase() == name.toString().trim().toLowerCase()) return true;
                          return false;
                        }).toList();

                        final testCount = matchingSubs.length;
                        final bestScore = matchingSubs.isEmpty
                            ? 0.0
                            : matchingSubs.map((s) => s.score).reduce((a, b) => a > b ? a : b);
                        final avgAccuracy = matchingSubs.isEmpty
                            ? 0.0
                            : (matchingSubs.map((s) => s.accuracy).reduce((a, b) => a + b) / testCount);

                        return _buildStudentCard(
                          context: context,
                          student: student,
                          name: name,
                          email: email,
                          phone: phone,
                          matchingSubs: matchingSubs,
                          testCount: testCount,
                          bestScore: bestScore,
                          avgAccuracy: avgAccuracy,
                          isMobile: isMobile,
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStudentCard({
    required BuildContext context,
    required Map<String, dynamic> student,
    required String name,
    required String email,
    required String phone,
    required List<TestSubmission> matchingSubs,
    required int testCount,
    required double bestScore,
    required double avgAccuracy,
    required bool isMobile,
  }) {
    String statusLabel;
    Color statusColor;
    Color statusBg;

    if (testCount == 0) {
      statusLabel = 'Not Attempted';
      statusColor = AppColors.textMuted;
      statusBg = AppColors.surfaceSubtle;
    } else if (bestScore >= 550) {
      statusLabel = 'Top Ranker';
      statusColor = const Color(0xFF047857);
      statusBg = const Color(0xFFD1FAE5);
    } else if (bestScore >= 380) {
      statusLabel = 'Good Standing';
      statusColor = const Color(0xFF1D4ED8);
      statusBg = const Color(0xFFDBEAFE);
    } else {
      statusLabel = 'Needs Revision';
      statusColor = const Color(0xFFB45309);
      statusBg = const Color(0xFFFEF3C7);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'S',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          Text(email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                      child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$testCount Tests Taken • Score: ${testCount > 0 ? bestScore.toInt() : '--'} / 720',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    Text(
                      testCount > 0 ? '${avgAccuracy.toStringAsFixed(0)}% Acc' : '',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => CandidateAnalysisDialog.show(
                      context,
                      student: student,
                      matchingSubmissions: matchingSubs,
                    ),
                    icon: const Icon(Icons.analytics_outlined, size: 16),
                    label: const Text('VIEW REPORT & ANALYSIS'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                            child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10.5, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$email • Mobile: $phone',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$testCount Tests Taken',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        testCount > 0 ? 'Highest: ${bestScore.toInt()} / 720 Marks' : 'No submission yet',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testCount > 0 ? '${avgAccuracy.toStringAsFixed(1)}% Accuracy' : '--',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        testCount > 0 ? '${matchingSubs.fold(0, (s, e) => s + e.correctCount)} Correct MCQs' : '--',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => CandidateAnalysisDialog.show(
                    context,
                    student: student,
                    matchingSubmissions: matchingSubs,
                  ),
                  icon: const Icon(Icons.analytics_outlined, size: 16),
                  label: const Text('VIEW ANALYSIS'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
    );
  }

  // --- ADMIN MODULES GRID (UNIFIED - NO DUPLICATE UPLOAD CARDS) ---
  Widget _buildAdminModuleGrid(double screenWidth) {
    final modules = <_ModuleItem>[
      _ModuleItem(
        title: 'Exam & Paper Management',
        description: 'Upload Excel papers, manage questions, and publish daily tests from one central console.',
        icon: Icons.admin_panel_settings_rounded,
        color: const Color(0xFF1E1B4B),
        route: '/admin',
      ),
      _ModuleItem(
        title: 'Performance Analytics',
        description: 'Inspect overall batch accuracy distribution, subject proficiency, and score trends.',
        icon: Icons.insights_rounded,
        color: AppColors.success,
        route: '/analytics',
      ),
      _ModuleItem(
        title: 'Test Submissions History',
        description: 'Review completed candidate test attempts, answer transcripts, and scores.',
        icon: Icons.history_rounded,
        color: AppColors.warning,
        route: '/history',
      ),
      _ModuleItem(
        title: 'Portal Settings',
        description: 'Manage administrator profile, examination rules, marking preferences, and data.',
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
        crossAxisCount: screenWidth > 1100 ? 4 : (screenWidth > 600 ? 2 : 1),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 160,
      ),
      itemBuilder: (context, index) {
        final mod = modules[index];
        return _buildModuleCard(mod);
      },
    );
  }

  // --- STUDENT LIVE TEST SECTION ---
  Widget _buildDailyLiveTestSection(bool isMobile) {
    return StreamBuilder<FirebaseDailyTest?>(
      stream: _todayTestStream,
      builder: (context, snapshot) {
        final todayTest = snapshot.data;

        if (todayTest != null) {
          final isLive = todayTest.isLive;

          return StreamBuilder<List<TestSubmission>>(
            stream: _submissionsStream,
            builder: (context, subSnapshot) {
              final mySubs = subSnapshot.data ?? [];
              final currentUid = sl<AuthService>().currentUser?.uid;
              final currentEmail = sl<AuthService>().currentUser?.email;

              final mySub = mySubs.where((s) {
                final matchTest = s.testId == todayTest.title ||
                    s.testId == todayTest.id ||
                    s.testDocId == todayTest.id ||
                    s.testDocId == todayTest.title;
                final matchUser = (currentUid != null && s.studentUid == currentUid) ||
                    (currentEmail != null && currentEmail.isNotEmpty && s.studentEmail?.toLowerCase() == currentEmail.toLowerCase());
                return matchTest && matchUser;
              }).firstOrNull;

              final hasSubmitted = mySub != null;

              Color borderColor = isLive ? const Color(0xFFFCA5A5) : const Color(0xFFC7D2FE);
              Color bgColor = isLive ? const Color(0xFFFEF2F2) : const Color(0xFFEEF2FF);
              if (hasSubmitted) {
                borderColor = const Color(0xFF86EFAC);
                bgColor = const Color(0xFFF0FDF4);
              }

              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 18 : 24),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: borderColor,
                    width: 1.5,
                  ),
                  boxShadow: hasSubmitted
                      ? [
                          BoxShadow(
                            color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ]
                      : (isLive
                          ? [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              )
                            ]
                          : AppColors.shadowSm),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: hasSubmitted ? AppColors.success : (isLive ? AppColors.error : AppColors.primary),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasSubmitted ? Icons.check_circle_rounded : (isLive ? Icons.play_arrow_rounded : Icons.alarm_on_rounded),
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: hasSubmitted ? AppColors.success : (isLive ? AppColors.error : AppColors.primary),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  hasSubmitted
                                      ? '✅ SUBMITTED BY YOU'
                                      : (isLive ? '🔴 LIVE NOW' : '⏳ SCHEDULED • 09:00 AM IST'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                hasSubmitted
                                    ? 'Score: ${mySub.score.toInt()} / ${mySub.totalMarks.toInt()} Marks'
                                    : '${todayTest.totalQuestions} MCQs • ${todayTest.durationMinutes} mins',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: hasSubmitted
                                      ? const Color(0xFF166534)
                                      : (isLive ? const Color(0xFF991B1B) : const Color(0xFF3730A3)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            todayTest.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 17,
                              fontWeight: FontWeight.w800,
                              color: hasSubmitted
                                  ? const Color(0xFF14532D)
                                  : (isLive ? const Color(0xFF7F1D1D) : const Color(0xFF1E1B4B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (hasSubmitted) {
                          CandidateAnalysisDialog.show(
                            context,
                            student: {
                              'displayName': sl<AuthService>().currentUser?.displayName ?? mySub.studentName,
                              'email': sl<AuthService>().currentUser?.email ?? mySub.studentEmail ?? '',
                              'uid': sl<AuthService>().currentUser?.uid ?? mySub.studentUid ?? '',
                              'createdAt': mySub.submittedAt,
                            },
                            matchingSubmissions: [mySub],
                          );
                        } else {
                          context.push('/daily-test');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasSubmitted
                            ? AppColors.success
                            : (isLive ? AppColors.error : AppColors.primary),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        hasSubmitted ? 'VIEW RESULT' : (isLive ? 'START EXAM' : 'VIEW TEST'),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.shadowSm,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.alarm_on_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily 09:00 AM Live Test Portal',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Live NEET CBT mock tests unlock daily at 09:00 AM IST. Prepare your revision!',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: isMobile ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => context.push('/daily-test'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('VIEW SCHEDULE'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
        );
      },
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
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _confirmDiscardExam(_ongoingTest!.id),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Discard Attempt'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => context.push('/exam/${_ongoingTest!.id}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('RESUME EXAM'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDiscardExam(int testId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Exam Session?'),
        content: const Text('Your current responses for this exam will be deleted permanently. You can retake it anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              final db = sl<AppDatabase>();
              await (db.delete(db.tests)..where((t) => t.id.equals(testId))).go();
              await (db.delete(db.userAnswers)..where((a) => a.testId.equals(testId))).go();
              _loadDashboardData();
            },
            child: const Text('DISCARD', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- STUDENT METRICS ROW ---
  Widget _buildStudentMetricsRow(double screenWidth) {
    final auth = sl<AuthService>();
    final studentUid = auth.currentUser?.uid ?? '';
    final studentEmail = auth.currentUser?.email ?? '';

    return StreamBuilder<List<TestSubmission>>(
      stream: sl<FirebaseTestService>().streamStudentSubmissions(studentUid, studentEmail: studentEmail),
      builder: (context, snap) {
        final countStr = snap.hasData ? '${snap.data!.length}' : (_isLoadingStats ? '...' : '0');

        final metrics = [
          AppMetricCard(
            title: 'Tests Attempted',
            value: countStr,
            subtitle: 'Completed full exams',
            icon: Icons.check_circle_rounded,
            color: AppColors.primary,
            onTap: () => context.push('/history').then((_) => _loadDashboardData()),
          ),
          AppMetricCard(
            title: 'Daily Live Test',
            value: '09:00 AM',
            subtitle: 'Everyday live mock',
            icon: Icons.alarm_on_rounded,
            color: const Color(0xFFEF4444),
            onTap: () => context.push('/daily-test'),
          ),
          AppMetricCard(
            title: 'Practice Papers',
            value: _isLoadingStats ? '...' : '$_totalTests',
            subtitle: 'Ready to attempt',
            icon: Icons.assignment_rounded,
            color: const Color(0xFF8B5CF6),
            onTap: () => context.push('/daily-test').then((_) => _loadDashboardData()),
          ),
          AppMetricCard(
            title: 'Reports & Analytics',
            value: 'View',
            subtitle: 'Score & accuracy breakdown',
            icon: Icons.insights_rounded,
            color: AppColors.success,
            onTap: () => context.push('/analytics').then((_) => _loadDashboardData()),
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenWidth > 1100 ? 4 : (screenWidth > 650 ? 2 : 1),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: 130,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) => metrics[index],
        );
      },
    );
  }

  // --- STUDENT MODULE GRID ---
  Widget _buildStudentModuleGrid(double screenWidth) {
    final modules = <_ModuleItem>[
      _ModuleItem(
        title: 'Daily Live Test (9 AM)',
        description: 'Take today\'s scheduled 180 questions NEET CBT mock examination.',
        icon: Icons.alarm_on_rounded,
        color: const Color(0xFFEF4444),
        route: '/daily-test',
      ),
      _ModuleItem(
        title: 'Practice Mock Papers',
        description: 'Attempt published practice papers with timer and negative marking.',
        icon: Icons.assignment_rounded,
        color: const Color(0xFF8B5CF6),
        route: '/daily-test',
      ),
      _ModuleItem(
        title: 'Test History & Scorecards',
        description: 'Review your past test scores, answer transcripts, and right/wrong answers.',
        icon: Icons.history_rounded,
        color: AppColors.warning,
        route: '/history',
      ),
      _ModuleItem(
        title: 'Performance Analytics',
        description: 'Track subject-wise breakdown, accuracy percentage, and weak topics.',
        icon: Icons.insights_rounded,
        color: AppColors.success,
        route: '/analytics',
      ),
      _ModuleItem(
        title: 'App Settings & Profile',
        description: 'Manage app display, examination preferences, and account info.',
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
        mainAxisExtent: 160,
      ),
      itemBuilder: (context, index) {
        final mod = modules[index];
        return _buildModuleCard(mod);
      },
    );
  }

  Widget _buildModuleCard(_ModuleItem mod) {
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
