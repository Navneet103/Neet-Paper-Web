import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart' hide Border;

/// Normalized data representation of a parsed MCQ row from an Excel spreadsheet.
class RawParsedQuestion {
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final double marks;
  final double negativeMarks;
  final String subject;
  final String topic;

  const RawParsedQuestion({
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    this.marks = 4.0,
    this.negativeMarks = 1.0,
    this.subject = 'General',
    this.topic = 'General',
  });
}

class ExcelMcqParser {
  /// Standardize subject names (e.g., 'physics' -> 'Physics', 'botany' -> 'Botany', etc.)
  static String normalizeSubject(String? raw) {
    if (raw == null) return 'General';
    final s = raw.trim();
    if (s.isEmpty) return 'General';
    final lower = s.toLowerCase();
    if (lower.startsWith('phy')) return 'Physics';
    if (lower.startsWith('chem')) return 'Chemistry';
    if (lower.startsWith('bio')) return 'Biology';
    if (lower.startsWith('bot')) return 'Botany';
    if (lower.startsWith('zoo')) return 'Zoology';

    // Capitalize each word nicely
    return s.split(RegExp(r'\s+')).map((w) {
      if (w.isEmpty) return '';
      return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
    }).join(' ');
  }

  /// Standardize answer keys to 'A', 'B', 'C', or 'D'.
  /// Handles:
  /// - 'A', 'B', 'C', 'D' (case-insensitive, with brackets/parens/dots)
  /// - '1', '2', '3', '4' -> mapped to 'A', 'B', 'C', 'D'
  /// - 'Option 1', 'Option A', 'Choice 1', etc.
  /// - Matching against Option A, B, C, D text itself
  static String normalizeAnswer(
    String? raw, {
    String optionA = '',
    String optionB = '',
    String optionC = '',
    String optionD = '',
  }) {
    if (raw == null || raw.trim().isEmpty) return 'A';

    var ans = raw.trim().toUpperCase();
    ans = ans.replaceAll(RegExp(r'^(OPTION|OPT|CHOICE|ANS|ANSWER)[\s:\-\.]*', caseSensitive: false), '').trim();
    ans = ans.replaceAll(RegExp(r'[\(\)\[\]\.]'), '').trim();

    // 1-4 numeric mapping
    if (ans == '1') return 'A';
    if (ans == '2') return 'B';
    if (ans == '3') return 'C';
    if (ans == '4') return 'D';

    // Direct A-D letter
    if (ans == 'A' || ans == 'B' || ans == 'C' || ans == 'D') return ans;

    // Check if the answer cell contains the text of one of the options
    final rawLower = raw.trim().toLowerCase();
    if (rawLower.isNotEmpty) {
      if (optionA.trim().isNotEmpty && rawLower == optionA.trim().toLowerCase()) return 'A';
      if (optionB.trim().isNotEmpty && rawLower == optionB.trim().toLowerCase()) return 'B';
      if (optionC.trim().isNotEmpty && rawLower == optionC.trim().toLowerCase()) return 'C';
      if (optionD.trim().isNotEmpty && rawLower == optionD.trim().toLowerCase()) return 'D';
    }

    // Check first character if starts with A-D
    if (ans.isNotEmpty && (ans[0] == 'A' || ans[0] == 'B' || ans[0] == 'C' || ans[0] == 'D')) {
      return ans[0];
    }

    return ans.isNotEmpty ? ans : 'A';
  }

  /// Parse binary Excel bytes (.xlsx) into a verified, deduplicated list of questions.
  static List<RawParsedQuestion> parseBytes(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final List<RawParsedQuestion> questions = [];
    final Set<String> seenQuestions = {};

    for (var tableName in excel.tables.keys) {
      final sheet = excel.tables[tableName];
      if (sheet == null || sheet.maxRows <= 1) continue;

      // Detect sheet subject if table is named e.g. "Physics", "Chemistry", "Biology"
      final sheetSubject = normalizeSubject(tableName);

      // 1. Detect Header Row with scoring mechanism
      int headerRowIndex = -1;
      Map<int, String> colIndexToHeader = {};

      final rowsToScan = sheet.maxRows < 20 ? sheet.maxRows : 20;
      for (int i = 0; i < rowsToScan; i++) {
        final row = sheet.rows[i];
        int score = 0;
        for (int j = 0; j < row.length; j++) {
          final val = row[j]?.value?.toString().toLowerCase().trim() ?? '';
          if (val.isEmpty) continue;

          if (val == 'question' || val == 'question text' || val == 'questions' || val == 'q' || val == 'problem') {
            score += 3;
          } else if (val.contains('question')) {
            score += 2;
          }
          if (val == 'option a' || val == 'option 1' || val == 'opt a' || val == 'opt 1' || val == '(a)' || val == 'a') {
            score += 2;
          }
          if (val == 'option b' || val == 'option 2' || val == 'opt b' || val == 'opt 2' || val == '(b)' || val == 'b') {
            score += 2;
          }
          if (val == 'answer' || val == 'ans' || val == 'correct' || val == 'key') {
            score += 2;
          }
        }

        if (score >= 4) {
          headerRowIndex = i;
          break;
        }
      }

      // If no definitive header detected, assume row 0
      if (headerRowIndex == -1) headerRowIndex = 0;

      final headerRow = sheet.rows[headerRowIndex];
      for (int j = 0; j < headerRow.length; j++) {
        final val = headerRow[j]?.value?.toString().toLowerCase().trim() ?? '';
        if (val.isNotEmpty) {
          colIndexToHeader[j] = val;
        }
      }

      // 2. Identify Column Indices accurately
      int qIdx = -1;
      int aIdx = -1;
      int bIdx = -1;
      int cIdx = -1;
      int dIdx = -1;
      int ansIdx = -1;
      int marksIdx = -1;
      int negIdx = -1;
      int subIdx = -1;
      int topIdx = -1;

      // Pass 1: High-confidence exact matches
      for (var entry in colIndexToHeader.entries) {
        final col = entry.key;
        final h = entry.value;

        // Question column
        if (qIdx == -1) {
          if (h == 'question' || h == 'question text' || h == 'questiontext' ||
              h == 'q_text' || h == 'problem' || h == 'questions' || h == 'q.text') {
            qIdx = col;
            continue;
          }
        }

        // Option A / 1
        if (aIdx == -1) {
          if (h == 'option a' || h == 'option 1' || h == 'option_a' || h == 'option_1' ||
              h == 'opt a' || h == 'opt 1' || h == 'opt_a' || h == 'opt_1' ||
              h == 'opta' || h == 'opt1' || h == 'optiona' || h == 'option1' ||
              h == '(a)' || h == '[a]' || h == 'a' || h == '1' ||
              h == 'choice a' || h == 'choice 1' || h == 'ans a' || h == 'ans 1') {
            aIdx = col;
            continue;
          }
        }

        // Option B / 2
        if (bIdx == -1) {
          if (h == 'option b' || h == 'option 2' || h == 'option_b' || h == 'option_2' ||
              h == 'opt b' || h == 'opt 2' || h == 'opt_b' || h == 'opt_2' ||
              h == 'optb' || h == 'opt2' || h == 'optionb' || h == 'option2' ||
              h == '(b)' || h == '[b]' || h == 'b' || h == '2' ||
              h == 'choice b' || h == 'choice 2' || h == 'ans b' || h == 'ans 2') {
            bIdx = col;
            continue;
          }
        }

        // Option C / 3
        if (cIdx == -1) {
          if (h == 'option c' || h == 'option 3' || h == 'option_c' || h == 'option_3' ||
              h == 'opt c' || h == 'opt 3' || h == 'opt_c' || h == 'opt_3' ||
              h == 'optc' || h == 'opt3' || h == 'optionc' || h == 'option3' ||
              h == '(c)' || h == '[c]' || h == 'c' || h == '3' ||
              h == 'choice c' || h == 'choice 3' || h == 'ans c' || h == 'ans 3') {
            cIdx = col;
            continue;
          }
        }

        // Option D / 4
        if (dIdx == -1) {
          if (h == 'option d' || h == 'option 4' || h == 'option_d' || h == 'option_4' ||
              h == 'opt d' || h == 'opt 4' || h == 'opt_d' || h == 'opt_4' ||
              h == 'optd' || h == 'opt4' || h == 'optiond' || h == 'option4' ||
              h == '(d)' || h == '[d]' || h == 'd' || h == '4' ||
              h == 'choice d' || h == 'choice 4' || h == 'ans d' || h == 'ans 4') {
            dIdx = col;
            continue;
          }
        }

        // Answer
        if (ansIdx == -1) {
          if (h == 'answer' || h == 'ans' || h == 'correct' || h == 'correct answer' ||
              h == 'correct option' || h == 'correct ans' || h == 'key' || h == 'answer key' ||
              h == 'correct_answer' || h == 'correct_option' || h == 'right answer' || h == 'ans key') {
            ansIdx = col;
            continue;
          }
        }

        // Marks
        if (marksIdx == -1) {
          if (h == 'marks' || h == 'mark' || h == 'positive marks' || h == 'pos marks' || h == 'weightage') {
            marksIdx = col;
            continue;
          }
        }

        // Negative Marks
        if (negIdx == -1) {
          if (h == 'negative marks' || h == 'neg marks' || h == 'negative' || h == 'penalty' || h == 'neg') {
            negIdx = col;
            continue;
          }
        }

        // Subject
        if (subIdx == -1) {
          if (h == 'subject' || h == 'subject name' || h == 'subject_name' || h == 'course' || h == 'sub') {
            subIdx = col;
            continue;
          }
        }

        // Topic
        if (topIdx == -1) {
          if (h == 'topic' || h == 'chapter' || h == 'unit' || h == 'lesson' || h == 'subtopic') {
            topIdx = col;
            continue;
          }
        }
      }

      // Pass 2: Secondary heuristic if still not found
      if (qIdx == -1) {
        for (var entry in colIndexToHeader.entries) {
          if (entry.value.contains('question') && !entry.value.contains('number') && !entry.value.contains('no')) {
            qIdx = entry.key;
            break;
          }
        }
      }
      if (qIdx == -1) qIdx = 0;

      // If options were not found by name, assign sequentially after question
      if (aIdx == -1 && bIdx == -1 && cIdx == -1 && dIdx == -1) {
        aIdx = qIdx + 1;
        bIdx = qIdx + 2;
        cIdx = qIdx + 3;
        dIdx = qIdx + 4;
      }

      if (ansIdx == -1) {
        for (var entry in colIndexToHeader.entries) {
          if (entry.value.contains('ans') || entry.value.contains('correct') || entry.value.contains('key')) {
            ansIdx = entry.key;
            break;
          }
        }
      }
      if (ansIdx == -1) ansIdx = dIdx + 1;

      if (subIdx == -1) {
        for (var entry in colIndexToHeader.entries) {
          if (entry.value.contains('subject')) {
            subIdx = entry.key;
            break;
          }
        }
      }

      // 3. Parse Data Rows
      for (int i = headerRowIndex + 1; i < sheet.maxRows; i++) {
        final row = sheet.rows[i];
        if (row.isEmpty) continue;

        String getVal(int idx) {
          if (idx < 0 || idx >= row.length) return '';
          final cell = row[idx];
          if (cell == null) return '';
          final v = cell.value;
          if (v == null) return '';
          return v.toString().trim();
        }

        final questionText = getVal(qIdx);
        final optA = getVal(aIdx);
        final optB = getVal(bIdx);
        final optC = getVal(cIdx);
        final optD = getVal(dIdx);
        final rawAns = getVal(ansIdx);
        final rawMarks = marksIdx != -1 ? getVal(marksIdx) : '';
        final rawNeg = negIdx != -1 ? getVal(negIdx) : '';
        final rawSub = subIdx != -1 ? getVal(subIdx) : '';
        final rawTop = topIdx != -1 ? getVal(topIdx) : '';

        // Discard junk / empty rows
        if (questionText.length < 3 || optA.isEmpty || optB.isEmpty) {
          continue;
        }

        // Deduplicate duplicate rows across sheets or repetitive tables
        final normalizedQKey = questionText.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
        if (seenQuestions.contains(normalizedQKey)) {
          continue;
        }
        seenQuestions.add(normalizedQKey);

        final resolvedSubject = rawSub.isNotEmpty
            ? normalizeSubject(rawSub)
            : (sheetSubject != 'General' ? sheetSubject : 'General');

        final resolvedAnswer = normalizeAnswer(
          rawAns,
          optionA: optA,
          optionB: optB,
          optionC: optC,
          optionD: optD,
        );

        questions.add(RawParsedQuestion(
          questionText: questionText,
          optionA: optA,
          optionB: optB,
          optionC: optC,
          optionD: optD,
          correctAnswer: resolvedAnswer,
          marks: double.tryParse(rawMarks) ?? 4.0,
          negativeMarks: double.tryParse(rawNeg) ?? 1.0,
          subject: resolvedSubject,
          topic: rawTop.isNotEmpty ? rawTop : 'General',
        ));
      }
    }

    return questions;
  }
}
