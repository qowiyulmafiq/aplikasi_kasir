class CurrencyFormatter {
  /// Format angka menjadi format Rupiah Indonesia dengan titik pemisah ribuan.
  /// Contoh: 46500 -> "Rp 46.500", 16000 -> "Rp 16.000"
  static String formatRupiah(num number, {bool withSymbol = true}) {
    final formatted = number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return withSymbol ? 'Rp $formatted' : formatted;
  }
}
