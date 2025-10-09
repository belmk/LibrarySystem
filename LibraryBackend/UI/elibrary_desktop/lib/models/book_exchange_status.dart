import 'package:json_annotation/json_annotation.dart';

enum BookExchangeStatus {
  @JsonValue(0)
  BookDeliveryPhase,

  @JsonValue(1)
  BookReceivingPhase,
}

extension BookExchangeStatusExtension on BookExchangeStatus {
  String get displayName {
    switch (this) {
      case BookExchangeStatus.BookDeliveryPhase:
        return 'Faza isporuke knjige';
      case BookExchangeStatus.BookReceivingPhase:
        return 'Faza primanja knjige';
    }
  }
}
