import 'package:intl/intl.dart';

/// Formats timestamps for display across the app.
class DateFormatter {
  /// Full readable timestamp for the Result screen, e.g. "18 Jun 2026, 3:42 PM".
  static String full(DateTime dateTime) {
    return DateFormat('d MMM yyyy, h:mm a').format(dateTime);
  }

  /// Relative timestamp for History list rows, e.g. "2h ago", "Just now",
  /// "3d ago". Falls back to a short date for anything older than 7 days.
  static String relative(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return DateFormat('d MMM yyyy').format(dateTime);
  }
}
