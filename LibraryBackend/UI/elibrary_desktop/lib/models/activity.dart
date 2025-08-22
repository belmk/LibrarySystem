import 'package:elibrary_desktop/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity {
  int? id;
  User? user;
  String? description;
  DateTime? activityDate;

  Activity(this.id, this.user, this.description, this.activityDate);

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}