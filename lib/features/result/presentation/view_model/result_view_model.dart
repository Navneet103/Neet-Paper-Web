import 'package:flutter/foundation.dart';
import '../../../../core/storage/app_database.dart';
import '../../data/repository/result_repository.dart';

enum ResultStatus { initial, loading, success, error }

class ResultState {
  final ResultStatus status;
  final TestResult? result;
  final List<Map<String, dynamic>> detailedReview;
  final String? errorMessage;

  ResultState({
    this.status = ResultStatus.initial,
    this.result,
    this.detailedReview = const [],
    this.errorMessage,
  });

  ResultState copyWith({
    ResultStatus? status,
    TestResult? result,
    List<Map<String, dynamic>>? detailedReview,
    String? errorMessage,
  }) {
    return ResultState(
      status: status ?? this.status,
      result: result ?? this.result,
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
      // First try to get existing result
      TestResult? result = await repository.getResultByTestId(testId);
      
      // If not found, calculate it
      if (result == null) {
        result = await repository.calculateAndSaveResult(testId);
      }

      final review = await repository.getDetailedReview(testId);

      _state = _state.copyWith(
        status: ResultStatus.success,
        result: result,
        detailedReview: review,
      );
    } catch (e) {
      _state = _state.copyWith(status: ResultStatus.error, errorMessage: e.toString());
    }
    notifyListeners();
  }
}
