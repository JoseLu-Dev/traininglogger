import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/exercise_providers.dart';

class ExerciseFormScreen extends ConsumerStatefulWidget {
  final String? exerciseId;

  const ExerciseFormScreen({
    super.key,
    this.exerciseId,
  });

  @override
  ConsumerState<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends ConsumerState<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;

  static const List<String> _categories = [
    'Strength',
    'Cardio',
    'Flexibility',
    'Sport Specific',
    'Balance',
    'Plyometric',
    'Other',
  ];

  bool _isEditMode = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseFormNotifierProvider(widget.exerciseId));

    // Listen for saved state to navigate back and refresh list
    ref.listen(exerciseFormNotifierProvider(widget.exerciseId), (previous, next) {
      next.maybeWhen(
        saved: () {
          if (mounted) {
            // Refresh the list before navigating back
            ref.invalidate(exerciseListNotifierProvider);
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
      loaded: (exercise) {
        // Initialize form fields only once
        if (exercise != null && !_isEditMode) {
          _nameController.text = exercise.name;
          _selectedCategory = exercise.category;
          _descriptionController.text = exercise.description ?? '';
          _isEditMode = true;
        }

        // Build category list, adding the current category if it's not in the predefined list
        final categoryItems = <String>[..._categories];
        if (_selectedCategory != null && !categoryItems.contains(_selectedCategory)) {
          categoryItems.add(_selectedCategory!);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditMode ? 'Edit Exercise' : 'Create Exercise'),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => _saveExercise(),
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
                      labelText: 'Exercise Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Exercise name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categoryItems.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
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
          title: Text(_isEditMode ? 'Edit Exercise' : 'Create Exercise'),
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
          title: Text(_isEditMode ? 'Edit Exercise' : 'Create Exercise'),
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

  void _saveExercise() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final category = _selectedCategory;
    final description = _descriptionController.text.trim();

    if (_isEditMode && widget.exerciseId != null) {
      ref.read(exerciseFormNotifierProvider(widget.exerciseId).notifier).updateExercise(
            widget.exerciseId!,
            name,
            category,
            description.isEmpty ? null : description,
          );
    } else {
      ref.read(exerciseFormNotifierProvider(widget.exerciseId).notifier).createExercise(
            name,
            category,
            description.isEmpty ? null : description,
          );
    }
  }
}
