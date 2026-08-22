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

  // Fungsi untuk menambah banyak barang sekaligus dari Excel
  Future<void> batchAddBarang(List<BarangCompanion> listBarang) async {
    final db = ref.read(appDatabaseProvider);
    await db.batchInsertBarang(listBarang);
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

enum ProductSortOption {
  namaAsc('Nama (A - Z)'),
  namaDesc('Nama (Z - A)'),
  hargaAsc('Harga (Termurah)'),
  hargaDesc('Harga (Termahal)'),
  stokAsc('Stok (Paling Sedikit)'),
  stokDesc('Stok (Paling Banyak)');

  final String label;
  const ProductSortOption(this.label);
}

// --- STATE KASIR (POS) ---
final posSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final posSelectedCategoryProvider = StateProvider.autoDispose<String>((ref) => 'Semua');
final posSortOptionProvider = StateProvider.autoDispose<ProductSortOption>((ref) => ProductSortOption.namaAsc);

final filteredPosCatalogProvider = Provider.autoDispose<AsyncValue<List<BarangData>>>((ref) {
  final inventoryState = ref.watch(inventoryProvider);
  final searchQuery = ref.watch(posSearchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(posSelectedCategoryProvider);
  final sortOption = ref.watch(posSortOptionProvider);

  return inventoryState.whenData((daftarBarang) {
    final filtered = daftarBarang.where((barang) {
      final matchKategori =
          selectedCategory == 'Semua' || barang.kategori == selectedCategory;
      final matchPencarian = barang.nama.toLowerCase().contains(searchQuery);
      return matchKategori && matchPencarian;
    }).toList();

    _sortBarang(filtered, sortOption);
    return filtered;
  });
});

// --- STATE INVENTARIS ---
final inventorySearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final inventorySelectedCategoryProvider = StateProvider.autoDispose<String>((ref) => 'Semua');
final inventorySortOptionProvider = StateProvider.autoDispose<ProductSortOption>((ref) => ProductSortOption.namaAsc);

final filteredInventoryProvider = Provider.autoDispose<AsyncValue<List<BarangData>>>((ref) {
  final inventoryState = ref.watch(inventoryProvider);
  final searchQuery = ref.watch(inventorySearchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(inventorySelectedCategoryProvider);
  final sortOption = ref.watch(inventorySortOptionProvider);

  return inventoryState.whenData((daftarBarang) {
    final filtered = daftarBarang.where((barang) {
      final matchKategori =
          selectedCategory == 'Semua' || barang.kategori == selectedCategory;
      final matchPencarian = barang.nama.toLowerCase().contains(searchQuery);
      return matchKategori && matchPencarian;
    }).toList();

    _sortBarang(filtered, sortOption);
    return filtered;
  });
});

void _sortBarang(List<BarangData> list, ProductSortOption option) {
  switch (option) {
    case ProductSortOption.namaAsc:
      list.sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
      break;
    case ProductSortOption.namaDesc:
      list.sort((a, b) => b.nama.toLowerCase().compareTo(a.nama.toLowerCase()));
      break;
    case ProductSortOption.hargaAsc:
      list.sort((a, b) => a.harga.compareTo(b.harga));
      break;
    case ProductSortOption.hargaDesc:
      list.sort((a, b) => b.harga.compareTo(a.harga));
      break;
    case ProductSortOption.stokAsc:
      list.sort((a, b) => a.stok.compareTo(b.stok));
      break;
    case ProductSortOption.stokDesc:
      list.sort((a, b) => b.stok.compareTo(a.stok));
      break;
  }
}
