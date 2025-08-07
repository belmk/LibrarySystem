import 'package:json_annotation/json_annotation.dart';

import 'user.dart';
import 'book.dart';

part 'forum_thread.g.dart';

@JsonSerializable()
class ForumThread {
  int? id;
  User? user;
  Book? book;
  String? title;
  DateTime? threadDate;

  ForumThread(this.id, this.user, this.book, this.title, this.threadDate);

  factory ForumThread.fromJson(Map<String, dynamic> json) => _$ForumThreadFromJson(json);
  Map<String, dynamic> toJson() => _$ForumThreadToJson(this);
}