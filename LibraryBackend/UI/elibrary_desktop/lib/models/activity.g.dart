// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  (json['id'] as num?)?.toInt(),
  json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  json['description'] as String?,
  json['activityDate'] == null
      ? null
      : DateTime.parse(json['activityDate'] as String),
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'id': instance.id,
  'user': instance.user,
  'description': instance.description,
  'activityDate': instance.activityDate?.toIso8601String(),
};
