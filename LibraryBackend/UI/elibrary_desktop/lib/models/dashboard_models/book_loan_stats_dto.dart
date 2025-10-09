import 'package:json_annotation/json_annotation.dart';

part 'book_loan_stats_dto.g.dart';

@JsonSerializable()
class BookLoanStatsDto {
  final String title;
  final int loanCount;

  BookLoanStatsDto({
    required this.title,
    required this.loanCount,
  });

  factory BookLoanStatsDto.fromJson(Map<String, dynamic> json) =>
      _$BookLoanStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookLoanStatsDtoToJson(this);
}
