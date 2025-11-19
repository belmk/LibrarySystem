// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForumThread _$ForumThreadFromJson(Map<String, dynamic> json) => ForumThread(
  (json['id'] as num?)?.toInt(),
  json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  json['book'] == null
      ? null
      : Book.fromJson(json['book'] as Map<String, dynamic>),
  json['title'] as String?,
  json['threadDate'] == null
      ? null
      : DateTime.parse(json['threadDate'] as String),
);

Map<String, dynamic> _$ForumThreadToJson(ForumThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'book': instance.book,
      'title': instance.title,
      'threadDate': instance.threadDate?.toIso8601String(),
    };
