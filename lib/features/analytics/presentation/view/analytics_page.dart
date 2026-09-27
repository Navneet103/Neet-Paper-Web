import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/firebase/firebase_test_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../core/widgets/candidate_analysis_dialog.dart';
import '../../../../core/widgets/submission_mcq_review_dialog.dart';
import '../../../../injection/injection_container.dart';
import '../view_model/analytics_view_model.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late AnalyticsViewModel _viewModel;
  late final AuthService _auth;
  late final FirebaseTestService _testService;
  late final Stream<List<TestSubmission>> _submissionsStream;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<AnalyticsViewModel>();
    _viewModel.loadAnalytics();
    _auth = sl<AuthService>();
    _testService = sl<FirebaseTestService>();

    if (_auth.isAdmin) {
      _submissionsStream = _testService.streamAllSubmissions();
    } else {
      final uid = _auth.currentUser?.uid ?? '';
      final email = _auth.currentUser?.email;
      _submissionsStream = _testService.streamStudentSubmissions(uid, studentEmail: email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_auth.isAdmin ? 'Candidate Analytics' : 'Your Analytics'),
        leading: isMobile
            ? null
            : IconButton(
                icon: const Icon(Icons.dashboard_rounded),
                onPressed: () => context.go('/dashboard'),
              ),
      ),
      body: StreamBuilder<List<TestSubmission>>(
        stream: _submissionsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final submissions = snapshot.data ?? [];

          if (submissions.isEmpty) {
            return AppEmptyState(
              icon: Icons.insights_rounded,
              title: 'No Exam Analytics Yet',
              message: _auth.isAdmin
                  ? 'No candidates have submitted any mock examinations yet.'
                  : 'You have not submitted any mock tests yet. Take today\'s live test or practice exams to generate comprehensive performance diagnostics!',
              actionLabel: _auth.isAdmin ? 'Go to Exam Management' : 'Take Daily Live Mock Test',
              onAction: () => context.push(_auth.isAdmin ? '/admin' : '/daily-test'),
            );
          }

          // Aggregated Metrics
          final int totalTests = submissions.length;
          final double totalScore = submissions.fold(0.0, (acc, s) => acc + s.score);
          final double avgScore = totalScore / totalTests;
          final double bestScore = submissions.map((s) => s.score).reduce((a, b) => a > b ? a : b);
          final double avgAccuracy = submissions.fold(0.0, (acc, s) => acc + s.accuracy) / totalTests;
          final int totalCorrect = submissions.fold(0, (acc, s) => acc + s.correctCount);
          final int totalWrong = submissions.fold(0, (acc, s) => acc + s.wrongCount);

          return SingleChildScrollView(
            child: AppPageContainer(
              maxWidth: 1000,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: _auth.isAdmin ? 'Batch Performance Summary' : 'Personal Diagnostic Summary',
                    subtitle: _auth.isAdmin
                        ? 'Consolidated examination metrics across all candidate submissions'
                        : 'Accurate performance diagnostics isolated strictly to your account',
                  ),
                  const SizedBox(height: 16),
                  _buildOverviewMetrics(
                    totalTests: totalTests,
                    avgScore: avgScore,
                    bestScore: bestScore,
                    avgAccuracy: avgAccuracy,
                    totalCorrect: totalCorrect,
                    totalWrong: totalWrong,
                    screenWidth: screenWidth,
                  ),
                  const SizedBox(height: 32),

                  // Recent Scores Progression Chart
                  _buildScoreProgressionCard(submissions, isMobile),
                  const SizedBox(height: 32),

                  // Local Subject-wise Accuracy Chart (if local database has records)
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) {
                      final subjectStats = _viewModel.state.subjectStats;
                      if (subjectStats.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSubjectChartCard(subjectStats, isMobile),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),

                  // Submissions Breakdown
                  const AppSectionHeader(
                    title: 'Exam Submission Transcripts',
                    subtitle: 'Detailed scorecard access for each attempted test paper',
                  ),
                  const SizedBox(height: 16),
                  _buildSubmissionsList(submissions, isMobile),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewMetrics({
    required int totalTests,
    required double avgScore,
    required double bestScore,
    required double avgAccuracy,
    required int totalCorrect,
    required int totalWrong,
    required double screenWidth,
  }) {
    final metrics = [
      AppMetricCard(
        title: 'Tests Attempted',
        value: '$totalTests',
        subtitle: 'Completed exams',
        icon: Icons.task_alt_rounded,
        color: AppColors.primary,
      ),
      AppMetricCard(
        title: 'Average Score',
        value: avgScore.toStringAsFixed(0),
        subtitle: 'Out of 720 marks',
        icon: Icons.score_rounded,
        color: const Color(0xFF8B5CF6),
      ),
      AppMetricCard(
        title: 'Overall Accuracy',
        value: '${avgAccuracy.toStringAsFixed(1)}%',
        subtitle: avgAccuracy >= 60 ? 'Proficient' : 'Needs revision',
        icon: Icons.pie_chart_rounded,
        color: avgAccuracy >= 60 ? AppColors.success : AppColors.warning,
      ),
      AppMetricCard(
        title: 'Highest Score',
        value: bestScore.toStringAsFixed(0),
        subtitle: 'Best test record',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFD97706),
      ),
      AppMetricCard(
        title: 'Total Correct MCQs',
        value: '$totalCorrect',
        subtitle: 'Accurate answers',
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.success,
      ),
      AppMetricCard(
        title: 'Total Mistakes',
        value: '$totalWrong',
        subtitle: 'Negative penalties',
        icon: Icons.highlight_off_rounded,
        color: AppColors.error,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 1),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 130,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) => metrics[index],
    );
  }

  Widget _buildScoreProgressionCard(List<TestSubmission> submissions, bool isMobile) {
    // Show up to 7 most recent submissions in chronological order for the trend
    final recent = submissions.take(7).toList().reversed.toList();

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score Progression Trend',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Performance evolution across recent mock tests',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 720,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = recent[group.x.toInt()];
                      return BarTooltipItem(
                        '${item.testId}\nScore: ${item.score.toInt()} / 720\nAccuracy: ${item.accuracy.toStringAsFixed(1)}%',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 180,
                  getDrawingHorizontalLine: (val) => const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 180,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= recent.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'T${index + 1}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: recent.asMap().entries.map((e) {
                  final score = e.value.score;
                  final clampedScore = score > 0 ? score : 0.0;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: clampedScore,
                        color: score >= 550 ? AppColors.success : (score >= 380 ? AppColors.primary : AppColors.warning),
                        width: isMobile ? 22 : 36,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(show: true, toY: 720, color: AppColors.surfaceSubtle),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectChartCard(List<Map<String, dynamic>> subjectStats, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accuracy by Subject',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Proficiency across syllabus domains from recent session',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: true),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (val) => const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 25,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}%',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= subjectStats.length) return const SizedBox.shrink();
                        final name = subjectStats[index]['subject'].toString();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            isMobile ? (name.length > 3 ? name.substring(0, 3).toUpperCase() : name.toUpperCase()) : name,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: subjectStats.asMap().entries.map((e) {
                  final accuracy = (e.value['accuracy'] as num).toDouble();
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: accuracy,
                        color: accuracy >= 70 ? AppColors.success : (accuracy >= 50 ? AppColors.primary : AppColors.warning),
                        width: isMobile ? 24 : 40,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: AppColors.surfaceSubtle),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsList(List<TestSubmission> submissions, bool isMobile) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: submissions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sub = submissions[index];
        final timeStr = dateFormat.format(sub.submittedAt);
        final mins = sub.timeTakenSeconds ~/ 60;
        final secs = sub.timeTakenSeconds % 60;

        return Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.shadowSm,
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sub.testId,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: sub.score >= 500 ? AppColors.successLight : (sub.score >= 350 ? AppColors.primaryLight : AppColors.warningLight),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${sub.score.toInt()} / ${sub.totalMarks.toInt()}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: sub.score >= 500 ? AppColors.success : (sub.score >= 350 ? AppColors.primary : AppColors.warning),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_auth.isAdmin ? '${sub.studentName} • ' : ''}$timeStr',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildMiniPill(Icons.check_circle_outline, '${sub.correctCount} Correct', AppColors.success),
                        _buildMiniPill(Icons.highlight_off, '${sub.wrongCount} Wrong', AppColors.error),
                        _buildMiniPill(Icons.pie_chart_outline, '${sub.accuracy.toStringAsFixed(1)}%', AppColors.primary),
                        _buildMiniPill(Icons.timer_outlined, '${mins}m ${secs}s', AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openScorecard(sub),
                            icon: const Icon(Icons.analytics_outlined, size: 15),
                            label: const Text('SCORECARD'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => SubmissionMcqReviewDialog.show(context, submission: sub),
                            icon: const Icon(Icons.quiz_outlined, size: 15),
                            label: const Text('SOLUTIONS'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.testId,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_auth.isAdmin ? 'Candidate: ${sub.studentName} • ' : ''}Submitted: $timeStr',
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _buildMiniPill(Icons.check_circle_outline, '${sub.correctCount} Correct', AppColors.success),
                          _buildMiniPill(Icons.highlight_off, '${sub.wrongCount} Wrong', AppColors.error),
                          _buildMiniPill(Icons.pie_chart_outline, '${sub.accuracy.toStringAsFixed(1)}%', AppColors.primary),
                          _buildMiniPill(Icons.timer_outlined, '${mins}m ${secs}s', AppColors.textSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sub.score >= 500 ? AppColors.successLight : (sub.score >= 350 ? AppColors.primaryLight : AppColors.warningLight),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${sub.score.toInt()} / ${sub.totalMarks.toInt()} Marks',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: sub.score >= 500 ? AppColors.success : (sub.score >= 350 ? AppColors.primary : AppColors.warning),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _openScorecard(sub),
                          icon: const Icon(Icons.analytics_outlined, size: 15),
                          label: const Text('SCORECARD'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
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
                  ],
                ),
        );
      },
    );
  }

  Widget _buildMiniPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  void _openScorecard(TestSubmission sub) {
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
  }
}
