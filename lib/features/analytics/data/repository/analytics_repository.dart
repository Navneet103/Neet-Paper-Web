import '../../../../core/storage/app_database.dart';

abstract class AnalyticsRepository {
  Future<Map<String, dynamic>> getGlobalAnalytics();
  Future<List<Map<String, dynamic>>> getSubjectWisePerformance();
}
