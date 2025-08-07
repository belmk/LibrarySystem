import 'package:json_annotation/json_annotation.dart';

import 'user.dart';
part 'notification.g.dart';

@JsonSerializable()
class Notification {
  int? id;
  User? user;
  DateTime? receivedDate;
  String? title;
  String? message;

  Notification(this.id, this.user, this.receivedDate, this.title, this.message);

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}