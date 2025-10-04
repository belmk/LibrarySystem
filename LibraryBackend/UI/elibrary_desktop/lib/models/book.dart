import 'package:elibrary_desktop/models/author.dart';
import 'package:json_annotation/json_annotation.dart';

import 'genre.dart';
part 'book.g.dart';

@JsonSerializable()
class Book {
  int? id;
  Author? author;
  String? title;
  String? description;
  int? pageNumber;
  int? availableNumber;
  List<Genre>? genres;

  bool? isUserBook;
  int? userId;

 Book(
    this.id,
    this.author,
    this.title,
    this.description,
    this.pageNumber,
    this.availableNumber,
    this.genres,
    this.isUserBook,
    this.userId,
  );
  
  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
  Map<String, dynamic> toJson() => _$BookToJson(this);
}