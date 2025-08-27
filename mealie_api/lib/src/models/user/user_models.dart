import 'package:json_annotation/json_annotation.dart';

part 'user_models.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String username;
  final String fullName;  // API returns camelCase
  final bool admin;
  final List<String>? tokens;
  final String? groupId;   // API returns camelCase
  final String? householdId;  // API returns camelCase
  final bool? canInvite;   // API returns camelCase
  final bool? canManage;   // API returns camelCase
  final bool? canOrganize; // API returns camelCase
  final bool? advanced;
  // Additional fields from API response
  final String? group;
  final String? household;
  final String? authMethod;  // API returns camelCase, no annotation needed
  final String? groupSlug;
  final String? householdSlug;
  final bool? canManageHousehold;  // API returns camelCase, no annotation needed
  final String? cacheKey;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.admin,
    this.tokens,
    this.groupId,
    this.householdId,
    this.canInvite,
    this.canManage,
    this.canOrganize,
    this.advanced,
    this.group,
    this.household,
    this.authMethod,
    this.groupSlug,
    this.householdSlug,
    this.canManageHousehold,
    this.cacheKey,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UpdateUserRequest {
  final String? email;
  final String? username;
  @JsonKey(name: 'full_name')
  final String? fullName;

  const UpdateUserRequest({
    this.email,
    this.username,
    this.fullName,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}