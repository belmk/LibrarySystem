// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_loan_stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookLoanStatsDto _$BookLoanStatsDtoFromJson(Map<String, dynamic> json) =>
    BookLoanStatsDto(
      title: json['title'] as String,
      loanCount: (json['loanCount'] as num).toInt(),
    );

Map<String, dynamic> _$BookLoanStatsDtoToJson(BookLoanStatsDto instance) =>
    <String, dynamic>{'title': instance.title, 'loanCount': instance.loanCount};
