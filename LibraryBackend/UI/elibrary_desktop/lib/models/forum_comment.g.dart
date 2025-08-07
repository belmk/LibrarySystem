// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForumComment _$ForumCommentFromJson(Map<String, dynamic> json) => ForumComment(
  (json['id'] as num?)?.toInt(),
  json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  json['forumThread'] == null
      ? null
      : ForumThread.fromJson(json['forumThread'] as Map<String, dynamic>),
  json['comment'] as String?,
  json['commentDate'] == null
      ? null
      : DateTime.parse(json['commentDate'] as String),
);

Map<String, dynamic> _$ForumCommentToJson(ForumComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'forumThread': instance.forumThread,
      'comment': instance.comment,
      'commentDate': instance.commentDate?.toIso8601String(),
    };
