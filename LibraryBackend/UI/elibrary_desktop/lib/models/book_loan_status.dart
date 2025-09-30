import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

enum BookLoanStatus {
  @JsonValue(0)
  pendingApproval,

  @JsonValue(1)
  approved,

  @JsonValue(2)
  pickedUp,

  @JsonValue(3)
  returned,
}

extension BookLoanStatusExtension on BookLoanStatus {
  String get displayName {
    switch (this) {
      case BookLoanStatus.pendingApproval:
        return 'Čeka odobrenje';
      case BookLoanStatus.approved:
        return 'Posudba odobrena';
      case BookLoanStatus.pickedUp:
        return 'Knjiga preuzeta';
      case BookLoanStatus.returned:
        return 'Knjiga vraćena';
    }
  }

   Color get color {
    switch (this) {
      case BookLoanStatus.pendingApproval:
        return Colors.grey;
      case BookLoanStatus.approved:
        return Colors.green;
      case BookLoanStatus.pickedUp:
        return Colors.blue;
      case BookLoanStatus.returned:
        return Colors.black;
    }
  }
}



