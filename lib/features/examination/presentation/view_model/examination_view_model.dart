import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../injection/injection_container.dart';
import '../../../result/data/repository/result_repository.dart';
import '../../data/repository/examination_repository.dart';

enum ExamStatus { initial, loading, ongoing, submitting, completed, error }

class ExaminationState {
  final ExamStatus status;
  final Test? test;
  final List<Question> questions;
  final Map<int, String?> answers;
  final Set<int> markedForReview;
  final int currentQuestionIndex;
  final int remainingSeconds;
  final String? errorMessage;

  ExaminationState({
    this.status = ExamStatus.initial,
    this.test,
    this.questions = const [],
    this.answers = const {},
    this.markedForReview = const {},
    this.currentQuestionIndex = 0,
    this.remainingSeconds = 0,
    this.errorMessage,
  });

  ExaminationState copyWith({
    ExamStatus? status,
    Test? test,
    List<Question>? questions,
    Map<int, String?>? answers,
    Set<int>? markedForReview,
    int? currentQuestionIndex,
    int? remainingSeconds,
    String? errorMessage,
  }) {
    return ExaminationState(
      status: status ?? this.status,
      test: test ?? this.test,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      markedForReview: markedForReview ?? this.markedForReview,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ExaminationViewModel extends ChangeNotifier {
  final ExaminationRepository repository;
  ExaminationState _state = ExaminationState();
  Timer? _timer;
  String? _testDocId;
  int? _activeTestId;
  DateTime? _examTargetEndTime;

  ExaminationViewModel({required this.repository});

  ExaminationState get state => _state;

  Future<void> loadTest(int testId, List<Question> questions, {String? testDocId}) async {
    _testDocId = testDocId;
    _activeTestId = testId;
    _state = _state.copyWith(status: ExamStatus.loading);
    notifyListeners();

    try {
      // 1. Fetch/Watch test metadata
      final test = await repository.watchTest(testId).first;
      if (test == null) throw Exception("Test not found");

      // 2. Start test if it hasn't been started yet (Requirement 13)
      if (test.status == 'pending') {
        await repository.startTest(testId);
      }

      // 3. Recovery: Load questions if missing (Requirement 14)
      List<Question> finalQuestions = questions;
      if (finalQuestions.isEmpty) {
        finalQuestions = await repository.getQuestionsForTest(testId);
      }

      // 4. Load existing answers
      final userAnswers = await repository.getUserAnswers(testId);
      final Map<int, String?> answersMap = {};
      final Set<int> markedSet = {};
      for (var ans in userAnswers) {
        answersMap[ans.questionId] = ans.selectedOption;
        if (ans.isMarkedForReview) markedSet.add(ans.questionId);
      }

      // 5. Sync Timer against absolute wall-clock (immune to tab throttling)
      final currentTest = await repository.watchTest(testId).first;
      final effectiveStart = currentTest?.startedAt ?? DateTime.now();
      final totalMinutes = currentTest?.durationMinutes ?? test.durationMinutes;
      _examTargetEndTime = effectiveStart.add(Duration(minutes: totalMinutes));
      final remaining = _examTargetEndTime!.difference(DateTime.now()).inSeconds;

      _state = _state.copyWith(
        status: currentTest?.status == 'completed' ? ExamStatus.completed : ExamStatus.ongoing,
        test: currentTest,
        questions: finalQuestions,
        answers: answersMap,
        markedForReview: markedSet,
        remainingSeconds: remaining > 0 ? remaining : 0,
      );

      if (_state.status == ExamStatus.ongoing) {
        _startTimer();
      }
    } catch (e) {
      _state = _state.copyWith(status: ExamStatus.error, errorMessage: e.toString());
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_examTargetEndTime == null) return;
      final diff = _examTargetEndTime!.difference(DateTime.now()).inSeconds;
      if (diff <= 0) {
        timer.cancel();
        _state = _state.copyWith(remainingSeconds: 0);
        notifyListeners();
        submitTest();
      } else {
        if (_state.remainingSeconds != diff) {
          _state = _state.copyWith(remainingSeconds: diff);
          notifyListeners();
        }
      }
    });
  }

  Future<void> selectAnswer(String option) async {
    final questionId = _state.questions[_state.currentQuestionIndex].id;
    final newAnswers = Map<int, String?>.from(_state.answers);
    
    // Toggle logic: click same option to clear
    if (newAnswers[questionId] == option) {
      newAnswers[questionId] = null;
    } else {
      newAnswers[questionId] = option;
    }

    _state = _state.copyWith(answers: newAnswers);
    notifyListeners();

    final testId = _activeTestId ?? _state.test?.id;
    if (testId != null) {
      await repository.saveAnswer(
        testId: testId,
        questionId: questionId,
        selectedOption: newAnswers[questionId],
        isMarkedForReview: _state.markedForReview.contains(questionId),
      );
    }
  }

  Future<void> toggleMarkForReview() async {
    final questionId = _state.questions[_state.currentQuestionIndex].id;
    final newMarked = Set<int>.from(_state.markedForReview);
    
    if (newMarked.contains(questionId)) {
      newMarked.remove(questionId);
    } else {
      newMarked.add(questionId);
    }

    _state = _state.copyWith(markedForReview: newMarked);
    notifyListeners();

    final testId = _activeTestId ?? _state.test?.id;
    if (testId != null) {
      await repository.saveAnswer(
        testId: testId,
        questionId: questionId,
        selectedOption: _state.answers[questionId],
        isMarkedForReview: newMarked.contains(questionId),
      );
    }
  }

  void nextQuestion() => jumpToQuestion(_state.currentQuestionIndex + 1);
  void previousQuestion() => jumpToQuestion(_state.currentQuestionIndex - 1);

  void jumpToQuestion(int index) {
    if (index >= 0 && index < _state.questions.length) {
      _state = _state.copyWith(currentQuestionIndex: index);
      notifyListeners();
    }
  }

  Future<void> submitTest() async {
    if (_state.status == ExamStatus.submitting || _state.status == ExamStatus.completed) return;
    
    _timer?.cancel();
    _state = _state.copyWith(status: ExamStatus.submitting);
    notifyListeners();

    try {
      final testId = _activeTestId ?? _state.test?.id;
      if (testId == null) {
        throw Exception("Active test session ID not found for submission.");
      }

      // 1. Ensure all active answer selections are flushed to local database
      for (final entry in _state.answers.entries) {
        try {
          await repository.saveAnswer(
            testId: testId,
            questionId: entry.key,
            selectedOption: entry.value,
            isMarkedForReview: _state.markedForReview.contains(entry.key),
          );
        } catch (err) {
          debugPrint("Note: Answer auto-flush skipped for question ${entry.key}: $err");
        }
      }

      // 2. Mark local test as completed
      await repository.submitTest(testId);

      // 3. Immediately evaluate score, save local results, and sync to Firebase Cloud DB
      if (sl.isRegistered<ResultRepository>()) {
        await sl<ResultRepository>().calculateAndSaveResult(testId, testDocId: _testDocId);
      }

      _state = _state.copyWith(status: ExamStatus.completed);
    } catch (e, stack) {
      debugPrint("Error in submitTest: $e\n$stack");
      _state = _state.copyWith(status: ExamStatus.error, errorMessage: e.toString());
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
