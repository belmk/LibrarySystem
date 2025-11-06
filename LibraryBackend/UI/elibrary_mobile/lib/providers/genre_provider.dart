import 'package:elibrary_mobile/models/genre.dart';
import 'package:elibrary_mobile/providers/base_provider.dart';

class GenreProvider extends BaseProvider<Genre> {
  GenreProvider() : super("Genre");

  @override
  Genre fromJson(data) => Genre.fromJson(data);
}