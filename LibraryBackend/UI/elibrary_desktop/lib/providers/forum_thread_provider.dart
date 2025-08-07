import 'package:elibrary_desktop/models/forum_thread.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';

class ForumThreadProvider extends BaseProvider<ForumThread> {
  ForumThreadProvider() : super("ForumThread");

  @override
  ForumThread fromJson(data) => ForumThread.fromJson(data);
}