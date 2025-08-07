import 'package:elibrary_desktop/models/genre.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';

class GenreProvider extends BaseProvider<Genre> {
  GenreProvider() : super("Genre");

  @override
  Genre fromJson(data) => Genre.fromJson(data);
}