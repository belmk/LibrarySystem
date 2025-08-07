// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
  (json['id'] as num?)?.toInt(),
  (json['authorId'] as num?)?.toInt(),
  json['title'] as String?,
  json['description'] as String?,
  (json['pageNumber'] as num?)?.toInt(),
  (json['availableNumber'] as num?)?.toInt(),
  (json['genres'] as List<dynamic>?)
      ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
  'id': instance.id,
  'authorId': instance.authorId,
  'title': instance.title,
  'description': instance.description,
  'pageNumber': instance.pageNumber,
  'availableNumber': instance.availableNumber,
  'genres': instance.genres,
};
