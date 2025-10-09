import 'package:elibrary_desktop/models/book_exchange.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';

class BookExchangeProvider extends BaseProvider<BookExchange> {
  BookExchangeProvider() : super("BookExchange");

  @override
  BookExchange fromJson(data) => BookExchange.fromJson(data);
}