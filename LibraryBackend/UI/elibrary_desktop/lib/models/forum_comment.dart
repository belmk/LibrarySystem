import 'package:json_annotation/json_annotation.dart';

import 'user.dart';
import 'forum_thread.dart';
part 'forum_comment.g.dart';

@JsonSerializable()
class ForumComment {
  int? id;
  User? user;
  ForumThread? forumThread;
  String? comment;
  DateTime? commentDate;

  ForumComment(this.id, this.user, this.forumThread, this.comment, this.commentDate);

  factory ForumComment.fromJson(Map<String, dynamic> json) => _$ForumCommentFromJson(json);
  Map<String, dynamic> toJson() => _$ForumCommentToJson(this);
}