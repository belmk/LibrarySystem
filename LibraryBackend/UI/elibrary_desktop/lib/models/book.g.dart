// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
  (json['id'] as num?)?.toInt(),
  json['author'] == null
      ? null
      : Author.fromJson(json['author'] as Map<String, dynamic>),
  json['title'] as String?,
  json['description'] as String?,
  (json['pageNumber'] as num?)?.toInt(),
  (json['availableNumber'] as num?)?.toInt(),
  (json['genres'] as List<dynamic>?)
      ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
      .toList(),
  json['isUserBook'] as bool?,
  (json['userId'] as num?)?.toInt(),
  json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  json['coverImageBase64'] as String?,
  json['coverImageContentType'] as String?,
);

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
  'id': instance.id,
  'author': instance.author,
  'title': instance.title,
  'description': instance.description,
  'pageNumber': instance.pageNumber,
  'availableNumber': instance.availableNumber,
  'genres': instance.genres,
  'isUserBook': instance.isUserBook,
  'userId': instance.userId,
  'user': instance.user,
  'coverImageBase64': instance.coverImageBase64,
  'coverImageContentType': instance.coverImageContentType,
};
