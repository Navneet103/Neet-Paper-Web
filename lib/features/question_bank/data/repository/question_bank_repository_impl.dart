import '../../../../core/storage/app_database.dart';
import '../datasource/question_bank_local_datasource.dart';
import 'question_bank_repository.dart';

class QuestionBankRepositoryImpl implements QuestionBankRepository {
  final QuestionBankLocalDataSource localDataSource;

  QuestionBankRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Question>> getQuestions({int limit = 50, int offset = 0, String? searchQuery, String? subject}) {
    return localDataSource.getQuestions(limit: limit, offset: offset, searchQuery: searchQuery, subject: subject);
  }

  @override
  Future<int> getTotalCount({String? searchQuery, String? subject}) {
    return localDataSource.getTotalCount(searchQuery: searchQuery, subject: subject);
  }

  @override
  Future<List<String>> getSubjects() {
    return localDataSource.getSubjects();
  }
}
