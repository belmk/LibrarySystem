// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookReview _$BookReviewFromJson(Map<String, dynamic> json) => BookReview(
  (json['id'] as num?)?.toInt(),
  (json['rating'] as num?)?.toInt(),
  json['comment'] as String?,
  json['reviewDate'] == null
      ? null
      : DateTime.parse(json['reviewDate'] as String),
  json['book'] == null
      ? null
      : Book.fromJson(json['book'] as Map<String, dynamic>),
  json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookReviewToJson(BookReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'comment': instance.comment,
      'reviewDate': instance.reviewDate?.toIso8601String(),
      'book': instance.book,
      'user': instance.user,
    };
