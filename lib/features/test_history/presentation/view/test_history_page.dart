import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test History'),
        leading: IconButton(
          icon: const Icon(Icons.dashboard),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No tests attempted yet.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/create-test'),
                    child: const Text('CREATE YOUR FIRST TEST'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              final item = state.history[index];
              final test = item['test'];
              final res = item['result'];
              return Card(
                child: ListTile(
                  title: Text(test.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Score: ${res?.finalScore ?? 0} | Date: ${test.completedAt ?? test.createdAt}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/result/${test.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
