// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) => Subscription(
  (json['id'] as num?)?.toInt(),
  json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  json['endDate'] == null ? null : DateTime.parse(json['endDate'] as String),
  (json['price'] as num?)?.toDouble(),
  json['isCancelled'] as bool?,
);

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'price': instance.price,
      'isCancelled': instance.isCancelled,
    };
