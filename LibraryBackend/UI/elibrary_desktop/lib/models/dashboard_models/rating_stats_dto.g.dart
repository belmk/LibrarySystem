// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RatingStatsDto _$RatingStatsDtoFromJson(Map<String, dynamic> json) =>
    RatingStatsDto(
      name: json['name'] as String,
      avgRating: (json['avgRating'] as num).toDouble(),
      totalRatings: (json['totalRatings'] as num).toInt(),
    );

Map<String, dynamic> _$RatingStatsDtoToJson(RatingStatsDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'avgRating': instance.avgRating,
      'totalRatings': instance.totalRatings,
    };
