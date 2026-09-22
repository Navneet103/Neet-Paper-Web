import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
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
        title: const Text('Test Result'),
        leading: IconButton(
          icon: const Icon(Icons.home_rounded),
          tooltip: 'Return to Dashboard',
          onPressed: () => context.go('/dashboard'),
        ),
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
              maxWidth: 960,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score Card Hero
                  _buildScoreHero(state, isMobile),
                  const SizedBox(height: 28),

                  // Subject Breakdown
                  _buildSubjectAnalysis(state, screenWidth),
                  const SizedBox(height: 28),

                  // Quick Action Buttons
                  _buildActionRow(context, isMobile),
                  const SizedBox(height: 36),

                  // Detailed Question Review Section
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

  Widget _buildScoreHero(ResultState state, bool isMobile) {
    final res = state.result!;
    final accuracy = res.accuracy;
    final isGood = accuracy >= 70;
    final isAvg = accuracy >= 50;
    final badgeColor = isGood ? AppColors.success : (isAvg ? AppColors.warning : AppColors.error);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.shadowLg,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.military_tech_rounded, color: Colors.amberAccent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      isMobile ? 'SCORECARD' : 'OFFICIAL SCORECARD', 
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    isMobile ? (isGood ? 'Excellent' : 'Needs Practice') : (isGood ? 'Excellent Performance' : (isAvg ? 'Average Score' : 'Needs Practice')),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'TOTAL SCORE',
            style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${res.finalScore.toInt()}',
              style: TextStyle(color: Colors.white, fontSize: isMobile ? 52 : 64, fontWeight: FontWeight.w800, letterSpacing: -1),
            ),
          ),
          const SizedBox(height: 24),
          
          // Responsive Stats Row/Grid
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 450) {
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 56, // Increased height for better fit
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  children: [
                    _scoreStat('Correct', '${res.correctCount}', const Color(0xFF34D399), Icons.check_circle_rounded),
                    _scoreStat('Incorrect', '${res.wrongCount}', const Color(0xFFF87171), Icons.cancel_rounded),
                    _scoreStat('Skipped', '${state.unattemptedCount}', Colors.white70, Icons.remove_circle_outline_rounded),
                    _scoreStat('Accuracy', '${res.accuracy.toStringAsFixed(0)}%', Colors.amberAccent, Icons.pie_chart_rounded),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _scoreStat('Correct', '${res.correctCount}', const Color(0xFF34D399), Icons.check_circle_rounded),
                  _scoreStat('Incorrect', '${res.wrongCount}', const Color(0xFFF87171), Icons.cancel_rounded),
                  _scoreStat('Skipped', '${state.unattemptedCount}', Colors.white70, Icons.remove_circle_outline_rounded),
                  _scoreStat('Accuracy', '${res.accuracy.toStringAsFixed(1)}%', Colors.amberAccent, Icons.pie_chart_rounded),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _scoreStat(String label, String value, Color color, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label, 
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500)
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildSubjectAnalysis(ResultState state, double screenWidth) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var review in state.detailedReview) {
      final subject = review['question'].subject ?? 'General';
      grouped.putIfAbsent(subject, () => []);
      grouped[subject]!.add(review);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Subject Breakdown',
          subtitle: 'Detailed accuracy and score analysis by syllabus subjects',
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 1),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 110,
          ),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final entry = grouped.entries.elementAt(index);
            final correct = entry.value.where((r) => r['isCorrect'] == true).length;
            final total = entry.value.length;
            final accuracy = total > 0 ? (correct / total) * 100 : 0.0;

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ),
                      AppBadge(
                        text: '${accuracy.toStringAsFixed(0)}%',
                        backgroundColor: accuracy >= 60 ? AppColors.successLight : AppColors.errorLight,
                        textColor: accuracy >= 60 ? AppColors.success : AppColors.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total > 0 ? (correct / total) : 0,
                      minHeight: 6,
                      color: accuracy >= 60 ? AppColors.success : AppColors.warning,
                      backgroundColor: AppColors.surfaceSubtle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$correct / $total Correct',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

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
          _ActionButton(
            onPressed: () => context.go('/dashboard'),
            icon: Icons.home_rounded,
            label: 'Home',
            isPrimary: true,
          ),
          _ActionButton(
            onPressed: () => context.push('/analytics'),
            icon: Icons.insights_rounded,
            label: 'Analytics',
          ),
          _ActionButton(
            onPressed: () => context.push('/history'),
            icon: Icons.history_rounded,
            label: 'History',
          ),
        ],
      ),
    );
  }

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
          title: 'Review Questions',
          subtitle: 'Analyze correct and incorrect responses',
        ),
        
        // Filter Scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('all', 'All (${state.detailedReview.length})'),
              const SizedBox(width: 8),
              _filterChip('correct', 'Correct (${res.correctCount})', AppColors.success),
              const SizedBox(width: 8),
              _filterChip('wrong', 'Incorrect (${res.wrongCount})', AppColors.error),
              const SizedBox(width: 8),
              _filterChip('unattempted', 'Skipped (${state.unattemptedCount})', AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Review List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final review = filtered[index];
            final q = review['question'];
            final isCorrect = review['isCorrect'] == true;
            final isUnattempted = review['isUnattempted'] == true;

            final statusColor = isUnattempted ? AppColors.textMuted : (isCorrect ? AppColors.success : AppColors.error);
            final statusIcon = isUnattempted ? Icons.remove_rounded : (isCorrect ? Icons.check_rounded : Icons.close_rounded);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.shadowSm,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                subtitle: Text(
                  '${q.subject} | ${isUnattempted ? "Not Attempted" : isCorrect ? "Correct" : "Incorrect"}',
                  style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w500),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.questionText,
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        _optionResultTile('A', q.optionA, q.correctAnswer == 'A', review['selectedAnswer'] == 'A', isMobile),
                        const SizedBox(height: 8),
                        _optionResultTile('B', q.optionB, q.correctAnswer == 'B', review['selectedAnswer'] == 'B', isMobile),
                        const SizedBox(height: 8),
                        _optionResultTile('C', q.optionC, q.correctAnswer == 'C', review['selectedAnswer'] == 'C', isMobile),
                        const SizedBox(height: 8),
                        _optionResultTile('D', q.optionD, q.correctAnswer == 'D', review['selectedAnswer'] == 'D', isMobile),
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

    if (isCorrect) {
      bg = AppColors.successLight;
      border = AppColors.successBorder;
      fg = const Color(0xFF065F46);
    } else if (isSelected) {
      bg = AppColors.errorLight;
      border = AppColors.errorBorder;
      fg = const Color(0xFF991B1B);
    }

    return Container(
      padding: const EdgeInsets.all(12),
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
            child: Text(key, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isCorrect || isSelected ? FontWeight.w600 : FontWeight.w400,
                color: fg,
              ),
            ),
          ),
          if (isCorrect && !isMobile) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isPrimary 
      ? ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14))
      : OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14));

    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: style,
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: style,
    );
  }
}
