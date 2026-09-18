import 'package:flutter/foundation.dart';
import '../../data/repository/question_import_repository.dart';
import '../../../../core/storage/app_database.dart';

enum ImportStatus { initial, parsing, validating, ready, importing, success, error }

class QuestionImportState {
  final ImportStatus status;
  final List<QuestionsCompanion> questions;
  final int totalCount;
  final int validCount;
  final int duplicateCount;
  final List<String> errors;
  final String? errorMessage;

  QuestionImportState({
    this.status = ImportStatus.initial,
    this.questions = const [],
    this.totalCount = 0,
    this.validCount = 0,
    this.duplicateCount = 0,
    this.errors = const [],
    this.errorMessage,
  });

  QuestionImportState copyWith({
    ImportStatus? status,
    List<QuestionsCompanion>? questions,
    int? totalCount,
    int? validCount,
    int? duplicateCount,
    List<String>? errors,
    String? errorMessage,
  }) {
    return QuestionImportState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      totalCount: totalCount ?? this.totalCount,
      validCount: validCount ?? this.validCount,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      errors: errors ?? this.errors,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class QuestionImportViewModel extends ChangeNotifier {
  final QuestionImportRepository repository;
  QuestionImportState _state = QuestionImportState();

  QuestionImportViewModel({required this.repository});

  QuestionImportState get state => _state;

  void _updateState(QuestionImportState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> handleFileSelection(Uint8List bytes) async {
    _updateState(_state.copyWith(status: ImportStatus.parsing, errors: [], errorMessage: null));
    
    try {
      final allParsed = await repository.parseExcelFile(bytes);
      
      _updateState(_state.copyWith(status: ImportStatus.validating));
      
      List<QuestionsCompanion> validQuestions = [];
      List<String> validationErrors = [];
      
      for (int i = 0; i < allParsed.length; i++) {
        final q = allParsed[i];
        final qText = q.questionText.value.trim();
        final optA = q.optionA.value.trim();
        final optB = q.optionB.value.trim();
        final ans = q.correctAnswer.value.trim();

        // 1. Skip completely empty rows
        if (qText.isEmpty) continue;

        // 2. Enterprise Quality Check:
        // If a row has a question but NO options, it's likely junk/footer text (Rows 182+).
        // We only report as Error if it's very likely a real question (has '?' or keywords).
        if (optA.isEmpty || optB.isEmpty || ans.isEmpty) {
          bool looksLikeRealQuestion = qText.contains('?') || 
                                     qText.toLowerCase().contains('what') || 
                                     qText.toLowerCase().contains('which');
          
          if (looksLikeRealQuestion) {
             validationErrors.add("Row ${i + 2}: Question text detected but Options are missing.");
          }
          // Ghost rows/Footers are skipped silently here
          continue; 
        }

        validQuestions.add(q);
      }

      final duplicates = await repository.getDuplicateCount(validQuestions);

      _updateState(_state.copyWith(
        status: ImportStatus.ready,
        questions: validQuestions,
        totalCount: validQuestions.length, // Only count what we can actually import
        validCount: validQuestions.length,
        duplicateCount: duplicates,
        errors: validationErrors,
      ));
    } catch (e) {
      _updateState(_state.copyWith(status: ImportStatus.error, errorMessage: "Error: $e"));
    }
  }

  Future<void> importQuestions() async {
    if (_state.status != ImportStatus.ready || _state.questions.isEmpty) return;
    
    _updateState(_state.copyWith(status: ImportStatus.importing));
    
    try {
      await repository.saveQuestions(_state.questions);
      _updateState(_state.copyWith(status: ImportStatus.success));
    } catch (e) {
      _updateState(_state.copyWith(status: ImportStatus.error, errorMessage: "Database Save Failed."));
    }
  }

  void reset() {
    _updateState(QuestionImportState());
  }
}
