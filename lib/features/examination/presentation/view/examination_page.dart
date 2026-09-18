import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
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

        if (state.status == ExamStatus.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/result/${widget.testId}');
          });
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Compiling responses and calculating score...', style: TextStyle(color: AppColors.textSecondary)),
                ],
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
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 18),
          ),
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

    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
              itemCount: state.questions.length,
              itemBuilder: (context, index) {
                final qId = state.questions[index].id;
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

  void _confirmSubmit() {
    final answered = _viewModel.state.answers.values.where((v) => v != null).length;
    final total = _viewModel.state.questions.length;
    final marked = _viewModel.state.markedForReview.length;
    final unattempted = total - answered;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_rounded, color: AppColors.primary),
            Text('Submit Test?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to finalize and submit? You cannot change answers after submission.',
                style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _dialogStatRow('Attempted', '$answered', AppColors.success),
                    const SizedBox(height: 8),
                    _dialogStatRow('Review Later', '$marked', AppColors.warning),
                    const SizedBox(height: 8),
                    _dialogStatRow('Remaining', '$unattempted', AppColors.error),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BACK'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
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

  Widget _dialogStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
