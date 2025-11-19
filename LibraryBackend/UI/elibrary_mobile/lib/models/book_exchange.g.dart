// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_exchange.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookExchange _$BookExchangeFromJson(Map<String, dynamic> json) => BookExchange(
  id: (json['id'] as num?)?.toInt(),
  offerUserId: (json['offerUserId'] as num?)?.toInt(),
  offerUser: json['offerUser'] == null
      ? null
      : User.fromJson(json['offerUser'] as Map<String, dynamic>),
  receiverUserId: (json['receiverUserId'] as num?)?.toInt(),
  receiverUser: json['receiverUser'] == null
      ? null
      : User.fromJson(json['receiverUser'] as Map<String, dynamic>),
  offerBookId: (json['offerBookId'] as num?)?.toInt(),
  offerBook: json['offerBook'] == null
      ? null
      : Book.fromJson(json['offerBook'] as Map<String, dynamic>),
  receiverBookId: (json['receiverBookId'] as num?)?.toInt(),
  receiverBook: json['receiverBook'] == null
      ? null
      : Book.fromJson(json['receiverBook'] as Map<String, dynamic>),
  offerUserAction: json['offerUserAction'] as bool? ?? false,
  receiverUserAction: json['receiverUserAction'] as bool? ?? false,
  bookExchangeStatus:
      $enumDecodeNullable(
        _$BookExchangeStatusEnumMap,
        json['bookExchangeStatus'],
      ) ??
      BookExchangeStatus.BookDeliveryPhase,
);

Map<String, dynamic> _$BookExchangeToJson(BookExchange instance) =>
    <String, dynamic>{
      'id': instance.id,
      'offerUserId': instance.offerUserId,
      'offerUser': instance.offerUser,
      'receiverUserId': instance.receiverUserId,
      'receiverUser': instance.receiverUser,
      'offerBookId': instance.offerBookId,
      'offerBook': instance.offerBook,
      'receiverBookId': instance.receiverBookId,
      'receiverBook': instance.receiverBook,
      'offerUserAction': instance.offerUserAction,
      'receiverUserAction': instance.receiverUserAction,
      'bookExchangeStatus':
          _$BookExchangeStatusEnumMap[instance.bookExchangeStatus],
    };

const _$BookExchangeStatusEnumMap = {
  BookExchangeStatus.PendingApproval: 0,
  BookExchangeStatus.BookDeliveryPhase: 1,
  BookExchangeStatus.BookReceivingPhase: 2,
  BookExchangeStatus.ExchangeCompleted: 3,
};
