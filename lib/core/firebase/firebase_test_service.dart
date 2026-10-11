import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' show Value, InsertMode, OrderingTerm, innerJoin;
import '../storage/app_database.dart';
import '../time/ist_clock.dart';
import '../utils/excel_mcq_parser.dart';

class LocalExamSession {
  final int testId;
  final List<Question> questions;
  final String? testDocId;

  const LocalExamSession({
    required this.testId,
    required this.questions,
    this.testDocId,
  });
}

class FirebaseQuestion {
  final int id;
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

  const FirebaseQuestion({
    required this.id,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': correctAnswer.trim().toUpperCase(),
      'marks': marks,
      'negativeMarks': negativeMarks,
      'subject': subject,
      'topic': topic,
    };
  }

  factory FirebaseQuestion.fromMap(Map<String, dynamic> map, int fallbackId) {
    return FirebaseQuestion(
      id: map['id'] is int
          ? map['id']
          : (int.tryParse('${map['id']}') ?? fallbackId),
      questionText: map['questionText'] ?? '',
      optionA: map['optionA'] ?? '',
      optionB: map['optionB'] ?? '',
      optionC: map['optionC'] ?? '',
      optionD: map['optionD'] ?? '',
      correctAnswer:
          (map['correctAnswer'] ?? 'A').toString().trim().toUpperCase(),
      marks: (map['marks'] as num?)?.toDouble() ?? 4.0,
      negativeMarks: (map['negativeMarks'] as num?)?.toDouble() ?? 1.0,
      subject: ExcelMcqParser.normalizeSubject(map['subject']?.toString()),
      topic: map['topic'] ?? 'General',
    );
  }

  Question toDriftQuestion() {
    return Question(
      id: id,
      questionText: questionText,
      optionA: optionA,
      optionB: optionB,
      optionC: optionC,
      optionD: optionD,
      correctAnswer: correctAnswer,
      marks: marks,
      negativeMarks: negativeMarks,
      subject: ExcelMcqParser.normalizeSubject(subject),
      topic: topic,
      createdAt: DateTime.now(),
    );
  }
}

class FirebaseDailyTest {
  final String id;
  final String dateKey; // Format: YYYY-MM-DD
  final String title;
  final DateTime scheduledStartTime;
  final int durationMinutes;
  final int totalQuestions;
  final double totalMarks;
  final double positiveMarks;
  final double negativeMarks;
  final String status; // 'scheduled', 'live', 'completed'
  final List<FirebaseQuestion> questions;
  final DateTime createdAt;

  FirebaseDailyTest({
    required this.id,
    required this.dateKey,
    required this.title,
    required this.scheduledStartTime,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.totalMarks,
    this.positiveMarks = 4.0,
    this.negativeMarks = 1.0,
    this.status = 'scheduled',
    required this.questions,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isUpcoming {
    return DateTime.now().isBefore(scheduledStartTime);
  }

  bool get isLive {
    final now = DateTime.now();
    final endTime = scheduledStartTime.add(Duration(minutes: durationMinutes));
    return now.isAfter(scheduledStartTime) && now.isBefore(endTime);
  }

  bool get isEnded {
    final endTime = scheduledStartTime.add(Duration(minutes: durationMinutes));
    return DateTime.now().isAfter(endTime);
  }

  Duration get timeUntilStart {
    final diff = scheduledStartTime.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateKey': dateKey,
      'title': title,
      'scheduledStartTime': Timestamp.fromDate(scheduledStartTime),
      'durationMinutes': durationMinutes,
      'totalQuestions': totalQuestions,
      'totalMarks': totalMarks,
      'positiveMarks': positiveMarks,
      'negativeMarks': negativeMarks,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory FirebaseDailyTest.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final startTime = data['scheduledStartTime'] is Timestamp
        ? (data['scheduledStartTime'] as Timestamp).toDate()
        : DateTime.now();

    final rawQuestions = data['questions'] as List<dynamic>? ?? [];
    final List<FirebaseQuestion> parsedQuestions = [];
    for (int i = 0; i < rawQuestions.length; i++) {
      if (rawQuestions[i] is Map<String, dynamic>) {
        parsedQuestions.add(FirebaseQuestion.fromMap(rawQuestions[i], i + 1));
      }
    }

    return FirebaseDailyTest(
      id: doc.id,
      dateKey: data['dateKey'] ?? doc.id,
      title: data['title'] ?? 'NEET Daily Mock Test',
      scheduledStartTime: startTime,
      durationMinutes: data['durationMinutes'] ?? 180,
      totalQuestions: data['totalQuestions'] ?? parsedQuestions.length,
      totalMarks: (data['totalMarks'] as num?)?.toDouble() ??
          (parsedQuestions.length * 4.0),
      positiveMarks: (data['positiveMarks'] as num?)?.toDouble() ?? 4.0,
      negativeMarks: (data['negativeMarks'] as num?)?.toDouble() ?? 1.0,
      status: data['status'] ?? 'scheduled',
      questions: parsedQuestions,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class TestSubmission {
  final String id;
  final String testId;
  final String? testDocId;
  final String studentName;
  final String? studentUid;
  final String? studentEmail;
  final double score;
  final double totalMarks;
  final int correctCount;
  final int wrongCount;
  final int unattemptedCount;
  final double accuracy;
  final int timeTakenSeconds;
  final DateTime submittedAt;
  final Map<String, String> answers;

  TestSubmission({
    required this.id,
    required this.testId,
    this.testDocId,
    required this.studentName,
    this.studentUid,
    this.studentEmail,
    required this.score,
    required this.totalMarks,
    required this.correctCount,
    required this.wrongCount,
    required this.unattemptedCount,
    required this.accuracy,
    required this.timeTakenSeconds,
    required this.submittedAt,
    this.answers = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testId': testId,
      if (testDocId != null) 'testDocId': testDocId,
      'studentName': studentName,
      'studentUid': studentUid,
      'studentEmail': studentEmail,
      'score': score,
      'totalMarks': totalMarks,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'unattemptedCount': unattemptedCount,
      'accuracy': accuracy,
      'timeTakenSeconds': timeTakenSeconds,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'answers': answers,
    };
  }

  factory TestSubmission.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TestSubmission(
      id: doc.id,
      testId: data['testId'] ?? '',
      testDocId: data['testDocId'] as String?,
      studentName: data['studentName'] ?? 'Anonymous Student',
      studentUid: data['studentUid'],
      studentEmail: data['studentEmail'],
      score: (data['score'] as num?)?.toDouble() ?? 0.0,
      totalMarks: (data['totalMarks'] as num?)?.toDouble() ?? 720.0,
      correctCount: data['correctCount'] ?? 0,
      wrongCount: data['wrongCount'] ?? 0,
      unattemptedCount: data['unattemptedCount'] ?? 0,
      accuracy: (data['accuracy'] as num?)?.toDouble() ?? 0.0,
      timeTakenSeconds: data['timeTakenSeconds'] ?? 0,
      submittedAt: data['submittedAt'] is Timestamp
          ? (data['submittedAt'] as Timestamp).toDate()
          : DateTime.now(),
      answers: (data['answers'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
    );
  }
}

class FirebaseTestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _dailyTestsCol =>
      _firestore.collection('daily_tests');
  CollectionReference get _submissionsCol =>
      _firestore.collection('test_submissions');
  CollectionReference get _usersCol => _firestore.collection('users');

  /// Upload/publish a daily test paper to Firebase Firestore
  Future<void> publishDailyTest(FirebaseDailyTest test) async {
    try {
      await _dailyTestsCol
          .doc(test.id)
          .set(test.toMap(), SetOptions(merge: true));
      debugPrint(
          "Successfully published Daily Test '${test.title}' with ${test.questions.length} questions to Firestore.");
    } catch (e) {
      debugPrint("Error publishing test to Firestore: $e");
      rethrow;
    }
  }

  /// Real-time stream of today's scheduled or active daily test
  Stream<FirebaseDailyTest?> streamTodayTest() {
    final todayKey = IstClock.dateKey();
    return _dailyTestsCol.doc(todayKey).snapshots().map((doc) {
      if (!doc.exists) return null;
      return FirebaseDailyTest.fromDoc(doc);
    });
  }

  /// Get test by ID once
  Future<FirebaseDailyTest?> getDailyTest(String testId) async {
    try {
      final doc = await _dailyTestsCol.doc(testId).get();
      if (!doc.exists) return null;
      return FirebaseDailyTest.fromDoc(doc);
    } catch (e) {
      debugPrint("Error getting test $testId: $e");
      return null;
    }
  }

  /// Get today's test once
  Future<FirebaseDailyTest?> getTodayTest() async {
    try {
      final todayKey = IstClock.dateKey();
      final doc = await _dailyTestsCol.doc(todayKey).get();
      if (doc.exists) {
        return FirebaseDailyTest.fromDoc(doc);
      }
      final latest = await _dailyTestsCol
          .orderBy('scheduledStartTime', descending: true)
          .limit(1)
          .get();
      if (latest.docs.isNotEmpty) {
        return FirebaseDailyTest.fromDoc(latest.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching today test: $e");
      return null;
    }
  }

  /// Find a test by ID, title, or dateKey (with fallback)
  Future<FirebaseDailyTest?> findTestByIdOrTitle(String identifier) async {
    if (identifier.trim().isEmpty) return null;
    try {
      // 1. By document ID
      final doc = await _dailyTestsCol.doc(identifier).get();
      if (doc.exists) {
        return FirebaseDailyTest.fromDoc(doc);
      }
      // 2. By title
      final byTitle = await _dailyTestsCol.where('title', isEqualTo: identifier).limit(1).get();
      if (byTitle.docs.isNotEmpty) {
        return FirebaseDailyTest.fromDoc(byTitle.docs.first);
      }
      // 3. By dateKey
      final byDate = await _dailyTestsCol.where('dateKey', isEqualTo: identifier).limit(1).get();
      if (byDate.docs.isNotEmpty) {
        return FirebaseDailyTest.fromDoc(byDate.docs.first);
      }
      // 4. By recent tests scan
      final recent = await _dailyTestsCol.orderBy('scheduledStartTime', descending: true).limit(30).get();
      for (final d in recent.docs) {
        final t = FirebaseDailyTest.fromDoc(d);
        if (t.id.toLowerCase() == identifier.toLowerCase() ||
            t.title.toLowerCase() == identifier.toLowerCase() ||
            t.dateKey == identifier) {
          return t;
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error finding test '$identifier': $e");
      return null;
    }
  }

  /// Stream all available daily tests (recent 50)
  Stream<List<FirebaseDailyTest>> streamRecentTests() {
    return _dailyTestsCol
        .orderBy('scheduledStartTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => FirebaseDailyTest.fromDoc(d)).toList());
  }

  /// Admin: Add a single question to an existing Daily Test
  Future<void> addQuestionToTest(
      String testId, FirebaseQuestion question) async {
    final doc = await _dailyTestsCol.doc(testId).get();
    if (!doc.exists) throw Exception("Test $testId not found in Firebase.");

    final test = FirebaseDailyTest.fromDoc(doc);
    final updatedList = List<FirebaseQuestion>.from(test.questions)
      ..add(question);

    await _dailyTestsCol.doc(testId).update({
      'questions': updatedList.map((q) => q.toMap()).toList(),
      'totalQuestions': updatedList.length,
      'totalMarks': updatedList.length * 4.0,
    });
  }

  /// Admin: Update/Edit an existing question in a Daily Test
  Future<void> updateQuestionInTest(
      String testId, FirebaseQuestion updatedQuestion) async {
    final doc = await _dailyTestsCol.doc(testId).get();
    if (!doc.exists) {
      throw Exception("Test $testId not found in Firebase.");
    }

    final test = FirebaseDailyTest.fromDoc(doc);
    final index = test.questions.indexWhere((q) => q.id == updatedQuestion.id);

    if (index == -1) {
      throw Exception("Question #${updatedQuestion.id} not found.");
    }

    final updatedList = List<FirebaseQuestion>.from(test.questions);
    updatedList[index] = updatedQuestion;

    await _dailyTestsCol.doc(testId).update({
      'questions': updatedList.map((q) => q.toMap()).toList(),
    });
  }

  /// Admin: Delete a single question from a Daily Test
  Future<void> deleteQuestionFromTest(String testId, int questionId) async {
    final doc = await _dailyTestsCol.doc(testId).get();
    if (!doc.exists) throw Exception("Test $testId not found in Firebase.");

    final test = FirebaseDailyTest.fromDoc(doc);
    final updatedList =
        test.questions.where((q) => q.id != questionId).toList();

    await _dailyTestsCol.doc(testId).update({
      'questions': updatedList.map((q) => q.toMap()).toList(),
      'totalQuestions': updatedList.length,
      'totalMarks': updatedList.length * 4.0,
    });
  }

  /// Admin: Delete an entire Daily Test
  Future<void> deleteDailyTest(String testId) async {
    await _dailyTestsCol.doc(testId).delete();
  }

  final List<TestSubmission> _pendingSubmissions = [];

  /// Submit student's result to Firestore with offline retry queue
  Future<void> submitResult(TestSubmission submission) async {
    try {
      await _submissionsCol.doc(submission.id).set(submission.toMap(), SetOptions(merge: true));
      _pendingSubmissions.removeWhere((s) => s.id == submission.id);
      debugPrint(
          "Submitted test result to Firestore for student: ${submission.studentName}");
    } catch (e) {
      debugPrint("Error uploading submission to Firestore: $e. Added to offline retry queue.");
      if (!_pendingSubmissions.any((s) => s.id == submission.id)) {
        _pendingSubmissions.add(submission);
      }
      rethrow;
    }
  }

  /// Retries syncing any offline queued test submissions to Firestore
  Future<void> flushPendingSubmissions() async {
    if (_pendingSubmissions.isEmpty) return;
    final toRetry = List<TestSubmission>.from(_pendingSubmissions);
    for (final sub in toRetry) {
      try {
        await _submissionsCol.doc(sub.id).set(sub.toMap(), SetOptions(merge: true));
        _pendingSubmissions.removeWhere((s) => s.id == sub.id);
        debugPrint("Successfully flushed offline submission ${sub.id} to Firestore.");
      } catch (e) {
        debugPrint("Failed to flush offline submission ${sub.id}: $e");
      }
    }
  }

  /// Stream live leaderboard for a test
  Stream<List<TestSubmission>> streamLeaderboard(String testId) {
    return _submissionsCol.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => TestSubmission.fromDoc(d))
          .where((d) => d.testId == testId || d.testDocId == testId)
          .toList();
      list.sort((a, b) => b.score.compareTo(a.score));
      return list.take(50).toList();
    });
  }

  /// Stream all submissions (for Admin panel)
  Stream<List<TestSubmission>> streamAllSubmissions({String? testId}) {
    return _submissionsCol
        .orderBy('submittedAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) {
      var list = snap.docs.map((d) => TestSubmission.fromDoc(d)).toList();
      if (testId != null && testId.isNotEmpty) {
        list = list.where((d) => d.testId == testId || d.testDocId == testId).toList();
      }
      return list;
    });
  }

  /// Stream submissions for a specific student (strictly isolated by student UID or email)
  Stream<List<TestSubmission>> streamStudentSubmissions(String studentUid, {String? studentEmail}) {
    return _submissionsCol.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => TestSubmission.fromDoc(d))
          .where((sub) {
            if (sub.studentUid != null && sub.studentUid == studentUid) return true;
            if (studentEmail != null &&
                studentEmail.isNotEmpty &&
                sub.studentEmail != null &&
                sub.studentEmail!.toLowerCase() == studentEmail.toLowerCase()) {
              return true;
            }
            return false;
          })
          .toList();
      list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return list;
    });
  }

  /// Stream all registered students (for Admin panel)
  Stream<List<Map<String, dynamic>>> streamAllStudents() {
    return _usersCol.snapshots().map((snap) {
      final list = snap.docs
          .map((d) {
            final data = Map<String, dynamic>.from(d.data() as Map<String, dynamic>);
            data['uid'] = d.id;
            return data;
          })
          .where((u) => u['role'] != 'admin')
          .toList();
      list.sort((a, b) {
        final aTime = a['createdAt'] is Timestamp
            ? (a['createdAt'] as Timestamp).toDate()
            : DateTime(2020);
        final bTime = b['createdAt'] is Timestamp
            ? (b['createdAt'] as Timestamp).toDate()
            : DateTime(2020);
        return bTime.compareTo(aTime);
      });
      return list;
    });
  }

  /// Convert a FirebaseDailyTest into local Drift DB Test and Questions so examination engine can run
  Future<LocalExamSession> prepareLocalSessionForDailyTest(
      FirebaseDailyTest firebaseTest, AppDatabase db) async {
    return await db.transaction(() async {
      // 1. Check for any existing local test attempt for this exam title
      final existingTests = await (db.select(db.tests)
            ..where((t) => t.name.equals(firebaseTest.title)))
          .get();

      for (final oldTest in existingTests) {
        if (oldTest.status == 'completed') {
          // Purge completed local test session so user can start fresh
          await (db.delete(db.testResults)..where((r) => r.testId.equals(oldTest.id))).go();
          await (db.delete(db.userAnswers)..where((a) => a.testId.equals(oldTest.id))).go();
          await (db.delete(db.testQuestions)..where((q) => q.testId.equals(oldTest.id))).go();
          await (db.delete(db.tests)..where((t) => t.id.equals(oldTest.id))).go();
        } else {
          // Active ongoing or pending attempt for this paper
          // Fetch the questions already linked to this test
          final qQuery = db.select(db.questions).join([
            innerJoin(db.testQuestions, db.testQuestions.questionId.equalsExp(db.questions.id)),
          ])
            ..where(db.testQuestions.testId.equals(oldTest.id))
            ..orderBy([OrderingTerm.asc(db.testQuestions.orderIndex)]);

          final rows = await qQuery.get();
          final linkedQuestions = rows.map((r) => r.readTable(db.questions)).toList();

          // If linked questions exist, return this existing session
          if (linkedQuestions.isNotEmpty) {
            return LocalExamSession(
              testId: oldTest.id,
              questions: linkedQuestions,
              testDocId: firebaseTest.id,
            );
          }

          // Otherwise, it was an incomplete/corrupted attempt - purge it and recreate
          await (db.delete(db.testQuestions)..where((q) => q.testId.equals(oldTest.id))).go();
          await (db.delete(db.userAnswers)..where((a) => a.testId.equals(oldTest.id))).go();
          await (db.delete(db.tests)..where((t) => t.id.equals(oldTest.id))).go();
        }
      }

      // 2. Insert questions for this exam
      final List<int> questionIds = [];
      for (final fq in firebaseTest.questions) {
        final insertedId = await db.into(db.questions).insert(
              QuestionsCompanion.insert(
                questionText: fq.questionText,
                optionA: fq.optionA,
                optionB: fq.optionB,
                optionC: fq.optionC,
                optionD: fq.optionD,
                correctAnswer: fq.correctAnswer,
                marks: fq.marks,
                negativeMarks: driftValue(fq.negativeMarks),
                subject: driftValue(ExcelMcqParser.normalizeSubject(fq.subject)),
                topic: driftValue(fq.topic),
              ),
              mode: InsertMode.insertOrReplace,
            );
        questionIds.add(insertedId);
      }

      // 3. Create the test session
      final newTestId = await db.into(db.tests).insert(
            TestsCompanion.insert(
              name: firebaseTest.title,
              totalQuestions: firebaseTest.totalQuestions,
              totalMarks: firebaseTest.totalMarks,
              durationMinutes: firebaseTest.durationMinutes,
              positiveMarking: firebaseTest.positiveMarks,
              negativeMarking: firebaseTest.negativeMarks,
            ),
          );

      // 4. Batch insert TestQuestions entries
      final testQuestionEntries = <TestQuestionsCompanion>[];
      for (int i = 0; i < questionIds.length; i++) {
        testQuestionEntries.add(
          TestQuestionsCompanion.insert(
            testId: newTestId,
            questionId: questionIds[i],
            orderIndex: i,
          ),
        );
      }
      await db.batch((batch) {
        batch.insertAll(db.testQuestions, testQuestionEntries);
      });

      // 5. Query and return the exact Question objects with their true DB IDs
      final qQuery = db.select(db.questions).join([
        innerJoin(db.testQuestions, db.testQuestions.questionId.equalsExp(db.questions.id)),
      ])
        ..where(db.testQuestions.testId.equals(newTestId))
        ..orderBy([OrderingTerm.asc(db.testQuestions.orderIndex)]);

      final rows = await qQuery.get();
      final finalQuestions = rows.map((r) => r.readTable(db.questions)).toList();

      return LocalExamSession(
        testId: newTestId,
        questions: finalQuestions,
        testDocId: firebaseTest.id,
      );
    });
  }

  Value<T> driftValue<T>(T value) => Value(value);
}
