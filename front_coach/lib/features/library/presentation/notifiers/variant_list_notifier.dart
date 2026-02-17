import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import '../state/variant_list_state.dart';

class VariantListNotifier extends StateNotifier<VariantListState> {
  final VariantRepository _repository;
  final String _coachId;

  static const int _pageSize = 20;
  List<Variant> _allVariants = [];
  List<Variant> _filteredVariants = [];

  VariantListNotifier(this._repository, this._coachId)
      : super(const VariantListState.initial()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    try {
      state = const VariantListState.loading();

      // Load all variants from repository
      _allVariants = await _repository.findAllActive();

      // Filter by coachId
      _allVariants = _allVariants
          .where((variant) => variant.coachId == _coachId)
          .toList();

      // Sort by name
      _allVariants.sort((a, b) => a.name.compareTo(b.name));

      _filteredVariants = _allVariants;

      // Return first page
      final hasMore = _filteredVariants.length > _pageSize;
      final variants = _filteredVariants.take(_pageSize).toList();

      state = VariantListState.loaded(
        variants: variants,
        hasMore: hasMore,
        currentPage: 0,
      );
    } catch (e) {
      state = VariantListState.error('Failed to load variants: $e');
    }
  }

  void loadMore() {
    state.maybeWhen(
      loaded: (variants, hasMore, currentPage, searchQuery) {
        if (!hasMore) return;

        final nextPage = currentPage + 1;
        final startIndex = (nextPage + 1) * _pageSize;
        final endIndex = startIndex + _pageSize;

        if (startIndex >= _filteredVariants.length) return;

        final moreVariants = _filteredVariants
            .skip(startIndex)
            .take(_pageSize)
            .toList();

        final updatedList = [...variants, ...moreVariants];
        final stillHasMore = endIndex < _filteredVariants.length;

        state = VariantListState.loaded(
          variants: updatedList,
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
      _filteredVariants = _allVariants;
    } else {
      _filteredVariants = _allVariants
          .where((variant) => variant.name.toLowerCase().contains(trimmedQuery))
          .toList();
    }

    // Return first page of filtered results
    final hasMore = _filteredVariants.length > _pageSize;
    final variants = _filteredVariants.take(_pageSize).toList();

    state = VariantListState.loaded(
      variants: variants,
      hasMore: hasMore,
      currentPage: 0,
      searchQuery: query.isEmpty ? null : query,
    );
  }

  Future<void> deleteVariant(String id) async {
    try {
      await _repository.delete(id);

      // Remove from cached lists
      _allVariants.removeWhere((variant) => variant.id == id);
      _filteredVariants.removeWhere((variant) => variant.id == id);

      // Update state
      state.maybeWhen(
        loaded: (variants, hasMore, currentPage, searchQuery) {
          final updatedVariants = variants.where((v) => v.id != id).toList();

          // Recalculate hasMore
          final totalFiltered = _filteredVariants.length;
          final stillHasMore = updatedVariants.length < totalFiltered;

          state = VariantListState.loaded(
            variants: updatedVariants,
            hasMore: stillHasMore,
            currentPage: currentPage,
            searchQuery: searchQuery,
          );
        },
        orElse: () {},
      );
    } catch (e) {
      state = VariantListState.error('Failed to delete variant: $e');
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}
