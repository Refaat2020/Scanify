import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _dayFormat = DateFormat('MMM d, yyyy');
  static final _fullFormat = DateFormat('MMM d, yyyy · h:mm a');
  static final _timeFormat = DateFormat('h:mm a');

  static String toDay(DateTime date) => _dayFormat.format(date);
  static String toFull(DateTime date) => _fullFormat.format(date);
  static String toTime(DateTime date) => _timeFormat.format(date);

  /// Returns a human-friendly relative string: "Just now", "2h ago", etc.
  static String toRelative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return toDay(date);
  }
}
