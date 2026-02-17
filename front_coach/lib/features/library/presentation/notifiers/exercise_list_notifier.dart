import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import '../state/exercise_list_state.dart';

class ExerciseListNotifier extends StateNotifier<ExerciseListState> {
  final ExerciseRepository _repository;
  final String _coachId;

  static const int _pageSize = 20;
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];

  ExerciseListNotifier(this._repository, this._coachId)
      : super(const ExerciseListState.initial()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    try {
      state = const ExerciseListState.loading();

      // Load all exercises from repository
      _allExercises = await _repository.findAllActive();

      // Filter by coachId
      _allExercises = _allExercises
          .where((exercise) => exercise.coachId == _coachId)
          .toList();

      // Sort by name
      _allExercises.sort((a, b) => a.name.compareTo(b.name));

      _filteredExercises = _allExercises;

      // Return first page
      final hasMore = _filteredExercises.length > _pageSize;
      final exercises = _filteredExercises.take(_pageSize).toList();

      state = ExerciseListState.loaded(
        exercises: exercises,
        hasMore: hasMore,
        currentPage: 0,
      );
    } catch (e) {
      state = ExerciseListState.error('Failed to load exercises: $e');
    }
  }

  void loadMore() {
    state.maybeWhen(
      loaded: (exercises, hasMore, currentPage, searchQuery) {
        if (!hasMore) return;

        final nextPage = currentPage + 1;
        final startIndex = (nextPage + 1) * _pageSize;
        final endIndex = startIndex + _pageSize;

        if (startIndex >= _filteredExercises.length) return;

        final moreExercises = _filteredExercises
            .skip(startIndex)
            .take(_pageSize)
            .toList();

        final updatedList = [...exercises, ...moreExercises];
        final stillHasMore = endIndex < _filteredExercises.length;

        state = ExerciseListState.loaded(
          exercises: updatedList,
          hasMore: stillHasMore,
          currentPage: nextPage,
          searchQuery: searchQuery,
        );
      },
      orElse: () {},
    );
  }

  Future<void> search(String query) async {
    final trimmedQuery = query.trim().toLowerCase();

    if (trimmedQuery.isEmpty) {
      _filteredExercises = _allExercises;
    } else {
      _filteredExercises = _allExercises
          .where((exercise) => exercise.name.toLowerCase().contains(trimmedQuery))
          .toList();
    }

    // Return first page of filtered results
    final hasMore = _filteredExercises.length > _pageSize;
    final exercises = _filteredExercises.take(_pageSize).toList();

    state = ExerciseListState.loaded(
      exercises: exercises,
      hasMore: hasMore,
      currentPage: 0,
      searchQuery: query.isEmpty ? null : query,
    );
  }

  Future<void> deleteExercise(String id) async {
    try {
      await _repository.delete(id);

      // Remove from cached lists
      _allExercises.removeWhere((exercise) => exercise.id == id);
      _filteredExercises.removeWhere((exercise) => exercise.id == id);

      // Update state
      state.maybeWhen(
        loaded: (exercises, hasMore, currentPage, searchQuery) {
          final updatedExercises = exercises.where((e) => e.id != id).toList();

          // Recalculate hasMore
          final totalFiltered = _filteredExercises.length;
          final stillHasMore = updatedExercises.length < totalFiltered;

          state = ExerciseListState.loaded(
            exercises: updatedExercises,
            hasMore: stillHasMore,
            currentPage: currentPage,
            searchQuery: searchQuery,
          );
        },
        orElse: () {},
      );
    } catch (e) {
      state = ExerciseListState.error('Failed to delete exercise: $e');
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}
