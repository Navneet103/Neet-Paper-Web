import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ResultViewModel>();
    _viewModel.loadResult(widget.testId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Examination Result'),
        leading: IconButton(
          icon: const Icon(Icons.dashboard),
          onPressed: () => context.go('/dashboard'),
          tooltip: 'Back to Dashboard',
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;
          if (state.status == ResultStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.result == null) {
            return const Center(child: Text('Result not found'));
          }

          final res = state.result!;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    _buildScoreOverview(res),
                    const SizedBox(height: 32),
                    _buildSubjectAnalysis(state),
                    const SizedBox(height: 32),
                    _buildActionRow(context),
                    const SizedBox(height: 48),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Question Review', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildDetailedReview(state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreOverview(dynamic res) {
    return Card(
      elevation: 4,
      color: const Color(0xFF1A237E),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            const Text('TOTAL SCORE', style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1.2)),
            Text('${res.finalScore.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('Correct', '${res.correctCount}', Colors.greenAccent),
                _statItem('Wrong', '${res.wrongCount}', Colors.redAccent),
                _statItem('Accuracy', '${res.accuracy.toStringAsFixed(1)}%', Colors.orangeAccent),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSubjectAnalysis(ResultState state) {
    // Basic subject grouping logic for the Result screen
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var review in state.detailedReview) {
      final subject = review['question'].subject ?? 'General';
      grouped.putIfAbsent(subject, () => []);
      grouped[subject]!.add(review);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Subject-wise Performance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.5,
          ),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final entry = grouped.entries.elementAt(index);
            final correct = entry.value.where((r) => r['isCorrect']).length;
            final total = entry.value.length;
            final accuracy = (correct / total) * 100;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('$correct / $total Correct', style: TextStyle(color: Colors.blue.shade700, fontSize: 13)),
                    LinearProgressIndicator(value: correct / total, color: Colors.blue, backgroundColor: Colors.blue.shade50),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.home),
          label: const Text('DASHBOARD'),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20)),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () => context.push('/analytics'),
          icon: const Icon(Icons.analytics),
          label: const Text('DETAILED ANALYTICS'),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20)),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () => context.push('/history'),
          icon: const Icon(Icons.history),
          label: const Text('TEST HISTORY'),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20)),
        ),
      ],
    );
  }

  Widget _buildDetailedReview(ResultState state) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.detailedReview.length,
      itemBuilder: (context, index) {
        final review = state.detailedReview[index];
        final q = review['question'];
        final isCorrect = review['isCorrect'];
        final isUnattempted = review['isUnattempted'];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: isUnattempted ? Colors.grey : (isCorrect ? Colors.green : Colors.red),
              child: Icon(isUnattempted ? Icons.remove : (isCorrect ? Icons.check : Icons.close), color: Colors.white, size: 16),
            ),
            title: Text('Question ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(q.questionText, maxLines: 1, overflow: TextOverflow.ellipsis),
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.questionText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    _optionRow('A', q.optionA, q.correctAnswer == 'A', review['selectedAnswer'] == 'A'),
                    _optionRow('B', q.optionB, q.correctAnswer == 'B', review['selectedAnswer'] == 'B'),
                    _optionRow('C', q.optionC, q.correctAnswer == 'C', review['selectedAnswer'] == 'C'),
                    _optionRow('D', q.optionD, q.correctAnswer == 'D', review['selectedAnswer'] == 'D'),
                    const Divider(height: 32),
                    Text('Subject: ${q.subject} | Topic: ${q.topic}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _optionRow(String key, String text, bool isCorrect, bool isSelected) {
    Color textColor = Colors.black87;
    IconData? icon;
    if (isCorrect) {
      textColor = Colors.green.shade700;
      icon = Icons.check_circle;
    } else if (isSelected) {
      textColor = Colors.red.shade700;
      icon = Icons.cancel;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$key. ', style: TextStyle(fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal, color: textColor)),
          Expanded(child: Text(text, style: TextStyle(color: textColor, fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal))),
          if (icon != null) Icon(icon, color: textColor, size: 16),
        ],
      ),
    );
  }
}
