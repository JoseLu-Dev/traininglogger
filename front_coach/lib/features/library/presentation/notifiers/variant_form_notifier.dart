import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import '../state/variant_form_state.dart';

class VariantFormNotifier extends StateNotifier<VariantFormState> {
  final VariantRepository _repository;
  final String _coachId;
  final String? _variantId;

  VariantFormNotifier(
    this._repository,
    this._coachId,
    this._variantId,
  ) : super(const VariantFormState.initial()) {
    if (_variantId != null) {
      _loadVariant(_variantId);
    } else {
      state = const VariantFormState.loaded();
    }
  }

  Future<void> _loadVariant(String id) async {
    try {
      state = const VariantFormState.loading();
      final variant = await _repository.findById(id);

      if (variant == null) {
        state = const VariantFormState.error('Variant not found');
        return;
      }

      state = VariantFormState.loaded(variant: variant);
    } catch (e) {
      state = VariantFormState.error('Failed to load variant: $e');
    }
  }

  Future<void> createVariant(
    String name,
    String? description,
  ) async {
    try {
      state = const VariantFormState.saving();

      final variant = Variant.create(
        coachId: _coachId,
        name: name,
        description: description,
      );

      await _repository.create(variant);

      state = const VariantFormState.saved();
    } catch (e) {
      state = VariantFormState.error('Failed to create variant: $e');
    }
  }

  Future<void> updateVariant(
    String id,
    String name,
    String? description,
  ) async {
    try {
      state = const VariantFormState.saving();

      final currentVariant = await _repository.findById(id);
      if (currentVariant == null) {
        state = const VariantFormState.error('Variant not found');
        return;
      }

      final updatedVariant = currentVariant.copyWith(
        name: name,
        description: description,
      ).markDirty();

      await _repository.update(updatedVariant);

      state = const VariantFormState.saved();
    } catch (e) {
      state = VariantFormState.error('Failed to update variant: $e');
    }
  }
}
