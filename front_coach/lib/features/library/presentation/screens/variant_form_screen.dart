import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/variant_providers.dart';

class VariantFormScreen extends ConsumerStatefulWidget {
  final String? variantId;

  const VariantFormScreen({
    super.key,
    this.variantId,
  });

  @override
  ConsumerState<VariantFormScreen> createState() => _VariantFormScreenState();
}

class _VariantFormScreenState extends ConsumerState<VariantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isEditMode = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(variantFormNotifierProvider(widget.variantId));

    // Listen for saved state to navigate back and refresh list
    ref.listen(variantFormNotifierProvider(widget.variantId), (previous, next) {
      next.maybeWhen(
        saved: () {
          if (mounted) {
            // Refresh the list before navigating back
            ref.invalidate(variantListNotifierProvider);
            context.pop();
          }
        },
        error: (message) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
        orElse: () {},
      );
    });

    return state.when(
      initial: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      loaded: (variant) {
        // Initialize form fields only once
        if (variant != null && !_isEditMode) {
          _nameController.text = variant.name;
          _descriptionController.text = variant.description ?? '';
          _isEditMode = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditMode ? 'Edit Variant' : 'Create Variant'),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => _saveVariant(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    autofocus: !_isEditMode,
                    decoration: const InputDecoration(
                      labelText: 'Variant Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Variant name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    minLines: 3,
                    maxLines: 8,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      saving: () => Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Variant' : 'Create Variant'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      saved: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (message) => Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Variant' : 'Create Variant'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveVariant() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (_isEditMode && widget.variantId != null) {
      ref.read(variantFormNotifierProvider(widget.variantId).notifier).updateVariant(
            widget.variantId!,
            name,
            description.isEmpty ? null : description,
          );
    } else {
      ref.read(variantFormNotifierProvider(widget.variantId).notifier).createVariant(
            name,
            description.isEmpty ? null : description,
          );
    }
  }
}
