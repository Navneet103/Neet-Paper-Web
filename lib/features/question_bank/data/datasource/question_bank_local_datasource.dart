import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';

abstract class QuestionBankLocalDataSource {
  Future<List<Question>> getQuestions({int limit = 50, int offset = 0, String? searchQuery, String? subject});
  Future<int> getTotalCount({String? searchQuery, String? subject});
  Future<List<String>> getSubjects();
}

class QuestionBankLocalDataSourceImpl implements QuestionBankLocalDataSource {
  final AppDatabase database;

  QuestionBankLocalDataSourceImpl({required this.database});

  @override
  Future<List<Question>> getQuestions({int limit = 50, int offset = 0, String? searchQuery, String? subject}) async {
    final query = database.select(database.questions);
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((t) => t.questionText.contains(searchQuery));
    }
    
    if (subject != null && subject.isNotEmpty) {
      query.where((t) => t.subject.equals(subject));
    }

    query.limit(limit, offset: offset);
    return await query.get();
  }

  @override
  Future<int> getTotalCount({String? searchQuery, String? subject}) async {
    final query = database.select(database.questions);
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((t) => t.questionText.contains(searchQuery));
    }
    
    if (subject != null && subject.isNotEmpty) {
      query.where((t) => t.subject.equals(subject));
    }

    final result = await query.get();
    return result.length;
  }

  @override
  Future<List<String>> getSubjects() async {
    final query = database.selectOnly(database.questions, distinct: true)
      ..addColumns([database.questions.subject]);
    
    final result = await query.map((row) => row.read(database.questions.subject)).get();
    return result.whereType<String>().toList();
  }
}
