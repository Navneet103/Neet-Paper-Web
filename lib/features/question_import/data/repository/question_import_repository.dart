import 'dart:typed_data';
import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';

abstract class QuestionImportRepository {
  Future<List<QuestionsCompanion>> parseExcelFile(Uint8List bytes);
  Future<void> saveQuestions(List<QuestionsCompanion> questions);
  Future<int> getDuplicateCount(List<QuestionsCompanion> questions);
}
