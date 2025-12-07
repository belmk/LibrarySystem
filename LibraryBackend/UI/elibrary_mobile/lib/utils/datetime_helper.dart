import 'package:intl/intl.dart';

class DateTimeHelper {
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "-";
    return DateFormat('dd-MM-yyyy HH:mm', 'en_US').format(dateTime);
  }

  static String formatDateOnly(DateTime? dateTime) {
    if (dateTime == null) return "-";
    return DateFormat('dd-MM-yyyy', 'en_US').format(dateTime);
  }
}
