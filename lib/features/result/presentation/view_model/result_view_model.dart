import 'package:flutter/foundation.dart';
import '../../../../core/storage/app_database.dart';
import '../../data/repository/result_repository.dart';

enum ResultStatus { initial, loading, success, error }

class ResultState {
  final ResultStatus status;
  final TestResult? result;
  final Test? test;
  final List<Map<String, dynamic>> detailedReview;
  final String? errorMessage;

  ResultState({
    this.status = ResultStatus.initial,
    this.result,
    this.test,
    this.detailedReview = const [],
    this.errorMessage,
  });

  int get totalQuestions => detailedReview.length;
  int get unattemptedCount => detailedReview.where((r) => r['isUnattempted'] == true).length;

  ResultState copyWith({
    ResultStatus? status,
    TestResult? result,
    Test? test,
    List<Map<String, dynamic>>? detailedReview,
    String? errorMessage,
  }) {
    return ResultState(
      status: status ?? this.status,
      result: result ?? this.result,
      test: test ?? this.test,
      detailedReview: detailedReview ?? this.detailedReview,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ResultViewModel extends ChangeNotifier {
  final ResultRepository repository;
  ResultState _state = ResultState();

  ResultViewModel({required this.repository});

  ResultState get state => _state;

  Future<void> loadResult(int testId) async {
    _state = _state.copyWith(status: ResultStatus.loading);
    notifyListeners();

    try {
      final test = await repository.getTest(testId);

      // Always calculate/refresh result to guarantee latest evaluation and Cloud DB sync
      final result = await repository.calculateAndSaveResult(testId);

      final review = await repository.getDetailedReview(testId);

      _state = _state.copyWith(
        status: ResultStatus.success,
        result: result,
        test: test,
        detailedReview: review,
      );
    } catch (e) {
      _state = _state.copyWith(status: ResultStatus.error, errorMessage: e.toString());
    }
    notifyListeners();
  }
}
