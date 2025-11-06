import 'package:elibrary_mobile/models/author.dart';
import 'package:elibrary_mobile/models/user.dart';
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
  User? user;

  String? coverImageBase64;
  String? coverImageContentType;

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
    this.user,
    this.coverImageBase64,
    this.coverImageContentType
  );
  
  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
  Map<String, dynamic> toJson() => _$BookToJson(this);
}