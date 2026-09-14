import '../../../../core/storage/app_database.dart';

abstract class QuestionBankRepository {
  Future<List<Question>> getQuestions({int limit = 50, int offset = 0, String? searchQuery, String? subject});
  Future<int> getTotalCount({String? searchQuery, String? subject});
  Future<List<String>> getSubjects();
}
