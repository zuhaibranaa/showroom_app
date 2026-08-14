import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toFormattedString() {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  String toFormattedTimeString() {
    return DateFormat('HH:mm').format(this);
  }

  String toFullFormattedString() {
    return DateFormat('MMM dd, yyyy HH:mm').format(this);
  }
}

extension DoubleExtension on double {
  String toCurrencyString() {
    return '\$${toStringAsFixed(2)}';
  }

  String toPercentageString() {
    return '${(this * 100).toStringAsFixed(2)}%';
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }
}
