import 'package:json_annotation/json_annotation.dart';

import 'role.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  int? id;
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  DateTime? registrationDate;
  Role? role;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.registrationDate,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}