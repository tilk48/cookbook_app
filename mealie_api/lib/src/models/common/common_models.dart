import 'package:json_annotation/json_annotation.dart';

part 'common_models.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  final List<T> items;
  final String? next;
  final String? previous;

  const PaginatedResponse({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.items,
    this.next,
    this.previous,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}

@JsonSerializable()
class ErrorResponse {
  final String message;
  final String? detail;
  final int? code;

  const ErrorResponse({
    required this.message,
    this.detail,
    this.code,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}

@JsonSerializable()
class SuccessResponse {
  final String message;

  const SuccessResponse({required this.message});

  factory SuccessResponse.fromJson(Map<String, dynamic> json) =>
      _$SuccessResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SuccessResponseToJson(this);
}

enum OrderDirection {
  asc,
  desc,
}

@JsonSerializable()
class QueryParameters {
  final int? page;
  @JsonKey(name: 'per_page')
  final int? perPage;
  @JsonKey(name: 'order_by')
  final String? orderBy;
  @JsonKey(name: 'order_direction')
  final OrderDirection? orderDirection;
  final String? search;
  final List<String>? tags;
  final List<String>? categories;
  final bool? requireAllTags;
  final bool? requireAllCategories;

  const QueryParameters({
    this.page,
    this.perPage,
    this.orderBy,
    this.orderDirection,
    this.search,
    this.tags,
    this.categories,
    this.requireAllTags,
    this.requireAllCategories,
  });

  factory QueryParameters.fromJson(Map<String, dynamic> json) =>
      _$QueryParametersFromJson(json);

  Map<String, dynamic> toJson() => _$QueryParametersToJson(this);

  Map<String, String> toQueryMap() {
    final map = <String, String>{};
    if (page != null) map['page'] = page.toString();
    if (perPage != null) map['perPage'] = perPage.toString(); // camelCase for Mealie
    if (orderBy != null) map['orderBy'] = orderBy!; // camelCase for Mealie
    if (orderDirection != null) map['orderDirection'] = orderDirection!.name; // camelCase for Mealie
    if (search != null) map['search'] = search!;
    
    // Add tag filtering support
    if (tags != null && tags!.isNotEmpty) {
      // Based on the curl example, use single 'tags' parameter with UUID
      if (tags!.length == 1) {
        map['tags'] = tags!.first;
      } else {
        // For multiple tags, join with commas (need to test this)
        map['tags'] = tags!.join(',');
      }
      map['requireAllTags'] = requireAllTags?.toString() ?? 'false';
    }
    
    // Add category filtering support  
    if (categories != null && categories!.isNotEmpty) {
      if (categories!.length == 1) {
        map['categories'] = categories!.first;
      } else {
        map['categories'] = categories!.join(',');
      }
      map['requireAllCategories'] = requireAllCategories?.toString() ?? 'false';
    }
    
    return map;
  }
}