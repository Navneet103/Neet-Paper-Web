import 'package:flutter/foundation.dart';
import '../../data/repository/test_generation_repository.dart';

enum TestGenerationStatus { initial, generating, success, error }

class TestGenerationState {
  final TestGenerationStatus status;
  final int? generatedTestId;
  final String? errorMessage;

  TestGenerationState({
    this.status = TestGenerationStatus.initial,
    this.generatedTestId,
    this.errorMessage,
  });

  TestGenerationState copyWith({
    TestGenerationStatus? status,
    int? generatedTestId,
    String? errorMessage,
  }) {
    return TestGenerationState(
      status: status ?? this.status,
      generatedTestId: generatedTestId ?? this.generatedTestId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TestGenerationViewModel extends ChangeNotifier {
  final TestGenerationRepository repository;
  TestGenerationState _state = TestGenerationState();

  TestGenerationViewModel({required this.repository});

  TestGenerationState get state => _state;

  Future<void> generateTest({
    required String name,
    required int questionCount,
    required int durationMinutes,
    required double positiveMarks,
    required double negativeMarks,
    String? subject,
  }) async {
    _state = _state.copyWith(status: TestGenerationStatus.generating);
    notifyListeners();

    try {
      final testId = await repository.generateTest(
        name: name,
        questionCount: questionCount,
        durationMinutes: durationMinutes,
        positiveMarks: positiveMarks,
        negativeMarks: negativeMarks,
        subject: subject,
      );
      _state = _state.copyWith(status: TestGenerationStatus.success, generatedTestId: testId);
    } catch (e) {
      _state = _state.copyWith(status: TestGenerationStatus.error, errorMessage: e.toString());
    }
    notifyListeners();
  }
  
  void reset() {
    _state = TestGenerationState();
    notifyListeners();
  }
}
