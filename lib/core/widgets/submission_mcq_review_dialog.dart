import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../firebase/firebase_test_service.dart';
import '../storage/app_database.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../../injection/injection_container.dart';

class SubmissionMcqReviewDialog extends StatefulWidget {
  final TestSubmission submission;

  const SubmissionMcqReviewDialog({
    super.key,
    required this.submission,
  });

  static void show(BuildContext context, {required TestSubmission submission}) {
    showDialog(
      context: context,
      builder: (ctx) => SubmissionMcqReviewDialog(submission: submission),
    );
  }

  @override
  State<SubmissionMcqReviewDialog> createState() => _SubmissionMcqReviewDialogState();
}

class _SubmissionMcqReviewDialogState extends State<SubmissionMcqReviewDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  List<FirebaseQuestion> _questions = [];
  String _selectedFilter = 'all'; // all, correct, wrong, skipped
  String _selectedSubject = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final service = sl<FirebaseTestService>();
      final test = await service.findTestByIdOrTitle(widget.submission.testId);

      if (test != null && test.questions.isNotEmpty) {
        if (mounted) {
          setState(() {
            _questions = test.questions;
            _isLoading = false;
          });
        }
        return;
      }

      // Fallback: check Drift DB questions
      if (sl.isRegistered<AppDatabase>()) {
        final db = sl<AppDatabase>();
        final localQ = await db.select(db.questions).get();
        if (localQ.isNotEmpty) {
          final mapped = localQ.map((q) => FirebaseQuestion(
            id: q.id,
            questionText: q.questionText,
            optionA: q.optionA,
            optionB: q.optionB,
            optionC: q.optionC,
            optionD: q.optionD,
            correctAnswer: q.correctAnswer,
            marks: q.marks,
            negativeMarks: q.negativeMarks,
            subject: q.subject ?? 'General',
            topic: q.topic ?? 'General',
          )).toList();

          if (mounted) {
            setState(() {
              _questions = mapped;
              _isLoading = false;
            });
          }
          return;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Question details for this examination are not archived in cloud storage.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading questions: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = widget.submission;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final dateStr = dateFormat.format(sub.submittedAt);
    final mins = sub.timeTakenSeconds ~/ 60;
    final secs = sub.timeTakenSeconds % 60;

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 860),
        child: Column(
          children: [
            // Modal Top Header
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: isMobile ? 22 : 26,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      sub.studentName.isNotEmpty ? sub.studentName[0].toUpperCase() : 'S',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                sub.studentName,
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'SCORECARD & SOLUTIONS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${sub.testId} • Submitted: $dateStr • ${mins}m ${secs}s taken',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _statPill(
                              'Score: ${sub.score.toInt()} / ${sub.totalMarks.toInt()}',
                              sub.score >= 500 ? AppColors.success : (sub.score >= 350 ? AppColors.primary : AppColors.warning),
                            ),
                            _statPill('+${sub.correctCount} Correct', AppColors.success),
                            _statPill('-${sub.wrongCount} Incorrect', AppColors.error),
                            _statPill('${sub.unattemptedCount} Skipped', AppColors.textMuted),
                            _statPill('${sub.accuracy.toStringAsFixed(1)}% Accuracy', const Color(0xFF8B5CF6)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Controls & Filters Bar
            if (!_isLoading && _errorMessage == null && _questions.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterButton('all', 'All Questions (${_questions.length})'),
                          const SizedBox(width: 8),
                          _filterButton('correct', 'Correct (+4) • ${sub.correctCount}', color: AppColors.success),
                          const SizedBox(width: 8),
                          _filterButton('wrong', 'Incorrect (-1) • ${sub.wrongCount}', color: AppColors.error),
                          const SizedBox(width: 8),
                          _filterButton('skipped', 'Skipped (0) • ${sub.unattemptedCount}', color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search in questions statement or options...',
                              prefixIcon: const Icon(Icons.search_rounded, size: 18),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 16),
                                      onPressed: () => setState(() => _searchQuery = ''),
                                    )
                                  : null,
                            ),
                            onChanged: (v) => setState(() => _searchQuery = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _selectedSubject,
                          underline: const SizedBox.shrink(),
                          borderRadius: BorderRadius.circular(12),
                          items: ['All', 'Physics', 'Chemistry', 'Biology', 'Botany', 'Zoology']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSubject = val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Modal Body: Questions List
            Expanded(
              child: _buildBody(isMobile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool isMobile) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Loading questions and official answer keys...', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 48),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    final answersMap = widget.submission.answers;

    // Filter questions
    final filtered = _questions.where((q) {
      // Subject filter
      if (_selectedSubject != 'All') {
        final qSub = q.subject.toLowerCase();
        final sSub = _selectedSubject.toLowerCase();
        if (!qSub.contains(sSub)) return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final match = q.questionText.toLowerCase().contains(query) ||
            q.optionA.toLowerCase().contains(query) ||
            q.optionB.toLowerCase().contains(query) ||
            q.optionC.toLowerCase().contains(query) ||
            q.optionD.toLowerCase().contains(query);
        if (!match) return false;
      }

      // Correct / Wrong / Skipped filter
      // Look up candidate answer by q.id or 1-indexed number
      final candidateChoice = answersMap[q.id.toString()] ?? answersMap['${_questions.indexOf(q) + 1}'];
      final bool isAnswered = candidateChoice != null && candidateChoice.isNotEmpty;
      final bool isCorrect = isAnswered && candidateChoice.toUpperCase() == q.correctAnswer.toUpperCase();
      final bool isWrong = isAnswered && !isCorrect;
      final bool isSkipped = !isAnswered;

      if (_selectedFilter == 'correct') return isCorrect;
      if (_selectedFilter == 'wrong') return isWrong;
      if (_selectedFilter == 'skipped') return isSkipped;
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.filter_list_off_rounded, size: 40, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text('No questions matched the selected filters.', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final q = filtered[index];
        final globalIndex = _questions.indexOf(q) + 1;
        final candidateChoice = answersMap[q.id.toString()] ?? answersMap['$globalIndex'];
        final bool isAnswered = candidateChoice != null && candidateChoice.isNotEmpty;
        final bool isCorrect = isAnswered && candidateChoice.toUpperCase() == q.correctAnswer.toUpperCase();
        final bool isWrong = isAnswered && !isCorrect;

        Color cardBorder = AppColors.border;
        Color statusBg = AppColors.surfaceSubtle;
        Color statusColor = AppColors.textMuted;
        String statusLabel = 'NOT ATTEMPTED (0 Marks)';
        IconData statusIcon = Icons.remove_circle_outline_rounded;

        if (isCorrect) {
          cardBorder = AppColors.success.withValues(alpha: 0.4);
          statusBg = AppColors.successLight;
          statusColor = AppColors.success;
          statusLabel = 'CORRECT (+4 Marks)';
          statusIcon = Icons.check_circle_rounded;
        } else if (isWrong) {
          cardBorder = AppColors.error.withValues(alpha: 0.4);
          statusBg = AppColors.errorLight;
          statusColor = AppColors.error;
          statusLabel = 'INCORRECT (-1 Mark)';
          statusIcon = Icons.cancel_rounded;
        }

        return Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder, width: isCorrect || isWrong ? 1.5 : 1),
            boxShadow: AppColors.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Header Bar
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Q$globalIndex',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppBadge(
                    text: q.subject,
                    backgroundColor: AppColors.primaryLight,
                    textColor: AppColors.primary,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Question Text
              Text(
                q.questionText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Options A, B, C, D
              _buildOptionRow('A', q.optionA, q.correctAnswer, candidateChoice, isMobile),
              const SizedBox(height: 8),
              _buildOptionRow('B', q.optionB, q.correctAnswer, candidateChoice, isMobile),
              const SizedBox(height: 8),
              _buildOptionRow('C', q.optionC, q.correctAnswer, candidateChoice, isMobile),
              const SizedBox(height: 8),
              _buildOptionRow('D', q.optionD, q.correctAnswer, candidateChoice, isMobile),

              if (isWrong) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Candidate selected Option $candidateChoice, but official key is Option ${q.correctAnswer.toUpperCase()}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionRow(String optKey, String optText, String correctKey, String? candidateChoice, bool isMobile) {
    final bool isCorrectAnswer = optKey.toUpperCase() == correctKey.toUpperCase();
    final bool isCandidateChoice = candidateChoice != null && optKey.toUpperCase() == candidateChoice.toUpperCase();

    Color bg = AppColors.background;
    Color border = AppColors.border;
    Color textColor = AppColors.textPrimary;
    Widget? trailingBadge;

    if (isCorrectAnswer) {
      bg = AppColors.successLight;
      border = AppColors.success;
      textColor = const Color(0xFF14532D);
      trailingBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, color: Colors.white, size: 13),
            SizedBox(width: 4),
            Text(
              'CORRECT ANSWER',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    } else if (isCandidateChoice) {
      bg = AppColors.errorLight;
      border = AppColors.error;
      textColor = const Color(0xFF7F1D1D);
      trailingBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close_rounded, color: Colors.white, size: 13),
            SizedBox(width: 4),
            Text(
              'STUDENT SELECTED',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: isCorrectAnswer || isCandidateChoice ? 1.5 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isCorrectAnswer ? AppColors.success : (isCandidateChoice ? AppColors.error : AppColors.surface),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCorrectAnswer ? AppColors.success : (isCandidateChoice ? AppColors.error : AppColors.border),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              optKey,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: (isCorrectAnswer || isCandidateChoice) ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                optText,
                style: TextStyle(fontSize: 13.5, color: textColor, fontWeight: isCorrectAnswer ? FontWeight.w700 : FontWeight.w500),
              ),
            ),
          ),
          if (trailingBadge != null) ...[
            const SizedBox(width: 8),
            trailingBadge,
          ],
        ],
      ),
    );
  }

  Widget _statPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _filterButton(String key, String label, {Color? color}) {
    final isSelected = _selectedFilter == key;
    final baseColor = color ?? AppColors.primary;

    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? baseColor : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
