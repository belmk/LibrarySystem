// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserReview _$UserReviewFromJson(Map<String, dynamic> json) => UserReview(
  id: (json['id'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toInt(),
  comment: json['comment'] as String?,
  reviewDate: json['reviewDate'] == null
      ? null
      : DateTime.parse(json['reviewDate'] as String),
  reviewerUser: json['reviewerUser'] == null
      ? null
      : User.fromJson(json['reviewerUser'] as Map<String, dynamic>),
  reviewedUser: json['reviewedUser'] == null
      ? null
      : User.fromJson(json['reviewedUser'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserReviewToJson(UserReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'comment': instance.comment,
      'reviewDate': instance.reviewDate?.toIso8601String(),
      'reviewerUser': instance.reviewerUser,
      'reviewedUser': instance.reviewedUser,
    };
