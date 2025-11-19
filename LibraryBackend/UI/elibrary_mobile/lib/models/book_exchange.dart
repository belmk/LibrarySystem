import 'package:json_annotation/json_annotation.dart';
import 'book.dart';
import 'user.dart';
import 'book_exchange_status.dart'; 

part 'book_exchange.g.dart';

@JsonSerializable()
class BookExchange {
  int? id;

  int? offerUserId;
  User? offerUser;

  int? receiverUserId;
  User? receiverUser;

  int? offerBookId;
  Book? offerBook;

  int? receiverBookId;
  Book? receiverBook;

  bool? offerUserAction;
  bool? receiverUserAction;

  BookExchangeStatus? bookExchangeStatus;

  BookExchange({
    this.id,
    this.offerUserId,
    this.offerUser,
    this.receiverUserId,
    this.receiverUser,
    this.offerBookId,
    this.offerBook,
    this.receiverBookId,
    this.receiverBook,
    this.offerUserAction = false,
    this.receiverUserAction = false,
    this.bookExchangeStatus = BookExchangeStatus.BookDeliveryPhase,
  });

  factory BookExchange.fromJson(Map<String, dynamic> json) =>
      _$BookExchangeFromJson(json);

  Map<String, dynamic> toJson() => _$BookExchangeToJson(this);
}
