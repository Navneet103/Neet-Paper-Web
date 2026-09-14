import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection/injection_container.dart';
import '../view_model/question_bank_view_model.dart';

class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({super.key});

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  late QuestionBankViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<QuestionBankViewModel>();
    _viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/import'),
            icon: const Icon(Icons.add),
            label: const Text('IMPORT NEW'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;
          return Column(
            children: [
              _buildSearchBar(),
              _buildFilterBar(state),
              Expanded(
                child: state.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _buildQuestionList(state),
              ),
              _buildPagination(state),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-test'),
        label: const Text('CREATE TEST'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search questions...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => _viewModel.updateSearch(value),
      ),
    );
  }

  Widget _buildFilterBar(QuestionBankState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All Subjects'),
            selected: state.selectedSubject == null,
            onSelected: (_) => _viewModel.updateSubject(null),
          ),
          const SizedBox(width: 8),
          ...state.subjects.map((s) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(s),
              selected: state.selectedSubject == s,
              onSelected: (_) => _viewModel.updateSubject(s),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildQuestionList(QuestionBankState state) {
    if (state.questions.isEmpty) {
      return const Center(child: Text('No questions found. Import some first!'));
    }
    return ListView.builder(
      itemCount: state.questions.length,
      itemBuilder: (context, index) {
        final q = state.questions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text(q.questionText, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text('${q.subject} | ${q.topic}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _optionText('A', q.optionA, q.correctAnswer == 'A'),
                    _optionText('B', q.optionB, q.correctAnswer == 'B'),
                    _optionText('C', q.optionC, q.correctAnswer == 'C'),
                    _optionText('D', q.optionD, q.correctAnswer == 'D'),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _optionText(String key, String text, bool isCorrect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isCorrect ? Colors.green : Colors.grey[300],
            child: Text(key, style: TextStyle(fontSize: 12, color: isCorrect ? Colors.white : Colors.black)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal))),
        ],
      ),
    );
  }

  Widget _buildPagination(QuestionBankState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total: ${state.totalCount}'),
          Row(
            children: [
              IconButton(onPressed: state.currentPage > 0 ? _viewModel.previousPage : null, icon: const Icon(Icons.chevron_left)),
              Text('Page ${state.currentPage + 1}'),
              IconButton(
                onPressed: (state.currentPage + 1) * state.pageSize < state.totalCount ? _viewModel.nextPage : null, 
                icon: const Icon(Icons.chevron_right)
              ),
            ],
          ),
        ],
      ),
    );
  }
}
