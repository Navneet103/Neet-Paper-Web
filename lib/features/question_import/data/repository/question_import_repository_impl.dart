import 'dart:convert';
import 'dart:typed_data';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/storage/app_database.dart';
import '../datasource/question_import_local_datasource.dart';
import 'question_import_repository.dart';

class QuestionImportRepositoryImpl implements QuestionImportRepository {
  final QuestionImportLocalDataSource localDataSource;

  QuestionImportRepositoryImpl({required this.localDataSource});

  @override
  Future<List<QuestionsCompanion>> parseExcelFile(Uint8List bytes) async {
    try {
      final excel = Excel.decodeBytes(bytes);
      final List<QuestionsCompanion> questions = [];

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null || sheet.maxRows <= 1) continue;

        // 1. Detect Header Row
        int headerRowIndex = -1;
        Map<String, int> colMap = {};
        for (int i = 0; i < (sheet.maxRows < 15 ? sheet.maxRows : 15); i++) {
          final row = sheet.rows[i];
          for (int j = 0; j < row.length; j++) {
            final val = row[j]?.value?.toString().toLowerCase().trim() ?? '';
            if (val.contains('question') || val.contains('option a')) {
              headerRowIndex = i;
              break;
            }
          }
          if (headerRowIndex != -1) break;
        }

        if (headerRowIndex == -1) headerRowIndex = 0;

        final headerRow = sheet.rows[headerRowIndex];
        for (int i = 0; i < headerRow.length; i++) {
          final val = headerRow[i]?.value?.toString().toLowerCase().trim() ?? '';
          if (val.isNotEmpty) colMap[val] = i;
        }

        int getIdx(List<String> keys, int defaultIdx) {
          for (var key in keys) {
            for (var entry in colMap.entries) {
              if (entry.key.contains(key.toLowerCase())) return entry.value;
            }
          }
          return defaultIdx;
        }

        final qIdx = getIdx(['question'], 0);
        final aIdx = getIdx(['option a', 'opt a', 'a'], 1);
        final bIdx = getIdx(['option b', 'opt b', 'b'], 2);
        final cIdx = getIdx(['option c', 'opt c', 'c'], 3);
        final dIdx = getIdx(['option d', 'opt d', 'd'], 4);
        final ansIdx = getIdx(['correct', 'answer', 'ans'], 5);
        final marksIdx = getIdx(['marks'], 6);
        final negIdx = getIdx(['neg'], 7);
        final subIdx = getIdx(['subject'], 8);
        final topIdx = getIdx(['topic'], 9);

        // 2. Parse Data Rows with Junk Filter
        for (int i = headerRowIndex + 1; i < sheet.maxRows; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty) continue;

          String getVal(int idx) {
            if (idx >= row.length) return '';
            return row[idx]?.value?.toString().trim() ?? '';
          }

          final questionText = getVal(qIdx);
          final optA = getVal(aIdx);
          final optB = getVal(bIdx);
          final correctAns = getVal(ansIdx);

          // SKIP GHOST ROWS: If it doesn't look like a real MCQ, ignore it silently.
          if (questionText.length < 5 || optA.isEmpty || optB.isEmpty || correctAns.isEmpty) {
            continue; 
          }

          questions.add(QuestionsCompanion(
            questionText: Value(questionText),
            optionA: Value(optA),
            optionB: Value(optB),
            optionC: Value(getVal(cIdx)),
            optionD: Value(getVal(dIdx)),
            correctAnswer: Value(correctAns.toUpperCase().replaceAll('OPTION ', '').trim()),
            marks: Value(double.tryParse(getVal(marksIdx)) ?? 4.0),
            negativeMarks: Value(double.tryParse(getVal(negIdx)) ?? 1.0),
            subject: Value(getVal(subIdx).isEmpty ? 'General' : getVal(subIdx)),
            topic: Value(getVal(topIdx).isEmpty ? 'General' : getVal(topIdx)),
          ));
        }
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
