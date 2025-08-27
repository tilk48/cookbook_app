import 'package:json_annotation/json_annotation.dart';

part 'meal_plan_models.g.dart';

@JsonSerializable()
class MealPlan {
  final String id;
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  @JsonKey(name: 'plan_entries')
  final List<PlanEntry> planEntries;

  const MealPlan({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.planEntries,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) => _$MealPlanFromJson(json);
  Map<String, dynamic> toJson() => _$MealPlanToJson(this);
}

@JsonSerializable()
class PlanEntry {
  final String id;
  final DateTime date;
  @JsonKey(name: 'entry_type')
  final PlanEntryType entryType;
  final String title;
  final String? text;
  @JsonKey(name: 'recipe_id')
  final String? recipeId;

  const PlanEntry({
    required this.id,
    required this.date,
    required this.entryType,
    required this.title,
    this.text,
    this.recipeId,
  });

  factory PlanEntry.fromJson(Map<String, dynamic> json) => _$PlanEntryFromJson(json);
  Map<String, dynamic> toJson() => _$PlanEntryToJson(this);
}

enum PlanEntryType {
  breakfast,
  lunch,  
  dinner,
  side,
}

@JsonSerializable()
class CreatePlanEntryRequest {
  final DateTime date;
  @JsonKey(name: 'entry_type')
  final PlanEntryType entryType;
  final String title;
  final String? text;
  @JsonKey(name: 'recipe_id')
  final String? recipeId;

  const CreatePlanEntryRequest({
    required this.date,
    required this.entryType,
    required this.title,
    this.text,
    this.recipeId,
  });

  factory CreatePlanEntryRequest.fromJson(Map<String, dynamic> json) => 
      _$CreatePlanEntryRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePlanEntryRequestToJson(this);
}