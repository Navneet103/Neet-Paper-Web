import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/utils/excel_mcq_parser.dart';

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
      query.where((t) => t.subject.collate(Collate.noCase).equals(subject));
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
      query.where((t) => t.subject.collate(Collate.noCase).equals(subject));
    }

    final result = await query.get();
    return result.length;
  }

  @override
  Future<List<String>> getSubjects() async {
    final query = database.selectOnly(database.questions, distinct: true)
      ..addColumns([database.questions.subject]);
    
    final result = await query.map((row) => row.read(database.questions.subject)).get();
    final set = <String>{};
    for (var s in result) {
      if (s != null && s.trim().isNotEmpty) {
        set.add(ExcelMcqParser.normalizeSubject(s));
      }
    }
    final list = set.toList();
    list.sort((a, b) {
      final order = {'Physics': 1, 'Chemistry': 2, 'Biology': 3, 'Botany': 4, 'Zoology': 5};
      final oa = order[a] ?? 100;
      final ob = order[b] ?? 100;
      if (oa != ob) return oa.compareTo(ob);
      return a.compareTo(b);
    });
    return list;
  }
}
