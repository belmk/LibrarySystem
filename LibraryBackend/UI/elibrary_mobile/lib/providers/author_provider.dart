import 'package:elibrary_mobile/models/author.dart';
import 'package:elibrary_mobile/providers/base_provider.dart';

class AuthorProvider extends BaseProvider<Author> {
  AuthorProvider() : super("Author");

  @override
  Author fromJson(data) => Author.fromJson(data);
}