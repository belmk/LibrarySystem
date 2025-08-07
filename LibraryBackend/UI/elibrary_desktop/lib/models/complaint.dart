import 'package:json_annotation/json_annotation.dart';

import 'user.dart';
part 'complaint.g.dart';

@JsonSerializable()
class Complaint {
  int? id;
  User? sender;
  User? target;
  String? reason;
  DateTime? complaintDate;
  bool? isResolved;

  Complaint(this.id, this.sender, this.target, this.reason, this.complaintDate, this.isResolved);

  factory Complaint.fromJson(Map<String, dynamic> json) => _$ComplaintFromJson(json);
  Map<String, dynamic> toJson() => _$ComplaintToJson(this);
}