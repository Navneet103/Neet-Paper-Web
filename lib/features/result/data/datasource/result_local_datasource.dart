import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';

abstract class ResultLocalDataSource {
  Future<void> saveResult(TestResultsCompanion result);
  Future<TestResult?> getResult(int testId);
  Future<List<TypedResult>> getAnswersWithQuestions(int testId);
}

class ResultLocalDataSourceImpl implements ResultLocalDataSource {
  final AppDatabase database;

  ResultLocalDataSourceImpl({required this.database});

  @override
  Future<void> saveResult(TestResultsCompanion result) async {
    await database.into(database.testResults).insertOnConflictUpdate(result);
  }

  @override
  Future<TestResult?> getResult(int testId) async {
    return await (database.select(database.testResults)..where((t) => t.testId.equals(testId))).getSingleOrNull();
  }

  @override
  Future<List<TypedResult>> getAnswersWithQuestions(int testId) async {
    final query = database.select(database.questions).join([
      innerJoin(database.testQuestions, database.testQuestions.questionId.equalsExp(database.questions.id)),
      leftOuterJoin(database.userAnswers, database.userAnswers.questionId.equalsExp(database.questions.id) & database.userAnswers.testId.equalsExp(database.testQuestions.testId)),
    ])
      ..where(database.testQuestions.testId.equals(testId))
      ..orderBy([OrderingTerm.asc(database.testQuestions.orderIndex)]);

    return await query.get();
  }
}
