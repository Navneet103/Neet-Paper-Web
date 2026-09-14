import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';

abstract class TestGenerationLocalDataSource {
  Future<int> createTest(TestsCompanion test);
  Future<void> addQuestionsToTest(List<TestQuestionsCompanion> entries);
  Future<Test?> getTest(int id);
  Future<List<Question>> getQuestionsForTest(int testId);
  Future<List<Question>> getRandomQuestions({int count = 180, String? subject});
}

class TestGenerationLocalDataSourceImpl implements TestGenerationLocalDataSource {
  final AppDatabase database;

  TestGenerationLocalDataSourceImpl({required this.database});

  @override
  Future<int> createTest(TestsCompanion test) async {
    return await database.into(database.tests).insert(test);
  }

  @override
  Future<void> addQuestionsToTest(List<TestQuestionsCompanion> entries) async {
    await database.batch((batch) {
      batch.insertAll(database.testQuestions, entries);
    });
  }

  @override
  Future<Test?> getTest(int id) async {
    return await (database.select(database.tests)..where((t) => t.id.equals(id))).getSingleOrNull();
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
  Future<List<Question>> getRandomQuestions({int count = 180, String? subject}) async {
    final query = database.select(database.questions);
    if (subject != null && subject.isNotEmpty) {
      query.where((t) => t.subject.equals(subject));
    }
    
    // Simple random selection: get all then shuffle or use SQL RANDOM()
    // For large datasets, a more efficient way is needed, but for 18k questions, fetching IDs then selecting is better.
    final allQuestions = await query.get();
    final shuffled = List<Question>.from(allQuestions)..shuffle();
    return shuffled.take(count).toList();
  }
}
