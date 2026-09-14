import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.dashboard),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;
          if (state.isLoading) return const Center(child: CircularProgressIndicator());
          if (state.globalStats.isEmpty || state.globalStats['totalTests'] == 0) {
            return const Center(child: Text('Complete a test to view analytics!'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverview(state.globalStats),
                const SizedBox(height: 40),
                _buildSectionHeader('Subject-wise Accuracy', Icons.subject),
                const SizedBox(height: 16),
                _buildSubjectChart(state.subjectStats),
                const SizedBox(height: 40),
                _buildSectionHeader('Weak Topics (Accuracy < 60%)', Icons.trending_down),
                const SizedBox(height: 16),
                _buildWeakTopics(state.topicStats), // Corrected property reference
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade800),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOverview(Map<String, dynamic> stats) {
    return Row(
      children: [
        _statCard('Total Tests', stats['totalTests'].toString(), Colors.blue),
        _statCard('Avg Score', (stats['averageScore'] as num).toDouble().toStringAsFixed(1), Colors.indigo),
        _statCard('Accuracy', '${(stats['averageAccuracy'] as num).toDouble().toStringAsFixed(1)}%', Colors.teal),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectChart(List<Map<String, dynamic>> subjectStats) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barGroups: subjectStats.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [BarChartRodData(toY: (e.value['accuracy'] as num).toDouble(), color: Colors.blue, width: 30, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= subjectStats.length) return const Text('');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(subjectStats[index]['subject'].toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeakTopics(List<Map<String, dynamic>> topicStats) {
    final weakTopics = topicStats.where((t) => (t['accuracy'] as num) < 60).toList();
    if (weakTopics.isEmpty) return const Text('Keep it up! No weak areas detected.');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: weakTopics.length,
      itemBuilder: (context, index) {
        final t = weakTopics[index];
        return Card(
          color: Colors.red.shade50,
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Text(t['topic'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Accuracy: ${(t['accuracy'] as num).toDouble().toStringAsFixed(1)}%'),
          ),
        );
      },
    );
  }
}
