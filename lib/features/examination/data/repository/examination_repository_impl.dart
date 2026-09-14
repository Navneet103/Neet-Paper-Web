import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';
import '../datasource/examination_local_datasource.dart';
import 'examination_repository.dart';

class ExaminationRepositoryImpl implements ExaminationRepository {
  final ExaminationLocalDataSource localDataSource;

  ExaminationRepositoryImpl({required this.localDataSource});

  @override
  Future<void> startTest(int testId) async {
    await localDataSource.startTest(testId);
  }

  @override
  Future<void> saveAnswer({
    required int testId,
    required int questionId,
    String? selectedOption,
    bool isMarkedForReview = false,
  }) async {
    await localDataSource.saveAnswer(UserAnswersCompanion(
      testId: Value(testId),
      questionId: Value(questionId),
      selectedOption: Value(selectedOption),
      isMarkedForReview: Value(isMarkedForReview),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<List<UserAnswer>> getUserAnswers(int testId) {
    return localDataSource.getUserAnswers(testId);
  }

  @override
  Future<List<Question>> getQuestionsForTest(int testId) {
    return localDataSource.getQuestionsForTest(testId);
  }

  @override
  Future<void> submitTest(int testId) async {
    await localDataSource.submitTest(testId, 'completed');
  }

  @override
  Stream<Test?> watchTest(int testId) {
    return localDataSource.watchTest(testId);
  }
}
