import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';
import '../datasource/test_generation_local_datasource.dart';
import 'test_generation_repository.dart';

class TestGenerationRepositoryImpl implements TestGenerationRepository {
  final TestGenerationLocalDataSource localDataSource;

  TestGenerationRepositoryImpl({required this.localDataSource});

  @override
  Future<int> generateTest({
    required String name,
    required int questionCount,
    required int durationMinutes,
    required double positiveMarks,
    required double negativeMarks,
    String? subject,
    List<int>? manualQuestionIds,
  }) async {
    // 1. Create the test record
    final testId = await localDataSource.createTest(TestsCompanion(
      name: Value(name),
      totalQuestions: Value(questionCount),
      totalMarks: Value(questionCount * positiveMarks),
      durationMinutes: Value(durationMinutes),
      positiveMarking: Value(positiveMarks),
      negativeMarking: Value(negativeMarks),
      status: const Value('pending'),
    ));

    // 2. Select questions
    List<Question> questions = [];
    if (manualQuestionIds != null && manualQuestionIds.isNotEmpty) {
      // In a real app, you'd fetch specific IDs. For simplicity, we'll use random or selected.
      // Assuming manual selection is handled by passing IDs.
    } else {
      questions = await localDataSource.getRandomQuestions(count: questionCount, subject: subject);
    }

    // 3. Link questions to the test
    final entries = questions.asMap().entries.map((entry) {
      return TestQuestionsCompanion(
        testId: Value(testId),
        questionId: Value(entry.value.id),
        orderIndex: Value(entry.key),
      );
    }).toList();

    await localDataSource.addQuestionsToTest(entries);
    
    return testId;
  }

  @override
  Future<Test?> getTestById(int id) {
    return localDataSource.getTest(id);
  }

  @override
  Future<List<Question>> getQuestionsForTest(int testId) {
    return localDataSource.getQuestionsForTest(testId);
  }
}
