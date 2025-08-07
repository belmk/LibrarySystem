import 'package:elibrary_desktop/models/book.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';

class BookProvider extends BaseProvider<Book> {
  BookProvider() : super("Book");

  @override
  Book fromJson(data) => Book.fromJson(data);
}