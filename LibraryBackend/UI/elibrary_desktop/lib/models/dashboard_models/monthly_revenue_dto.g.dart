// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_revenue_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthlyRevenueDto _$MonthlyRevenueDtoFromJson(Map<String, dynamic> json) =>
    MonthlyRevenueDto(
      month: json['month'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$MonthlyRevenueDtoToJson(MonthlyRevenueDto instance) =>
    <String, dynamic>{'month': instance.month, 'count': instance.count};
