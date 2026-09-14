import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection/injection_container.dart';
import '../view_model/test_generation_view_model.dart';
import '../../../../core/storage/app_database.dart';

class TestGenerationPage extends StatefulWidget {
  const TestGenerationPage({super.key});

  @override
  State<TestGenerationPage> createState() => _TestGenerationPageState();
}

class _TestGenerationPageState extends State<TestGenerationPage> {
  late TestGenerationViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  
  String _name = 'Mock Test ${DateTime.now().day}/${DateTime.now().month}';
  int _questionCount = 180;
  int _duration = 180;
  double _positiveMarks = 4.0;
  double _negativeMarks = 1.0;
  String? _selectedSubject;
  List<String> _subjects = [];

  @override
  void initState() {
    super.initState();
    _viewModel = sl<TestGenerationViewModel>();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final db = sl<AppDatabase>();
    final query = db.selectOnly(db.questions, distinct: true)..addColumns([db.questions.subject]);
    final result = await query.map((row) => row.read(db.questions.subject)).get();
    if (mounted) {
      setState(() {
        _subjects = result.whereType<String>().toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;

          if (state.status == TestGenerationStatus.success) {
            return _buildSuccessState(state.generatedTestId!);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Test Configuration', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      TextFormField(
                        initialValue: _name,
                        decoration: const InputDecoration(labelText: 'Test Title', border: OutlineInputBorder(), prefixIcon: Icon(Icons.title)),
                        onChanged: (v) => _name = v,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _questionCount.toString(),
                              decoration: const InputDecoration(labelText: 'Question Count', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => _questionCount = int.tryParse(v) ?? 180,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: _duration.toString(),
                              decoration: const InputDecoration(labelText: 'Minutes', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => _duration = int.tryParse(v) ?? 180,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedSubject,
                        decoration: const InputDecoration(labelText: 'Subject Filter (Optional)', border: OutlineInputBorder()),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Subjects')),
                          ..._subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                        ],
                        onChanged: (v) => setState(() => _selectedSubject = v),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: state.status == TestGenerationStatus.generating ? null : _generate,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                          child: state.status == TestGenerationStatus.generating 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('GENERATE PAPER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _generate() {
    _viewModel.generateTest(
      name: _name,
      questionCount: _questionCount,
      durationMinutes: _duration,
      positiveMarks: _positiveMarks,
      negativeMarks: _negativeMarks,
      subject: _selectedSubject,
    );
  }

  Widget _buildSuccessState(int testId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
          const SizedBox(height: 24),
          const Text('Test Ready!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Questions have been selected and saved offline.'),
          const SizedBox(height: 40),
          SizedBox(
            width: 250,
            height: 55,
            child: ElevatedButton(
              onPressed: () => context.push('/preview-test/$testId'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Text('REVIEW PAPER PREVIEW'),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _viewModel.reset(),
            child: const Text('Create Another Test'),
          ),
          TextButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }
}
