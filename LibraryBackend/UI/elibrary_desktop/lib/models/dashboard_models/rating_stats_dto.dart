import 'package:json_annotation/json_annotation.dart';

part 'rating_stats_dto.g.dart';

@JsonSerializable()
class RatingStatsDto {
  final String name;
  final double avgRating;
  final int totalRatings;

  RatingStatsDto({
    required this.name,
    required this.avgRating,
    required this.totalRatings,
  });

  factory RatingStatsDto.fromJson(Map<String, dynamic> json) =>
      _$RatingStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RatingStatsDtoToJson(this);
}
