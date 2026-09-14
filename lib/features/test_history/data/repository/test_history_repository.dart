import '../../../../core/storage/app_database.dart';

abstract class TestHistoryRepository {
  Future<List<Map<String, dynamic>>> getHistory();
}
