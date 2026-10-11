import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/excel_mcq_parser.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../injection/injection_container.dart';
import '../view_model/examination_view_model.dart';

class ExaminationPage extends StatefulWidget {
  final int testId;
  final List<Question> questions;
  final String? testDocId;

  const ExaminationPage({
    super.key,
    required this.testId,
    required this.questions,
    this.testDocId,
  });

  @override
  State<ExaminationPage> createState() => _ExaminationPageState();
}

class _ExaminationPageState extends State<ExaminationPage> {
  late ExaminationViewModel _viewModel;
  bool _isRedirecting = false;
  String _selectedPaletteSubject = 'ALL';

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ExaminationViewModel>();
    _viewModel.loadTest(widget.testId, widget.questions, testDocId: widget.testDocId);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final state = _viewModel.state;

        if (state.status == ExamStatus.loading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (state.status == ExamStatus.error) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.errorLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Submission Interrupted',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ?? 'An error occurred while evaluating or syncing your test.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _viewModel.loadTest(widget.testId, widget.questions, testDocId: widget.testDocId);
                            },
                            child: const Text('Back to Test'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Retry Submit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _viewModel.submitTest(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state.status == ExamStatus.completed || state.status == ExamStatus.submitting) {
          if (state.status == ExamStatus.completed && !_isRedirecting) {
            _isRedirecting = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.go('/result/${widget.testId}');
              }
            });
          }
          final isCompleted = state.status == ExamStatus.completed;

          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.successLight : AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48)
                            : const SizedBox(
                                width: 38,
                                height: 38,
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 3.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isCompleted ? 'Examination Submitted!' : 'Submitting Examination...',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCompleted
                          ? 'Responses encrypted & verified. Opening your Official NEET Scorecard...'
                          : 'Evaluating responses under standard NTA rules (+4 for correct, -1 for wrong)...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    // Submission Process Checklist
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _buildSubmitStep('Encrypting candidate responses', isDone: true),
                          const SizedBox(height: 10),
                          _buildSubmitStep('Applying NTA (+4 / -1) marking rules', isDone: true),
                          const SizedBox(height: 10),
                          _buildSubmitStep('Syncing scorecard to Firebase Cloud DB', isDone: true),
                          const SizedBox(height: 10),
                          _buildSubmitStep('Generating All India Rank & Scorecard', isDone: isCompleted, isCurrent: !isCompleted),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state.questions.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(title: const Text('Examination')),
            body: AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'No Questions Found',
              message: 'This examination does not contain any questions.',
              actionLabel: 'Back to Dashboard',
              onAction: () => context.go('/dashboard'),
            ),
          );
        }

        final width = MediaQuery.of(context).size.width;
        final isDesktop = width >= 900;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildExamAppBar(state, isDesktop),
          endDrawer: !isDesktop ? Drawer(child: SafeArea(child: _buildQuestionPalette(state))) : null,
          body: Row(
            children: [
              // Main Question Viewport
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 850),
                            child: _buildQuestionCard(state),
                          ),
                        ),
                      ),
                    ),
                    _buildStickyBottomBar(state, isDesktop),
                  ],
                ),
              ),

              // Desktop Question Palette
              if (isDesktop) ...[
                const VerticalDivider(width: 1, color: AppColors.border),
                SizedBox(
                  width: 320,
                  child: _buildQuestionPalette(state),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildExamAppBar(ExaminationState state, bool isDesktop) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const AppLogo(size: 30, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.test?.name ?? 'NEET Mock Examination',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'NTA Standard CBT Mode',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _buildTimerWidget(state),
        const SizedBox(width: 8),
        if (!isDesktop)
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 20),
              tooltip: 'Question Palette',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton(
            onPressed: _confirmSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('SUBMIT', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerWidget(ExaminationState state) {
    final seconds = state.remainingSeconds;
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final timeStr = "$hours:$minutes:$secs";

    final isUrgent = seconds < 300; 
    final isWarning = seconds < 600;

    final Color timerColor = isUrgent ? AppColors.error : (isWarning ? AppColors.warning : AppColors.primary);
    final Color timerBg = isUrgent ? AppColors.errorLight : (isWarning ? AppColors.warningLight : AppColors.primaryLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: timerBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: timerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: timerColor, size: 14),
          const SizedBox(width: 4),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              color: timerColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(ExaminationState state) {
    final question = state.questions[state.currentQuestionIndex];
    final selectedOption = state.answers[question.id];

    // Compute NEET UG Section Info
    final currentSubject = ExcelMcqParser.normalizeSubject(question.subject);
    final subjectQuestions = state.questions.where(
      (q) => ExcelMcqParser.normalizeSubject(q.subject) == currentSubject,
    ).toList();
    final indexInSubject = subjectQuestions.indexOf(question);

    String? sectionLabel;
    if (subjectQuestions.length >= 45 && indexInSubject >= 0) {
      if (indexInSubject < 35) {
        sectionLabel = 'Sec A (Q${indexInSubject + 1}/35)';
      } else {
        sectionLabel = 'Sec B (Q${indexInSubject + 1 - 35}/15)';
      }
    } else if (state.questions.length >= 180) {
      final modIndex = state.currentQuestionIndex % 50;
      if (modIndex < 35) {
        sectionLabel = 'Sec A (Mandatory)';
      } else {
        sectionLabel = 'Sec B (Optional 10/15)';
      }
    }

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
          // Responsive Question Header
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Q${state.currentQuestionIndex + 1} / ${state.questions.length}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
                    ),
                  ),
                  if (sectionLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: sectionLabel.contains('Sec A') ? const Color(0xFFEFF6FF) : const Color(0xFFFDF2F8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: sectionLabel.contains('Sec A') ? const Color(0xFF93C5FD) : const Color(0xFFF472B6),
                        ),
                      ),
                      child: Text(
                        sectionLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: sectionLabel.contains('Sec A') ? const Color(0xFF1D4ED8) : const Color(0xFFBE185D),
                        ),
                      ),
                    ),
                  AppBadge(
                    text: question.subject ?? 'General',
                    backgroundColor: AppColors.primaryLight,
                    textColor: AppColors.primary,
                  ),
                  if (question.topic != null && question.topic!.isNotEmpty && question.topic != 'General')
                    AppBadge(
                      text: question.topic!,
                      backgroundColor: AppColors.surfaceSubtle,
                      textColor: AppColors.textSecondary,
                    ),
                ],
              ),
              AppBadge(
                text: '+${question.marks.toInt()} / -${question.negativeMarks.toInt()}',
                backgroundColor: const Color(0xFFFEF3C7),
                textColor: const Color(0xFFB45309),
              ),
            ],
          ),
          const Divider(height: 32),

          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          _buildInteractiveOptionTile('A', question.optionA, selectedOption == 'A'),
          const SizedBox(height: 12),
          _buildInteractiveOptionTile('B', question.optionB, selectedOption == 'B'),
          const SizedBox(height: 12),
          _buildInteractiveOptionTile('C', question.optionC, selectedOption == 'C'),
          const SizedBox(height: 12),
          _buildInteractiveOptionTile('D', question.optionD, selectedOption == 'D'),
        ],
      ),
    );
  }

  Widget _buildInteractiveOptionTile(String key, String text, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryLight : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.8 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _viewModel.selectAnswer(key),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceSubtle,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    key,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStickyBottomBar(ExaminationState state, bool isDesktop) {
    final qId = state.questions[state.currentQuestionIndex].id;
    final isMarked = state.markedForReview.contains(qId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: state.currentQuestionIndex > 0 ? _viewModel.previousQuestion : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    minimumSize: Size.zero,
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 20),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: state.currentQuestionIndex < state.questions.length - 1 ? _viewModel.nextQuestion : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Save & Next'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: _viewModel.toggleMarkForReview,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                side: BorderSide(color: isMarked ? AppColors.warning : AppColors.border),
                foregroundColor: isMarked ? const Color(0xFFD97706) : AppColors.textSecondary,
                backgroundColor: isMarked ? AppColors.warningLight : Colors.transparent,
              ),
              icon: Icon(
                isMarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: isMarked ? AppColors.warning : AppColors.textSecondary,
                size: 18,
              ),
              label: Text(isMarked ? 'Marked' : 'Review Later'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPalette(ExaminationState state) {
    final answeredCount = state.answers.values.where((v) => v != null).length;
    final markedCount = state.markedForReview.length;
    final totalCount = state.questions.length;
    final unattemptedCount = (totalCount - answeredCount).clamp(0, totalCount);

    final subjects = <String>['ALL'];
    for (final q in state.questions) {
      final s = ExcelMcqParser.normalizeSubject(q.subject);
      if (!subjects.contains(s)) {
        subjects.add(s);
      }
    }

    final List<MapEntry<int, Question>> filteredQuestions = [];
    for (int i = 0; i < state.questions.length; i++) {
      final q = state.questions[i];
      final s = ExcelMcqParser.normalizeSubject(q.subject);
      if (_selectedPaletteSubject == 'ALL' || s == _selectedPaletteSubject) {
        filteredQuestions.add(MapEntry(i, q));
      }
    }

    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Question Palette',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _paletteStat('$answeredCount', 'Ans', AppColors.success),
                    _paletteStat('$markedCount', 'Mark', AppColors.warning),
                    _paletteStat('$unattemptedCount', 'Rem', AppColors.textMuted),
                  ],
                ),
                if (subjects.length > 2) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 30,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: subjects.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, sIdx) {
                        final sub = subjects[sIdx];
                        final isSel = _selectedPaletteSubject == sub;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPaletteSubject = sub;
                            });
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary : AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSel ? AppColors.primary : AppColors.border,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              sub,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: filteredQuestions.length,
              itemBuilder: (context, fIdx) {
                final entry = filteredQuestions[fIdx];
                final index = entry.key;
                final q = entry.value;
                final qId = q.id;
                final isAnswered = state.answers.containsKey(qId) && state.answers[qId] != null;
                final isMarked = state.markedForReview.contains(qId);
                final isCurrent = state.currentQuestionIndex == index;

                Color bgColor = AppColors.surface;
                Color textColor = AppColors.textSecondary;
                Color borderColor = AppColors.border;

                if (isMarked) {
                  bgColor = AppColors.warning;
                  textColor = Colors.white;
                  borderColor = AppColors.warning;
                } else if (isAnswered) {
                  bgColor = AppColors.success;
                  textColor = Colors.white;
                  borderColor = AppColors.success;
                }

                return InkWell(
                  onTap: () {
                    _viewModel.jumpToQuestion(index);
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border.all(
                        color: isCurrent ? AppColors.primary : borderColor,
                        width: isCurrent ? 2.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Column(
              children: [
                _legendRow(AppColors.success, 'Answered'),
                _legendRow(AppColors.warning, 'Review Later'),
                _legendRow(AppColors.surface, 'Not Attempted', isBordered: true),
                _legendRow(AppColors.primary, 'Current Active', isCurrent: true),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('SUBMIT TEST', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 2,
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      _confirmSubmit();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paletteStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _legendRow(Color color, String label, {bool isBordered = false, bool isCurrent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isBordered ? AppColors.surface : color,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: isCurrent ? AppColors.primary : (isBordered ? AppColors.border : color),
                width: isCurrent ? 2 : 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label, 
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitStep(String text, {bool isDone = false, bool isCurrent = false}) {
    return Row(
      children: [
        if (isDone)
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18)
        else if (isCurrent)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          )
        else
          Icon(Icons.radio_button_unchecked_rounded, color: AppColors.textMuted.withValues(alpha: 0.5), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCurrent || isDone ? FontWeight.w600 : FontWeight.w400,
              color: isDone
                  ? AppColors.textPrimary
                  : (isCurrent ? AppColors.primary : AppColors.textMuted),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmSubmit() {
    final state = _viewModel.state;
    final questions = state.questions;
    final total = questions.length;
    final answered = state.answers.values.where((v) => v != null && v.isNotEmpty).length;
    final marked = state.markedForReview.length;
    final unattempted = (total - answered).clamp(0, total);

    // Subject breakdown
    final Map<String, List<Question>> subjectMap = {};
    for (final q in questions) {
      final s = ExcelMcqParser.normalizeSubject(q.subject);
      subjectMap.putIfAbsent(s, () => []).add(q);
    }

    // Time calculations
    final remainingSec = state.remainingSeconds;
    final dur = Duration(seconds: remainingSec);
    final hours = dur.inHours.toString().padLeft(2, '0');
    final mins = (dur.inMinutes % 60).toString().padLeft(2, '0');
    final secs = (dur.inSeconds % 60).toString().padLeft(2, '0');
    final timeStr = "$hours:$mins:$secs";
    final hasHighTimeLeft = remainingSec > 300;

    final studentName = sl.isRegistered<AuthService>()
        ? (sl<AuthService>().currentUser?.displayName ?? 'NEET Aspirant')
        : 'NEET Aspirant';
    final testName = state.test?.name ?? 'NEET UG Mock Examination';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Official NTA Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    const AppLogo(size: 38, borderRadius: 10, hasGlow: true),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'NATIONAL TESTING AGENCY (NTA)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'NEET (UG) CBT Examination Summary',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      tooltip: 'Return to Test',
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ],
                ),
              ),

              // 2. Candidate & Timing Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: AppColors.surfaceSubtle,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          studentName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  $testName',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: hasHighTimeLeft ? AppColors.primaryLight : AppColors.errorLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: hasHighTimeLeft ? AppColors.primary.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: hasHighTimeLeft ? AppColors.primary : AppColors.error,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$timeStr Left',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              color: hasHighTimeLeft ? AppColors.primary : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 4-Card KPI Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 460;
                          return GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isNarrow ? 2 : 4,
                              mainAxisExtent: 68,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                            children: [
                              _buildKpiCard('Total MCQs', '$total', AppColors.primary, Icons.format_list_numbered_rounded),
                              _buildKpiCard('Answered', '$answered', AppColors.success, Icons.check_circle_rounded),
                              _buildKpiCard('Review Later', '$marked', AppColors.warning, Icons.bookmark_rounded),
                              _buildKpiCard('Not Attempted', '$unattempted', AppColors.error, Icons.cancel_outlined),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Subject Breakdown Section
                      const Text(
                        'Subject-wise Response Breakdown',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(flex: 3, child: Text('Subject', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
                                  Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
                                  Expanded(flex: 2, child: Text('Answered', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.success))),
                                  Expanded(flex: 2, child: Text('Review', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.warning))),
                                  Expanded(flex: 2, child: Text('Skipped', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.error))),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: AppColors.border),
                            // Table Rows
                            ...subjectMap.entries.map((entry) {
                              final subTotal = entry.value.length;
                              final subAnswered = entry.value.where((q) => state.answers[q.id] != null && state.answers[q.id]!.isNotEmpty).length;
                              final subMarked = entry.value.where((q) => state.markedForReview.contains(q.id)).length;
                              final subSkipped = (subTotal - subAnswered).clamp(0, subTotal);

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                                      ),
                                    ),
                                    Expanded(flex: 2, child: Text('$subTotal', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                    Expanded(flex: 2, child: Text('$subAnswered', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success))),
                                    Expanded(flex: 2, child: Text('$subMarked', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.warning))),
                                    Expanded(flex: 2, child: Text('$subSkipped', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.error))),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // NTA Final Disclaimer Callout
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                hasHighTimeLeft
                                    ? 'You still have $timeStr remaining! Once submitted, your answers will be permanently locked and evaluated (+4 for correct, -1 for wrong). You cannot change them after submission.'
                                    : 'Submitting will lock your responses and compute your final NEET score and AIR rank. This action cannot be undone.',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.4, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Action Buttons Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Back to Test'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        onPressed: () => Navigator.pop(dialogCtx),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('Confirm & Final Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          _viewModel.submitTest();
                        },
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
  }

  Widget _buildKpiCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color, height: 1.1),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
