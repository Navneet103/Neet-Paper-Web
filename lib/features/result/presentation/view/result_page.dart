import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/excel_mcq_parser.dart';
import '../../../../core/utils/platform_print.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../injection/injection_container.dart';
import '../view_model/result_view_model.dart';

class ResultPage extends StatefulWidget {
  final int testId;
  const ResultPage({super.key, required this.testId});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late ResultViewModel _viewModel;
  String _reviewFilter = 'all'; // all, correct, wrong, unattempted

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ResultViewModel>();
    _viewModel.loadResult(widget.testId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('NEET (UG) Scorecard & Analysis'),
        leading: IconButton(
          icon: const Icon(Icons.home_rounded),
          tooltip: 'Return to Dashboard',
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded),
            tooltip: 'Print Scorecard / Save PDF',
            onPressed: () => triggerPlatformPrint(),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Copy Scorecard Summary',
            onPressed: () => _copyScoreSummary(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;

          if (state.status == ResultStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state.status == ResultStatus.error) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Error Loading Result',
              message: state.errorMessage ?? 'Unable to compute results for this test.',
              actionLabel: 'Back to Dashboard',
              onAction: () => context.go('/dashboard'),
            );
          }

          final res = state.result;
          if (res == null) {
            return const Center(child: Text('No result data found.'));
          }

          return SingleChildScrollView(
            child: AppPageContainer(
              maxWidth: 980,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Candidate & Official Examination Verification Bar
                  _buildCandidateHeader(state, isMobile),
                  const SizedBox(height: 20),

                  // 2. Scorecard & AIR Predictor Hero
                  _buildScoreHero(state, isMobile),
                  const SizedBox(height: 24),

                  // 3. 6-KPI Detailed Performance Grid
                  _buildKpiMetricsGrid(state, screenWidth),
                  const SizedBox(height: 28),

                  // 4. Subject-wise Analysis Cards
                  _buildSubjectAnalysis(state, screenWidth),
                  const SizedBox(height: 28),

                  // 5. Quick Actions Row
                  _buildActionRow(context, isMobile),
                  const SizedBox(height: 36),

                  // 6. Detailed Question Review Section
                  _buildReviewSection(state, isMobile),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Official Candidate & Test Info Banner
  Widget _buildCandidateHeader(ResultState state, bool isMobile) {
    final auth = sl.isRegistered<AuthService>() ? sl<AuthService>() : null;
    final candidateName = auth?.currentUser?.displayName ?? 'NEET Aspirant';
    final candidateEmail = auth?.currentUser?.email ?? 'NTA-2026-UG';
    final testName = state.test?.name ?? 'NEET UG Full Mock Examination';
    final totalMarks = (state.test?.totalMarks ?? (state.totalQuestions * 4.0)).toInt();
    final submissionDate = state.result?.generatedAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(state.result!.generatedAt)
        : DateFormat('dd MMM yyyy').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppLogo(size: 38, borderRadius: 10, hasGlow: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'NATIONAL TESTING AGENCY (NTA) - NEET (UG)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Official Examination Scorecard & Rank Verification',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'VERIFIED',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.success),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 10,
            children: [
              _candidateInfoItem(Icons.person_rounded, 'Candidate Name', candidateName),
              _candidateInfoItem(Icons.badge_outlined, 'Application / Roll', candidateEmail),
              _candidateInfoItem(Icons.assignment_outlined, 'Examination', testName),
              _candidateInfoItem(Icons.event_available_rounded, 'Date & Time', submissionDate),
              _candidateInfoItem(Icons.grading_rounded, 'Marking Scheme', '+4 / -1 / 0'),
              _candidateInfoItem(Icons.stars_rounded, 'Maximum Marks', '$totalMarks Marks'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _candidateInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
            Text(
              value,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ],
        ),
      ],
    );
  }

  /// Scorecard & Predicted All India Rank Hero
  Widget _buildScoreHero(ResultState state, bool isMobile) {
    final res = state.result!;
    final totalMarks = (state.test?.totalMarks ?? (state.totalQuestions * 4.0)).toDouble();
    final maxScore = totalMarks > 0 ? totalMarks : 720.0;
    final score = res.finalScore;
    final scorePercent = ((score / maxScore) * 100).clamp(0.0, 100.0);

    // NEET AIR & Percentile prediction
    final ranking = _calculateNeetAirAndPercentile(score, maxScore);
    final airRank = ranking['rank']!;
    final tier = ranking['tier']!;
    final percentile = ranking['percentile']!;
    final isQualified = (score / maxScore) >= 0.50 || score >= 137;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.shadowLg,
      ),
      child: Column(
        children: [
          // Top official badge bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.military_tech_rounded, color: Colors.amberAccent, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'NEET (UG) OFFICIAL RESULT',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isQualified ? AppColors.success.withValues(alpha: 0.2) : AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isQualified ? AppColors.success.withValues(alpha: 0.5) : AppColors.warning.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isQualified ? Icons.verified_user_rounded : Icons.info_outline_rounded,
                        color: isQualified ? AppColors.success : AppColors.warning,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isQualified ? 'QUALIFIED FOR COUNSELING' : 'BELOW CUTOFF',
                        style: TextStyle(
                          color: isQualified ? AppColors.success : AppColors.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),

          // Main Hero Metrics: Score (Left) + Predicted AIR (Right)
          Padding(
            padding: EdgeInsets.all(isMobile ? 20.0 : 28.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;

                final scoreColumn = Column(
                  crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'TOTAL NEET SCORE EARNED',
                      style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${score.toInt()}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 54 : 64,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/ ${maxScore.toInt()}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Score percentage bar
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 140,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: scorePercent / 100,
                              minHeight: 8,
                              color: isQualified ? const Color(0xFF10B981) : Colors.amberAccent,
                              backgroundColor: Colors.white12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${scorePercent.toStringAsFixed(1)}% Score',
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                );

                final airRankCard = Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.workspace_premium_rounded, color: Colors.amberAccent, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'PREDICTED ALL INDIA RANK',
                                style: TextStyle(
                                  color: Colors.amberAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              percentile,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        airRank,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 26 : 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tier,
                        style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(flex: 5, child: scoreColumn),
                      const SizedBox(width: 24),
                      Expanded(flex: 5, child: airRankCard),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      scoreColumn,
                      const SizedBox(height: 20),
                      airRankCard,
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 6-KPI Detailed Performance Grid
  Widget _buildKpiMetricsGrid(ResultState state, double screenWidth) {
    final res = state.result!;
    final totalQ = state.totalQuestions > 0 ? state.totalQuestions : 1;
    final avgSecPerQ = (res.timeTakenSeconds / totalQ).round();
    final negativeMarking = (state.test?.negativeMarking ?? 1.0).toInt();
    final marksLostInNegatives = res.wrongCount * negativeMarking;

    final dur = Duration(seconds: res.timeTakenSeconds);
    final hours = dur.inHours;
    final mins = dur.inMinutes % 60;
    final timeTakenStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m ${dur.inSeconds % 60}s';

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 900 ? 6 : (screenWidth > 600 ? 3 : 2),
        mainAxisExtent: 80,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      children: [
        _kpiMetricCard('Correct (+4)', '${res.correctCount}', AppColors.success, Icons.check_circle_rounded),
        _kpiMetricCard('Incorrect (-1)', '${res.wrongCount}', AppColors.error, Icons.cancel_rounded),
        _kpiMetricCard('Skipped (0)', '${state.unattemptedCount}', AppColors.textSecondary, Icons.remove_circle_outline_rounded),
        _kpiMetricCard('Accuracy', '${res.accuracy.toStringAsFixed(1)}%', Colors.amber.shade700, Icons.pie_chart_rounded),
        _kpiMetricCard('Negative Penalty', '-$marksLostInNegatives', Colors.deepOrange, Icons.trending_down_rounded),
        _kpiMetricCard('Time Taken', timeTakenStr, AppColors.primary, Icons.timer_outlined, subtitle: '$avgSecPerQ s / Q'),
      ],
    );
  }

  Widget _kpiMetricCard(String label, String value, Color color, IconData icon, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Subject-wise Detailed Breakdown
  Widget _buildSubjectAnalysis(ResultState state, double screenWidth) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var review in state.detailedReview) {
      final subject = ExcelMcqParser.normalizeSubject(review['question'].subject);
      grouped.putIfAbsent(subject, () => []);
      grouped[subject]!.add(review);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Subject Performance Breakdown',
          subtitle: 'Section-wise score, accuracy, and negative marking analysis',
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 1),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: 145,
          ),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final entry = grouped.entries.elementAt(index);
            final correct = entry.value.where((r) => r['isCorrect'] == true).length;
            final wrong = entry.value.where((r) => r['isCorrect'] == false && r['isUnattempted'] != true).length;
            final skipped = entry.value.where((r) => r['isUnattempted'] == true).length;
            final total = entry.value.length;
            final attempted = correct + wrong;
            final accuracy = attempted > 0 ? (correct / attempted) * 100 : 0.0;
            final subjectMarks = (correct * 4) - (wrong * 1);
            final maxSubjectMarks = total * 4;

            final isHighAccuracy = accuracy >= 70;
            final isAvgAccuracy = accuracy >= 50;
            final statusColor = isHighAccuracy ? AppColors.success : (isAvgAccuracy ? AppColors.warning : AppColors.error);

            IconData subjectIcon = Icons.science_outlined;
            if (entry.key.toLowerCase().contains('phys')) {
              subjectIcon = Icons.electric_bolt_rounded;
            } else if (entry.key.toLowerCase().contains('chem')) {
              subjectIcon = Icons.biotech_rounded;
            } else if (entry.key.toLowerCase().contains('bio') || entry.key.toLowerCase().contains('bot') || entry.key.toLowerCase().contains('zoo')) {
              subjectIcon = Icons.eco_rounded;
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.shadowSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(subjectIcon, color: statusColor, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$subjectMarks / $maxSubjectMarks M',
                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Accuracy: ${accuracy.toStringAsFixed(0)}%',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                          ),
                          Text(
                            '$correct Correct  •  $wrong Wrong',
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total > 0 ? (correct / total) : 0,
                          minHeight: 6,
                          color: statusColor,
                          backgroundColor: AppColors.surfaceSubtle,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$attempted / $total Attempted',
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '$skipped Skipped',
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Action Row
  Widget _buildActionRow(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          ElevatedButton.icon(
            onPressed: () => context.go('/dashboard'),
            icon: const Icon(Icons.home_rounded, size: 18),
            label: const Text('Dashboard'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => context.push('/daily-test'),
            icon: const Icon(Icons.today_rounded, size: 18),
            label: const Text('Daily Live Test'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => triggerPlatformPrint(),
            icon: const Icon(Icons.print_rounded, size: 18),
            label: const Text('Print / PDF'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _copyScoreSummary(context),
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copy Scorecard'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Detailed Question Review Section
  Widget _buildReviewSection(ResultState state, bool isMobile) {
    final res = state.result!;
    final filtered = state.detailedReview.where((r) {
      if (_reviewFilter == 'correct') return r['isCorrect'] == true;
      if (_reviewFilter == 'wrong') return r['isCorrect'] == false && r['isUnattempted'] != true;
      if (_reviewFilter == 'unattempted') return r['isUnattempted'] == true;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Detailed Question Paper Review',
          subtitle: 'Verify your answers against official NTA answer keys with +4 / -1 marking analysis',
        ),

        // Filter Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('all', 'All Questions (${state.detailedReview.length})'),
              const SizedBox(width: 8),
              _filterChip('correct', 'Correct (+4) • ${res.correctCount}', AppColors.success),
              const SizedBox(width: 8),
              _filterChip('wrong', 'Incorrect (-1) • ${res.wrongCount}', AppColors.error),
              const SizedBox(width: 8),
              _filterChip('unattempted', 'Skipped (0) • ${state.unattemptedCount}', AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Question Cards List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final review = filtered[index];
            final q = review['question'];
            final isCorrect = review['isCorrect'] == true;
            final isUnattempted = review['isUnattempted'] == true;
            final selected = review['selectedAnswer'];

            final statusColor = isUnattempted ? AppColors.textMuted : (isCorrect ? AppColors.success : AppColors.error);
            final statusIcon = isUnattempted ? Icons.remove_rounded : (isCorrect ? Icons.check_rounded : Icons.close_rounded);
            final marksText = isUnattempted ? '0 Marks' : (isCorrect ? '+${q.marks.toInt()} Marks' : '-${q.negativeMarks.toInt()} Marks');

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.shadowSm,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  child: Icon(statusIcon, color: statusColor, size: 16),
                ),
                title: Text(
                  q.questionText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
                ),
                subtitle: Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      q.subject ?? 'General',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    Text('•', style: TextStyle(color: AppColors.textMuted)),
                    Text(
                      isUnattempted ? 'Skipped' : (isCorrect ? 'Correct' : 'Incorrect (Selected: Option $selected)'),
                      style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    marksText,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.questionText,
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.5, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 18),
                        _optionResultTile('A', q.optionA, q.correctAnswer == 'A', selected == 'A', isMobile),
                        const SizedBox(height: 8),
                        _optionResultTile('B', q.optionB, q.correctAnswer == 'B', selected == 'B', isMobile),
                        const SizedBox(height: 8),
                        _optionResultTile('C', q.optionC, q.correctAnswer == 'C', selected == 'C', isMobile),
                        const SizedBox(height: 8),
                        _optionResultTile('D', q.optionD, q.correctAnswer == 'D', selected == 'D', isMobile),
                        const SizedBox(height: 12),
                        // Answer key confirmation box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.key_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Official Answer Key: Option ${q.correctAnswer}  |  Marks: +${q.marks.toInt()} for correct, -${q.negativeMarks.toInt()} for incorrect',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _filterChip(String key, String label, [Color? color]) {
    final isSelected = _reviewFilter == key;
    final chipColor = color ?? AppColors.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _reviewFilter = key),
      showCheckmark: false,
      selectedColor: chipColor.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        color: isSelected ? chipColor : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
    );
  }

  Widget _optionResultTile(String key, String text, bool isCorrect, bool isSelected, bool isMobile) {
    Color bg = AppColors.surface;
    Color border = AppColors.border;
    Color fg = AppColors.textPrimary;
    Widget? trailingBadge;

    if (isCorrect) {
      bg = AppColors.successLight;
      border = AppColors.successBorder;
      fg = const Color(0xFF065F46);
      trailingBadge = const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
          SizedBox(width: 4),
          Text('Correct Answer', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      );
    } else if (isSelected) {
      bg = AppColors.errorLight;
      border = AppColors.errorBorder;
      fg = const Color(0xFF991B1B);
      trailingBadge = const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cancel_rounded, color: AppColors.error, size: 16),
          SizedBox(width: 4),
          Text('Your Selection', style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: isCorrect || isSelected ? 1.5 : 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isCorrect ? AppColors.success : (isSelected ? AppColors.error : AppColors.surfaceSubtle),
            child: Text(
              key,
              style: TextStyle(
                fontSize: 11,
                color: (isCorrect || isSelected) ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isCorrect || isSelected ? FontWeight.w600 : FontWeight.w400,
                color: fg,
              ),
            ),
          ),
          if (trailingBadge != null && !isMobile) ...[
            const SizedBox(width: 8),
            trailingBadge,
          ],
        ],
      ),
    );
  }

  void _copyScoreSummary(BuildContext context) {
    final state = _viewModel.state;
    final res = state.result;
    if (res == null) return;

    final auth = sl.isRegistered<AuthService>() ? sl<AuthService>() : null;
    final candidateName = auth?.currentUser?.displayName ?? 'NEET Aspirant';
    final totalMarks = (state.test?.totalMarks ?? (state.totalQuestions * 4.0)).toInt();
    final ranking = _calculateNeetAirAndPercentile(res.finalScore, totalMarks.toDouble());

    final summary = '''
🏆 NEET (UG) OFFICIAL SCORECARD
Candidate: $candidateName
Examination: ${state.test?.name ?? 'Mock Test'}
Score: ${res.finalScore.toInt()} / $totalMarks
Predicted AIR: ${ranking['rank']}
Percentile: ${ranking['percentile']}
College Prospect: ${ranking['tier']}
Accuracy: ${res.accuracy.toStringAsFixed(1)}%
Correct: ${res.correctCount} | Wrong: ${res.wrongCount} | Skipped: ${state.unattemptedCount}
''';

    Clipboard.setData(ClipboardData(text: summary));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scorecard summary copied to clipboard!'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Map<String, String> _calculateNeetAirAndPercentile(double score, double maxScore) {
    if (maxScore <= 0) maxScore = 720;
    final scaled = (score / maxScore) * 720;

    if (scaled >= 710) {
      return {
        'rank': 'AIR 1 - 100',
        'tier': 'AIIMS New Delhi / Top Central GMCs',
        'percentile': '99.98 %ile',
      };
    } else if (scaled >= 680) {
      return {
        'rank': 'AIR 100 - 1,200',
        'tier': 'Central GMCs (MAMC, VMMC, IMS-BHU)',
        'percentile': '99.80 %ile',
      };
    } else if (scaled >= 650) {
      return {
        'rank': 'AIR 1,200 - 4,500',
        'tier': 'Top State Govt Medical College (MBBS)',
        'percentile': '99.20 %ile',
      };
    } else if (scaled >= 615) {
      return {
        'rank': 'AIR 4,500 - 16,000',
        'tier': 'State Govt Medical College (MBBS)',
        'percentile': '97.80 %ile',
      };
    } else if (scaled >= 580) {
      return {
        'rank': 'AIR 16,000 - 35,000',
        'tier': 'Semi-Govt MBBS / Govt Dental (BDS)',
        'percentile': '94.50 %ile',
      };
    } else if (scaled >= 500) {
      return {
        'rank': 'AIR 35,000 - 85,000',
        'tier': 'Private Medical College MBBS / BAMS / BHMS',
        'percentile': '86.00 %ile',
      };
    } else if (scaled >= 400) {
      return {
        'rank': 'AIR 85,000 - 1,80,000',
        'tier': 'BDS / BAMS / Veterinary / Allied Sciences',
        'percentile': '72.00 %ile',
      };
    } else {
      final p = ((scaled / 720) * 70).clamp(5.0, 68.0).toStringAsFixed(1);
      return {
        'rank': 'AIR > 1,80,000',
        'tier': 'Needs Focused Strategy & Revision',
        'percentile': '$p %ile',
      };
    }
  }
}
