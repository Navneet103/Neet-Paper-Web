import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/firebase/firebase_test_service.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/time/ist_clock.dart';
import '../../../../core/utils/excel_mcq_parser.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../injection/injection_container.dart';

class PublishDailyTestPage extends StatefulWidget {
  const PublishDailyTestPage({super.key});

  @override
  State<PublishDailyTestPage> createState() => _PublishDailyTestPageState();
}

class _PublishDailyTestPageState extends State<PublishDailyTestPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '180');
  
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 9, minute: 0); // 09:00 AM by default
  
  List<FirebaseQuestion> _parsedQuestions = [];
  bool _isParsing = false;
  bool _isPublishing = false;
  String? _statusMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _updateDefaultTitle();
  }

  void _updateDefaultTitle([int count = 180]) {
    final d = _scheduledDate;
    final dateStr = '${d.day}/${d.month}/${d.year}';
    _titleController.text = 'NEET Live Mock Test ($count MCQs) - $dateStr';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickExcelFile() async {
    setState(() {
      _isParsing = true;
      _errorMessage = null;
      _statusMessage = 'Reading spreadsheet file...';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
        withData: true,
      );

      if (result == null || result.files.first.bytes == null) {
        setState(() => _isParsing = false);
        return;
      }

      final bytes = result.files.first.bytes!;
      final questions = await compute(_parseExcelBytes, bytes);

      if (questions.isEmpty) {
        setState(() {
          _isParsing = false;
          _errorMessage = 'No valid MCQ rows found in the selected file. Ensure Question, Options A-D, and Answer columns are present.';
        });
        return;
      }

      setState(() {
        _parsedQuestions = questions;
        _isParsing = false;
        _durationController.text = '${IstClock.durationMinutesForCount(questions.length)}';
        _updateDefaultTitle(questions.length);
        _statusMessage = null;
      });
    } catch (e) {
      setState(() {
        _isParsing = false;
        _errorMessage = 'Error reading file: $e';
      });
    }
  }

  Future<void> _loadFromLocalBank() async {
    setState(() {
      _isParsing = true;
      _errorMessage = null;
      _statusMessage = 'Loading questions from local question bank...';
    });

    try {
      final db = sl<AppDatabase>();
      final allQ = await db.select(db.questions).get();

      if (allQ.isEmpty) {
        setState(() {
          _isParsing = false;
          _errorMessage = 'Local Question Bank is empty. Please upload an Excel file or import questions first.';
        });
        return;
      }

      // Convert Drift Question to FirebaseQuestion
      final list = allQ.map((q) => FirebaseQuestion(
        id: q.id,
        questionText: q.questionText,
        optionA: q.optionA,
        optionB: q.optionB,
        optionC: q.optionC,
        optionD: q.optionD,
        correctAnswer: q.correctAnswer,
        marks: q.marks,
        negativeMarks: q.negativeMarks,
        subject: ExcelMcqParser.normalizeSubject(q.subject),
        topic: q.topic ?? 'General',
      )).toList();

      setState(() {
        _parsedQuestions = list;
        _isParsing = false;
        _durationController.text = '${IstClock.durationMinutesForCount(list.length)}';
        _updateDefaultTitle(list.length);
        _statusMessage = null;
      });
    } catch (e) {
      setState(() {
        _isParsing = false;
        _errorMessage = 'Error loading local questions: $e';
      });
    }
  }

  Future<void> _publishToFirebase() async {
    if (!_formKey.currentState!.validate()) return;
    if (_parsedQuestions.isEmpty) {
      setState(() => _errorMessage = 'Please select or upload questions before publishing.');
      return;
    }

    setState(() {
      _isPublishing = true;
      _errorMessage = null;
    });

    try {
      final scheduledDateTime = DateTime(
        _scheduledDate.year,
        _scheduledDate.month,
        _scheduledDate.day,
        _scheduledTime.hour,
        _scheduledTime.minute,
      );

      final dateKey = IstClock.dateKey(_scheduledDate);
      final duration = int.tryParse(_durationController.text) ?? 180;
      final totalQuestions = _parsedQuestions.length;
      final totalMarks = totalQuestions * 4.0;

      final dailyTest = FirebaseDailyTest(
        id: dateKey,
        dateKey: dateKey,
        title: _titleController.text.trim(),
        scheduledStartTime: scheduledDateTime,
        durationMinutes: duration,
        totalQuestions: totalQuestions,
        totalMarks: totalMarks,
        positiveMarks: 4.0,
        negativeMarks: 1.0,
        status: scheduledDateTime.isBefore(DateTime.now()) ? 'live' : 'scheduled',
        questions: _parsedQuestions,
      );

      final service = sl<FirebaseTestService>();
      await service.publishDailyTest(dailyTest);

      if (!mounted) return;
      setState(() => _isPublishing = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
              SizedBox(width: 10),
              Text('Paper Published to Firebase!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Test Title: ${dailyTest.title}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Questions Uploaded: $totalQuestions MCQs'),
              Text('Scheduled Start: ${_scheduledTime.format(context)} on $dateKey (IST)'),
              Text('Total Marks: ${totalMarks.toInt()} | Duration: $duration Mins'),
              const SizedBox(height: 12),
              const Text(
                'Aspirants accessing the website will now be able to see the countdown and take the live test at 9:00 AM!',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/daily-test');
              },
              child: const Text('VIEW DAILY TEST HUB'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPublishing = false;
        _errorMessage = 'Firebase Cloud Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = sl<AuthService>();
    if (!auth.isAdmin) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Access Restricted'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/dashboard'),
          ),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.shadowSm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.errorLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.error, size: 36),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Administrator Access Required',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Publishing exam papers to Firebase Cloud DB requires administrator credentials.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/login?tab=admin'),
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: const Text('SIGN IN AS ADMINISTRATOR'),
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

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Publish Daily NEET Paper'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        child: AppPageContainer(
          maxWidth: 900,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSectionHeader(
                  title: 'Daily NEET Test Publisher (Firebase Cloud)',
                  subtitle: 'Upload 180, 45, or 90 questions and schedule the 9:00 AM live test for students',
                ),
                const SizedBox(height: 16),

                if (_errorMessage != null) ...[
                  _buildErrorBanner(_errorMessage!),
                  const SizedBox(height: 16),
                ],

                // Configuration Card
                _buildScheduleCard(isMobile),
                const SizedBox(height: 24),

                // Question Source Card (Excel or Local Bank)
                _buildQuestionSourceCard(isMobile),
                const SizedBox(height: 24),

                // Question Preview & Subject Distribution
                if (_parsedQuestions.isNotEmpty) ...[
                  _buildQuestionsSummaryCard(),
                  const SizedBox(height: 24),
                ],

                // Publish Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: (_isPublishing || _isParsing || _parsedQuestions.isEmpty)
                        ? null
                        : _publishToFirebase,
                    icon: _isPublishing
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload_rounded, size: 24),
                    label: Text(
                      _isPublishing
                          ? 'Publishing to Firebase Cloud DB...'
                          : 'PUBLISH LIVE TEST TO FIREBASE (${_parsedQuestions.length} MCQs)',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(bool isMobile) {
    final dateStr = '${_scheduledDate.day.toString().padLeft(2, '0')}/${_scheduledDate.month.toString().padLeft(2, '0')}/${_scheduledDate.year}';
    final timeStr = _scheduledTime.format(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule_rounded, color: AppColors.primary, size: 22),
              SizedBox(width: 10),
              Text(
                '1. Test Schedule & Settings',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Live Test Title',
              hintText: 'e.g. NEET 2026 Daily Live Test #1',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a test title' : null,
          ),
          const SizedBox(height: 20),
          if (isMobile) ...[
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Scheduled Date', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFEFF6FF),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start Time (IST)', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(timeStr, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Scheduled Date', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFEFF6FF),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Time (IST)', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(timeStr, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          if (isMobile) ...[
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (Minutes)',
                hintText: '180',
                prefixIcon: Icon(Icons.timer_outlined),
                suffixText: 'mins',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Marking Rule', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  SizedBox(height: 4),
                  Text('+4 Correct / -1 Penalty', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (Minutes)',
                      hintText: '180',
                      prefixIcon: Icon(Icons.timer_outlined),
                      suffixText: 'mins',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Marking Rule', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        SizedBox(height: 4),
                        Text('+4 Correct / -1 Penalty', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionSourceCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 22),
              SizedBox(width: 10),
              Text(
                '2. Choose Question Source',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your daily 180 questions (or 45/90/custom) via Excel, or sync from your local bank.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          if (_isParsing) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(_statusMessage ?? 'Processing questions...', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ] else ...[
            if (isMobile) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickExcelFile,
                  icon: const Icon(Icons.file_upload_rounded),
                  label: const Text('UPLOAD EXCEL (.xlsx)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loadFromLocalBank,
                  icon: const Icon(Icons.folder_shared_rounded),
                  label: const Text('LOAD FROM LOCAL BANK'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickExcelFile,
                      icon: const Icon(Icons.file_upload_rounded),
                      label: const Text('UPLOAD EXCEL (.xlsx)'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _loadFromLocalBank,
                      icon: const Icon(Icons.folder_shared_rounded),
                      label: const Text('LOAD FROM LOCAL BANK'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionsSummaryCard() {
    final Map<String, int> subjectCounts = {};
    for (final q in _parsedQuestions) {
      final s = ExcelMcqParser.normalizeSubject(q.subject);
      subjectCounts[s] = (subjectCounts[s] ?? 0) + 1;
    }

    Color getChipColor(String sub) {
      final lower = sub.toLowerCase();
      if (lower.contains('phy')) return const Color(0xFF3B82F6);
      if (lower.contains('chem')) return const Color(0xFF8B5CF6);
      if (lower.contains('bio') || lower.contains('bot') || lower.contains('zoo')) return const Color(0xFF10B981);
      return AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    '${_parsedQuestions.length} Questions Ready to Publish',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
              AppBadge(
                text: 'Total Marks: ${(_parsedQuestions.length * 4.0).toInt()}',
                backgroundColor: AppColors.successLight,
                textColor: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: subjectCounts.entries.map((entry) {
              return _statChip(entry.key, '${entry.value} MCQs', getChipColor(entry.key));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: color)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
        _updateDefaultTitle(_parsedQuestions.isNotEmpty ? _parsedQuestions.length : 180);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );
    if (picked != null) {
      setState(() => _scheduledTime = picked);
    }
  }
}

// Top-level compute function for parsing Excel in background
List<FirebaseQuestion> _parseExcelBytes(Uint8List bytes) {
  final parsed = ExcelMcqParser.parseBytes(bytes);
  return parsed.asMap().entries.map((entry) {
    final idx = entry.key;
    final q = entry.value;
    return FirebaseQuestion(
      id: idx + 1,
      questionText: q.questionText,
      optionA: q.optionA,
      optionB: q.optionB,
      optionC: q.optionC,
      optionD: q.optionD,
      correctAnswer: q.correctAnswer,
      marks: q.marks,
      negativeMarks: q.negativeMarks,
      subject: q.subject,
      topic: q.topic,
    );
  }).toList();
}
