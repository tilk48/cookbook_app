// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealPlan _$MealPlanFromJson(Map<String, dynamic> json) => MealPlan(
      id: json['id'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      planEntries: (json['plan_entries'] as List<dynamic>)
          .map((e) => PlanEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MealPlanToJson(MealPlan instance) => <String, dynamic>{
      'id': instance.id,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'plan_entries': instance.planEntries,
    };

PlanEntry _$PlanEntryFromJson(Map<String, dynamic> json) => PlanEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      entryType: $enumDecode(_$PlanEntryTypeEnumMap, json['entry_type']),
      title: json['title'] as String,
      text: json['text'] as String?,
      recipeId: json['recipe_id'] as String?,
    );

Map<String, dynamic> _$PlanEntryToJson(PlanEntry instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'entry_type': _$PlanEntryTypeEnumMap[instance.entryType]!,
      'title': instance.title,
      'text': instance.text,
      'recipe_id': instance.recipeId,
    };

const _$PlanEntryTypeEnumMap = {
  PlanEntryType.breakfast: 'breakfast',
  PlanEntryType.lunch: 'lunch',
  PlanEntryType.dinner: 'dinner',
  PlanEntryType.side: 'side',
};

CreatePlanEntryRequest _$CreatePlanEntryRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePlanEntryRequest(
      date: DateTime.parse(json['date'] as String),
      entryType: $enumDecode(_$PlanEntryTypeEnumMap, json['entry_type']),
      title: json['title'] as String,
      text: json['text'] as String?,
      recipeId: json['recipe_id'] as String?,
    );

Map<String, dynamic> _$CreatePlanEntryRequestToJson(
        CreatePlanEntryRequest instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'entry_type': _$PlanEntryTypeEnumMap[instance.entryType]!,
      'title': instance.title,
      'text': instance.text,
      'recipe_id': instance.recipeId,
    };
