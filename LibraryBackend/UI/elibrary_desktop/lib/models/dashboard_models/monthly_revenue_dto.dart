import 'package:json_annotation/json_annotation.dart';

part 'monthly_revenue_dto.g.dart';

@JsonSerializable()
class MonthlyRevenueDto {
  final String month;
  final int count;

  MonthlyRevenueDto({
    required this.month,
    required this.count,
  });

  factory MonthlyRevenueDto.fromJson(Map<String, dynamic> json) =>
      _$MonthlyRevenueDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyRevenueDtoToJson(this);
}
