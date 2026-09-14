import '../../../../core/storage/app_database.dart';

abstract class TestGenerationRepository {
  Future<int> generateTest({
    required String name,
    required int questionCount,
    required int durationMinutes,
    required double positiveMarks,
    required double negativeMarks,
    String? subject,
    List<int>? manualQuestionIds,
  });
  
  Future<Test?> getTestById(int id);
  Future<List<Question>> getQuestionsForTest(int testId);
}
