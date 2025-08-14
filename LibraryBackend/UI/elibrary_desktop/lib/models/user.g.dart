// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) =>
    User(
        (json['id'] as num?)?.toInt(),
        json['firstName'] as String?,
        json['lastName'] as String?,
        json['username'] as String?,
        json['role'] == null
            ? null
            : Role.fromJson(json['role'] as Map<String, dynamic>),
      )
      ..email = json['email'] as String?
      ..registrationDate = json['registrationDate'] == null
          ? null
          : DateTime.parse(json['registrationDate'] as String);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'username': instance.username,
  'email': instance.email,
  'registrationDate': instance.registrationDate?.toIso8601String(),
  'role': instance.role,
};
