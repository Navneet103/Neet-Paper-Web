import 'package:get_it/get_it.dart';
import 'package:neet_paper_test/core/storage/app_database.dart';

// Question Import
import 'package:neet_paper_test/features/question_import/data/datasource/question_import_local_datasource.dart';
import 'package:neet_paper_test/features/question_import/data/repository/question_import_repository.dart';
import 'package:neet_paper_test/features/question_import/data/repository/question_import_repository_impl.dart';
import 'package:neet_paper_test/features/question_import/presentation/view_model/question_import_view_model.dart';

// Question Bank
import 'package:neet_paper_test/features/question_bank/data/datasource/question_bank_local_datasource.dart';
import 'package:neet_paper_test/features/question_bank/data/repository/question_bank_repository.dart';
import 'package:neet_paper_test/features/question_bank/data/repository/question_bank_repository_impl.dart';
import 'package:neet_paper_test/features/question_bank/presentation/view_model/question_bank_view_model.dart';

// Test Generation
import 'package:neet_paper_test/features/test_generation/data/datasource/test_generation_local_datasource.dart';
import 'package:neet_paper_test/features/test_generation/data/repository/test_generation_repository.dart';
import 'package:neet_paper_test/features/test_generation/data/repository/test_generation_repository_impl.dart';
import 'package:neet_paper_test/features/test_generation/presentation/view_model/test_generation_view_model.dart';

// Examination
import 'package:neet_paper_test/features/examination/data/datasource/examination_local_datasource.dart';
import 'package:neet_paper_test/features/examination/data/repository/examination_repository.dart';
import 'package:neet_paper_test/features/examination/data/repository/examination_repository_impl.dart';
import 'package:neet_paper_test/features/examination/presentation/view_model/examination_view_model.dart';

// Result
import 'package:neet_paper_test/features/result/data/datasource/result_local_datasource.dart';
import 'package:neet_paper_test/features/result/data/repository/result_repository.dart';
import 'package:neet_paper_test/features/result/data/repository/result_repository_impl.dart';
import 'package:neet_paper_test/features/result/presentation/view_model/result_view_model.dart';

// Test History
import 'package:neet_paper_test/features/test_history/data/datasource/test_history_local_datasource.dart';
import 'package:neet_paper_test/features/test_history/data/repository/test_history_repository.dart';
import 'package:neet_paper_test/features/test_history/data/repository/test_history_repository_impl.dart';
import 'package:neet_paper_test/features/test_history/presentation/view_model/test_history_view_model.dart';

// Analytics
import 'package:neet_paper_test/features/analytics/data/datasource/analytics_local_datasource.dart';
import 'package:neet_paper_test/features/analytics/data/repository/analytics_repository.dart';
import 'package:neet_paper_test/features/analytics/data/repository/analytics_repository_impl.dart';
import 'package:neet_paper_test/features/analytics/presentation/view_model/analytics_view_model.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  final database = AppDatabase();
  sl.registerSingleton<AppDatabase>(database);

  // Question Import
  sl.registerLazySingleton<QuestionImportLocalDataSource>(() => QuestionImportLocalDataSourceImpl(database: sl()));
  sl.registerLazySingleton<QuestionImportRepository>(() => QuestionImportRepositoryImpl(localDataSource: sl()));
  sl.registerFactory(() => QuestionImportViewModel(repository: sl()));

  // Question Bank
  sl.registerLazySingleton<QuestionBankLocalDataSource>(() => QuestionBankLocalDataSourceImpl(database: sl()));
  sl.registerLazySingleton<QuestionBankRepository>(() => QuestionBankRepositoryImpl(localDataSource: sl()));
  sl.registerFactory(() => QuestionBankViewModel(repository: sl()));

  // Test Generation
  sl.registerLazySingleton<TestGenerationLocalDataSource>(() => TestGenerationLocalDataSourceImpl(database: sl()));
  sl.registerLazySingleton<TestGenerationRepository>(() => TestGenerationRepositoryImpl(localDataSource: sl()));
  sl.registerFactory(() => TestGenerationViewModel(repository: sl()));

  // Examination
  sl.registerLazySingleton<ExaminationLocalDataSource>(() => ExaminationLocalDataSourceImpl(database: sl()));
  sl.registerLazySingleton<ExaminationRepository>(() => ExaminationRepositoryImpl(localDataSource: sl()));
  sl.registerFactory(() => ExaminationViewModel(repository: sl()));

  // Result
  sl.registerLazySingleton<ResultLocalDataSource>(() => ResultLocalDataSourceImpl(database: sl()));
  sl.registerLazySingleton<ResultRepository>(() => ResultRepositoryImpl(localDataSource: sl()));
  sl.registerFactory(() => ResultViewModel(repository: sl()));

  // Test History
  sl.registerLazySingleton<TestHistoryLocalDataSource>(() => TestHistoryLocalDataSourceImpl(database: sl()));
  sl.registerLazySingleton<TestHistoryRepository>(() => TestHistoryRepositoryImpl(localDataSource: sl()));
  sl.registerFactory(() => TestHistoryViewModel(repository: sl()));

  // Analytics
  sl.registerLazySingleton<AnalyticsLocalDataSource>(() => AnalyticsLocalDataSourceImpl(database: sl()));
  sl.registerLazySingleton<AnalyticsRepository>(() => AnalyticsRepositoryImpl(localDataSource: sl()));
  sl.registerFactory(() => AnalyticsViewModel(repository: sl()));
}
