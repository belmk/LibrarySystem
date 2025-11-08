import 'package:elibrary_mobile/models/book_review.dart';
import 'package:elibrary_mobile/providers/base_provider.dart';

class BookReviewProvider extends BaseProvider<BookReview> {
  BookReviewProvider() : super("BookReview");

  @override
  BookReview fromJson(data) => BookReview.fromJson(data);
}