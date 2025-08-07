import 'package:json_annotation/json_annotation.dart';

import 'genre.dart';
part 'book.g.dart';

@JsonSerializable()
class Book {
  int? id;
  int? authorId;
  String? title;
  String? description;
  int? pageNumber;
  int? availableNumber;
  List<Genre>? genres;

  Book(this.id, this.authorId, this.title, this.description, this.pageNumber, this.availableNumber, this.genres);

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
  Map<String, dynamic> toJson() => _$BookToJson(this);
}