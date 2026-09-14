import '../../../../core/storage/app_database.dart';

abstract class ResultRepository {
  Future<TestResult> calculateAndSaveResult(int testId);
  Future<TestResult?> getResultByTestId(int testId);
  Future<List<Map<String, dynamic>>> getDetailedReview(int testId);
}
