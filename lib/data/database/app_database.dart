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
  IntColumn get stok => integer().withDefault(const Constant(0))();
  IntColumn get stokMinimal => integer().withDefault(const Constant(5))();
  BoolColumn get kelolaStok => boolean().withDefault(const Constant(true))();
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

class Kategori extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nama => text().withLength(min: 1, max: 100)();
}

@DriftDatabase(tables: [Barang, Transaksi, DetailTransaksi, Kategori])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(barang, barang.stok);
          await m.addColumn(barang, barang.stokMinimal);
          await m.addColumn(barang, barang.kelolaStok);
        }
        if (from < 3) {
          await m.createTable(kategori);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        // Initial seed default categories if empty
        final listKategori = await select(kategori).get();
        if (listKategori.isEmpty) {
          final defaultCategories = ['Umum', 'Sembako', 'Makanan', 'Minuman', 'Lainnya'];
          for (final cat in defaultCategories) {
            await into(kategori).insert(KategoriCompanion.insert(nama: cat));
          }
        }
      },
    );
  }

  // Listen Perubahan Kategori
  Stream<List<KategoriData>> watchAllKategori() {
    return select(kategori).watch();
  }

  Future<List<KategoriData>> getAllKategori() {
    return select(kategori).get();
  }

  Future<int> insertKategori(KategoriCompanion companion) {
    return into(kategori).insert(companion);
  }

  Future<bool> updateKategori(KategoriData data) {
    return update(kategori).replace(data);
  }

  Future<void> deleteKategori(int idKategori, String namaKategori) async {
    await transaction(() async {
      await (update(barang)..where((b) => b.kategori.equals(namaKategori)))
          .write(const BarangCompanion(kategori: Value('Umum')));
      await (delete(kategori)..where((k) => k.id.equals(idKategori))).go();
    });
  }

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

  // Menghapus barang (beserta detail transaksi terkait secara aman)
  Future<void> deleteBarang(BarangData barangData) async {
    await transaction(() async {
      await (delete(detailTransaksi)..where((d) => d.idBarang.equals(barangData.id))).go();
      await (delete(barang)..where((b) => b.id.equals(barangData.id))).go();
    });
  }

  // Google Sheets Sync Helpers
  Future<List<BarangData>> getUnsyncedBarang() {
    return (select(barang)..where((b) => b.isSynced.equals(false))).get();
  }

  Future<void> markBarangAsSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    await (update(barang)..where((b) => b.id.isIn(ids)))
        .write(const BarangCompanion(isSynced: Value(true)));
  }

  Future<void> upsertBarangFromSync(List<BarangCompanion> items) async {
    await transaction(() async {
      final existingCategories = (await select(kategori).get()).map((k) => k.nama.toLowerCase()).toSet();
      
      for (final companion in items) {
        final categoryName = companion.kategori.value;
        if (categoryName.isNotEmpty && !existingCategories.contains(categoryName.toLowerCase())) {
          await into(kategori).insert(KategoriCompanion.insert(nama: categoryName));
          existingCategories.add(categoryName.toLowerCase());
        }

        BarangData? existing;
        if (companion.id.present && companion.id.value > 0) {
          existing = await (select(barang)..where((b) => b.id.equals(companion.id.value))).getSingleOrNull();
        }
        existing ??= await (select(barang)..where((b) => b.nama.equals(companion.nama.value))).getSingleOrNull();

        final targetItem = existing;
        if (targetItem != null) {
          await (update(barang)..where((b) => b.id.equals(targetItem.id))).write(
            companion.copyWith(
              id: Value(targetItem.id),
              isSynced: const Value(true),
              updatedAt: Value(DateTime.now()),
            ),
          );
        } else {
          await into(barang).insert(
            companion.copyWith(
              isSynced: const Value(true),
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
    });
  }

  // Mendengarkan riwayat transaksi
  Stream<List<TransaksiData>> watchAllTransaksi() {
    return select(transaksi).watch();
  }

  // Menyimpan struk transaksi lengkap (Header + Detail) dan kurangi stok otomatis
  Future<void> simpanTransaksi(
      int totalHarga, List<DetailTransaksiCompanion> rincianKeranjang) async {
    await transaction(() async {
      // 1. Simpan header ke tabel Transaksi dan ambil ID barunya
      final idTransaksiBaru = await into(transaksi).insert(
        TransaksiCompanion.insert(totalHarga: totalHarga),
      );

      // 2. Simpan setiap item di keranjang ke DetailTransaksi
      for (var item in rincianKeranjang) {
        await into(detailTransaksi).insert(
          item.copyWith(idTransaksi: Value(idTransaksiBaru)),
        );

        // 3. Potong stok barang secara otomatis
        final idBarangTarget = item.idBarang.value;
        final kuantitasBeli = item.kuantitas.value;

        final targetBarang = await (select(barang)..where((b) => b.id.equals(idBarangTarget))).getSingleOrNull();
        if (targetBarang != null) {
          final sisaStokBaru = targetBarang.stok - kuantitasBeli;
          await (update(barang)..where((b) => b.id.equals(idBarangTarget)))
              .write(BarangCompanion(stok: Value(sisaStokBaru)));
        }
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

  // Menghapus transaksi beserta detailnya dan mengembalikan stok barang
  Future<void> deleteTransaksi(int idTransaksi, {bool kembalikanStok = true}) async {
    await transaction(() async {
      if (kembalikanStok) {
        final rincian = await (select(detailTransaksi)..where((t) => t.idTransaksi.equals(idTransaksi))).get();
        for (var item in rincian) {
          final targetBarang = await (select(barang)..where((b) => b.id.equals(item.idBarang))).getSingleOrNull();
          if (targetBarang != null) {
            await (update(barang)..where((b) => b.id.equals(item.idBarang)))
                .write(BarangCompanion(stok: Value(targetBarang.stok + item.kuantitas)));
          }
        }
      }
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
