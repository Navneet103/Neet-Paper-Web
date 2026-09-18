import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../injection/injection_container.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Import Questions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/bank'),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;

          if (state.status == ImportStatus.success) {
            return _buildSuccessState();
          }

          return SingleChildScrollView(
            child: AppPageContainer(
              maxWidth: 880,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(
                    title: 'Upload Question Paper',
                    subtitle: 'Bulk import multiple choice questions into your offline local bank',
                  ),
                  const SizedBox(height: 8),

                  if (state.status == ImportStatus.error) ...[
                    _buildErrorBanner(state.errorMessage ?? 'An error occurred while reading the file.'),
                    const SizedBox(height: 16),
                  ],

                  // Upload Dropzone Card
                  _buildUploadDropzone(state),
                  const SizedBox(height: 28),

                  // Import Preview Stats
                  if (state.status == ImportStatus.ready || state.status == ImportStatus.importing) ...[
                    _buildPreviewStats(state),
                    const SizedBox(height: 28),
                  ],

                  // Error List (if any)
                  if (state.errors.isNotEmpty) ...[
                    _buildErrorList(state.errors),
                    const SizedBox(height: 28),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.errorBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13.5, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.error),
            onPressed: () => _viewModel.reset(),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadDropzone(QuestionImportState state) {
    final isBusy = state.status == ImportStatus.parsing ||
        state.status == ImportStatus.validating ||
        state.status == ImportStatus.importing;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_upload_rounded, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 20),
          const Text(
            'Upload Question Spreadsheet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3),
          ),
          const SizedBox(height: 8),
          const Text(
            'Supports Excel (.xlsx) and CSV files. Standard MCQ format auto-detected.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              AppBadge(text: 'Question', backgroundColor: AppColors.surfaceSubtle, textColor: AppColors.textSecondary),
              AppBadge(text: 'Option A-D', backgroundColor: AppColors.surfaceSubtle, textColor: AppColors.textSecondary),
              AppBadge(text: 'Answer (Key)', backgroundColor: AppColors.surfaceSubtle, textColor: AppColors.textSecondary),
              AppBadge(text: 'Subject', backgroundColor: AppColors.surfaceSubtle, textColor: AppColors.textSecondary),
              AppBadge(text: 'Topic', backgroundColor: AppColors.surfaceSubtle, textColor: AppColors.textSecondary),
              AppBadge(text: 'Marks / Neg', backgroundColor: AppColors.surfaceSubtle, textColor: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 28),
          if (isBusy) ...[
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 14),
            Text(
              state.status == ImportStatus.parsing
                  ? 'Parsing spreadsheet tables...'
                  : state.status == ImportStatus.validating
                      ? 'Validating MCQ columns and checking duplicates...'
                      : 'Saving questions into offline database...',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.file_open_rounded, size: 18),
              label: const Text('Select File from Device'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewStats(QuestionImportState state) {
    final invalidCount = (state.totalCount - state.validCount).clamp(0, state.totalCount);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Import Validation Summary',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              AppBadge(
                text: '${state.validCount} Ready',
                backgroundColor: AppColors.successLight,
                textColor: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              return isNarrow
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _miniStat('Total Rows', '${state.totalCount}', AppColors.info, AppColors.infoLight)),
                            const SizedBox(width: 12),
                            Expanded(child: _miniStat('Valid MCQs', '${state.validCount}', AppColors.success, AppColors.successLight)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _miniStat('Duplicates', '${state.duplicateCount}', AppColors.warning, AppColors.warningLight)),
                            const SizedBox(width: 12),
                            Expanded(child: _miniStat('Invalid', '$invalidCount', AppColors.error, AppColors.errorLight)),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _miniStat('Total Rows', '${state.totalCount}', AppColors.info, AppColors.infoLight)),
                        const SizedBox(width: 12),
                        Expanded(child: _miniStat('Valid MCQs', '${state.validCount}', AppColors.success, AppColors.successLight)),
                        const SizedBox(width: 12),
                        Expanded(child: _miniStat('Duplicates', '${state.duplicateCount}', AppColors.warning, AppColors.warningLight)),
                        const SizedBox(width: 12),
                        Expanded(child: _miniStat('Invalid', '$invalidCount', AppColors.error, AppColors.errorLight)),
                      ],
                    );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: state.validCount > 0 && state.status != ImportStatus.importing
                  ? () => _viewModel.importQuestions()
                  : null,
              icon: state.status == ImportStatus.importing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_circle_rounded, size: 20),
              label: Text(
                state.status == ImportStatus.importing
                    ? 'Saving into Database...'
                    : 'Confirm & Import ${state.validCount} Questions',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _buildErrorList(List<String> errors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Non-Importable Rows (${errors.length})',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: errors.length > 50 ? 50 : errors.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.close_rounded, color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(errors[index], style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.shadowMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 40, color: AppColors.success),
              ),
              const SizedBox(height: 24),
              const Text(
                'Questions Successfully Imported!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.4),
              ),
              const SizedBox(height: 8),
              const Text(
                'The question bank has been updated in your local offline database. You can now generate custom mock tests.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/bank'),
                  icon: const Icon(Icons.library_books_rounded, size: 18),
                  label: const Text('View Question Bank'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _viewModel.reset(),
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text('Upload Another File'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Return to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
        withData: true,
      );
      if (result != null && result.files.first.bytes != null) {
        _viewModel.handleFileSelection(result.files.first.bytes!);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }
}
