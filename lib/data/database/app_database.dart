import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Menghubungkan ke file hasil generate
part 'app_database.g.dart';

class Barang extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nama => text().withLength(min: 1, max: 255)();
  TextColumn get kategori => text()();
  IntColumn get harga => integer()();
  TextColumn get gambarPath => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Transaksi extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get totalHarga => integer()();
  DateTimeColumn get tanggalTransaksi =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

class DetailTransaksi extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get idTransaksi => integer().references(Transaksi, #id)();
  IntColumn get idBarang => integer().references(Barang, #id)();
  IntColumn get kuantitas => integer()();
  IntColumn get hargaSatuan => integer()();
  IntColumn get subtotal => integer()();
}

@DriftDatabase(tables: [Barang, Transaksi, DetailTransaksi])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Listen Perubahan Barang
  Stream<List<BarangData>> watchAllBarang() {
    return select(barang).watch();
  }

  // Menambah barang baru
  Future<int> insertBarang(BarangCompanion barangCompanion) {
    return into(barang).insert(barangCompanion);
  }

  // Menambah banyak barang sekaligus (Batch Insert secara atomis)
  Future<void> batchInsertBarang(List<BarangCompanion> items) async {
    await batch((b) {
      b.insertAll(barang, items);
    });
  }

  // Mengubah data barang
  Future<bool> updateBarang(BarangData barangData) {
    return update(barang).replace(barangData);
  }

  // Menghapus barang
  Future<int> deleteBarang(BarangData barangData) {
    return delete(barang).delete(barangData);
  }

  // Mendengarkan riwayat transaksi
  Stream<List<TransaksiData>> watchAllTransaksi() {
    return select(transaksi).watch();
  }

  // Menyimpan struk transaksi lengkap (Header + Detail)
  Future<void> simpanTransaksi(
      int totalHarga, List<DetailTransaksiCompanion> rincianKeranjang) async {
    await transaction(() async {
      // 1. Simpan header ke tabel Transaksi dan ambil ID barunya
      final idTransaksiBaru = await into(transaksi).insert(
        TransaksiCompanion.insert(totalHarga: totalHarga),
      );

      // 2. Simpan setiap item di keranjang ke DetailTransaksi
      // dengan menautkan idTransaksiBaru
      for (var item in rincianKeranjang) {
        await into(detailTransaksi).insert(
          item.copyWith(idTransaksi: Value(idTransaksiBaru)),
        );
      }
    });
  }

  // Mengambil detail transaksi beserta nama barang
  Future<List<DetailTransaksiWithBarang>> getDetailTransaksi(int idTransaksi) async {
    final query = select(detailTransaksi).join([
      innerJoin(barang, barang.id.equalsExp(detailTransaksi.idBarang)),
    ])..where(detailTransaksi.idTransaksi.equals(idTransaksi));

    final result = await query.get();

    return result.map((row) {
      return DetailTransaksiWithBarang(
        row.readTable(detailTransaksi),
        row.readTable(barang),
      );
    }).toList();
  }

  // Menghapus transaksi beserta detailnya
  Future<void> deleteTransaksi(int idTransaksi) async {
    await transaction(() async {
      await (delete(detailTransaksi)..where((t) => t.idTransaksi.equals(idTransaksi))).go();
      await (delete(transaksi)..where((t) => t.id.equals(idTransaksi))).go();
    });
  }
}

class DetailTransaksiWithBarang {
  final DetailTransaksiData detail;
  final BarangData barang;

  DetailTransaksiWithBarang(this.detail, this.barang);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Mendapatkan lokasi folder penyimpanan lokal di perangkat
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pos_offline.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
