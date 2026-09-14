import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Questions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get questionText => text().customConstraint('UNIQUE')();
  TextColumn get optionA => text()();
  TextColumn get optionB => text()();
  TextColumn get optionC => text()();
  TextColumn get optionD => text()();
  TextColumn get correctAnswer => text()();
  RealColumn get marks => real()();
  RealColumn get negativeMarks => real().withDefault(const Constant(0.0))();
  TextColumn get subject => text().nullable()();
  TextColumn get topic => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Tests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get totalQuestions => integer()();
  RealColumn get totalMarks => real()();
  IntColumn get durationMinutes => integer()();
  RealColumn get positiveMarking => real()();
  RealColumn get negativeMarking => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, ongoing, completed
}

class TestQuestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get testId => integer().references(Tests, #id)();
  IntColumn get questionId => integer().references(Questions, #id)();
  IntColumn get orderIndex => integer()();
}

class UserAnswers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get testId => integer().references(Tests, #id)();
  IntColumn get questionId => integer().references(Questions, #id)();
  TextColumn get selectedOption => text().nullable()();
  BoolColumn get isMarkedForReview => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [{testId, questionId}];
}

class TestResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get testId => integer().references(Tests, #id).unique()();
  IntColumn get attemptedCount => integer()();
  IntColumn get correctCount => integer()();
  IntColumn get wrongCount => integer()();
  RealColumn get finalScore => real()();
  RealColumn get accuracy => real()();
  IntColumn get timeTakenSeconds => integer()();
  DateTimeColumn get generatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Questions, Tests, TestQuestions, UserAnswers, TestResults])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  // Cleanup helper for enterprise data management
  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.drop(questions);
        await m.create(questions);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'neet_exam_db');
  }
}
