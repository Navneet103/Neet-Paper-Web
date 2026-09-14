import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../injection/injection_container.dart';
import '../datasource/analytics_local_datasource.dart';
import 'analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsLocalDataSource localDataSource;

  AnalyticsRepositoryImpl({required this.localDataSource});

  @override
  Future<Map<String, dynamic>> getGlobalAnalytics() async {
    final results = await localDataSource.getAllResults();
    
    if (results.isEmpty) {
      return {
        'totalTests': 0,
        'averageScore': 0.0,
        'bestScore': 0.0,
        'averageAccuracy': 0.0,
        'totalCorrect': 0,
        'totalWrong': 0,
      };
    }

    double totalScore = 0.0;
    double bestScore = 0.0;
    double totalAccuracy = 0.0;
    int totalCorrect = 0;
    int totalWrong = 0;

    for (final TestResult r in results) {
      totalScore += r.finalScore;
      if (r.finalScore > bestScore) bestScore = r.finalScore;
      totalAccuracy += r.accuracy;
      totalCorrect += r.correctCount;
      totalWrong += r.wrongCount;
    }

    return {
      'totalTests': results.length,
      'averageScore': totalScore / results.length,
      'bestScore': bestScore,
      'averageAccuracy': totalAccuracy / results.length,
      'totalCorrect': totalCorrect,
      'totalWrong': totalWrong,
      'results': results,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getSubjectWisePerformance() async {
    final List<TypedResult> data = await localDataSource.getSubjectWisePerformance();
    final Map<String, List<bool>> subjectData = {};
    final db = sl<AppDatabase>();

    for (final TypedResult row in data) {
      final question = row.readTable(db.questions);
      final answer = row.readTableOrNull(db.userAnswers);
      
      final subject = question.subject ?? 'Unknown';
      subjectData.putIfAbsent(subject, () => []);
      
      final isCorrect = answer != null && answer.selectedOption == question.correctAnswer;
      subjectData[subject]!.add(isCorrect);
    }

    return subjectData.entries.map((e) {
      final total = e.value.length;
      final correct = e.value.where((v) => v).length;
      return {
        'subject': e.key,
        'total': total,
        'correct': correct,
        'accuracy': total > 0 ? (correct / total) * 100 : 0.0,
      };
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getTopicWisePerformance() async {
    final List<TypedResult> data = await localDataSource.getSubjectWisePerformance();
    final Map<String, List<bool>> topicData = {};
    final db = sl<AppDatabase>();

    for (final TypedResult row in data) {
      final question = row.readTable(db.questions);
      final answer = row.readTableOrNull(db.userAnswers);
      
      final topic = question.topic ?? 'General';
      topicData.putIfAbsent(topic, () => []);
      
      final isCorrect = answer != null && answer.selectedOption == question.correctAnswer;
      topicData[topic]!.add(isCorrect);
    }

    return topicData.entries.map((e) {
      final total = e.value.length;
      final correct = e.value.where((v) => v).length;
      return {
        'topic': e.key,
        'total': total,
        'correct': correct,
        'accuracy': total > 0 ? (correct / total) * 100 : 0.0,
      };
    }).toList();
  }
}
