import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../injection/injection_container.dart';
import '../datasource/result_local_datasource.dart';
import 'result_repository.dart';

class ResultRepositoryImpl implements ResultRepository {
  final ResultLocalDataSource localDataSource;

  ResultRepositoryImpl({required this.localDataSource});

  @override
  Future<TestResult> calculateAndSaveResult(int testId) async {
    final db = sl<AppDatabase>();
    
    // 1. Fetch Test configuration for marking rules
    final test = await (db.select(db.tests)..where((t) => t.id.equals(testId))).getSingle();
    final data = await localDataSource.getAnswersWithQuestions(testId);

    int attempted = 0;
    int correct = 0;
    int wrong = 0;
    double score = 0;

    for (final row in data) {
      final question = row.readTable(db.questions);
      final answer = row.readTableOrNull(db.userAnswers);

      if (answer?.selectedOption != null && answer!.selectedOption!.isNotEmpty) {
        attempted++;
        if (answer.selectedOption == question.correctAnswer) {
          correct++;
          score += test.positiveMarking;
        } else {
          wrong++;
          score -= test.negativeMarking;
        }
      }
    }

    final accuracy = attempted > 0 ? (correct / attempted) * 100 : 0.0;
    
    // 2. Calculate time taken
    int timeTaken = 0;
    if (test.startedAt != null) {
      final endTime = test.completedAt ?? DateTime.now();
      timeTaken = endTime.difference(test.startedAt!).inSeconds;
    }
    
    final resultCompanion = TestResultsCompanion(
      testId: Value(testId),
      attemptedCount: Value(attempted),
      correctCount: Value(correct),
      wrongCount: Value(wrong),
      finalScore: Value(score),
      accuracy: Value(accuracy),
      timeTakenSeconds: Value(timeTaken),
    );

    await localDataSource.saveResult(resultCompanion);
    return (await localDataSource.getResult(testId))!;
  }

  @override
  Future<TestResult?> getResultByTestId(int testId) {
    return localDataSource.getResult(testId);
  }

  @override
  Future<List<Map<String, dynamic>>> getDetailedReview(int testId) async {
    final data = await localDataSource.getAnswersWithQuestions(testId);
    final db = sl<AppDatabase>();
    
    return data.map((row) {
      final question = row.readTable(db.questions);
      final answer = row.readTableOrNull(db.userAnswers);
      
      bool isCorrect = answer?.selectedOption == question.correctAnswer;
      bool isUnattempted = answer?.selectedOption == null || answer!.selectedOption!.isEmpty;

      return {
        'question': question,
        'selectedAnswer': answer?.selectedOption,
        'isCorrect': isCorrect,
        'isUnattempted': isUnattempted,
        'marksEarned': isUnattempted ? 0.0 : (isCorrect ? question.marks : -question.negativeMarks),
      };
    }).toList();
  }
}
