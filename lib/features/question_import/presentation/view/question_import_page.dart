import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neet_paper_test/injection/injection_container.dart';
import '../view_model/question_import_view_model.dart';

class QuestionImportPage extends StatefulWidget {
  const QuestionImportPage({super.key});

  @override
  State<QuestionImportPage> createState() => _QuestionImportPageState();
}

class _QuestionImportPageState extends State<QuestionImportPage> {
  late QuestionImportViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<QuestionImportViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Question Bank')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;

          if (state.status == ImportStatus.success) {
            return _buildSuccessState();
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status == ImportStatus.error)
                  _buildErrorBanner(state.errorMessage ?? 'Unknown error occurred'),
                _buildUploadSection(state),
                const SizedBox(height: 32),
                if (state.status == ImportStatus.ready || state.status == ImportStatus.importing)
                  _buildStatsSection(state),
                if (state.errors.isNotEmpty) _buildErrorList(state.errors),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
          IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.red), onPressed: () => _viewModel.reset()),
        ],
      ),
    );
  }

  Widget _buildUploadSection(QuestionImportState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.upload_file, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              const Text('Upload Excel (.xlsx) or CSV file', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Format: Question, Option A-D, Correct Answer, Marks, Subject, Topic'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: state.status == ImportStatus.importing || state.status == ImportStatus.parsing || state.status == ImportStatus.validating ? null : _pickFile,
                icon: const Icon(Icons.search),
                label: const Text('Select File'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              ),
              if (state.status == ImportStatus.parsing || state.status == ImportStatus.validating)
                const Padding(padding: EdgeInsets.only(top: 16.0), child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(QuestionImportState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Import Preview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            _statCard('Total Rows', state.totalCount.toString(), Colors.blue),
            _statCard('Valid Questions', state.validCount.toString(), Colors.green),
            _statCard('Invalid/Empty', (state.totalCount - state.validCount).toString(), Colors.red),
            _statCard('Duplicates', state.duplicateCount.toString(), Colors.orange),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: state.validCount > 0 && state.status != ImportStatus.importing ? () => _viewModel.importQuestions() : null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: state.status == ImportStatus.importing 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text('IMPORT VALID QUESTIONS'),
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorList(List<String> errors) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('Errors Found (Non-Importable Rows):', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: errors.length > 50 ? 50 : errors.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.error_outline, color: Colors.red),
                title: Text(errors[index], style: const TextStyle(fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 100, color: Colors.green),
          const SizedBox(height: 24),
          const Text('Import Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: () => _viewModel.reset(), child: const Text('Upload More')),
          const SizedBox(height: 16),
          TextButton(onPressed: () => context.go('/bank'), child: const Text('Go to Question Bank')),
          TextButton(onPressed: () => context.go('/dashboard'), child: const Text('Back to Dashboard')),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'csv'], withData: true);
      if (result != null && result.files.first.bytes != null) {
        _viewModel.handleFileSelection(result.files.first.bytes!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }
}
