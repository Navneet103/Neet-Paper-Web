import '../datasource/test_history_local_datasource.dart';
import 'test_history_repository.dart';

class TestHistoryRepositoryImpl implements TestHistoryRepository {
  final TestHistoryLocalDataSource localDataSource;

  TestHistoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Map<String, dynamic>>> getHistory() async {
    final tests = await localDataSource.getCompletedTests();
    final List<Map<String, dynamic>> history = [];

    for (var test in tests) {
      final result = await localDataSource.getResultForTest(test.id);
      history.add({
        'test': test,
        'result': result,
      });
    }

    return history;
  }
}
