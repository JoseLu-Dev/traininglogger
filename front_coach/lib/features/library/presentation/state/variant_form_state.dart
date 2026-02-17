import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:front_shared/front_shared.dart';

part 'variant_form_state.freezed.dart';

@freezed
class VariantFormState with _$VariantFormState {
  const factory VariantFormState.initial() = _Initial;
  const factory VariantFormState.loading() = _Loading;
  const factory VariantFormState.loaded({Variant? variant}) = _Loaded;
  const factory VariantFormState.saving() = _Saving;
  const factory VariantFormState.saved() = _Saved;
  const factory VariantFormState.error(String message) = _Error;
}
