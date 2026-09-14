import 'package:flutter/foundation.dart';
import '../../../../core/storage/app_database.dart';
import '../../data/repository/question_bank_repository.dart';

class QuestionBankState {
  final List<Question> questions;
  final List<String> subjects;
  final bool isLoading;
  final int totalCount;
  final String? searchQuery;
  final String? selectedSubject;
  final int currentPage;
  final int pageSize;

  QuestionBankState({
    this.questions = const [],
    this.subjects = const [],
    this.isLoading = false,
    this.totalCount = 0,
    this.searchQuery,
    this.selectedSubject,
    this.currentPage = 0,
    this.pageSize = 50,
  });

  QuestionBankState copyWith({
    List<Question>? questions,
    List<String>? subjects,
    bool? isLoading,
    int? totalCount,
    String? searchQuery,
    String? selectedSubject,
    int? currentPage,
    int? pageSize,
  }) {
    return QuestionBankState(
      questions: questions ?? this.questions,
      subjects: subjects ?? this.subjects,
      isLoading: isLoading ?? this.isLoading,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class QuestionBankViewModel extends ChangeNotifier {
  final QuestionBankRepository repository;
  QuestionBankState _state = QuestionBankState();

  QuestionBankViewModel({required this.repository});

  QuestionBankState get state => _state;

  Future<void> init() async {
    await fetchSubjects();
    await fetchQuestions();
  }

  Future<void> fetchSubjects() async {
    final subjects = await repository.getSubjects();
    _state = _state.copyWith(subjects: subjects);
    notifyListeners();
  }

  Future<void> fetchQuestions({bool resetPage = false}) async {
    if (resetPage) {
      _state = _state.copyWith(currentPage: 0, isLoading: true);
    } else {
      _state = _state.copyWith(isLoading: true);
    }
    notifyListeners();

    final questions = await repository.getQuestions(
      limit: _state.pageSize,
      offset: _state.currentPage * _state.pageSize,
      searchQuery: _state.searchQuery,
      subject: _state.selectedSubject,
    );

    final total = await repository.getTotalCount(
      searchQuery: _state.searchQuery,
      subject: _state.selectedSubject,
    );

    _state = _state.copyWith(
      questions: questions,
      totalCount: total,
      isLoading: false,
    );
    notifyListeners();
  }

  void updateSearch(String query) {
    _state = _state.copyWith(searchQuery: query);
    fetchQuestions(resetPage: true);
  }

  void updateSubject(String? subject) {
    _state = _state.copyWith(selectedSubject: subject);
    fetchQuestions(resetPage: true);
  }

  void nextPage() {
    if ((_state.currentPage + 1) * _state.pageSize < _state.totalCount) {
      _state = _state.copyWith(currentPage: _state.currentPage + 1);
      fetchQuestions();
    }
  }

  void previousPage() {
    if (_state.currentPage > 0) {
      _state = _state.copyWith(currentPage: _state.currentPage - 1);
      fetchQuestions();
    }
  }
}
