import 'package:json_annotation/json_annotation.dart';

enum BookExchangeStatus {
  @JsonValue(0)
  PendingApproval,

  @JsonValue(1)
  BookDeliveryPhase,

  @JsonValue(2)
  BookReceivingPhase,

  @JsonValue(3)
  ExchangeCompleted,
}

extension BookExchangeStatusExtension on BookExchangeStatus {
  String get displayName {
    switch (this) {
      case BookExchangeStatus.PendingApproval:
        return 'Čeka odobrenje';
      case BookExchangeStatus.BookDeliveryPhase:
        return 'Faza isporuke knjige';
      case BookExchangeStatus.BookReceivingPhase:
        return 'Faza primanja knjige';
      case BookExchangeStatus.ExchangeCompleted:
        return 'Razmjena završena';

    }
  }
}
