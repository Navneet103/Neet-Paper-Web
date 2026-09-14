import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';

abstract class ExaminationLocalDataSource {
  Future<void> startTest(int testId);
  Future<void> saveAnswer(UserAnswersCompanion answer);
  Future<List<UserAnswer>> getUserAnswers(int testId);
  Future<List<Question>> getQuestionsForTest(int testId);
  Future<void> submitTest(int testId, String status);
  Stream<Test?> watchTest(int testId);
}

class ExaminationLocalDataSourceImpl implements ExaminationLocalDataSource {
  final AppDatabase database;

  ExaminationLocalDataSourceImpl({required this.database});

  @override
  Future<void> startTest(int testId) async {
    await (database.update(database.tests)..where((t) => t.id.equals(testId))).write(
      TestsCompanion(
        startedAt: Value(DateTime.now()),
        status: const Value('ongoing'),
      ),
    );
  }

  @override
  Future<void> saveAnswer(UserAnswersCompanion answer) async {
    await database.into(database.userAnswers).insertOnConflictUpdate(answer);
  }

  @override
  Future<List<UserAnswer>> getUserAnswers(int testId) async {
    return await (database.select(database.userAnswers)..where((t) => t.testId.equals(testId))).get();
  }

  @override
  Future<List<Question>> getQuestionsForTest(int testId) async {
    final query = database.select(database.questions).join([
      innerJoin(database.testQuestions, database.testQuestions.questionId.equalsExp(database.questions.id)),
    ])
      ..where(database.testQuestions.testId.equals(testId))
      ..orderBy([OrderingTerm.asc(database.testQuestions.orderIndex)]);

    final result = await query.get();
    return result.map((row) => row.readTable(database.questions)).toList();
  }

  @override
  Future<void> submitTest(int testId, String status) async {
    await (database.update(database.tests)..where((t) => t.id.equals(testId))).write(
      TestsCompanion(
        completedAt: Value(DateTime.now()),
        status: Value(status),
      ),
    );
  }

  @override
  Stream<Test?> watchTest(int testId) {
    return (database.select(database.tests)..where((t) => t.id.equals(testId))).watchSingleOrNull();
  }
}
