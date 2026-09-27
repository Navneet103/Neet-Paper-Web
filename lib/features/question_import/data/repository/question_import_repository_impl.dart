import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/utils/excel_mcq_parser.dart';
import '../datasource/question_import_local_datasource.dart';
import 'question_import_repository.dart';

class QuestionImportRepositoryImpl implements QuestionImportRepository {
  final QuestionImportLocalDataSource localDataSource;

  QuestionImportRepositoryImpl({required this.localDataSource});

  @override
  Future<List<QuestionsCompanion>> parseExcelFile(Uint8List bytes) async {
    try {
      final parsed = ExcelMcqParser.parseBytes(bytes);
      final List<QuestionsCompanion> questions = [];

      for (var q in parsed) {
        questions.add(QuestionsCompanion(
          questionText: Value(q.questionText),
          optionA: Value(q.optionA),
          optionB: Value(q.optionB),
          optionC: Value(q.optionC),
          optionD: Value(q.optionD),
          correctAnswer: Value(q.correctAnswer),
          marks: Value(q.marks),
          negativeMarks: Value(q.negativeMarks),
          subject: Value(q.subject),
          topic: Value(q.topic),
        ));
      }

      return questions;
    } catch (e) {
      throw Exception('Format Error: Please ensure your file is a valid XLSX MCQ bank.');
    }
  }

  @override
  Future<void> saveQuestions(List<QuestionsCompanion> questions) async {
    await localDataSource.insertQuestions(questions);
  }

  @override
  Future<int> getDuplicateCount(List<QuestionsCompanion> questions) async {
    int duplicates = 0;
    for (var q in questions) {
      final count = await localDataSource.checkDuplicate(q.questionText.value);
      if (count > 0) duplicates++;
    }
    return duplicates;
  }
}
