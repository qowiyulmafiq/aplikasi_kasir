import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database/app_database.dart';
import 'database_provider.dart';
import 'package:drift/drift.dart';

part 'cart_provider.g.dart';

// Model lokal khusus untuk menampung item di keranjang
class CartItem {
  final BarangData barang;
  final int kuantitas;

  CartItem({required this.barang, this.kuantitas = 1});

  // Kalkulasi subtotal per item
  int get subtotal => barang.harga * kuantitas;

  // Fungsi pembantu untuk memanipulasi data yang immutable
  CartItem copyWith({int? kuantitas}) {
    return CartItem(
      barang: barang,
      kuantitas: kuantitas ?? this.kuantitas,
    );
  }
}

@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  @override
  List<CartItem> build() {
    return []; // Keranjang selalu kosong saat pertama kali dibuka
  }

  // Mendapatkan grand total dari seluruh isi keranjang
  int get grandTotal {
    return state.fold(0, (total, item) => total + item.subtotal);
  }

  // Menambahkan barang ke keranjang
  void addItem(BarangData barang) {
    // Cek apakah barang sudah ada di keranjang
    final existingIndex =
        state.indexWhere((item) => item.barang.id == barang.id);

    if (existingIndex >= 0) {
      // Jika sudah ada, tambahkan kuantitasnya +1
      final newState = [...state];
      final existingItem = newState[existingIndex];
      newState[existingIndex] =
          existingItem.copyWith(kuantitas: existingItem.kuantitas + 1);
      state = newState;
    } else {
      // Jika belum ada, masukkan sebagai item baru
      state = [...state, CartItem(barang: barang)];
    }
  }

  // Mengurangi kuantitas barang
  void decreaseItem(BarangData barang) {
    final existingIndex =
        state.indexWhere((item) => item.barang.id == barang.id);
    if (existingIndex >= 0) {
      final existingItem = state[existingIndex];
      if (existingItem.kuantitas > 1) {
        // Kurangi kuantitas jika lebih dari 1
        final newState = [...state];
        newState[existingIndex] =
            existingItem.copyWith(kuantitas: existingItem.kuantitas - 1);
        state = newState;
      } else {
        // Hapus item jika kuantitas mencapai 0
        removeItem(barang);
      }
    }
  }

  // Menghapus barang sepenuhnya dari keranjang
  void removeItem(BarangData barang) {
    state = state.where((item) => item.barang.id != barang.id).toList();
  }

  // Membersihkan keranjang (misal saat batal transaksi)
  void clearCart() {
    state = [];
  }

  // Eksekusi penyimpanan ke database saat checkout
  Future<void> checkout() async {
    if (state.isEmpty) return;

    final db = ref.read(appDatabaseProvider);

    // Mapping format CartItem lokal kita menjadi format Drift DetailTransaksi
    final rincian = state.map((item) {
      return DetailTransaksiCompanion(
        idBarang: Value(item.barang.id),
        kuantitas: Value(item.kuantitas),
        hargaSatuan: Value(item.barang.harga), // Bekukan harga saat ini
        subtotal: Value(item.subtotal),
      );
    }).toList();

    // Panggil fungsi transaction yang sudah kita buat di AppDatabase
    await db.simpanTransaksi(grandTotal, rincian);

    // Kosongkan keranjang setelah transaksi berhasil disimpan
    clearCart();
  }
}
