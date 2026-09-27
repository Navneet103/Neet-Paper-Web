import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../firebase/firebase_test_service.dart';
import '../theme/app_theme.dart';
import '../../injection/injection_container.dart';
import 'submission_mcq_review_dialog.dart';

class CandidateAnalysisDialog extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<TestSubmission> matchingSubmissions;

  const CandidateAnalysisDialog({
    super.key,
    required this.student,
    required this.matchingSubmissions,
  });

  static void show(
    BuildContext context, {
    required Map<String, dynamic> student,
    required List<TestSubmission> matchingSubmissions,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => CandidateAnalysisDialog(
        student: student,
        matchingSubmissions: matchingSubmissions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = student['displayName'] ?? 'Aspirant';
    final email = student['email'] ?? 'No email';
    final phone = student['phone'] ?? 'N/A';
    final uid = (student['uid'] ?? student['id'] ?? '').toString();
    
    DateTime? joinedDate;
    if (student['createdAt'] is Timestamp) {
      joinedDate = (student['createdAt'] as Timestamp).toDate();
    } else if (student['createdAt'] is DateTime) {
      joinedDate = student['createdAt'] as DateTime;
    }

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: isMobile ? 16 : 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 780),
        child: StreamBuilder<List<TestSubmission>>(
          stream: sl<FirebaseTestService>().streamStudentSubmissions(uid, studentEmail: email),
          builder: (context, snapshot) {
            // Merge stream with passed submissions to guarantee data availability
            final List<TestSubmission> effectiveSubmissions;
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              effectiveSubmissions = snapshot.data!;
            } else if (matchingSubmissions.isNotEmpty) {
              effectiveSubmissions = matchingSubmissions;
            } else {
              effectiveSubmissions = snapshot.data ?? [];
            }

            final int testCount = effectiveSubmissions.length;
            final double bestScore = effectiveSubmissions.isEmpty
                ? 0.0
                : effectiveSubmissions.map((s) => s.score).reduce((a, b) => a > b ? a : b);
            final double avgAccuracy = effectiveSubmissions.isEmpty
                ? 0.0
                : (effectiveSubmissions.map((s) => s.accuracy).reduce((a, b) => a + b) / testCount);
            final int totalCorrect = effectiveSubmissions.fold(0, (acc, s) => acc + s.correctCount);
            final int totalWrong = effectiveSubmissions.fold(0, (acc, s) => acc + s.wrongCount);
            final int totalSkipped = effectiveSubmissions.fold(0, (acc, s) => acc + s.unattemptedCount);
            final int totalQuestionsEncountered = totalCorrect + totalWrong + totalSkipped;

            String statusText;
            Color statusColor;
            Color statusBg;
            if (testCount == 0) {
              statusText = 'Pending • No Tests Attempted';
              statusColor = AppColors.textMuted;
              statusBg = AppColors.surfaceSubtle;
            } else if (bestScore >= 550) {
              statusText = '🌟 Elite Ranker (Top Tier)';
              statusColor = const Color(0xFF047857);
              statusBg = const Color(0xFFD1FAE5);
            } else if (bestScore >= 380) {
              statusText = '🎯 Proficient (Good Potential)';
              statusColor = const Color(0xFF1D4ED8);
              statusBg = const Color(0xFFDBEAFE);
            } else {
              statusText = '⚠️ Needs Revision & Practice';
              statusColor = const Color(0xFFB45309);
              statusBg = const Color(0xFFFEF3C7);
            }

            return Column(
              children: [
                // Modal Header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 20),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: isMobile ? 22 : 26,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'S',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
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
                                    name,
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$email • Mobile: $phone',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (joinedDate != null)
                              Text(
                                'Enrolled: ${joinedDate.day}/${joinedDate.month}/${joinedDate.year}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),

                // Modal Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview Metric Cards
                        const Text(
                          'Performance Summary',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmall = constraints.maxWidth < 450;
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildKpiCard(
                                  title: 'Tests Taken',
                                  value: '$testCount',
                                  subtitle: 'Examinations completed',
                                  color: AppColors.primary,
                                  width: isSmall ? constraints.maxWidth : (constraints.maxWidth - 12) / 2,
                                ),
                                _buildKpiCard(
                                  title: 'Highest Score',
                                  value: testCount > 0 ? '${bestScore.toInt()} / 720' : '--',
                                  subtitle: testCount > 0 ? '${((bestScore / 720) * 100).toStringAsFixed(1)}% Marks' : 'No attempt',
                                  color: const Color(0xFF0D9488),
                                  width: isSmall ? constraints.maxWidth : (constraints.maxWidth - 12) / 2,
                                ),
                                _buildKpiCard(
                                  title: 'Average Accuracy',
                                  value: testCount > 0 ? '${avgAccuracy.toStringAsFixed(1)}%' : '--',
                                  subtitle: 'Across all mock attempts',
                                  color: const Color(0xFF8B5CF6),
                                  width: isSmall ? constraints.maxWidth : (constraints.maxWidth - 12) / 2,
                                ),
                                _buildKpiCard(
                                  title: 'Question Accuracy',
                                  value: testCount > 0 ? '+$totalCorrect / -$totalWrong' : '--',
                                  subtitle: '$totalSkipped questions skipped',
                                  color: const Color(0xFFF59E0B),
                                  width: isSmall ? constraints.maxWidth : (constraints.maxWidth - 12) / 2,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Visual Question Answer Ratio Bar
                        if (testCount > 0 && totalQuestionsEncountered > 0) ...[
                          const Text(
                            'Total Questions Response Breakdown',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 16,
                              child: Row(
                                children: [
                                  if (totalCorrect > 0)
                                    Expanded(
                                      flex: totalCorrect,
                                      child: Container(color: AppColors.success),
                                    ),
                                  if (totalWrong > 0)
                                    Expanded(
                                      flex: totalWrong,
                                      child: Container(color: AppColors.error),
                                    ),
                                  if (totalSkipped > 0)
                                    Expanded(
                                      flex: totalSkipped,
                                      child: Container(color: Colors.grey.shade300),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _legendItem(AppColors.success, 'Correct ($totalCorrect)'),
                              _legendItem(AppColors.error, 'Wrong ($totalWrong)'),
                              _legendItem(Colors.grey.shade400, 'Skipped ($totalSkipped)'),
                            ],
                          ),
                          const SizedBox(height: 28),
                        ],

                        // Submissions List
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Attempted Test Papers & Scorecards',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            Text(
                              '$testCount Records',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (effectiveSubmissions.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.assignment_late_outlined, size: 36, color: AppColors.textMuted),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'This aspirant has not attempted any mock tests yet.',
                                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'When $name submits an exam, their full score, accuracy, and MCQ answers will appear here in real-time.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: effectiveSubmissions.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, idx) {
                              final sub = effectiveSubmissions[idx];
                              final date = sub.submittedAt;
                              final dateStr = '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                              final durationMin = (sub.timeTakenSeconds / 60).ceil();

                              return Container(
                                padding: EdgeInsets.all(isMobile ? 14 : 16),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: isMobile
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryLight,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '#${idx + 1}',
                                                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  sub.testId.isNotEmpty ? sub.testId : 'NEET CBT Mock Test',
                                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: sub.score >= 500 ? AppColors.successLight : (sub.score >= 350 ? AppColors.primaryLight : AppColors.warningLight),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  '${sub.score.toInt()} / ${sub.totalMarks.toInt()}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 12.5,
                                                    color: sub.score >= 500 ? AppColors.success : (sub.score >= 350 ? AppColors.primary : AppColors.warning),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Attempted: $dateStr • Duration: $durationMin mins',
                                            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Right: +${sub.correctCount}  Wrong: -${sub.wrongCount}  (${sub.accuracy.toStringAsFixed(0)}% Accuracy)',
                                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () => SubmissionMcqReviewDialog.show(context, submission: sub),
                                              icon: const Icon(Icons.quiz_outlined, size: 15),
                                              label: const Text('VIEW SOLUTIONS & MCQs'),
                                              style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '#${idx + 1}',
                                              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sub.testId.isNotEmpty ? sub.testId : 'NEET CBT Mock Test',
                                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Attempted: $dateStr • Duration: $durationMin mins',
                                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${sub.score.toInt()} / ${sub.totalMarks.toInt()} Marks',
                                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Right: +${sub.correctCount}  Wrong: -${sub.wrongCount}  (${sub.accuracy.toStringAsFixed(0)}% Acc)',
                                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 14),
                                          ElevatedButton.icon(
                                            onPressed: () => SubmissionMcqReviewDialog.show(context, submission: sub),
                                            icon: const Icon(Icons.quiz_outlined, size: 15),
                                            label: const Text('SOLUTIONS'),
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                            ),
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
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
