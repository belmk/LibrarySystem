// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  (json['id'] as num?)?.toInt(),
  json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  json['receivedDate'] == null
      ? null
      : DateTime.parse(json['receivedDate'] as String),
  json['title'] as String?,
  json['message'] as String?,
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'receivedDate': instance.receivedDate?.toIso8601String(),
      'title': instance.title,
      'message': instance.message,
    };
