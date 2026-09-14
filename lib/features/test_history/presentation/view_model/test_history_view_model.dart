import 'package:flutter/foundation.dart';
import '../../data/repository/test_history_repository.dart';

class TestHistoryState {
  final List<Map<String, dynamic>> history;
  final bool isLoading;
  final String? errorMessage;

  TestHistoryState({
    this.history = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TestHistoryState copyWith({
    List<Map<String, dynamic>>? history,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TestHistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TestHistoryViewModel extends ChangeNotifier {
  final TestHistoryRepository repository;
  TestHistoryState _state = TestHistoryState();

  TestHistoryViewModel({required this.repository});

  TestHistoryState get state => _state;

  Future<void> loadHistory() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final history = await repository.getHistory();
      _state = _state.copyWith(history: history, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
    }
    notifyListeners();
  }
}
