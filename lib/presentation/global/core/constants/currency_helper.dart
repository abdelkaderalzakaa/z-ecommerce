import 'package:intl/intl.dart';

class AppCurrencyHelper {
  /// Standard USD to LBP conversion rate (1 USD = 89,500 LBP)
  static const double usdToLbpRate = 89500.0;

  /// Format amount in USD (e.g. $15.00)
  static String formatUSD(double amountInUSD) {
    return '\$${amountInUSD.toStringAsFixed(2)}';
  }

  /// Format amount in Lebanese Pounds (e.g. 1,342,500 ل.ل)
  static String formatLBP(double amountInUSD, {bool isArabic = true}) {
    final double lbpAmount = amountInUSD * usdToLbpRate;
    final formatter = NumberFormat('#,###');
    final formatted = formatter.format(lbpAmount.round());
    return isArabic ? '$formatted ل.ل' : '$formatted LBP';
  }

  /// Format in Dual Currency (e.g. $15.00 • 1,342,500 ل.ل)
  static String formatDual(double amountInUSD, {bool isArabic = true}) {
    final usd = formatUSD(amountInUSD);
    final lbp = formatLBP(amountInUSD, isArabic: isArabic);
    return '$usd ($lbp)';
  }

  /// Format single dynamic display based on user preference or symbol
  static String format(double amount, {String? currencySymbol, bool isArabic = true}) {
    if (currencySymbol == 'ل.ل' || currencySymbol == 'LBP') {
      return formatLBP(amount, isArabic: isArabic);
    }
    return formatDual(amount, isArabic: isArabic);
  }
}
