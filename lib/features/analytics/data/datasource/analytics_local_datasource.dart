import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';

abstract class AnalyticsLocalDataSource {
  Future<List<TestResult>> getAllResults();
  Future<List<TypedResult>> getSubjectWisePerformance();
}

class AnalyticsLocalDataSourceImpl implements AnalyticsLocalDataSource {
  final AppDatabase database;

  AnalyticsLocalDataSourceImpl({required this.database});

  @override
  Future<List<TestResult>> getAllResults() async {
    return await (database.select(database.testResults)
          ..orderBy([(t) => OrderingTerm.asc(t.generatedAt)]))
        .get();
  }

  @override
  Future<List<TypedResult>> getSubjectWisePerformance() async {
    // Join questions with testQuestions to get all questions assigned to tests,
    // join tests to filter by completed status,
    // and leftOuterJoin userAnswers to see if they were answered correctly.
    final query = database.select(database.questions).join([
      innerJoin(database.testQuestions,
          database.testQuestions.questionId.equalsExp(database.questions.id)),
      innerJoin(database.tests,
          database.tests.id.equalsExp(database.testQuestions.testId)),
      leftOuterJoin(database.userAnswers,
          database.userAnswers.questionId.equalsExp(database.questions.id) &
          database.userAnswers.testId.equalsExp(database.testQuestions.testId)),
    ])..where(database.tests.status.equals('completed'));
    
    return await query.get();
  }
}
