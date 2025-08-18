import 'package:intl/intl.dart';

class DateTimeHelper {
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "-";
    return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
  }
}
