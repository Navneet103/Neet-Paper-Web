import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/firebase/firebase_test_service.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../core/widgets/candidate_analysis_dialog.dart';
import '../../../../injection/injection_container.dart';

class DailyTestPage extends StatefulWidget {
  const DailyTestPage({super.key});

  @override
  State<DailyTestPage> createState() => _DailyTestPageState();
}

class _DailyTestPageState extends State<DailyTestPage> {
  final _service = sl<FirebaseTestService>();
  final _auth = sl<AuthService>();
  final _db = sl<AppDatabase>();
  late final Stream<FirebaseDailyTest?> _todayTestStream;
  late final Stream<List<FirebaseDailyTest>> _recentTestsStream;
  late final Stream<List<TestSubmission>> _mySubmissionsStream;
  bool _isLaunching = false;

  @override
  void initState() {
    super.initState();
    _todayTestStream = _service.streamTodayTest();
    _recentTestsStream = _service.streamRecentTests();

    final currentUid = _auth.currentUser?.uid;
    final currentEmail = _auth.currentUser?.email;
    _mySubmissionsStream = (_auth.isAuthenticated && currentUid != null)
        ? _service.streamStudentSubmissions(currentUid, studentEmail: currentEmail)
        : Stream.value([]);
  }

  Future<void> _startExam(FirebaseDailyTest test) async {
    // 1. Check Authentication
    if (!_auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in with your Student account to start the examination.'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.push('/login');
      return;
    }

    // 2. Timing Gate: verify test is not upcoming
    if (test.isUpcoming && !kDebugMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This exam is scheduled for 09:00 AM IST. Portal will unlock automatically.'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    // 3. Prevent duplicate attempts
    final hasAttemptedTitle = await _auth.hasStudentAttempted(test.title);
    final hasAttemptedId = await _auth.hasStudentAttempted(test.id);
    if (hasAttemptedTitle || hasAttemptedId) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already submitted this exam. Please tap "View Scorecard" to review your results.'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    setState(() => _isLaunching = true);

    try {
      final testId = await _service.prepareLocalSessionForDailyTest(test, _db);
      final driftQuestions = test.questions.map((q) => q.toDriftQuestion()).toList();

      if (!mounted) return;
      setState(() => _isLaunching = false);

      context.push('/exam/$testId', extra: driftQuestions);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLaunching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to launch exam: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('NEET Daily Live Test'),
        actions: [
          if (_auth.isAuthenticated) ...[
            if (isMobile)
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _auth.currentUser!.displayName.isNotEmpty
                        ? _auth.currentUser!.displayName[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(
                    avatar: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        _auth.currentUser!.displayName.isNotEmpty
                            ? _auth.currentUser!.displayName[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                    label: Text(
                      _auth.currentUser!.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    backgroundColor: AppColors.surfaceSubtle,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 20),
              tooltip: 'Sign Out',
              onPressed: () async {
                await _auth.signOut();
                if (mounted) setState(() {});
              },
            ),
          ] else ...[
            if (isMobile)
              IconButton(
                icon: const Icon(Icons.login_rounded, size: 20),
                tooltip: 'Student Login',
                onPressed: () => context.push('/login'),
              )
            else
              TextButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Student Login'),
              ),
          ],
          if (_auth.isAdmin)
            if (isMobile)
              IconButton(
                icon: const Icon(Icons.cloud_upload_rounded, color: AppColors.primary, size: 20),
                tooltip: 'Upload Paper',
                onPressed: () => context.push('/publish-daily-test'),
              )
            else
              TextButton.icon(
                onPressed: () => context.push('/publish-daily-test'),
                icon: const Icon(Icons.cloud_upload_rounded, color: AppColors.primary, size: 20),
                label: const Text('Upload Paper (Admin)', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<TestSubmission>>(
        stream: _mySubmissionsStream,
        builder: (context, subSnapshot) {
          final mySubmissions = subSnapshot.data ?? [];

          return StreamBuilder<FirebaseDailyTest?>(
            stream: _todayTestStream,
            builder: (context, snapshot) {
              final todayTest = snapshot.data;
              final isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;

              return SingleChildScrollView(
                child: AppPageContainer(
                  maxWidth: 1000,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Header
                      _buildHeader(isMobile),
                      const SizedBox(height: 28),

                      if (isLoading) ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
                      ] else if (todayTest == null) ...[
                        _buildNoTestCard(isMobile),
                      ] else ...[
                        // Today's Live/Scheduled Test Card
                        _buildTodayTestCard(todayTest, isMobile, mySubmissions),
                      ],

                      const SizedBox(height: 36),

                      // Recent & Archive Tests Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Daily Mock Papers',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          if (_auth.isAdmin)
                            TextButton.icon(
                              onPressed: () => context.push('/publish-daily-test'),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add Paper'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildRecentTestsStream(todayTest?.id, mySubmissions),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'DAILY LIVE SCHEDULE • 09:00 AM IST',
                      style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text('NTA Standard Pattern', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Official Daily Mock Test Portal',
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fresh full syllabus NEET tests publish everyday at 09:00 AM IST. Attempt under official time pressure with negative marking.',
            style: TextStyle(
              fontSize: isMobile ? 13 : 15,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTestCard(FirebaseDailyTest test, bool isMobile, List<TestSubmission> mySubmissions) {
    final isUpcoming = test.isUpcoming;
    final isLive = test.isLive;

    // Strict check: has the current student submitted this test?
    final mySub = mySubmissions
        .where((s) => s.testId == test.title || s.testId == test.id)
        .firstOrNull;
    final hasSubmitted = mySub != null;

    Color borderColor = AppColors.border;
    if (hasSubmitted) {
      borderColor = AppColors.success;
    } else if (isLive) {
      borderColor = AppColors.error;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
          width: (hasSubmitted || isLive) ? 2 : 1,
        ),
        boxShadow: isLive
            ? [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                )
              ]
            : (hasSubmitted
                ? [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    )
                  ]
                : AppColors.shadowSm),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Badges
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                if (hasSubmitted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'EXAM COMPLETED & SUBMITTED',
                          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.radio_button_checked_rounded, color: AppColors.error, size: 16),
                        SizedBox(width: 8),
                        Text(
                          '🔴 EXAM IS LIVE NOW',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else if (isUpcoming)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined, color: AppColors.primary, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'SCHEDULED FOR 09:00 AM (IST)',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('AVAILABLE PRACTICE PAPER', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ),

                AppBadge(
                  text: '${test.totalQuestions} Questions • ${test.totalMarks.toInt()} Marks',
                  backgroundColor: AppColors.surfaceSubtle,
                  textColor: AppColors.textPrimary,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              test.title,
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),

            // Specs Row
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _specBadge(Icons.timer_outlined, '${test.durationMinutes} Minutes'),
                _specBadge(Icons.check_circle_outline, '+4 Marks Correct'),
                _specBadge(Icons.cancel_outlined, '-1 Penalty Negative'),
                _specBadge(Icons.calendar_today_rounded, test.dateKey),
              ],
            ),
            const SizedBox(height: 24),

            // Countdown Timer (if upcoming and not submitted)
            if (isUpcoming && !hasSubmitted) ...[
              _LiveCountdownWidget(
                test: test,
                onTimerExpired: () {
                  if (mounted) setState(() {});
                },
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons & Result State Separation
            if (hasSubmitted) ...[
              // Already Completed by this student: show scorecard banner & view result button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.successLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                      child: const Icon(Icons.verified_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Score: ${mySub.score.toInt()} / ${mySub.totalMarks.toInt()} Marks (${mySub.accuracy.toStringAsFixed(1)}% Accuracy)',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Right: +${mySub.correctCount} • Wrong: -${mySub.wrongCount} • Skipped: ${mySub.unattemptedCount} • Attempt recorded',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    CandidateAnalysisDialog.show(
                      context,
                      student: {
                        'displayName': _auth.currentUser?.displayName ?? mySub.studentName,
                        'email': _auth.currentUser?.email ?? mySub.studentEmail ?? '',
                        'uid': _auth.currentUser?.uid ?? mySub.studentUid ?? '',
                        'createdAt': mySub.submittedAt,
                      },
                      matchingSubmissions: [mySub],
                    );
                  },
                  icon: const Icon(Icons.analytics_outlined, size: 22),
                  label: const Text('VIEW YOUR SCORECARD & SOLUTIONS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ] else ...[
              // Student has NOT submitted this test: display Start Exam button
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: (_isLaunching || (isUpcoming && !kDebugMode))
                            ? null
                            : () => _startExam(test),
                        icon: _isLaunching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Icon(isLive ? Icons.play_arrow_rounded : Icons.login_rounded, size: 22),
                        label: Text(
                          _isLaunching
                              ? 'Preparing Exam Session...'
                              : (isLive ? 'START LIVE EXAM NOW' : (isUpcoming ? 'OPENS AT 09:00 AM' : 'START PRACTICE EXAM')),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLive ? AppColors.error : AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  if (kDebugMode && isUpcoming) ...[
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => _startExam(test),
                      child: const Text('Test Preview'),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _specBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildNoTestCard(bool isMobile) {
    if (_auth.isAdmin) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 24 : 40),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.shadowSm,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_upload_rounded, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Daily Test Configured for Today',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Administrator: Upload today\'s 180 questions via Excel to make today\'s mock exam live for students.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/publish-daily-test'),
              icon: const Icon(Icons.cloud_upload_rounded),
              label: const Text('UPLOAD TODAY\'S 180 QUESTIONS'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.alarm_on_rounded, color: AppColors.primary, size: 34),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Live Exam Scheduled for Today',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Today\'s scheduled 09:00 AM live CBT examination is not active. You can attempt past papers below to practice.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTestsStream(String? currentTestId, List<TestSubmission> mySubmissions) {
    return StreamBuilder<List<FirebaseDailyTest>>(
      stream: _recentTestsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final isMobile = MediaQuery.of(context).size.width < 768;
        final tests = snapshot.data ?? [];
        if (tests.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: Text('No previous papers found in Firebase.', style: TextStyle(color: AppColors.textMuted))),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final t = tests[index];
            final isCurrent = t.id == currentTestId;

            final mySub = mySubmissions
                .where((s) => s.testId == t.title || s.testId == t.id)
                .firstOrNull;
            final hasSubmitted = mySub != null;

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: hasSubmitted ? AppColors.success : (isCurrent ? AppColors.primary : AppColors.border)),
              ),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: hasSubmitted ? AppColors.successLight : AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                hasSubmitted ? Icons.check_circle_rounded : Icons.assignment_rounded,
                                color: hasSubmitted ? AppColors.success : AppColors.primary,
                                size: 20,
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
                                      const SizedBox(width: 6),
                                      if (hasSubmitted)
                                        AppBadge(
                                          text: 'Attempted • ${mySub.score.toInt()}/720',
                                          backgroundColor: AppColors.successLight,
                                          textColor: AppColors.success,
                                        )
                                      else
                                        const AppBadge(
                                          text: 'Available',
                                          backgroundColor: AppColors.surfaceSubtle,
                                          textColor: AppColors.textMuted,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${t.totalQuestions} MCQs • ${t.durationMinutes} Mins • ${t.dateKey}',
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: hasSubmitted
                              ? OutlinedButton.icon(
                                  onPressed: () {
                                    CandidateAnalysisDialog.show(
                                      context,
                                      student: {
                                        'displayName': _auth.currentUser?.displayName ?? mySub.studentName,
                                        'email': _auth.currentUser?.email ?? mySub.studentEmail ?? '',
                                        'uid': _auth.currentUser?.uid ?? mySub.studentUid ?? '',
                                        'createdAt': mySub.submittedAt,
                                      },
                                      matchingSubmissions: [mySub],
                                    );
                                  },
                                  icon: const Icon(Icons.analytics_outlined, size: 16),
                                  label: const Text('VIEW RESULT & STATS', style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () => _startExam(t),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                                  ),
                                  child: const Text('PRACTICE NOW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: hasSubmitted ? AppColors.successLight : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            hasSubmitted ? Icons.check_circle_rounded : Icons.assignment_rounded,
                            color: hasSubmitted ? AppColors.success : AppColors.primary,
                            size: 22,
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
                                      t.title,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (hasSubmitted)
                                    AppBadge(
                                      text: 'Attempted • ${mySub.score.toInt()}/720',
                                      backgroundColor: AppColors.successLight,
                                      textColor: AppColors.success,
                                    )
                                  else
                                    const AppBadge(
                                      text: 'Available',
                                      backgroundColor: AppColors.surfaceSubtle,
                                      textColor: AppColors.textMuted,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${t.totalQuestions} Questions • ${t.totalMarks.toInt()} Marks • ${t.durationMinutes} Mins • Date: ${t.dateKey}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (hasSubmitted)
                          OutlinedButton.icon(
                            onPressed: () {
                              CandidateAnalysisDialog.show(
                                context,
                                student: {
                                  'displayName': _auth.currentUser?.displayName ?? mySub.studentName,
                                  'email': _auth.currentUser?.email ?? mySub.studentEmail ?? '',
                                  'uid': _auth.currentUser?.uid ?? mySub.studentUid ?? '',
                                  'createdAt': mySub.submittedAt,
                                },
                                matchingSubmissions: [mySub],
                              );
                            },
                            icon: const Icon(Icons.analytics_outlined, size: 16),
                            label: const Text('VIEW RESULT', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: () => _startExam(t),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('PRACTICE', style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}

class _LiveCountdownWidget extends StatefulWidget {
  final FirebaseDailyTest test;
  final VoidCallback? onTimerExpired;

  const _LiveCountdownWidget({required this.test, this.onTimerExpired});

  @override
  State<_LiveCountdownWidget> createState() => _LiveCountdownWidgetState();
}

class _LiveCountdownWidgetState extends State<_LiveCountdownWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
        if (!widget.test.isUpcoming && widget.onTimerExpired != null) {
          widget.onTimerExpired!();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.test.timeUntilStart;
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.alarm_on_rounded, color: Color(0xFF16A34A), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Exam Portal Starts At 09:00 AM',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF15803D)),
                ),
                SizedBox(height: 2),
                Text(
                  'Please be ready with rough paper and timer',
                  style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
                ),
              ],
            ),
          ),
          Text(
            '$hours : $minutes : $seconds',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              color: Color(0xFF15803D),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
