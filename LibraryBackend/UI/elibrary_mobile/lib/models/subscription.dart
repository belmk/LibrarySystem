import 'package:json_annotation/json_annotation.dart';

import 'user.dart';
part 'subscription.g.dart';

@JsonSerializable()
class Subscription {
  int? id;
  User? user;
  DateTime? startDate;
  DateTime? endDate;
  double? price;
  bool? isCancelled;

  Subscription(this.id, this.user, this.startDate, this.endDate, this.price, this.isCancelled);

  factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);
}