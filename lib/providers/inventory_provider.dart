import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database/app_database.dart';
import 'database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'inventory_provider.g.dart';

@riverpod
class Inventory extends _$Inventory {
  @override
  Stream<List<BarangData>> build() {
    // Membaca stream dari database.
    // Setiap ada perubahan (tambah/edit/hapus), UI akan otomatis update.
    final db = ref.watch(appDatabaseProvider);
    return db.watchAllBarang();
  }

  // Fungsi untuk menambah barang
  Future<void> addBarang(BarangCompanion barang) async {
    final db = ref.read(appDatabaseProvider);
    await db.insertBarang(barang);
  }

  // Fungsi untuk mengedit barang
  Future<void> updateBarang(BarangData barang) async {
    final db = ref.read(appDatabaseProvider);
    await db.updateBarang(barang);
  }

  // Fungsi untuk menghapus barang
  Future<void> deleteBarang(BarangData barang) async {
    final db = ref.read(appDatabaseProvider);
    await db.deleteBarang(barang);
  }
}

// --- STATE KASIR (POS) ---
final posSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final posSelectedCategoryProvider = StateProvider.autoDispose<String>((ref) => 'Semua');

final filteredPosCatalogProvider = Provider.autoDispose<AsyncValue<List<BarangData>>>((ref) {
  final inventoryState = ref.watch(inventoryProvider);
  final searchQuery = ref.watch(posSearchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(posSelectedCategoryProvider);

  return inventoryState.whenData((daftarBarang) {
    return daftarBarang.where((barang) {
      final matchKategori =
          selectedCategory == 'Semua' || barang.kategori == selectedCategory;
      final matchPencarian = barang.nama.toLowerCase().contains(searchQuery);
      return matchKategori && matchPencarian;
    }).toList();
  });
});

// --- STATE INVENTARIS ---
final inventorySearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final inventorySelectedCategoryProvider = StateProvider.autoDispose<String>((ref) => 'Semua');

final filteredInventoryProvider = Provider.autoDispose<AsyncValue<List<BarangData>>>((ref) {
  final inventoryState = ref.watch(inventoryProvider);
  final searchQuery = ref.watch(inventorySearchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(inventorySelectedCategoryProvider);

  return inventoryState.whenData((daftarBarang) {
    return daftarBarang.where((barang) {
      final matchKategori =
          selectedCategory == 'Semua' || barang.kategori == selectedCategory;
      final matchPencarian = barang.nama.toLowerCase().contains(searchQuery);
      return matchKategori && matchPencarian;
    }).toList();
  });
});
