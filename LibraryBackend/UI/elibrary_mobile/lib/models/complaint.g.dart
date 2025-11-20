// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Complaint _$ComplaintFromJson(Map<String, dynamic> json) => Complaint(
  (json['id'] as num?)?.toInt(),
  json['sender'] == null
      ? null
      : User.fromJson(json['sender'] as Map<String, dynamic>),
  json['target'] == null
      ? null
      : User.fromJson(json['target'] as Map<String, dynamic>),
  json['reason'] as String?,
  json['complaintDate'] == null
      ? null
      : DateTime.parse(json['complaintDate'] as String),
  json['isResolved'] as bool?,
);

Map<String, dynamic> _$ComplaintToJson(Complaint instance) => <String, dynamic>{
  'id': instance.id,
  'sender': instance.sender,
  'target': instance.target,
  'reason': instance.reason,
  'complaintDate': instance.complaintDate?.toIso8601String(),
  'isResolved': instance.isResolved,
};
