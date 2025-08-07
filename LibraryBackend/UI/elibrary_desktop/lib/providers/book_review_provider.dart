import 'package:elibrary_desktop/models/book_review.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';

class BookReviewProvider extends BaseProvider<BookReview> {
  BookReviewProvider() : super("BookReview");

  @override
  BookReview fromJson(data) => BookReview.fromJson(data);
}