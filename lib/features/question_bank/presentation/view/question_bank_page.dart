import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../injection/injection_container.dart';
import '../view_model/question_bank_view_model.dart';

class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({super.key});

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  late QuestionBankViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = sl<QuestionBankViewModel>();
    _viewModel.init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getSubjectColor(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('physic')) return const Color(0xFF3B82F6);
    if (s.contains('chem')) return const Color(0xFF8B5CF6);
    if (s.contains('bio') || s.contains('botany') || s.contains('zool')) return const Color(0xFF10B981);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // Match global breakpoint

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Question Bank'),
        actions: isMobile 
          ? [
              IconButton(
                icon: const Icon(Icons.add_task_rounded),
                onPressed: () => context.push('/create-test'),
                tooltip: 'Create Test',
              ),
              const SizedBox(width: 8),
            ]
          : [
              OutlinedButton.icon(
                onPressed: () => context.push('/import').then((_) => _viewModel.init()),
                icon: const Icon(Icons.upload_file_rounded, size: 16),
                label: const Text('Import'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => context.push('/create-test'),
                icon: const Icon(Icons.add_task_rounded, size: 16),
                label: const Text('Create Test'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
              const SizedBox(width: 16),
            ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;

          return Column(
            children: [
              // Search & Filter Bar
              Container(
                color: AppColors.surface,
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 20, 
                  16, 
                  isMobile ? 16 : 20, 
                  12
                ),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    _buildFilterBar(state),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Question List or Loading/Empty States
              Expanded(
                child: state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : state.questions.isEmpty
                        ? AppEmptyState(
                            icon: Icons.library_books_rounded,
                            title: 'No questions found',
                            message: state.selectedSubject != null
                                ? 'No questions match the "${state.selectedSubject}" filter.'
                                : 'Your question bank is empty. Import an Excel file to get started.',
                            actionLabel: 'Import Questions',
                            onAction: () => context.push('/import').then((_) => _viewModel.init()),
                          )
                        : _buildQuestionList(state, isMobile),
              ),

              // Pagination Footer
              if (!state.isLoading && state.questions.isNotEmpty) 
                _buildPagination(state, isMobile),
            ],
          );
        },
      ),
      floatingActionButton: isMobile 
        ? FloatingActionButton(
            onPressed: () => context.push('/import').then((_) => _viewModel.init()),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.upload_file_rounded, color: Colors.white),
          )
        : null,
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search questions, topics...',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                onPressed: () {
                  _searchController.clear();
                  _viewModel.updateSearch('');
                },
              )
            : null,
      ),
      onChanged: (value) {
        setState(() {});
        _viewModel.updateSearch(value);
      },
    );
  }

  Widget _buildFilterBar(QuestionBankState state) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: state.selectedSubject == null,
            onSelected: (_) => _viewModel.updateSubject(null),
            showCheckmark: false,
            selectedColor: AppColors.primaryLight,
            labelStyle: TextStyle(
              color: state.selectedSubject == null ? AppColors.primary : AppColors.textSecondary,
              fontWeight: state.selectedSubject == null ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          ...state.subjects.map((s) {
            final isSelected = state.selectedSubject == s;
            final color = _getSubjectColor(s);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(s),
                selected: isSelected,
                onSelected: (_) => _viewModel.updateSubject(s),
                showCheckmark: false,
                selectedColor: color.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionList(QuestionBankState state, bool isMobile) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20, 
        vertical: 16
      ),
      itemCount: state.questions.length,
      itemBuilder: (context, index) {
        final q = state.questions[index];
        final globalIndex = state.currentPage * state.pageSize + index + 1;
        final subjectColor = _getSubjectColor(q.subject ?? 'General');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.shadowSm,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                '$globalIndex',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              q.questionText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                AppBadge(
                  text: q.subject ?? 'General',
                  backgroundColor: subjectColor.withValues(alpha: 0.1),
                  textColor: subjectColor,
                ),
                if (!isMobile && q.topic != null)
                  AppBadge(text: q.topic!),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.questionText,
                      style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    _optionTile('A', q.optionA, q.correctAnswer == 'A'),
                    const SizedBox(height: 8),
                    _optionTile('B', q.optionB, q.correctAnswer == 'B'),
                    const SizedBox(height: 8),
                    _optionTile('C', q.optionC, q.correctAnswer == 'C'),
                    const SizedBox(height: 8),
                    _optionTile('D', q.optionD, q.correctAnswer == 'D'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _optionTile(String key, String text, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.successLight : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? AppColors.successBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isCorrect ? AppColors.success : AppColors.surfaceSubtle,
            child: Text(
              key, 
              style: TextStyle(
                fontSize: 11, 
                color: isCorrect ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(QuestionBankState state, bool isMobile) {
    final totalPages = (state.totalCount / state.pageSize).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isMobile)
            Text(
              'Total: ${state.totalCount}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: state.currentPage > 0 ? _viewModel.previousPage : null,
              ),
              Text(
                'Page ${state.currentPage + 1} of $totalPages',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: (state.currentPage + 1) * state.pageSize < state.totalCount ? _viewModel.nextPage : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
