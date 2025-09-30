// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_loan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookLoan _$BookLoanFromJson(Map<String, dynamic> json) => BookLoan(
  id: (json['id'] as num?)?.toInt(),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  book: json['book'] == null
      ? null
      : Book.fromJson(json['book'] as Map<String, dynamic>),
  loanDate: json['loanDate'] == null
      ? null
      : DateTime.parse(json['loanDate'] as String),
  returnDate: json['returnDate'] == null
      ? null
      : DateTime.parse(json['returnDate'] as String),
  loanStatus: $enumDecodeNullable(_$BookLoanStatusEnumMap, json['loanStatus']),
);

Map<String, dynamic> _$BookLoanToJson(BookLoan instance) => <String, dynamic>{
  'id': instance.id,
  'user': instance.user,
  'book': instance.book,
  'loanDate': instance.loanDate?.toIso8601String(),
  'returnDate': instance.returnDate?.toIso8601String(),
  'loanStatus': _$BookLoanStatusEnumMap[instance.loanStatus],
};

const _$BookLoanStatusEnumMap = {
  BookLoanStatus.pendingApproval: 0,
  BookLoanStatus.approved: 1,
  BookLoanStatus.pickedUp: 2,
  BookLoanStatus.returned: 3,
};
