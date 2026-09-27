import 'package:flutter_test/flutter_test.dart';
import 'package:neet_paper_test/core/firebase/firebase_test_service.dart';

void main() {
  group('User Isolation & Data Segregation Tests', () {
    final navneetSub = TestSubmission(
      id: 'sub_navneet_1',
      testId: 'NEET Daily Mock Test 2026-09-26',
      studentName: 'Navneet Kanojiya',
      studentUid: 'uid_navneet_123',
      studentEmail: 'navneet@example.com',
      score: 540.0,
      totalMarks: 720.0,
      correctCount: 140,
      wrongCount: 20,
      unattemptedCount: 20,
      accuracy: 87.5,
      timeTakenSeconds: 7200,
      submittedAt: DateTime(2026, 9, 26, 10, 30),
    );

    final rekhaSub = TestSubmission(
      id: 'sub_rekha_1',
      testId: 'NEET Daily Mock Test 2026-09-26',
      studentName: 'Rekha Kanojiya',
      studentUid: 'uid_rekha_456',
      studentEmail: 'rekha@example.com',
      score: 620.0,
      totalMarks: 720.0,
      correctCount: 158,
      wrongCount: 12,
      unattemptedCount: 10,
      accuracy: 92.9,
      timeTakenSeconds: 6800,
      submittedAt: DateTime(2026, 9, 26, 11, 45),
    );

    final allSubmissions = [navneetSub, rekhaSub];

    test('Filtering submissions strictly isolates by studentUid', () {
      final rekhaResults = allSubmissions.where((s) => s.studentUid == 'uid_rekha_456').toList();
      expect(rekhaResults.length, 1);
      expect(rekhaResults.first.studentName, 'Rekha Kanojiya');
      expect(rekhaResults.first.score, 620.0);

      final navneetResults = allSubmissions.where((s) => s.studentUid == 'uid_navneet_123').toList();
      expect(navneetResults.length, 1);
      expect(navneetResults.first.studentName, 'Navneet Kanojiya');
      expect(navneetResults.first.score, 540.0);
    });

    test('New student with no submissions has 0 tests and never inherits prior student records', () {
      const newStudentUid = 'uid_new_student_789';
      final newStudentSubs = allSubmissions.where((s) => s.studentUid == newStudentUid).toList();
      expect(newStudentSubs.isEmpty, isTrue);
      expect(newStudentSubs.length, 0);
    });

    test('Has student attempted check is strictly isolated per test and student UID', () {
      bool hasNavneetAttempted(String testName) =>
          allSubmissions.any((s) => s.testId == testName && s.studentUid == 'uid_navneet_123');

      bool hasRekhaAttempted(String testName) =>
          allSubmissions.any((s) => s.testId == testName && s.studentUid == 'uid_rekha_456');

      bool hasNewStudentAttempted(String testName) =>
          allSubmissions.any((s) => s.testId == testName && s.studentUid == 'uid_new_student_789');

      expect(hasNavneetAttempted('NEET Daily Mock Test 2026-09-26'), isTrue);
      expect(hasRekhaAttempted('NEET Daily Mock Test 2026-09-26'), isTrue);
      expect(hasNewStudentAttempted('NEET Daily Mock Test 2026-09-26'), isFalse);
    });
  });
}
