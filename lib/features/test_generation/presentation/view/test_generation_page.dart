import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../injection/injection_container.dart';
import '../view_model/test_generation_view_model.dart';

class TestGenerationPage extends StatefulWidget {
  const TestGenerationPage({super.key});

  @override
  State<TestGenerationPage> createState() => _TestGenerationPageState();
}

class _TestGenerationPageState extends State<TestGenerationPage> {
  late TestGenerationViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _countController;
  late TextEditingController _durationController;

  int _questionCount = 180;
  int _duration = 180;
  final double _positiveMarks = 4.0;
  final double _negativeMarks = 1.0;
  String? _selectedSubject;
  List<String> _subjects = [];

  @override
  void initState() {
    super.initState();
    _viewModel = sl<TestGenerationViewModel>();
    final defaultTitle = 'NEET Mock Paper - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    _nameController = TextEditingController(text: defaultTitle);
    _countController = TextEditingController(text: '$_questionCount');
    _durationController = TextEditingController(text: '$_duration');
    _loadSubjects();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    _durationController.dispose();
    super.dispose();
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

  void _applyPreset(String label, int questions, int minutes) {
    setState(() {
      _questionCount = questions;
      _duration = minutes;
      _countController.text = '$questions';
      _durationController.text = '$minutes';
      _nameController.text = '$label - ${DateTime.now().day}/${DateTime.now().month}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile ? null : AppBar(
        title: const Text('Create Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
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
            child: AppPageContainer(
              maxWidth: 680,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMobile) ...[
                      const SizedBox(height: 8),
                      IconButton(
                        onPressed: () => context.go('/dashboard'),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ],
                    const AppSectionHeader(
                      title: 'Configure Exam Paper',
                      subtitle: 'Set question count, time limit, and subject filter for practice',
                    ),
                    const SizedBox(height: 8),

                    // Quick Presets Row
                    _buildPresetsRow(),
                    const SizedBox(height: 24),

                    // Main Configuration Form Card
                    Container(
                      padding: EdgeInsets.all(isMobile ? 20 : 28),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppColors.shadowSm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Paper Details',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Test Name / Title',
                              hintText: 'e.g. NEET Full Syllabus Mock 1',
                              prefixIcon: Icon(Icons.title_rounded, size: 20, color: AppColors.textMuted),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a test title' : null,
                          ),
                          const SizedBox(height: 20),
                          
                          // Responsive Row/Column for inputs
                          if (isMobile) ...[
                            TextFormField(
                              controller: _countController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Questions',
                                hintText: '180',
                                prefixIcon: Icon(Icons.help_outline_rounded, size: 20, color: AppColors.textMuted),
                                suffixText: 'MCQs',
                              ),
                              onChanged: (v) => _questionCount = int.tryParse(v) ?? 180,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _durationController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Duration',
                                hintText: '180',
                                prefixIcon: Icon(Icons.timer_outlined, size: 20, color: AppColors.textMuted),
                                suffixText: 'mins',
                              ),
                              onChanged: (v) => _duration = int.tryParse(v) ?? 180,
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _countController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Questions',
                                      hintText: '180',
                                      prefixIcon: Icon(Icons.help_outline_rounded, size: 20, color: AppColors.textMuted),
                                      suffixText: 'MCQs',
                                    ),
                                    onChanged: (v) => _questionCount = int.tryParse(v) ?? 180,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _durationController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Duration',
                                      hintText: '180',
                                      prefixIcon: Icon(Icons.timer_outlined, size: 20, color: AppColors.textMuted),
                                      suffixText: 'mins',
                                    ),
                                    onChanged: (v) => _duration = int.tryParse(v) ?? 180,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: _selectedSubject,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Subject Scope',
                              prefixIcon: Icon(Icons.category_outlined, size: 20, color: AppColors.textMuted),
                            ),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Subjects (Comprehensive)')),
                              ..._subjects.map((s) => DropdownMenuItem(value: s, child: Text('$s Only'))),
                            ],
                            onChanged: (v) => setState(() => _selectedSubject = v),
                          ),
                          const SizedBox(height: 24),
                          // Rules Info Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Scoring Rule: +${_positiveMarks.toInt()} for each correct answer, -${_negativeMarks.toInt()} penalty for wrong responses. Unattempted questions award 0.',
                                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF3730A3), height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 56, // Larger touch target
                            child: ElevatedButton.icon(
                              onPressed: state.status == TestGenerationStatus.generating ? null : _generate,
                              icon: state.status == TestGenerationStatus.generating
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.play_arrow_rounded, size: 22),
                              label: Text(
                                state.status == TestGenerationStatus.generating ? 'Selecting Questions...' : 'GENERATE TEST PAPER',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Presets:',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PresetChip(
              icon: Icons.stars_rounded,
              color: AppColors.primary,
              label: 'Full NEET Mock',
              onPressed: () => _applyPreset('NEET Full Mock', 180, 180),
            ),
            _PresetChip(
              icon: Icons.flash_on_rounded,
              color: const Color(0xFFF59E0B),
              label: 'Speed Drill',
              onPressed: () => _applyPreset('Speed Drill', 45, 45),
            ),
            _PresetChip(
              icon: Icons.school_rounded,
              color: const Color(0xFF10B981),
              label: 'Mini Test',
              onPressed: () => _applyPreset('NEET Mini Test', 90, 90),
            ),
          ],
        ),
      ],
    );
  }

  void _generate() {
    if (_formKey.currentState?.validate() ?? false) {
      _viewModel.generateTest(
        name: _nameController.text.trim(),
        questionCount: _questionCount,
        durationMinutes: _duration,
        positiveMarks: _positiveMarks,
        negativeMarks: _negativeMarks,
        subject: _selectedSubject,
      );
    }
  }

  Widget _buildSuccessState(int testId) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.shadowMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 48, color: AppColors.success),
              ),
              const SizedBox(height: 24),
              const Text(
                'Test Paper Generated!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'Questions have been randomly selected from your local question bank and compiled offline.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/preview-test/$testId'),
                  icon: const Icon(Icons.remove_red_eye_rounded, size: 18),
                  label: const Text('REVIEW PAPER PREVIEW'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => _viewModel.reset(),
                  child: const Text('Configure Another Test'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onPressed;

  const _PresetChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
