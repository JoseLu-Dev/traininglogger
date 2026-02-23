import 'package:front_shared/front_shared.dart';

class ExerciseDetailData {
  final ExercisePlan plan;
  final Exercise exercise;
  final List<Variant> variants;
  final List<SetPlan> sets;
  // See-mode extras
  final ExerciseSession? session;
  final List<Variant> sessionVariants;
  final List<SetSession> sessionSets;

  const ExerciseDetailData({
    required this.plan,
    required this.exercise,
    required this.variants,
    required this.sets,
    this.session,
    this.sessionVariants = const [],
    this.sessionSets = const [],
  });

  ExerciseDetailData copyWith({
    ExercisePlan? plan,
    Exercise? exercise,
    List<Variant>? variants,
    List<SetPlan>? sets,
    ExerciseSession? Function()? session,
    List<Variant>? sessionVariants,
    List<SetSession>? sessionSets,
  }) {
    return ExerciseDetailData(
      plan: plan ?? this.plan,
      exercise: exercise ?? this.exercise,
      variants: variants ?? this.variants,
      sets: sets ?? this.sets,
      session: session != null ? session() : this.session,
      sessionVariants: sessionVariants ?? this.sessionVariants,
      sessionSets: sessionSets ?? this.sessionSets,
    );
  }
}
