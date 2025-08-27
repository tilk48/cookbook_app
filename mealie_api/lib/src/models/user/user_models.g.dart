// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      admin: json['admin'] as bool,
      tokens:
          (json['tokens'] as List<dynamic>?)?.map((e) => e as String).toList(),
      groupId: json['groupId'] as String?,
      householdId: json['householdId'] as String?,
      canInvite: json['canInvite'] as bool?,
      canManage: json['canManage'] as bool?,
      canOrganize: json['canOrganize'] as bool?,
      advanced: json['advanced'] as bool?,
      group: json['group'] as String?,
      household: json['household'] as String?,
      authMethod: json['authMethod'] as String?,
      groupSlug: json['groupSlug'] as String?,
      householdSlug: json['householdSlug'] as String?,
      canManageHousehold: json['canManageHousehold'] as bool?,
      cacheKey: json['cacheKey'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'fullName': instance.fullName,
      'admin': instance.admin,
      'tokens': instance.tokens,
      'groupId': instance.groupId,
      'householdId': instance.householdId,
      'canInvite': instance.canInvite,
      'canManage': instance.canManage,
      'canOrganize': instance.canOrganize,
      'advanced': instance.advanced,
      'group': instance.group,
      'household': instance.household,
      'authMethod': instance.authMethod,
      'groupSlug': instance.groupSlug,
      'householdSlug': instance.householdSlug,
      'canManageHousehold': instance.canManageHousehold,
      'cacheKey': instance.cacheKey,
    };

UpdateUserRequest _$UpdateUserRequestFromJson(Map<String, dynamic> json) =>
    UpdateUserRequest(
      email: json['email'] as String?,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
    );

Map<String, dynamic> _$UpdateUserRequestToJson(UpdateUserRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'username': instance.username,
      'full_name': instance.fullName,
    };
