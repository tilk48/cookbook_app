/// Utility functions for working with dates in the Mealie API
class DateUtils {
  static const String isoDateFormat = 'yyyy-MM-dd';
  static const String isoDateTimeFormat = 'yyyy-MM-ddTHH:mm:ss';

  /// Format DateTime to ISO date string (YYYY-MM-DD)
  static String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Format DateTime to ISO datetime string
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)}T'
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// Parse ISO date string to DateTime
  static DateTime parseDate(String dateString) {
    return DateTime.parse(dateString);
  }

  /// Parse ISO datetime string to DateTime
  static DateTime parseDateTime(String dateTimeString) {
    return DateTime.parse(dateTimeString);
  }

  /// Get start of day for a DateTime
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day for a DateTime
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get days between two dates
  static int daysBetween(DateTime date1, DateTime date2) {
    final start = startOfDay(date1);
    final end = startOfDay(date2);
    return end.difference(start).inDays;
  }
}