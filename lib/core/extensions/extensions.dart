import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is empty or whitespace
  bool get isEmptyOrWhitespace => trim().isEmpty;

  /// Capitalize first letter
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Get initials from name
  String get initials {
    return split(' ')
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
  }

  /// Truncate string to max length with ellipsis
  String truncate(int maxLength) {
    return length > maxLength ? '${substring(0, maxLength)}...' : this;
  }

  /// Convert to title case
  String get toTitleCase {
    return split(' ')
        .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Remove special characters
  String get removeSpecialCharacters {
    return replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }

  /// Check if string contains only alphabets
  bool get isAlphabetOnly => RegExp(r'^[a-zA-Z\s]*$').hasMatch(this);
}

extension DateTimeExtensions on DateTime {
  /// Format date as relative time (e.g., "2 hours ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return DateFormat('MMM d, y').format(this);
    }
  }

  /// Format date as short date (e.g., "Jan 15")
  String get shortDate => DateFormat('MMM d').format(this);

  /// Format date as full date (e.g., "January 15, 2024")
  String get fullDate => DateFormat('MMMM d, y').format(this);

  /// Format time (e.g., "2:30 PM")
  String get formattedTime => DateFormat('h:mm a').format(this);

  /// Format date and time (e.g., "Jan 15, 2:30 PM")
  String get dateTime => DateFormat('MMM d, h:mm a').format(this);

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is overdue
  bool get isOverdue => isBefore(DateTime.now());

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Format for display on tasks/due dates
  String get taskDueDate {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    if (isYesterday) return 'Yesterday';
    return DateFormat('MMM d').format(this);
  }
}

extension IntExtensions on int {
  /// Convert bytes to human readable format
  String get byteSize {
    if (this < 1024) return '$this B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(2)} KB';
    if (this < 1024 * 1024 * 1024) return '${(this / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Add leading zeros
  String padZero() => toString().padLeft(2, '0');
}

extension DurationExtensions on Duration {
  /// Format duration as HH:MM:SS
  String get formatted {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Get duration in readable format (e.g., "2h 30m")
  String get readableFormat {
    if (inDays > 0) return '${inDays}d ${inHours.remainder(24)}h';
    if (inHours > 0) return '${inHours}h ${inMinutes.remainder(60)}m';
    if (inMinutes > 0) return '${inMinutes}m';
    return '${inSeconds}s';
  }
}

extension BuildContextExtensions on BuildContext {
  /// Get media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get device height
  double get height => screenSize.height;

  /// Get device width
  double get width => screenSize.width;

  /// Check if device is mobile
  bool get isMobile => width < 600;

  /// Check if device is tablet
  bool get isTablet => width >= 600 && width < 1200;

  /// Check if device is desktop
  bool get isDesktop => width >= 1200;

  /// Check if landscape
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Check if portrait
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Device padding
  EdgeInsets get devicePadding => mediaQuery.padding;

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Check if dark mode
  bool get isDarkMode => mediaQuery.platformBrightness == Brightness.dark;
}

extension IterableExtensions<T> on Iterable<T> {
  /// Check if iterable contains no elements matching predicate
  bool none(bool Function(T) test) => !any(test);

  /// Group by key
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunc) {
    final groups = <K, List<T>>{};
    for (final item in this) {
      final key = keyFunc(item);
      groups.putIfAbsent(key, () => []).add(item);
    }
    return groups;
  }

  /// Zip with another iterable
  Iterable<(T, U)> zip<U>(Iterable<U> other) sync* {
    final iterator = other.iterator;
    for (final item in this) {
      if (!iterator.moveNext()) return;
      yield (item, iterator.current);
    }
  }
}

extension MapExtensions<K, V> on Map<K, V> {
  /// Get value or default
  V? getOrNull(K key) => this[key];

  /// Map values
  Map<K, U> mapValues<U>(U Function(V) transform) {
    return map((k, v) => MapEntry(k, transform(v)));
  }

  /// Filter entries
  Map<K, V> filter(bool Function(K, V) predicate) {
    return Map.fromEntries(
      entries.where((e) => predicate(e.key, e.value)),
    );
  }
}
