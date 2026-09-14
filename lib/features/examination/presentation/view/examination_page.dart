import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../injection/injection_container.dart';
import '../view_model/examination_view_model.dart';

class ExaminationPage extends StatefulWidget {
  final int testId;
  final List<Question> questions;

  const ExaminationPage({
    super.key,
    required this.testId,
    required this.questions,
  });

  @override
  State<ExaminationPage> createState() => _ExaminationPageState();
}

class _ExaminationPageState extends State<ExaminationPage> {
  late ExaminationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ExaminationViewModel>();
    _viewModel.loadTest(widget.testId, widget.questions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_viewModel.state.test?.name ?? 'Examination'),
        automaticallyImplyLeading: false,
        actions: [
          _buildTimer(),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _confirmSubmit,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('SUBMIT'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;

          if (state.status == ExamStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ExamStatus.completed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/result/${widget.testId}');
            });
            return const Center(child: Text('Test Submitted. Redirecting...'));
          }

          if (state.questions.isEmpty) {
            return const Center(child: Text('No questions available for this test.'));
          }

          return Row(
            children: [
              Expanded(flex: 3, child: _buildQuestionArea(state)),
              const VerticalDivider(width: 1),
              Expanded(flex: 1, child: _buildQuestionPalette(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimer() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final seconds = _viewModel.state.remainingSeconds;
        final duration = Duration(seconds: seconds);
        final timeStr = "${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
        
        return Center(
          child: Text(
            timeStr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: seconds < 300 ? Colors.red : Colors.blue,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionArea(ExaminationState state) {
    final question = state.questions[state.currentQuestionIndex];
    final selectedOption = state.answers[question.id];

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${state.currentQuestionIndex + 1} of ${state.questions.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Text(
            question.questionText,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          _buildOptionTile('A', question.optionA, selectedOption == 'A'),
          _buildOptionTile('B', question.optionB, selectedOption == 'B'),
          _buildOptionTile('C', question.optionC, selectedOption == 'C'),
          _buildOptionTile('D', question.optionD, selectedOption == 'D'),
          const Spacer(),
          _buildNavigationButtons(state),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String key, String text, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _viewModel.selectAnswer(key),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!, width: isSelected ? 2 : 1),
            color: isSelected ? Colors.blue.withOpacity(0.05) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
                child: Text(key, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 14)),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 18))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(ExaminationState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: state.currentQuestionIndex > 0 ? _viewModel.previousQuestion : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('PREVIOUS'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: state.currentQuestionIndex < state.questions.length - 1 ? _viewModel.nextQuestion : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('SAVE & NEXT'),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: _viewModel.toggleMarkForReview,
          icon: Icon(
            state.markedForReview.contains(state.questions[state.currentQuestionIndex].id)
                ? Icons.bookmark
                : Icons.bookmark_border,
            color: Colors.orange,
          ),
          label: const Text('MARK FOR REVIEW', style: TextStyle(color: Colors.orange)),
        ),
      ],
    );
  }

  Widget _buildQuestionPalette(ExaminationState state) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.blue[800],
            child: const Text('Question Palette', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: state.questions.length,
              itemBuilder: (context, index) {
                final qId = state.questions[index].id;
                final isAnswered = state.answers.containsKey(qId) && state.answers[qId] != null;
                final isMarked = state.markedForReview.contains(qId);
                final isCurrent = state.currentQuestionIndex == index;

                Color bgColor = Colors.white;
                Color textColor = Colors.black;
                if (isMarked) {
                  bgColor = Colors.orange;
                  textColor = Colors.white;
                } else if (isAnswered) {
                  bgColor = Colors.green;
                  textColor = Colors.white;
                }

                return InkWell(
                  onTap: () => _viewModel.jumpToQuestion(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border.all(color: isCurrent ? Colors.blue : Colors.grey[300]!, width: isCurrent ? 3 : 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text('${index + 1}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _legendItem(Colors.green, 'Answered'),
          _legendItem(Colors.orange, 'Marked'),
          _legendItem(Colors.white, 'Not Answered'),
          _legendItem(Colors.blue, 'Current', isBorder: true),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, {bool isBorder = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isBorder ? Colors.white : color,
              border: isBorder ? Border.all(color: color, width: 2) : Border.all(color: Colors.grey[300]!),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _confirmSubmit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Test?'),
        content: Text('Are you sure you want to submit? \nAttempted: ${_viewModel.state.answers.length} / ${_viewModel.state.questions.length}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.submitTest();
            },
            child: const Text('SUBMIT'),
          ),
        ],
      ),
    );
  }
}
