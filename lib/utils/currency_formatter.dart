import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatterWithSymbol =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _formatterNoSymbol =
      NumberFormat.decimalPattern('id_ID');

  /// Format angka menjadi format Rupiah Indonesia dengan titik pemisah ribuan.
  /// Contoh: 46500 -> "Rp 46.500", 16000 -> "Rp 16.000"
  static String formatRupiah(num number, {bool withSymbol = true}) {
    return withSymbol
        ? _formatterWithSymbol.format(number).trim()
        : _formatterNoSymbol.format(number);
  }
}

