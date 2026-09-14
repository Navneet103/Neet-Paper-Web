import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection/injection_container.dart';
import '../../data/repository/test_generation_repository.dart';
import '../../../../core/storage/app_database.dart';

class PaperPreviewPage extends StatefulWidget {
  final int testId;
  const PaperPreviewPage({super.key, required this.testId});

  @override
  State<PaperPreviewPage> createState() => _PaperPreviewPageState();
}

class _PaperPreviewPageState extends State<PaperPreviewPage> {
  Test? _test;
  List<Question> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = sl<TestGenerationRepository>();
    final test = await repo.getTestById(widget.testId);
    final questions = await repo.getQuestionsForTest(widget.testId);
    if (mounted) {
      setState(() {
        _test = test;
        _questions = questions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_test == null) return const Scaffold(body: Center(child: Text('Test not found')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paper Preview'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/create-test'),
          tooltip: 'Cancel and return to configuration',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildInstructions(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Question Preview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Total questions: ${_questions.length}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                _buildQuestionList(),
                const SizedBox(height: 48),
                _buildStartButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.blue.shade100)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(_test!.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _headerItem(Icons.help_outline, '${_test!.totalQuestions} Questions'),
                _headerItem(Icons.timer_outlined, '${_test!.durationMinutes} Minutes'),
                _headerItem(Icons.grade_outlined, '${_test!.totalMarks.toInt()} Marks'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Exam Guidelines:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _bulletPoint('Each correct answer adds ${_test!.positiveMarking.toInt()} marks.'),
          _bulletPoint('Each wrong answer deducts ${_test!.negativeMarking.toInt()} marks.'),
          _bulletPoint('You can "Mark for Review" questions to return to them later.'),
          _bulletPoint('The timer starts the moment you click the button below.'),
          _bulletPoint('Do not refresh the browser during the exam (though your progress is saved).'),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildQuestionList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _questions.length > 5 ? 5 : _questions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            radius: 14,
            child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
          title: Text(_questions[index].questionText, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${_questions[index].subject} • ${_questions[index].topic}'),
        );
      },
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () => context.go('/exam/${widget.testId}', extra: _questions),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A73E8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: const Text('START EXAMINATION', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
    );
  }
}
