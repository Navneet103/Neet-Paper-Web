import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/firebase/firebase_test_service.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../injection/injection_container.dart';
import '../datasource/result_local_datasource.dart';
import 'result_repository.dart';

class ResultRepositoryImpl implements ResultRepository {
  final ResultLocalDataSource localDataSource;

  ResultRepositoryImpl({required this.localDataSource});

  @override
  Future<TestResult> calculateAndSaveResult(int testId, {String? testDocId}) async {
    final db = sl<AppDatabase>();
    
    // 1. Fetch Test configuration for marking rules
    final test = await (db.select(db.tests)..where((t) => t.id.equals(testId))).getSingle();
    final data = await localDataSource.getAnswersWithQuestions(testId);

    int attempted = 0;
    int correct = 0;
    int wrong = 0;
    double score = 0;

    for (final row in data) {
      final question = row.readTable(db.questions);
      final answer = row.readTableOrNull(db.userAnswers);

      if (answer?.selectedOption != null && answer!.selectedOption!.isNotEmpty) {
        attempted++;
        if (answer.selectedOption == question.correctAnswer) {
          correct++;
          score += test.positiveMarking;
        } else {
          wrong++;
          score -= test.negativeMarking;
        }
      }
    }

    final accuracy = attempted > 0 ? (correct / attempted) * 100 : 0.0;
    
    // 2. Calculate time taken
    int timeTaken = 0;
    if (test.startedAt != null) {
      final endTime = test.completedAt ?? DateTime.now();
      timeTaken = endTime.difference(test.startedAt!).inSeconds;
      if (timeTaken < 0) timeTaken = 0;
    }
    
    final resultCompanion = TestResultsCompanion(
      testId: Value(testId),
      attemptedCount: Value(attempted),
      correctCount: Value(correct),
      wrongCount: Value(wrong),
      finalScore: Value(score),
      accuracy: Value(accuracy),
      timeTakenSeconds: Value(timeTaken),
    );

    await localDataSource.saveResult(resultCompanion);

    // 3. Sync to Firebase Cloud DB (test_submissions collection)
    try {
      final unattempted = test.totalQuestions - attempted;
      final auth = sl.isRegistered<AuthService>() ? sl<AuthService>() : null;
      final currentUser = auth?.currentUser;
      final fbUser = FirebaseAuth.instance.currentUser;

      final resolvedUid = currentUser?.uid ?? fbUser?.uid;
      final resolvedEmail = currentUser?.email ?? fbUser?.email;
      String resolvedName = 'Aspirant';
      if (currentUser?.displayName != null && currentUser!.displayName.isNotEmpty) {
        resolvedName = currentUser.displayName;
      } else if (fbUser?.displayName != null && fbUser!.displayName!.isNotEmpty) {
        resolvedName = fbUser.displayName!;
      } else if (resolvedEmail != null && resolvedEmail.contains('@')) {
        resolvedName = resolvedEmail.split('@').first;
      }

      final Map<String, String> answersMap = {};
      for (final row in data) {
        final tq = row.readTable(db.testQuestions);
        final q = row.readTable(db.questions);
        final a = row.readTableOrNull(db.userAnswers);
        if (a?.selectedOption != null && a!.selectedOption!.isNotEmpty) {
          final chosenOpt = a.selectedOption!;
          // Map by 1-indexed question number, 0-indexed question index, and SQLite ID
          // to ensure review dialogs and admin panels on any device can read the answer accurately.
          answersMap['${tq.orderIndex + 1}'] = chosenOpt;
          answersMap['${tq.orderIndex}'] = chosenOpt;
          answersMap[q.id.toString()] = chosenOpt;
        }
      }

      final submissionId = resolvedUid != null
          ? '${resolvedUid}_${testId}_${DateTime.now().millisecondsSinceEpoch}'
          : '${testId}_${DateTime.now().millisecondsSinceEpoch}';

      String? resolvedDocId = testDocId;
      if (resolvedDocId == null || resolvedDocId.isEmpty) {
        try {
          final cloudTest = await sl<FirebaseTestService>().findTestByIdOrTitle(test.name);
          resolvedDocId = cloudTest?.id;
        } catch (_) {}
      }

      final submission = TestSubmission(
        id: submissionId,
        testId: test.name,
        testDocId: resolvedDocId,
        studentName: resolvedName,
        studentUid: resolvedUid,
        studentEmail: resolvedEmail,
        score: score,
        totalMarks: test.totalMarks,
        correctCount: correct,
        wrongCount: wrong,
        unattemptedCount: unattempted > 0 ? unattempted : 0,
        accuracy: accuracy,
        timeTakenSeconds: timeTaken,
        submittedAt: DateTime.now(),
        answers: answersMap,
      );

      if (sl.isRegistered<FirebaseTestService>()) {
        await sl<FirebaseTestService>().submitResult(submission);
        debugPrint("Successfully saved & synced test submission $submissionId to Firebase Firestore");
      }
    } catch (e, stack) {
      debugPrint("Warning: Cloud submission sync encountered error: $e\n$stack");
    }

    return (await localDataSource.getResult(testId))!;
  }

  @override
  Future<TestResult?> getResultByTestId(int testId) {
    return localDataSource.getResult(testId);
  }

  @override
  Future<Test?> getTest(int testId) {
    return localDataSource.getTest(testId);
  }

  @override
  Future<List<Map<String, dynamic>>> getDetailedReview(int testId) async {
    final data = await localDataSource.getAnswersWithQuestions(testId);
    final db = sl<AppDatabase>();
    
    return data.map((row) {
      final question = row.readTable(db.questions);
      final answer = row.readTableOrNull(db.userAnswers);
      
      bool isCorrect = answer?.selectedOption == question.correctAnswer;
      bool isUnattempted = answer?.selectedOption == null || answer!.selectedOption!.isEmpty;

      return {
        'question': question,
        'selectedAnswer': answer?.selectedOption,
        'isCorrect': isCorrect,
        'isUnattempted': isUnattempted,
        'marksEarned': isUnattempted ? 0.0 : (isCorrect ? question.marks : -question.negativeMarks),
      };
    }).toList();
  }
}
