import '../../../../core/storage/app_database.dart';

abstract class ExaminationRepository {
  Future<void> startTest(int testId);
  Future<void> saveAnswer({
    required int testId,
    required int questionId,
    String? selectedOption,
    bool isMarkedForReview = false,
  });
  Future<List<UserAnswer>> getUserAnswers(int testId);
  Future<List<Question>> getQuestionsForTest(int testId); // Added for refresh recovery
  Future<void> submitTest(int testId);
  Stream<Test?> watchTest(int testId);
}
