import 'package:elibrary_mobile/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_review.g.dart';

@JsonSerializable()
class UserReview {
  int? id;
  int? rating;
  String? comment;
  DateTime? reviewDate;
  User? reviewerUser;
  User? reviewedUser;

  UserReview({
    this.id,
    this.rating,
    this.comment,
    this.reviewDate,
    this.reviewerUser,
    this.reviewedUser
  });

  factory UserReview.fromJson(Map<String, dynamic> json) => _$UserReviewFromJson(json);
  Map<String, dynamic> toJson() => _$UserReviewToJson(this);
}