import 'package:flutter/foundation.dart';
import '../../data/repository/analytics_repository.dart';

class AnalyticsState {
  final Map<String, dynamic> globalStats;
  final List<Map<String, dynamic>> subjectStats;
  final List<Map<String, dynamic>> topicStats; // Added for detailed analysis
  final bool isLoading;
  final String? errorMessage;

  AnalyticsState({
    this.globalStats = const {},
    this.subjectStats = const [],
    this.topicStats = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AnalyticsState copyWith({
    Map<String, dynamic>? globalStats,
    List<Map<String, dynamic>>? subjectStats,
    List<Map<String, dynamic>>? topicStats,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AnalyticsState(
      globalStats: globalStats ?? this.globalStats,
      subjectStats: subjectStats ?? this.subjectStats,
      topicStats: topicStats ?? this.topicStats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AnalyticsViewModel extends ChangeNotifier {
  final AnalyticsRepository repository;
  AnalyticsState _state = AnalyticsState();

  AnalyticsViewModel({required this.repository});

  AnalyticsState get state => _state;

  Future<void> loadAnalytics() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final global = await repository.getGlobalAnalytics();
      final subjects = await repository.getSubjectWisePerformance();
      final topics = await repository.getTopicWisePerformance(); // Load topic performance
      
      _state = _state.copyWith(
        globalStats: global,
        subjectStats: subjects,
        topicStats: topics,
        isLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
    }
    notifyListeners();
  }
}
