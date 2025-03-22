var filename_currency_extension = 'lib/utils/helper/currency_extension.dart';
String file_currency_extension(projectName) => '''
import 'package:intl/intl.dart';

String formatRupiah(String amount) {
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return currencyFormatter.format(int.tryParse(amount) ?? 0);
}

extension CurrencyFormat on String {
  String toRupiah() {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return currencyFormatter.format(int.tryParse(this) ?? 0);
  }
}

extension CurrencyFormatInt on int {
  String toRupiah() {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return currencyFormatter.format(this);
  }
}
''';