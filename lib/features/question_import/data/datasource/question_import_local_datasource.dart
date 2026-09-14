import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';

abstract class QuestionImportLocalDataSource {
  Future<void> insertQuestions(List<QuestionsCompanion> questions);
  Future<int> checkDuplicate(String questionText);
}

class QuestionImportLocalDataSourceImpl implements QuestionImportLocalDataSource {
  final AppDatabase database;

  QuestionImportLocalDataSourceImpl({required this.database});

  @override
  Future<void> insertQuestions(List<QuestionsCompanion> questions) async {
    await database.batch((batch) {
      batch.insertAll(database.questions, questions, mode: InsertMode.insertOrReplace);
    });
  }

  @override
  Future<int> checkDuplicate(String questionText) async {
    final query = database.select(database.questions)
      ..where((t) => t.questionText.equals(questionText));
    final result = await query.get();
    return result.length;
  }
}
