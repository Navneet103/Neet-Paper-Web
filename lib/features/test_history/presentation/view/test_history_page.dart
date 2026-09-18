import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../injection/injection_container.dart';
import '../view_model/test_history_view_model.dart';

class TestHistoryPage extends StatefulWidget {
  const TestHistoryPage({super.key});

  @override
  State<TestHistoryPage> createState() => _TestHistoryPageState();
}

class _TestHistoryPageState extends State<TestHistoryPage> {
  late TestHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<TestHistoryViewModel>();
    _viewModel.loadHistory();
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Recent';
    try {
      final d = DateTime.parse(date.toString());
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} at ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return date.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // Match global breakpoint

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Test History'),
        actions: isMobile 
          ? [
              IconButton(
                icon: const Icon(Icons.add_task_rounded),
                onPressed: () => context.push('/create-test').then((_) => _viewModel.loadHistory()),
              ),
              const SizedBox(width: 8),
            ]
          : [
              ElevatedButton.icon(
                onPressed: () => context.push('/create-test').then((_) => _viewModel.loadHistory()),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Mock Test'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
              const SizedBox(width: 16),
            ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state.history.isEmpty) {
            return AppEmptyState(
              icon: Icons.history_toggle_off_rounded,
              title: 'No Mock Tests Found',
              message: 'Take your first full-length or speed mock test to track your scores and performance metrics.',
              actionLabel: 'Create Mock Test',
              onAction: () => context.push('/create-test').then((_) => _viewModel.loadHistory()),
            );
          }

          return SingleChildScrollView(
            child: AppPageContainer(
              maxWidth: 960,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(
                    title: 'Past Test Records',
                    subtitle: 'Review performance, score trends, and answer scripts',
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.history.length,
                    itemBuilder: (context, index) {
                      final item = state.history[index];
                      final test = item['test'];
                      final res = item['result'];
                      final accuracy = res != null ? (res.accuracy as num).toDouble() : 0.0;
                      final isCompleted = test.status == 'completed';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                            onTap: () => context.push(isCompleted ? '/result/${test.id}' : '/exam/${test.id}'),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: EdgeInsets.all(isMobile ? 16 : 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Score Badge
                                  _buildScoreBadge(res, accuracy, isMobile),
                                  const SizedBox(width: 20),
                                  
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                test.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: isMobile ? 15 : 17,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            AppBadge(
                                              text: isCompleted ? 'DONE' : 'LIVE',
                                              backgroundColor: isCompleted ? AppColors.successLight : AppColors.warningLight,
                                              textColor: isCompleted ? AppColors.success : AppColors.warning,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _formatDate(test.completedAt ?? test.createdAt),
                                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: [
                                            _miniChip(Icons.help_outline, '${test.totalQuestions} Qs'),
                                            _miniChip(Icons.timer_outlined, '${test.durationMinutes}m'),
                                            if (isCompleted && res != null) 
                                              _miniChip(Icons.pie_chart_rounded, '${accuracy.toStringAsFixed(0)}% Acc', AppColors.primary),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  if (!isMobile) ...[
                                    const SizedBox(width: 16),
                                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreBadge(dynamic res, double accuracy, bool isMobile) {
    final score = res?.finalScore?.toInt() ?? 0;
    final color = accuracy >= 60 ? AppColors.success : (accuracy >= 40 ? AppColors.warning : AppColors.primary);
    final size = isMobile ? 64.0 : 72.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '$score',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
          Text(
            'Score',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(IconData icon, String label, [Color? color]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5, 
              fontWeight: FontWeight.w600, 
              color: color ?? AppColors.textSecondary
            ),
          ),
        ],
      ),
    );
  }
}
