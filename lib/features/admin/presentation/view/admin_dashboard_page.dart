import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/firebase/firebase_test_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/submission_mcq_review_dialog.dart';
import '../../../../core/widgets/candidate_analysis_dialog.dart';
import '../../../../injection/injection_container.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _firebaseService = sl<FirebaseTestService>();
  final _auth = sl<AuthService>();

  late final Stream<List<FirebaseDailyTest>> _recentTestsStream;
  late final Stream<List<TestSubmission>> _submissionsStream;
  late final Stream<List<Map<String, dynamic>>> _studentsStream;

  FirebaseDailyTest? _selectedTestForQuestions;
  int _questionPage = 0;
  static const int _questionPageSize = 25;
  String _questionSearchQuery = '';
  String _questionSubjectFilter = 'All';
  bool _showDailyUploadTracker = true;
  String _studentSearchQuery = '';
  String _submissionSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _recentTestsStream = _firebaseService.streamRecentTests();
    _submissionsStream = _firebaseService.streamAllSubmissions();
    _studentsStream = _firebaseService.streamAllStudents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_auth.isAdmin) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Admin Console Access'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/dashboard'),
          ),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.shadowSm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.errorLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded, color: AppColors.error, size: 36),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Administrator Access Required',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This section is strictly reserved for exam coordinators and teachers. Please log in with administrator credentials.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/login?tab=admin'),
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: const Text('SIGN IN AS ADMINISTRATOR'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Text('Back to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            AppLogo(size: 28, borderRadius: 6),
            SizedBox(width: 10),
            Text('Admin Examination Console'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () async {
              await _auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: isMobile,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.assignment_rounded), text: 'Daily Papers'),
            Tab(icon: Icon(Icons.quiz_rounded), text: 'Question Manager'),
            Tab(icon: Icon(Icons.analytics_rounded), text: 'Student Submissions'),
            Tab(icon: Icon(Icons.people_alt_rounded), text: 'Registered Students'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _KeepAliveTab(child: _buildDailyPapersTab(isMobile)),
          _KeepAliveTab(child: _buildQuestionManagerTab(isMobile)),
          _KeepAliveTab(child: _buildSubmissionsTab(isMobile)),
          _KeepAliveTab(child: _buildStudentsTab(isMobile)),
        ],
      ),
    );
  }

  // --- TAB 1: DAILY PAPERS MANAGER ---
  Widget _buildDailyPapersTab(bool isMobile) {
    return StreamBuilder<List<FirebaseDailyTest>>(
      stream: _recentTestsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tests = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 28),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Published Daily Exam Papers',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${tests.length} tests configured in Firebase Cloud DB',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => context.push('/publish-daily-test'),
                                icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                                label: const Text('PUBLISH NEW PAPER'),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Published Daily Exam Papers',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${tests.length} tests configured in Firebase Cloud DB',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/publish-daily-test'),
                              icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                              label: const Text('PUBLISH NEW PAPER'),
                            ),
                          ],
                        ),
                  const SizedBox(height: 24),

                  if (tests.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.post_add_rounded, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          const Text('No daily test papers uploaded yet.', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 8),
                          const Text('Upload your daily 180 questions via Excel to get started.'),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => context.push('/publish-daily-test'),
                            child: const Text('Upload Paper Now'),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final test = tests[index];
                        final isLive = test.isLive;

                        return Container(
                          padding: EdgeInsets.all(isMobile ? 16 : 20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isLive ? AppColors.error : AppColors.border),
                            boxShadow: AppColors.shadowSm,
                          ),
                          child: isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isLive ? AppColors.errorLight : AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            isLive ? Icons.radio_button_checked_rounded : Icons.assignment_rounded,
                                            color: isLive ? AppColors.error : AppColors.primary,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      test.title,
                                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (isLive) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.error,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800)),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Scheduled: ${test.dateKey} at 09:00 AM',
                                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                          tooltip: 'Delete Test',
                                          onPressed: () => _confirmDeleteTest(test),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${test.totalQuestions} Questions • ${test.totalMarks.toInt()} Marks • ${test.durationMinutes} Mins',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _selectedTestForQuestions = test;
                                            _tabController.animateTo(1);
                                          });
                                        },
                                        icon: const Icon(Icons.edit_note_rounded, size: 18),
                                        label: const Text('MANAGE MCQs'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isLive ? AppColors.errorLight : AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        isLive ? Icons.radio_button_checked_rounded : Icons.assignment_rounded,
                                        color: isLive ? AppColors.error : AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  test.title,
                                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isLive) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.error,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${test.totalQuestions} Questions • ${test.totalMarks.toInt()} Marks • ${test.durationMinutes} Mins • Scheduled: ${test.dateKey} at 09:00 AM',
                                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _selectedTestForQuestions = test;
                                          _tabController.animateTo(1);
                                        });
                                      },
                                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                                      label: const Text('MANAGE MCQs'),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                      tooltip: 'Delete Test',
                                      onPressed: () => _confirmDeleteTest(test),
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- TAB 2: QUESTION MANAGER (DAILY TRACKER, ADD / EDIT / DELETE QUESTIONS) ---
  Widget _buildQuestionManagerTab(bool isMobile) {
    return StreamBuilder<List<FirebaseDailyTest>>(
      stream: _recentTestsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final tests = snapshot.data ?? [];

        if (tests.isEmpty) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 550),
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.shadowSm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.upload_file_rounded, color: AppColors.primary, size: 40),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No Question Papers Added Yet',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload your daily NEET MCQ Excel spreadsheet or add questions manually to start tracking daily papers and questions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/publish-daily-test'),
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: const Text('UPLOAD TODAY\'S EXCEL PAPER'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                  ),
                ],
              ),
            ),
          );
        }

        // Default to first test or retain selection
        final currentTest = _selectedTestForQuestions != null && tests.any((t) => t.id == _selectedTestForQuestions!.id)
            ? tests.firstWhere((t) => t.id == _selectedTestForQuestions!.id)
            : tests.first;

        // Search & Subject filtering
        final filteredQuestions = currentTest.questions.where((q) {
          if (_questionSubjectFilter != 'All') {
            final qSub = q.subject.toLowerCase();
            final fSub = _questionSubjectFilter.toLowerCase();
            if (!qSub.contains(fSub)) return false;
          }
          if (_questionSearchQuery.isNotEmpty) {
            final query = _questionSearchQuery.toLowerCase();
            final match = q.questionText.toLowerCase().contains(query) ||
                q.subject.toLowerCase().contains(query) ||
                q.topic.toLowerCase().contains(query) ||
                q.optionA.toLowerCase().contains(query) ||
                q.optionB.toLowerCase().contains(query) ||
                q.optionC.toLowerCase().contains(query) ||
                q.optionD.toLowerCase().contains(query);
            if (!match) return false;
          }
          return true;
        }).toList();

        final totalQuestions = filteredQuestions.length;
        final totalPages = (totalQuestions / _questionPageSize).ceil();
        final currentPage = _questionPage.clamp(0, totalPages > 0 ? totalPages - 1 : 0);
        final startIndex = currentPage * _questionPageSize;
        final endIndex = (startIndex + _questionPageSize).clamp(0, totalQuestions);
        final pageQuestions = totalQuestions > 0 ? filteredQuestions.sublist(startIndex, endIndex) : <FirebaseQuestion>[];

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 28),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: DAILY QUESTION PAPERS & EXCEL UPLOADS TRACKER ---
                  Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.shadowSm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.date_range_rounded, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Excel Question Uploads Track (${tests.length} Papers)',
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Daily history of Excel sheets and question papers uploaded by administrator',
                                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            if (!isMobile) ...[
                              ElevatedButton.icon(
                                onPressed: () => context.push('/publish-daily-test'),
                                icon: const Icon(Icons.upload_file_rounded, size: 16),
                                label: const Text('UPLOAD EXCEL SHEET'),
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                              ),
                              const SizedBox(width: 8),
                            ],
                            IconButton(
                              icon: Icon(_showDailyUploadTracker ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                              tooltip: _showDailyUploadTracker ? 'Collapse tracker' : 'Expand tracker',
                              onPressed: () => setState(() => _showDailyUploadTracker = !_showDailyUploadTracker),
                            ),
                          ],
                        ),

                        if (isMobile) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/publish-daily-test'),
                              icon: const Icon(Icons.upload_file_rounded, size: 16),
                              label: const Text('UPLOAD NEW EXCEL SHEET'),
                            ),
                          ),
                        ],

                        if (_showDailyUploadTracker) ...[
                          const Divider(height: 28),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: tests.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final t = tests[idx];
                              final isSelected = t.id == currentTest.id;
                              final dateStr = _formatUploadDate(t.scheduledStartTime);
                              final physicsCount = t.questions.where((q) => q.subject.toLowerCase().contains('physic')).length;
                              final chemCount = t.questions.where((q) => q.subject.toLowerCase().contains('chem')).length;
                              final bioCount = t.questions.where((q) => q.subject.toLowerCase().contains('bio') || q.subject.toLowerCase().contains('botany') || q.subject.toLowerCase().contains('zool')).length;

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.35) : AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                    width: isSelected ? 1.8 : 1,
                                  ),
                                ),
                                child: isMobile
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: isSelected ? AppColors.primary : AppColors.surface,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'DAY ${tests.length - idx}',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w800,
                                                        color: isSelected ? Colors.white : AppColors.textSecondary,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${t.questions.length}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w900,
                                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                                      ),
                                                    ),
                                                    Text(
                                                      'MCQs',
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.w700,
                                                        color: isSelected ? Colors.white70 : AppColors.textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            t.title,
                                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.textPrimary),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        if (isSelected)
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                            decoration: BoxDecoration(
                                                              color: AppColors.primary,
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                                                          ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      'Uploaded: $dateStr',
                                                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              _miniBadge(Icons.science_outlined, 'Physics: $physicsCount', AppColors.primaryLight, AppColors.primary),
                                              _miniBadge(Icons.biotech_outlined, 'Chemistry: $chemCount', const Color(0xFFF3E8FF), const Color(0xFF7E22CE)),
                                              _miniBadge(Icons.nature_outlined, 'Biology: $bioCount', AppColors.successLight, AppColors.success),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _selectedTestForQuestions = t;
                                                  _questionPage = 0;
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceSubtle,
                                                foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                              ),
                                              child: Text(
                                                isSelected ? 'EDITING THIS PAPER' : 'MANAGE MCQS',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isSelected ? AppColors.primary : AppColors.surface,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'DAY ${tests.length - idx}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w800,
                                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                                  ),
                                                ),
                                                Text(
                                                  '${t.questions.length}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w900,
                                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                                  ),
                                                ),
                                                Text(
                                                  'MCQs',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w700,
                                                    color: isSelected ? Colors.white70 : AppColors.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        t.title,
                                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.textPrimary),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    if (isSelected)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.primary,
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  'Uploaded / Scheduled: $dateStr • ${t.durationMinutes} mins',
                                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                                ),
                                                const SizedBox(height: 6),
                                                Wrap(
                                                  spacing: 6,
                                                  runSpacing: 4,
                                                  children: [
                                                    _miniBadge(Icons.science_outlined, 'Physics: $physicsCount', AppColors.primaryLight, AppColors.primary),
                                                    _miniBadge(Icons.biotech_outlined, 'Chemistry: $chemCount', const Color(0xFFF3E8FF), const Color(0xFF7E22CE)),
                                                    _miniBadge(Icons.nature_outlined, 'Biology: $bioCount', AppColors.successLight, AppColors.success),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _selectedTestForQuestions = t;
                                                _questionPage = 0;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceSubtle,
                                              foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                            ),
                                            child: Text(
                                              isSelected ? 'EDITING' : 'MANAGE',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                        ],
                                      ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- SECTION 2: ACTIVE PAPER QUESTION INSPECTOR & EDITOR ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMobile) ...[
                          DropdownButtonFormField<String>(
                            key: ValueKey(currentTest.id),
                            initialValue: currentTest.id,
                            decoration: const InputDecoration(
                              labelText: 'Select Paper to Edit Questions',
                              prefixIcon: Icon(Icons.assignment_outlined),
                            ),
                            items: tests.map((t) => DropdownMenuItem(
                              value: t.id,
                              child: Text('${t.title} (${t.questions.length} MCQs)', overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: (id) {
                              if (id != null) {
                                setState(() {
                                  _selectedTestForQuestions = tests.firstWhere((t) => t.id == id);
                                  _questionPage = 0;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _showAddQuestionDialog(currentTest.id, currentTest.questions.length + 1),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('ADD MCQ'),
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
                            ),
                          ),
                        ] else
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  key: ValueKey(currentTest.id),
                                  initialValue: currentTest.id,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Paper to Edit Questions',
                                    prefixIcon: Icon(Icons.assignment_outlined),
                                  ),
                                  items: tests.map((t) => DropdownMenuItem(
                                    value: t.id,
                                    child: Text('${t.title} (${t.questions.length} MCQs)'),
                                  )).toList(),
                                  onChanged: (id) {
                                    if (id != null) {
                                      setState(() {
                                        _selectedTestForQuestions = tests.firstWhere((t) => t.id == id);
                                        _questionPage = 0;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              ElevatedButton.icon(
                                onPressed: () => _showAddQuestionDialog(currentTest.id, currentTest.questions.length + 1),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('ADD MCQ'),
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16)),
                              ),
                            ],
                          ),
                        const SizedBox(height: 14),

                        // Search Field
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search in ${currentTest.questions.length} questions (statement, options, subject)...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 20),
                            suffixIcon: _questionSearchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () => setState(() {
                                      _questionSearchQuery = '';
                                      _questionPage = 0;
                                    }),
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _questionSearchQuery = val;
                              _questionPage = 0;
                            });
                          },
                        ),
                        const SizedBox(height: 12),

                        // Subject Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['All', 'Physics', 'Chemistry', 'Biology', 'Botany', 'Zoology'].map((s) {
                              final isSel = _questionSubjectFilter == s;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  selected: isSel,
                                  label: Text(s),
                                  selectedColor: AppColors.primaryLight,
                                  labelStyle: TextStyle(
                                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                    color: isSel ? AppColors.primary : AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  onSelected: (val) {
                                    setState(() {
                                      _questionSubjectFilter = s;
                                      _questionPage = 0;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _questionSearchQuery.isEmpty && _questionSubjectFilter == 'All'
                            ? 'Questions in "${currentTest.title}" (${currentTest.questions.length})'
                            : 'Filtered Questions ($totalQuestions / ${currentTest.questions.length})',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Total: ${currentTest.questions.length * 4} Marks',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Top Pagination Bar
                  if (totalPages > 1) ...[
                    _buildPaginationControls(currentPage, totalPages, startIndex, endIndex, totalQuestions),
                    const SizedBox(height: 14),
                  ],

                  // Questions List
                  if (pageQuestions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text('No questions matched your search/filter.', style: TextStyle(color: AppColors.textMuted)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pageQuestions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, localIndex) {
                        final globalIndex = startIndex + localIndex;
                        final q = pageQuestions[localIndex];

                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('Q${globalIndex + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        AppBadge(text: q.subject, backgroundColor: AppColors.primaryLight, textColor: AppColors.primary),
                                        AppBadge(text: 'Key: Option ${q.correctAnswer}', backgroundColor: AppColors.successLight, textColor: AppColors.success),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                                    tooltip: 'Edit Question',
                                    onPressed: () => _showEditQuestionDialog(currentTest.id, q),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                                    tooltip: 'Delete Question',
                                    onPressed: () => _confirmDeleteQuestion(currentTest.id, q.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                q.questionText,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.4),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 6,
                                children: [
                                  _optionBadge('A', q.optionA, q.correctAnswer == 'A'),
                                  _optionBadge('B', q.optionB, q.correctAnswer == 'B'),
                                  _optionBadge('C', q.optionC, q.correctAnswer == 'C'),
                                  _optionBadge('D', q.optionD, q.correctAnswer == 'D'),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  // Bottom Pagination Bar
                  if (totalPages > 1) ...[
                    const SizedBox(height: 16),
                    _buildPaginationControls(currentPage, totalPages, startIndex, endIndex, totalQuestions),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatUploadDate(DateTime date) {
    final now = DateTime.now();
    final diffDays = DateTime(now.year, now.month, now.day).difference(DateTime(date.year, date.month, date.day)).inDays;
    final timeStr = DateFormat('hh:mm a').format(date);
    final dateStr = DateFormat('dd MMM yyyy').format(date);
    if (diffDays == 0) return 'Today • $dateStr at $timeStr';
    if (diffDays == 1) return 'Yesterday • $dateStr at $timeStr';
    return '$dateStr at $timeStr';
  }

  Widget _optionBadge(String label, String text, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.successLight : AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isCorrect ? AppColors.success : AppColors.border),
      ),
      child: Text(
        '($label) $text',
        style: TextStyle(
          fontSize: 12,
          fontWeight: isCorrect ? FontWeight.w700 : FontWeight.w400,
          color: isCorrect ? AppColors.success : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _miniBadge(IconData icon, String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: SUBMISSIONS & SCORES ---
  Widget _buildSubmissionsTab(bool isMobile) {
    return StreamBuilder<List<TestSubmission>>(
      stream: _submissionsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final allSubmissions = snapshot.data ?? [];
        final filteredSubmissions = _submissionSearchQuery.isEmpty
            ? allSubmissions
            : allSubmissions.where((sub) {
                final query = _submissionSearchQuery.toLowerCase();
                return sub.studentName.toLowerCase().contains(query) ||
                    (sub.studentEmail?.toLowerCase().contains(query) ?? false) ||
                    sub.testId.toLowerCase().contains(query);
              }).toList();

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 28),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student Test Submissions (${allSubmissions.length})',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Real-time records saved in Firebase Cloud DB • Tap any submission to view MCQ answers',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search submission by Candidate Name, Email, or Test Title...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _submissionSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () => setState(() => _submissionSearchQuery = ''),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) => setState(() => _submissionSearchQuery = val),
                  ),
                  const SizedBox(height: 18),

                  if (filteredSubmissions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.assignment_late_outlined, size: 44, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              _submissionSearchQuery.isEmpty
                                  ? 'No student submissions recorded yet.'
                                  : 'No submissions matched "$_submissionSearchQuery".',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredSubmissions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final sub = filteredSubmissions[index];
                        final accuracy = sub.accuracy;
                        final scoreColor = accuracy >= 70
                            ? AppColors.success
                            : (accuracy >= 45 ? AppColors.primary : AppColors.warning);

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: AppColors.shadowSm,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => SubmissionMcqReviewDialog.show(context, submission: sub),
                              child: Padding(
                                padding: EdgeInsets.all(isMobile ? 16 : 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '#${index + 1}',
                                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      sub.studentName,
                                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primaryLight,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: const Text('SUBMITTED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                sub.studentEmail ?? 'No email associated',
                                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${sub.score.toInt()} / ${sub.totalMarks.toInt()} Marks',
                                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: scoreColor),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${sub.accuracy.toStringAsFixed(1)}% Accuracy',
                                              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    if (isMobile) ...[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sub.testId.isNotEmpty ? sub.testId : 'NEET Mock Paper',
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Submitted: ${sub.submittedAt.day}/${sub.submittedAt.month}/${sub.submittedAt.year} at ${sub.submittedAt.hour.toString().padLeft(2, '0')}:${sub.submittedAt.minute.toString().padLeft(2, '0')} • ${(sub.timeTakenSeconds / 60).ceil()} mins taken',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () {
                                                    CandidateAnalysisDialog.show(
                                                      context,
                                                      student: {
                                                        'displayName': sub.studentName,
                                                        'email': sub.studentEmail ?? '',
                                                        'uid': sub.studentUid ?? '',
                                                        'createdAt': sub.submittedAt,
                                                      },
                                                      matchingSubmissions: [sub],
                                                    );
                                                  },
                                                  icon: const Icon(Icons.analytics_outlined, size: 14),
                                                  label: const Text('STATS', style: TextStyle(fontSize: 12)),
                                                  style: OutlinedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () => SubmissionMcqReviewDialog.show(context, submission: sub),
                                                  icon: const Icon(Icons.quiz_outlined, size: 14),
                                                  label: const Text('REVIEW', style: TextStyle(fontSize: 12)),
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ] else
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sub.testId.isNotEmpty ? sub.testId : 'NEET Mock Paper',
                                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Submitted: ${sub.submittedAt.day}/${sub.submittedAt.month}/${sub.submittedAt.year} at ${sub.submittedAt.hour.toString().padLeft(2, '0')}:${sub.submittedAt.minute.toString().padLeft(2, '0')} • ${(sub.timeTakenSeconds / 60).ceil()} mins taken',
                                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 6,
                                            children: [
                                              OutlinedButton.icon(
                                                onPressed: () {
                                                  CandidateAnalysisDialog.show(
                                                    context,
                                                    student: {
                                                      'displayName': sub.studentName,
                                                      'email': sub.studentEmail ?? '',
                                                      'uid': sub.studentUid ?? '',
                                                      'createdAt': sub.submittedAt,
                                                    },
                                                    matchingSubmissions: [sub],
                                                  );
                                                },
                                                icon: const Icon(Icons.analytics_outlined, size: 15),
                                                label: const Text('STUDENT STATS'),
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                ),
                                              ),
                                              ElevatedButton.icon(
                                                onPressed: () => SubmissionMcqReviewDialog.show(context, submission: sub),
                                                icon: const Icon(Icons.quiz_outlined, size: 15),
                                                label: const Text('SOLUTIONS & MCQs'),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        _miniBadge(Icons.check_circle_rounded, '+${sub.correctCount} Correct (+4)', AppColors.successLight, AppColors.success),
                                        _miniBadge(Icons.cancel_rounded, '-${sub.wrongCount} Wrong (-1)', AppColors.errorLight, AppColors.error),
                                        _miniBadge(Icons.help_outline_rounded, '${sub.unattemptedCount} Skipped (0)', AppColors.surfaceSubtle, AppColors.textSecondary),
                                        _miniBadge(Icons.timelapse_rounded, '${(sub.timeTakenSeconds / 60).ceil()} mins duration', AppColors.primaryLight, AppColors.primary),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- TAB 4: REGISTERED STUDENTS & ANALYTICS ---
  Widget _buildStudentsTab(bool isMobile) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _studentsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final students = snapshot.data ?? [];

        return StreamBuilder<List<TestSubmission>>(
          stream: _submissionsStream,
          builder: (context, subSnapshot) {
            final submissions = subSnapshot.data ?? [];

            final filteredStudents = _studentSearchQuery.isEmpty
                ? students
                : students.where((s) {
                    final name = (s['displayName'] ?? '').toString().toLowerCase();
                    final email = (s['email'] ?? '').toString().toLowerCase();
                    final phone = (s['phone'] ?? '').toString().toLowerCase();
                    final query = _studentSearchQuery.toLowerCase();
                    return name.contains(query) || email.contains(query) || phone.contains(query);
                  }).toList();

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 28),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registered Aspirants & Performance (${students.length})',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              const Text('Live candidate directory with exam scores, accuracy, and detailed analytical status', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Search input
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search candidate by name, email, or mobile...',
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
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.person_search_rounded, size: 44, color: AppColors.textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  _studentSearchQuery.isEmpty
                                      ? 'No students registered yet.'
                                      : 'No candidates matched "$_studentSearchQuery".',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredStudents.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final s = filteredStudents[index];
                            final name = s['displayName'] ?? 'Student';
                            final email = s['email'] ?? '';
                            final phone = s['phone'] ?? 'N/A';
                            final uid = s['uid'] ?? '';

                            final matchingSubs = submissions.where((sub) {
                              if (uid.isNotEmpty && sub.studentUid != null && sub.studentUid == uid) return true;
                              if (sub.studentEmail != null && sub.studentEmail!.toLowerCase() == email.toString().toLowerCase()) return true;
                              if (sub.studentName.trim().toLowerCase() == name.toString().trim().toLowerCase()) return true;
                              return false;
                            }).toList();

                            final testCount = matchingSubs.length;
                            final bestScore = matchingSubs.isEmpty
                                ? 0.0
                                : matchingSubs.map((sub) => sub.score).reduce((a, b) => a > b ? a : b);
                            final avgAccuracy = matchingSubs.isEmpty
                                ? 0.0
                                : (matchingSubs.map((sub) => sub.accuracy).reduce((a, b) => a + b) / testCount);

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
                                borderRadius: BorderRadius.circular(14),
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
                                              child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'S', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
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
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('$testCount Tests • Score: ${testCount > 0 ? bestScore.toInt() : '--'} / 720', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                            if (testCount > 0)
                                              Text('${avgAccuracy.toStringAsFixed(0)}% Accuracy', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () => CandidateAnalysisDialog.show(
                                              context,
                                              student: s,
                                              matchingSubmissions: matchingSubs,
                                            ),
                                            icon: const Icon(Icons.analytics_outlined, size: 16),
                                            label: const Text('VIEW DETAILED ANALYSIS'),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: AppColors.primaryLight,
                                          child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'S', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                                                    child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
                                                  ),
                                                ],
                                              ),
                                              Text('$email • Mobile: $phone', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$testCount Tests Attempted',
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                                              ),
                                              Text(
                                                testCount > 0 ? 'Highest: ${bestScore.toInt()} / 720 Marks' : 'No tests taken',
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
                                              Text(
                                                testCount > 0 ? '${matchingSubs.fold(0, (sum, sub) => sum + sub.correctCount)} Correct MCQs' : '--',
                                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () => CandidateAnalysisDialog.show(
                                            context,
                                            student: s,
                                            matchingSubmissions: matchingSubs,
                                          ),
                                          icon: const Icon(Icons.analytics_outlined, size: 16),
                                          label: const Text('VIEW ANALYSIS'),
                                        ),
                                      ],
                                    ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- QUESTION DIALOGS (ADD / EDIT) ---

  void _showAddQuestionDialog(String testId, int newId) {
    final formKey = GlobalKey<FormState>();
    final qCtrl = TextEditingController();
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    final cCtrl = TextEditingController();
    final dCtrl = TextEditingController();
    String key = 'A';
    String subject = 'Physics';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('Add New Question #$newId'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: qCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Question Statement *'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: aCtrl,
                      decoration: const InputDecoration(labelText: 'Option A *'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: bCtrl,
                      decoration: const InputDecoration(labelText: 'Option B *'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: cCtrl,
                      decoration: const InputDecoration(labelText: 'Option C *'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: dCtrl,
                      decoration: const InputDecoration(labelText: 'Option D *'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: key,
                            decoration: const InputDecoration(labelText: 'Correct Key'),
                            items: ['A', 'B', 'C', 'D'].map((o) => DropdownMenuItem(value: o, child: Text('Option $o'))).toList(),
                            onChanged: (v) => setDlgState(() => key = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: subject,
                            decoration: const InputDecoration(labelText: 'Subject'),
                            items: ['Physics', 'Chemistry', 'Biology', 'Botany', 'Zoology', 'General'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setDlgState(() => subject = v!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newQ = FirebaseQuestion(
                    id: newId,
                    questionText: qCtrl.text.trim(),
                    optionA: aCtrl.text.trim(),
                    optionB: bCtrl.text.trim(),
                    optionC: cCtrl.text.trim(),
                    optionD: dCtrl.text.trim(),
                    correctAnswer: key,
                    subject: subject,
                    marks: 4.0,
                    negativeMarks: 1.0,
                  );
                  Navigator.pop(ctx);
                  await _firebaseService.addQuestionToTest(testId, newQ);
                  if (mounted) setState(() {});
                }
              },
              child: const Text('SAVE QUESTION'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditQuestionDialog(String testId, FirebaseQuestion question) {
    final formKey = GlobalKey<FormState>();
    final qCtrl = TextEditingController(text: question.questionText);
    final aCtrl = TextEditingController(text: question.optionA);
    final bCtrl = TextEditingController(text: question.optionB);
    final cCtrl = TextEditingController(text: question.optionC);
    final dCtrl = TextEditingController(text: question.optionD);
    String key = question.correctAnswer;
    String subject = question.subject;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('Edit Question #${question.id}'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: qCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Question Statement *'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: aCtrl,
                      decoration: const InputDecoration(labelText: 'Option A *'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: bCtrl,
                      decoration: const InputDecoration(labelText: 'Option B *'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: cCtrl,
                      decoration: const InputDecoration(labelText: 'Option C *'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: dCtrl,
                      decoration: const InputDecoration(labelText: 'Option D *'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: key,
                            decoration: const InputDecoration(labelText: 'Correct Key'),
                            items: ['A', 'B', 'C', 'D'].map((o) => DropdownMenuItem(value: o, child: Text('Option $o'))).toList(),
                            onChanged: (v) => setDlgState(() => key = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: ['Physics', 'Chemistry', 'Biology', 'Botany', 'Zoology', 'General'].contains(subject) ? subject : 'General',
                            decoration: const InputDecoration(labelText: 'Subject'),
                            items: ['Physics', 'Chemistry', 'Biology', 'Botany', 'Zoology', 'General'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setDlgState(() => subject = v!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final updatedQ = FirebaseQuestion(
                    id: question.id,
                    questionText: qCtrl.text.trim(),
                    optionA: aCtrl.text.trim(),
                    optionB: bCtrl.text.trim(),
                    optionC: cCtrl.text.trim(),
                    optionD: dCtrl.text.trim(),
                    correctAnswer: key,
                    subject: subject,
                    marks: question.marks,
                    negativeMarks: question.negativeMarks,
                  );
                  Navigator.pop(ctx);
                  await _firebaseService.updateQuestionInTest(testId, updatedQ);
                  if (mounted) setState(() {});
                }
              },
              child: const Text('UPDATE QUESTION'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteQuestion(String testId, int questionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Question?'),
        content: Text('Are you sure you want to remove question #$questionId from this test?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await _firebaseService.deleteQuestionFromTest(testId, questionId);
              if (mounted) setState(() {});
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTest(FirebaseDailyTest test) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Paper?'),
        content: Text('Are you sure you want to permanently delete "${test.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await _firebaseService.deleteDailyTest(test.id);
              if (mounted) setState(() {});
            },
            child: const Text('DELETE TEST'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int currentPage, int totalPages, int startIndex, int endIndex, int totalQuestions) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${startIndex + 1} - $endIndex of $totalQuestions MCQs',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: 'Previous Page',
                onPressed: currentPage > 0
                    ? () => setState(() => _questionPage = currentPage - 1)
                    : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Page ${currentPage + 1} of $totalPages',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: 'Next Page',
                onPressed: currentPage < totalPages - 1
                    ? () => setState(() => _questionPage = currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeepAliveTab extends StatefulWidget {
  final Widget child;
  const _KeepAliveTab({required this.child});

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

