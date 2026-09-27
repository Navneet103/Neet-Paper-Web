import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../injection/injection_container.dart';
import '../../data/repository/test_generation_repository.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_test == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Paper Preview')),
        body: AppEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Test Not Found',
          message: 'The requested test could not be located in local storage.',
          actionLabel: 'Return to Dashboard',
          onAction: () => context.go('/dashboard'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isMobile ? 'Paper Preview' : 'Paper Overview & Instructions'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/create-test'),
          tooltip: 'Cancel and return',
        ),
      ),
      body: SingleChildScrollView(
        child: AppPageContainer(
          maxWidth: 860,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Test Specification Card
              _buildSpecificationCard(isMobile),
              const SizedBox(height: 24),

              // Instructions Guidelines Card
              _buildInstructionsCard(isMobile),
              const SizedBox(height: 32),

              // Subject Distribution Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isMobile ? 'Paper Structure' : 'Paper Structure & Syllabus Scope',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.4),
                  ),
                  AppBadge(
                    text: '${_questions.length} MCQs',
                    backgroundColor: AppColors.primaryLight,
                    textColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSubjectDistributionCard(isMobile),
              const SizedBox(height: 40),

              // Start Exam CTA
              _buildStartButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecificationCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'CONFIDENTIAL • MOCK EXAM',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ),
              if (!isMobile) ...[
                const Spacer(),
                const Icon(Icons.offline_bolt_rounded, color: Colors.greenAccent, size: 18),
                const SizedBox(width: 4),
                const Text('Offline Mode Enabled', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _test!.name,
            style: TextStyle(
              fontSize: isMobile ? 22 : 28, 
              fontWeight: FontWeight.w800, 
              color: Colors.white, 
              letterSpacing: -0.6
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _specItem(Icons.help_outline_rounded, '${_test!.totalQuestions}', 'Questions', isMobile),
                _specItem(Icons.timer_outlined, '${_test!.durationMinutes}m', 'Time', isMobile),
                _specItem(Icons.military_tech_outlined, '${_test!.totalMarks.toInt()}', 'Max Marks', isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specItem(IconData icon, String value, String label, bool isMobile) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: isMobile ? 14 : 16),
            const SizedBox(width: 6),
            Text(value, style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildInstructionsCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
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
            children: [
              const Icon(Icons.rule_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                isMobile ? 'Rules & Instructions' : 'Candidate Instructions & Rules',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _instructionBullet('1', 'The examination consists of multiple-choice questions with 4 options.'),
          _instructionBullet('2', 'Marking: +4 marks for Correct, -1 mark for Incorrect answers.'),
          _instructionBullet('3', 'Unattempted questions receive 0 marks (No penalty).'),
          _instructionBullet('4', 'The countdown begins immediately upon clicking start.'),
          _instructionBullet('5', 'The exam runs completely offline. Do not close the window.'),
        ],
      ),
    );
  }

  Widget _instructionBullet(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(number, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectDistributionCard(bool isMobile) {
    final Map<String, int> subjectCounts = {};
    for (final q in _questions) {
      final s = (q.subject != null && q.subject!.trim().isNotEmpty) ? q.subject!.trim() : 'General';
      subjectCounts[s] = (subjectCounts[s] ?? 0) + 1;
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_outline_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Text(
                'Subject Breakdown & Distribution',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: subjectCounts.entries.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      e.key,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${e.value} MCQs',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(Icons.lock_clock_rounded, size: 16, color: AppColors.textMuted),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Questions are secured and encrypted until exam initiation. The examination timer begins immediately upon clicking the button below.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          context.push('/exam/${widget.testId}', extra: _questions);
        },
        icon: const Icon(Icons.play_arrow_rounded, size: 28),
        label: const Text(
          'START EXAMINATION NOW',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
