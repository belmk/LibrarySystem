// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
  (json['id'] as num?)?.toInt(),
  json['firstName'] as String?,
  json['lastName'] as String?,
);

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
};
