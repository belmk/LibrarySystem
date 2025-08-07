import 'package:elibrary_desktop/models/author.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';

class AuthorProvider extends BaseProvider<Author> {
  AuthorProvider() : super("Author");

  @override
  Author fromJson(data) => Author.fromJson(data);
}