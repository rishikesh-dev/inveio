/// Utility for formatting currency amounts in Indian Rupee (₹) format.
class CurrencyFormatter {
  const CurrencyFormatter._();

  /// Formats [amount] as a compact currency string (e.g. ₹1,234).
  ///
  /// [showCents] includes decimal places when true.
  /// [includeSign] prepends a + or - sign based on [isExpense].
  /// [isExpense] determines the sign when [includeSign] is true.
  static String compact(
    double amount, {
    bool showCents = false,
    bool includeSign = false,
    bool isExpense = true,
  }) {
    final sign = includeSign ? (isExpense ? '-' : '+') : '';
    final decimals = showCents ? 2 : 0;
    final fixed = amount.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final whole = _withCommas(parts.first);
    final cents = showCents ? '.${parts.last}' : '';

    return '$sign₹$whole$cents';
  }

  /// Returns the whole-number portion of [amount] formatted with commas.
  static String splitWhole(double amount) {
    return compact(amount);
  }

  /// Returns the cents portion of [amount] as a string (e.g. ".50").
  static String splitCents(double amount) {
    return '.${amount.toStringAsFixed(2).split('.').last}';
  }

  /// Inserts commas into [value] every three digits from the right.
  static String _withCommas(String value) {
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final reverseIndex = value.length - i;
      buffer.write(value[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}
