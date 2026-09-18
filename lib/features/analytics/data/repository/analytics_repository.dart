abstract class AnalyticsRepository {
  Future<Map<String, dynamic>> getGlobalAnalytics();
  Future<List<Map<String, dynamic>>> getSubjectWisePerformance();
  Future<List<Map<String, dynamic>>> getTopicWisePerformance();
}
