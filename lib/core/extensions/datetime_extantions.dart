// core/extensions/datetime_extensions.dart
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  bool isSameDay(DateTime other) {
    return this.year == other.year && this.month == other.month && this.day == other.day;
  }

  bool isToday() {
    final now = DateTime.now();
    return this.isSameDay(now);
  }

  bool isTomorrow() {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return this.isSameDay(tomorrow);
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return this.isSameDay(yesterday);
  }

  bool isInSameWeek(DateTime other) {
    final thisMonday = this.subtract(Duration(days: this.weekday - 1));
    final otherMonday = other.subtract(Duration(days: other.weekday - 1));
    return thisMonday.isSameDay(otherMonday);
  }

  bool isInSameMonth(DateTime other) {
    return this.year == other.year && this.month == other.month;
  }

  String formatDate() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  String formatTime() {
    return DateFormat('HH:mm').format(this);
  }

  String formatDateTime() {
    return DateFormat('dd MMM yyyy, HH:mm').format(this);
  }

  String formatRelative() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day ago';
    } else {
      return DateFormat('dd MMM yyyy').format(this);
    }
  }

  DateTime getStartOfDay() {
    return DateTime(this.year, this.month, this.day);
  }

  DateTime getEndOfDay() {
    return DateTime(this.year, this.month, this.day, 23, 59, 59);
  }

  DateTime getStartOfMonth() {
    return DateTime(this.year, this.month, 1);
  }

  DateTime getEndOfMonth() {
    return DateTime(this.year, this.month + 1, 0, 23, 59, 59);
  }

  int getDaysInMonth() {
    return DateTime(this.year, this.month + 1, 0).day;
  }
}