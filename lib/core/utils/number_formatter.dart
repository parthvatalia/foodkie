// core/utils/number_formatter.dart
import 'package:intl/intl.dart';

class NumberFormatter {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '\u{20B9}',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatNumber(int number) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(number);
  }

  static String formatPercentage(double percentage) {
    final formatter = NumberFormat.percentPattern();
    return formatter.format(percentage / 100);
  }

  static String formatCompact(int number) {
    final formatter = NumberFormat.compact();
    return formatter.format(number);
  }

  static String formatDecimal(double number, {int decimalDigits = 2}) {
    final formatter = NumberFormat.decimalPattern()
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return formatter.format(number);
  }

  // Format with custom currency symbol
  static String formatCurrencyWithSymbol(double amount, String symbol) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Format price without decimal if it's a whole number
  static String formatPrice(double price) {
    if (price == price.roundToDouble()) {
      // Price is a whole number, don't show decimals
      return NumberFormat.currency(
        symbol: '\$',
        decimalDigits: 0,
      ).format(price);
    } else {
      // Price has decimals, show them
      return NumberFormat.currency(
        symbol: '\$',
        decimalDigits: 2,
      ).format(price);
    }
  }
}