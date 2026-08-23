import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database/app_database.dart';
import 'database_provider.dart';

part 'category_provider.g.dart';

@riverpod
class CategoryList extends _$CategoryList {
  @override
  Stream<List<KategoriData>> build() {
    final db = ref.watch(appDatabaseProvider);
    return db.watchAllKategori();
  }

  Future<void> addKategori(String nama) async {
    if (nama.trim().isEmpty) return;
    final db = ref.read(appDatabaseProvider);
    await db.insertKategori(KategoriCompanion.insert(nama: nama.trim()));
  }

  Future<void> updateKategori(KategoriData kategori) async {
    final db = ref.read(appDatabaseProvider);
    await db.updateKategori(kategori);
  }

  Future<void> deleteKategori(KategoriData kategori) async {
    final db = ref.read(appDatabaseProvider);
    await db.deleteKategori(kategori.id, kategori.nama);
  }
}

@riverpod
List<String> categoryNames(CategoryNamesRef ref) {
  return [
    'Semua',
    ...ref.watch(categoryListProvider).maybeWhen(
          data: (list) => list.map((k) => k.nama).toList(),
          orElse: () => ['Umum', 'Sembako', 'Makanan', 'Minuman', 'Lainnya'],
        ),
  ];
}

