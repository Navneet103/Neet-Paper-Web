import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';

abstract class ResultLocalDataSource {
  Future<void> saveResult(TestResultsCompanion result);
  Future<TestResult?> getResult(int testId);
  Future<Test?> getTest(int testId);
  Future<List<TypedResult>> getAnswersWithQuestions(int testId);
}

class ResultLocalDataSourceImpl implements ResultLocalDataSource {
  final AppDatabase database;

  ResultLocalDataSourceImpl({required this.database});

  @override
  Future<void> saveResult(TestResultsCompanion result) async {
    final existing = await (database.select(database.testResults)
          ..where((r) => r.testId.equals(result.testId.value)))
        .getSingleOrNull();

    if (existing != null) {
      await (database.update(database.testResults)
            ..where((r) => r.id.equals(existing.id)))
          .write(result);
    } else {
      await database.into(database.testResults).insert(result);
    }
  }

  @override
  Future<TestResult?> getResult(int testId) async {
    return await (database.select(database.testResults)..where((t) => t.testId.equals(testId))).getSingleOrNull();
  }

  @override
  Future<Test?> getTest(int testId) async {
    return await (database.select(database.tests)..where((t) => t.id.equals(testId))).getSingleOrNull();
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
