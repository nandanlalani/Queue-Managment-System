import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  static String formatDateTime(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  static String todayFormatted() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}
