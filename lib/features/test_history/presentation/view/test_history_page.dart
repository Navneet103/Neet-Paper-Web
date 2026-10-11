import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/firebase/firebase_test_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../core/widgets/candidate_analysis_dialog.dart';
import '../../../../core/widgets/submission_mcq_review_dialog.dart';
import '../../../../injection/injection_container.dart';

class TestHistoryPage extends StatefulWidget {
  const TestHistoryPage({super.key});

  @override
  State<TestHistoryPage> createState() => _TestHistoryPageState();
}

class _TestHistoryPageState extends State<TestHistoryPage> {
  final _auth = sl<AuthService>();
  final _service = sl<FirebaseTestService>();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _service.flushPendingSubmissions();
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} at ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isAdmin = _auth.isAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isAdmin ? 'All Candidates Test Submissions' : 'My Test History'),
        actions: [
          if (!isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/daily-test'),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Take Mock Test'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ),
        ],
      ),
      body: isAdmin
          ? _buildAdminSubmissionsView(screenWidth, isMobile)
          : _buildStudentSubmissionsView(screenWidth, isMobile),
    );
  }

  // --- ADMIN VIEW: ALL STUDENTS SUBMISSIONS WITH NAME & STATS ---
  Widget _buildAdminSubmissionsView(double screenWidth, bool isMobile) {
    return StreamBuilder<List<TestSubmission>>(
      stream: _service.streamAllSubmissions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final allSubmissions = snapshot.data ?? [];
        final filteredSubmissions = _searchQuery.isEmpty
            ? allSubmissions
            : allSubmissions.where((sub) {
                final query = _searchQuery.toLowerCase();
                return sub.studentName.toLowerCase().contains(query) ||
                    (sub.studentEmail?.toLowerCase().contains(query) ?? false) ||
                    sub.testId.toLowerCase().contains(query) ||
                    (sub.testDocId?.toLowerCase().contains(query) ?? false);
              }).toList();

        return SingleChildScrollView(
          child: AppPageContainer(
            maxWidth: 1000,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSectionHeader(
                  title: 'All Candidate Submissions',
                  subtitle: 'Real-time record of all student test attempts across the platform',
                ),
                const SizedBox(height: 12),

                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by Student Name, Email, or Test Title...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 20),

                if (filteredSubmissions.isEmpty)
                  AppEmptyState(
                    icon: Icons.history_toggle_off_rounded,
                    title: _searchQuery.isEmpty ? 'No Submissions Recorded' : 'No Matching Submissions',
                    message: _searchQuery.isEmpty
                        ? 'No students have submitted any test papers yet.'
                        : 'No submissions matched your search query "$_searchQuery".',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredSubmissions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final sub = filteredSubmissions[index];
                      return _buildAdminSubmissionCard(sub, isMobile);
                    },
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminSubmissionCard(TestSubmission sub, bool isMobile) {
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
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    sub.studentName.isNotEmpty ? sub.studentName[0].toUpperCase() : 'S',
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
                            child: const Text('CANDIDATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
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
                      '${sub.score.toInt()} / ${sub.totalMarks.toInt()}',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: scoreColor),
                    ),
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
                    sub.testId.isNotEmpty ? sub.testId : 'NEET Mock Examination',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Submitted: ${_formatDate(sub.submittedAt)} • ${(sub.timeTakenSeconds / 60).ceil()} mins',
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
                          sub.testId.isNotEmpty ? sub.testId : 'NEET Mock Examination',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Submitted: ${_formatDate(sub.submittedAt)} • Duration: ${(sub.timeTakenSeconds / 60).ceil()} mins',
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
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _miniBadge(Icons.check_circle_rounded, '+${sub.correctCount} Correct', AppColors.successLight, AppColors.success),
                _miniBadge(Icons.cancel_rounded, '-${sub.wrongCount} Wrong', AppColors.errorLight, AppColors.error),
                _miniBadge(Icons.help_outline_rounded, '${sub.unattemptedCount} Skipped', AppColors.surfaceSubtle, AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- STUDENT VIEW: STRICTLY THIS STUDENT'S OWN SUBMISSIONS ---
  Widget _buildStudentSubmissionsView(double screenWidth, bool isMobile) {
    if (!_auth.isAuthenticated || _auth.currentUser == null) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_person_rounded, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Student Login Required',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please sign in with your candidate credentials to access your personal test scorecards and history.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('SIGN IN TO ACCOUNT'),
              ),
            ],
          ),
        ),
      );
    }

    final currentUid = _auth.currentUser!.uid;
    final currentEmail = _auth.currentUser!.email;

    return StreamBuilder<List<TestSubmission>>(
      stream: _service.streamStudentSubmissions(currentUid, studentEmail: currentEmail),
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final mySubmissions = snapshot.data ?? [];

        if (mySubmissions.isEmpty) {
          return AppEmptyState(
            icon: Icons.history_toggle_off_rounded,
            title: 'No Test Attempts Yet',
            message: 'You have not submitted any test papers yet. Take today\'s live test to generate your performance scorecard.',
            actionLabel: 'Take Today\'s Live Test',
            onAction: () => context.push('/daily-test'),
          );
        }

        return SingleChildScrollView(
          child: AppPageContainer(
            maxWidth: 960,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Completed Examinations',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${mySubmissions.length} tests completed by ${_auth.currentUser!.displayName}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mySubmissions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final sub = mySubmissions[index];
                    return _buildStudentSubmissionCard(sub, isMobile);
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentSubmissionCard(TestSubmission sub, bool isMobile) {
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
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: scoreColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${sub.score.toInt()}',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: scoreColor),
                                ),
                                Text(
                                  '/ ${sub.totalMarks.toInt()}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted),
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
                                        sub.testId.isNotEmpty ? sub.testId : 'NEET Daily Mock Test',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.successLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('SUBMITTED', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 10)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Attempted: ${_formatDate(sub.submittedAt)} • ${(sub.timeTakenSeconds / 60).ceil()} mins taken',
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
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
                          _miniBadge(Icons.check_circle_rounded, '+${sub.correctCount} Right', AppColors.successLight, AppColors.success),
                          _miniBadge(Icons.cancel_rounded, '-${sub.wrongCount} Wrong', AppColors.errorLight, AppColors.error),
                          _miniBadge(Icons.pie_chart_rounded, '${sub.accuracy.toStringAsFixed(1)}% Acc', AppColors.primaryLight, AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => SubmissionMcqReviewDialog.show(context, submission: sub),
                          icon: const Icon(Icons.quiz_outlined, size: 15),
                          label: const Text('SOLUTIONS & REVIEW'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      // Score Badge
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: scoreColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${sub.score.toInt()}',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: scoreColor),
                            ),
                            Text(
                              '/ ${sub.totalMarks.toInt()}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    sub.testId.isNotEmpty ? sub.testId : 'NEET Daily Mock Test',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('SUBMITTED', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 10.5)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Attempted: ${_formatDate(sub.submittedAt)} • ${(sub.timeTakenSeconds / 60).ceil()} mins taken',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _miniBadge(Icons.check_circle_rounded, '+${sub.correctCount} Right', AppColors.successLight, AppColors.success),
                                _miniBadge(Icons.cancel_rounded, '-${sub.wrongCount} Wrong', AppColors.errorLight, AppColors.error),
                                _miniBadge(Icons.pie_chart_rounded, '${sub.accuracy.toStringAsFixed(1)}% Acc', AppColors.primaryLight, AppColors.primary),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => SubmissionMcqReviewDialog.show(context, submission: sub),
                        icon: const Icon(Icons.quiz_outlined, size: 15),
                        label: const Text('SOLUTIONS'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ],
                  ),
          ),
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
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}
