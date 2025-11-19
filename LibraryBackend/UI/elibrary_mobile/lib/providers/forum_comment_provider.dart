import 'package:elibrary_mobile/models/forum_comment.dart';
import 'package:elibrary_mobile/providers/base_provider.dart';

class ForumCommentProvider extends BaseProvider<ForumComment> {
  ForumCommentProvider() : super("ForumComment");

  @override
  ForumComment fromJson(data) => ForumComment.fromJson(data);
}