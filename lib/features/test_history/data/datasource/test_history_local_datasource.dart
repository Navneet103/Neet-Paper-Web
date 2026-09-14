import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';

abstract class TestHistoryLocalDataSource {
  Future<List<Test>> getCompletedTests();
  Future<TestResult?> getResultForTest(int testId);
}

class TestHistoryLocalDataSourceImpl implements TestHistoryLocalDataSource {
  final AppDatabase database;

  TestHistoryLocalDataSourceImpl({required this.database});

  @override
  Future<List<Test>> getCompletedTests() async {
    return await (database.select(database.tests)
      ..where((t) => t.status.equals('completed'))
      ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
      .get();
  }

  @override
  Future<TestResult?> getResultForTest(int testId) async {
    return await (database.select(database.testResults)..where((t) => t.testId.equals(testId))).getSingleOrNull();
  }
}
