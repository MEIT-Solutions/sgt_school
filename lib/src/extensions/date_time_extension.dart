extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  String get toIso8601DateOnly {
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  /// Formats as "23 Jul 2026".
  String get toDisplayDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '$day ${months[month - 1]} $year';
  }

  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }
}

/// Extension on [String] for formatting date strings from the API.
///
/// Handles ISO date strings like "2026-07-10" or datetime strings like
/// "2026-07-10T16:36:17+06:30".
///
/// ```dart
/// "2026-07-10".toDisplayDate        // "10 Jul 2026"
/// "2026-07-10T16:36:17+06:30".toDisplayDate  // "10 Jul 2026"
/// ```
extension StringDateExtension on String {
  /// Parses the ISO date/datetime string and formats as "23 Jul 2026".
  /// Returns the original string if parsing fails.
  String get toDisplayDate {
    try {
      final dt = DateTime.parse(this);
      return dt.toDisplayDate;
    } catch (_) {
      return this;
    }
  }
}

