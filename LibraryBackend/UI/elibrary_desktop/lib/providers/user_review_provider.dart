import 'package:elibrary_desktop/models/user_review.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';

class UserReviewProvider extends BaseProvider<UserReview> {
  UserReviewProvider() : super("UserReview");

  @override
  UserReview fromJson(data) => UserReview.fromJson(data);
}