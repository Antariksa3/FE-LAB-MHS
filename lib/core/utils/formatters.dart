import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String currency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Mora ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
