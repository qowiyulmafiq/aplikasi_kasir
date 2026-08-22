import 'dart:io';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../data/database/app_database.dart';

/// Class penampung hasil ekstraksi Excel
class ExcelImportResult {
  final List<BarangCompanion> items;
  final int totalBaris;
  final int sukses;
  final int dilewati;
  final String? error;

  ExcelImportResult({
    required this.items,
    required this.totalBaris,
    required this.sukses,
    required this.dilewati,
    this.error,
  });

  bool get isSuccess => error == null && items.isNotEmpty;
}

class ExcelImportService {
  /// Membuka file picker dan mengurai file Excel yang dipilih
  static Future<ExcelImportResult> pickAndParseExcel() async {
    try {
      // 1. Buka File Picker secara aman untuk Android SAF
      final FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (pickerResult == null || pickerResult.files.isEmpty) {
        return ExcelImportResult(
          items: [],
          totalBaris: 0,
          sukses: 0,
          dilewati: 0,
          error: 'Pemilihan file dibatalkan.',
        );
      }

      final file = pickerResult.files.first;
      final fileName = file.name.toLowerCase();

      // Validasi ekstensi file secara manual agar tidak diblokir oleh MIME type provider Android
      if (!fileName.endsWith('.xlsx') && !fileName.endsWith('.xls')) {
        return ExcelImportResult(
          items: [],
          totalBaris: 0,
          sukses: 0,
          dilewati: 0,
          error: 'File yang dipilih bukan file Excel (.xlsx atau .xls).',
        );
      }

      List<int>? bytes = file.bytes;

      // Baca byte file secara aman dari path lokal Android/Desktop
      if ((bytes == null || bytes.isEmpty) && file.path != null) {
        final ioFile = File(file.path!);
        if (await ioFile.exists()) {
          bytes = await ioFile.readAsBytes();
        }
      }

      if (bytes == null || bytes.isEmpty) {
        return ExcelImportResult(
          items: [],
          totalBaris: 0,
          sukses: 0,
          dilewati: 0,
          error: 'Gagal membaca isi file Excel. Pastikan file tidak rusak.',
        );
      }

      // 2. Decode Excel
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        return ExcelImportResult(
          items: [],
          totalBaris: 0,
          sukses: 0,
          dilewati: 0,
          error: 'File Excel tidak memiliki lembar kerja (sheet).',
        );
      }

      // Ambil sheet pertama yang berisi data
      final String sheetName = excel.tables.keys.first;
      final Sheet? table = excel.tables[sheetName];

      if (table == null || table.maxRows <= 1) {
        return ExcelImportResult(
          items: [],
          totalBaris: 0,
          sukses: 0,
          dilewati: 0,
          error: 'Lembar kerja Excel kosong atau tidak memiliki data.',
        );
      }

      final List<BarangCompanion> parsedItems = [];
      int skippedCount = 0;

      // Cari indeks kolom berdasarkan nama header (baris pertama)
      int nameColIndex = 0;
      int categoryColIndex = 1;
      int priceColIndex = 2;
      int stockColIndex = -1;
      int minStockColIndex = -1;

      final headerRow = table.rows.first;
      for (int i = 0; i < headerRow.length; i++) {
        final cellValue = _getCellValueString(headerRow[i]).toLowerCase();
        if (cellValue.contains('nama') || cellValue.contains('barang') || cellValue.contains('item')) {
          nameColIndex = i;
        } else if (cellValue.contains('kategori') || cellValue.contains('category')) {
          categoryColIndex = i;
        } else if (cellValue.contains('harga') || cellValue.contains('price')) {
          priceColIndex = i;
        } else if (cellValue.contains('stok_min') || cellValue.contains('min_stok') || cellValue.contains('minimal')) {
          minStockColIndex = i;
        } else if (cellValue.contains('stok') || cellValue.contains('stock') || cellValue.contains('qty')) {
          stockColIndex = i;
        }
      }

      // 3. Iterasi setiap baris data (mulai dari baris ke-2 / indeks 1)
      for (int rowIndex = 1; rowIndex < table.maxRows; rowIndex++) {
        final row = table.rows[rowIndex];
        if (row.isEmpty) {
          skippedCount++;
          continue;
        }

        final namaStr = nameColIndex < row.length ? _getCellValueString(row[nameColIndex]).trim() : '';
        final kategoriStr = categoryColIndex < row.length ? _getCellValueString(row[categoryColIndex]).trim() : '';
        final hargaVal = priceColIndex < row.length ? _parsePrice(row[priceColIndex]) : 0;
        final stokVal = (stockColIndex >= 0 && stockColIndex < row.length) ? _parsePrice(row[stockColIndex]) : 0;
        final stokMinVal = (minStockColIndex >= 0 && minStockColIndex < row.length) ? _parsePrice(row[minStockColIndex]) : 5;

        // Validasi: Nama barang tidak boleh kosong & harga harus valid
        if (namaStr.isEmpty) {
          skippedCount++;
          continue;
        }

        final kategoriFix = kategoriStr.isEmpty ? 'Umum' : kategoriStr;

        parsedItems.add(
          BarangCompanion.insert(
            nama: namaStr,
            kategori: kategoriFix,
            harga: hargaVal,
            gambarPath: const Value.absent(),
            stok: Value(stokVal),
            stokMinimal: Value(stokMinVal),
            kelolaStok: const Value(true),
          ),
        );
      }

      return ExcelImportResult(
        items: parsedItems,
        totalBaris: table.maxRows - 1,
        sukses: parsedItems.length,
        dilewati: skippedCount,
      );
    } catch (e) {
      return ExcelImportResult(
        items: [],
        totalBaris: 0,
        sukses: 0,
        dilewati: 0,
        error: 'Terjadi kesalahan saat mengurai Excel: $e',
      );
    }
  }

  /// Helper untuk mengambil nilai sel sebagai String
  static String _getCellValueString(Data? cell) {
    if (cell == null || cell.value == null) return '';
    return cell.value.toString();
  }

  /// Helper mengonversi harga sel Excel ke integer (rupiah)
  static int _parsePrice(Data? cell) {
    if (cell == null || cell.value == null) return 0;
    final val = cell.value;
    if (val is IntCellValue) {
      return val.value;
    } else if (val is DoubleCellValue) {
      return val.value.toInt();
    } else {
      final str = _getCellValueString(cell).replaceAll(RegExp(r'[^\d]'), '');
      return int.tryParse(str) ?? 0;
    }
  }
}
