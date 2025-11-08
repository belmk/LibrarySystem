import 'package:json_annotation/json_annotation.dart';

import 'user.dart';
import 'book.dart';
part 'book_review.g.dart';

@JsonSerializable()
class BookReview {
  int? id;
  int? rating;
  String? comment;
  DateTime? reviewDate;
  Book? book;
  User? user;

  BookReview(this.id, this.rating, this.comment, this.reviewDate, this.book, this.user);

  factory BookReview.fromJson(Map<String, dynamic> json) => _$BookReviewFromJson(json);
  Map<String, dynamic> toJson() => _$BookReviewToJson(this);
}