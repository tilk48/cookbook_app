// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PaginatedResponse<T>(
      page: (json['page'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
      items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );

Map<String, dynamic> _$PaginatedResponseToJson<T>(
  PaginatedResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'page': instance.page,
      'per_page': instance.perPage,
      'total': instance.total,
      'total_pages': instance.totalPages,
      'items': instance.items.map(toJsonT).toList(),
      'next': instance.next,
      'previous': instance.previous,
    };

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      message: json['message'] as String,
      detail: json['detail'] as String?,
      code: (json['code'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'detail': instance.detail,
      'code': instance.code,
    };

SuccessResponse _$SuccessResponseFromJson(Map<String, dynamic> json) =>
    SuccessResponse(
      message: json['message'] as String,
    );

Map<String, dynamic> _$SuccessResponseToJson(SuccessResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
    };

QueryParameters _$QueryParametersFromJson(Map<String, dynamic> json) =>
    QueryParameters(
      page: (json['page'] as num?)?.toInt(),
      perPage: (json['per_page'] as num?)?.toInt(),
      orderBy: json['order_by'] as String?,
      orderDirection:
          $enumDecodeNullable(_$OrderDirectionEnumMap, json['order_direction']),
      search: json['search'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      requireAllTags: json['requireAllTags'] as bool?,
      requireAllCategories: json['requireAllCategories'] as bool?,
    );

Map<String, dynamic> _$QueryParametersToJson(QueryParameters instance) =>
    <String, dynamic>{
      'page': instance.page,
      'per_page': instance.perPage,
      'order_by': instance.orderBy,
      'order_direction': _$OrderDirectionEnumMap[instance.orderDirection],
      'search': instance.search,
      'tags': instance.tags,
      'categories': instance.categories,
      'requireAllTags': instance.requireAllTags,
      'requireAllCategories': instance.requireAllCategories,
    };

const _$OrderDirectionEnumMap = {
  OrderDirection.asc: 'asc',
  OrderDirection.desc: 'desc',
};
