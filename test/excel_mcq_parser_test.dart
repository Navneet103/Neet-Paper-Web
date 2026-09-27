import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neet_paper_test/core/utils/excel_mcq_parser.dart';

void main() {
  group('ExcelMcqParser Tests', () {
    test('Correctly maps Option 1, Option 2, Option 3, Option 4 without putting subject in options', () {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];
      sheet.appendRow([
        TextCellValue('Question'),
        TextCellValue('Option 1'),
        TextCellValue('Option 2'),
        TextCellValue('Option 3'),
        TextCellValue('Option 4'),
        TextCellValue('Answer'),
        TextCellValue('Subject'),
      ]);
      sheet.appendRow([
        TextCellValue('What is the SI unit of force?'),
        TextCellValue('Newton'),
        TextCellValue('Joule'),
        TextCellValue('Watt'),
        TextCellValue('Pascal'),
        TextCellValue('1'),
        TextCellValue('physics'),
      ]);

      final bytes = Uint8List.fromList(excel.encode()!);
      final questions = ExcelMcqParser.parseBytes(bytes);

      expect(questions.length, 1);
      final q = questions.first;
      expect(q.questionText, 'What is the SI unit of force?');
      expect(q.optionA, 'Newton');
      expect(q.optionB, 'Joule');
      expect(q.optionC, 'Watt');
      expect(q.optionD, 'Pascal');
      expect(q.correctAnswer, 'A');
      expect(q.subject, 'Physics');
    });

    test('Correctly handles A, B, C, D headers', () {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];
      sheet.appendRow([
        TextCellValue('Q.No'),
        TextCellValue('Question'),
        TextCellValue('A'),
        TextCellValue('B'),
        TextCellValue('C'),
        TextCellValue('D'),
        TextCellValue('Ans'),
        TextCellValue('Subject'),
      ]);
      sheet.appendRow([
        IntCellValue(1),
        TextCellValue('Formula of water?'),
        TextCellValue('H2O'),
        TextCellValue('CO2'),
        TextCellValue('NaCl'),
        TextCellValue('CH4'),
        TextCellValue('A'),
        TextCellValue('chemistry'),
      ]);

      final bytes = Uint8List.fromList(excel.encode()!);
      final questions = ExcelMcqParser.parseBytes(bytes);

      expect(questions.length, 1);
      final q = questions.first;
      expect(q.optionA, 'H2O');
      expect(q.optionB, 'CO2');
      expect(q.optionC, 'NaCl');
      expect(q.optionD, 'CH4');
      expect(q.correctAnswer, 'A');
      expect(q.subject, 'Chemistry');
    });

    test('Deduplicates duplicate sheets or questions', () {
      final excel = Excel.createExcel();
      final sheet1 = excel['Sheet1'];
      sheet1.appendRow([
        TextCellValue('Question'),
        TextCellValue('Option A'),
        TextCellValue('Option B'),
        TextCellValue('Option C'),
        TextCellValue('Option D'),
        TextCellValue('Answer'),
      ]);
      sheet1.appendRow([
        TextCellValue('Same question text?'),
        TextCellValue('Opt A'),
        TextCellValue('Opt B'),
        TextCellValue('Opt C'),
        TextCellValue('Opt D'),
        TextCellValue('B'),
      ]);

      final sheet2 = excel['Sheet2'];
      sheet2.appendRow([
        TextCellValue('Question'),
        TextCellValue('Option A'),
        TextCellValue('Option B'),
        TextCellValue('Option C'),
        TextCellValue('Option D'),
        TextCellValue('Answer'),
      ]);
      sheet2.appendRow([
        TextCellValue('Same question text?'),
        TextCellValue('Opt A'),
        TextCellValue('Opt B'),
        TextCellValue('Opt C'),
        TextCellValue('Opt D'),
        TextCellValue('B'),
      ]);

      final bytes = Uint8List.fromList(excel.encode()!);
      final questions = ExcelMcqParser.parseBytes(bytes);

      expect(questions.length, 1);
    });
  });
}
