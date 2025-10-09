import 'package:json_annotation/json_annotation.dart';

part 'user_loan_stats_dto.g.dart';

@JsonSerializable()
class UserLoanStatsDto {
  final String username;
  final int loanCount;

  UserLoanStatsDto({
    required this.username,
    required this.loanCount,
  });

  factory UserLoanStatsDto.fromJson(Map<String, dynamic> json) =>
      _$UserLoanStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoanStatsDtoToJson(this);
}
