// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_loan_stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLoanStatsDto _$UserLoanStatsDtoFromJson(Map<String, dynamic> json) =>
    UserLoanStatsDto(
      username: json['username'] as String,
      loanCount: (json['loanCount'] as num).toInt(),
    );

Map<String, dynamic> _$UserLoanStatsDtoToJson(UserLoanStatsDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'loanCount': instance.loanCount,
    };
