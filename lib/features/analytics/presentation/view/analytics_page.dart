import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../injection/injection_container.dart';
import '../view_model/analytics_view_model.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late AnalyticsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<AnalyticsViewModel>();
    _viewModel.loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // Consistent with sidebar breakpoint

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: isMobile ? null : IconButton(
          icon: const Icon(Icons.dashboard_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final hasData = state.globalStats.isNotEmpty && (state.globalStats['totalTests'] ?? 0) > 0;
          if (!hasData) {
            return AppEmptyState(
              icon: Icons.insights_rounded,
              title: 'No Data Yet',
              message: 'Take a mock test to see your performance metrics, subject proficiency, and accuracy diagnostics.',
              actionLabel: 'Start Mock Test',
              onAction: () => context.push('/create-test').then((_) => _viewModel.loadAnalytics()),
            );
          }

          return SingleChildScrollView(
            child: AppPageContainer(
              maxWidth: 1000,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(
                    title: 'Performance Summary',
                    subtitle: 'Aggregated analytics across all attempted papers',
                  ),
                  _buildOverviewMetrics(state.globalStats, screenWidth),
                  const SizedBox(height: 32),

                  // Subject-wise Accuracy Chart
                  _buildSubjectChartCard(state.subjectStats, isMobile),
                  const SizedBox(height: 32),

                  // Weak Topics Diagnostic
                  _buildWeakTopicsCard(state.topicStats, isMobile),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewMetrics(Map<String, dynamic> stats, double screenWidth) {
    final totalTests = stats['totalTests'] ?? 0;
    final avgScore = ((stats['averageScore'] ?? 0) as num).toDouble();
    final avgAccuracy = ((stats['averageAccuracy'] ?? 0) as num).toDouble();

    final metrics = [
      AppMetricCard(
        title: 'Tests Attempted',
        value: '$totalTests',
        subtitle: 'Completed papers',
        icon: Icons.task_alt_rounded,
        color: AppColors.primary,
      ),
      AppMetricCard(
        title: 'Average Score',
        value: avgScore.toStringAsFixed(0),
        subtitle: 'Points per test',
        icon: Icons.score_rounded,
        color: const Color(0xFF8B5CF6),
      ),
      AppMetricCard(
        title: 'Overall Accuracy',
        value: '${avgAccuracy.toStringAsFixed(1)}%',
        subtitle: avgAccuracy >= 60 ? 'Good' : 'Needs improvement',
        icon: Icons.pie_chart_rounded,
        color: avgAccuracy >= 60 ? AppColors.success : AppColors.warning,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 1),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 130, // Use mainAxisExtent for predictable card height
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) => metrics[index],
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
            'Proficiency across syllabus domains',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 240,
            child: subjectStats.isEmpty
                ? const Center(child: Text('No subject data'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(enabled: true),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (val) => FlLine(color: AppColors.border, strokeWidth: 1),
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

  Widget _buildWeakTopicsCard(List<Map<String, dynamic>> topicStats, bool isMobile) {
    final weakTopics = topicStats.where((t) => (t['accuracy'] as num) < 60).toList();

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
              const Icon(Icons.analytics_rounded, color: AppColors.error, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Critical Improvement Areas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (weakTopics.isEmpty)
            const AppBadge(text: 'All topics are above 60% accuracy! Well done.', backgroundColor: AppColors.successLight, textColor: AppColors.success)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weakTopics.length,
              itemBuilder: (context, index) {
                final topic = weakTopics[index];
                final accuracy = (topic['accuracy'] as num).toDouble();
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        child: Text('${accuracy.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.error)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          topic['topic'].toString(),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (!isMobile) const AppBadge(text: 'REVISION NEEDED', backgroundColor: AppColors.errorLight, textColor: AppColors.error),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
