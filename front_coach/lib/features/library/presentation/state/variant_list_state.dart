import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:front_shared/front_shared.dart';

part 'variant_list_state.freezed.dart';

@freezed
class VariantListState with _$VariantListState {
  const factory VariantListState.initial() = _Initial;
  const factory VariantListState.loading() = _Loading;
  const factory VariantListState.loaded({
    required List<Variant> variants,
    @Default(false) bool hasMore,
    @Default(0) int currentPage,
    String? searchQuery,
  }) = _Loaded;
  const factory VariantListState.error(String message) = _Error;
}
