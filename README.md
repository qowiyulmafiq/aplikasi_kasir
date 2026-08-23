# Aplikasi Kasir (POS) Mobile

Aplikasi Point of Sale (POS) mobile berbasis Flutter dengan pendekatan *offline-first*.

## Fitur Utama

- **Point of Sale (POS)**: Transaksi penjualan cepat, filter kategori, dan kalkulasi otomatis.
- **Manajemen Inventaris**: Pengelolaan produk, stok, kategori, serta opsi impor data via Excel.
- **Riwayat Transaksi**: Pencatatan riwayat transaksi dan pembatalan/refund.
- **Profil & Pengaturan**: Pengelolaan informasi toko dan preferensi sistem.

## Teknologi

- **Framework**: Flutter
- **State Management**: Flutter Riverpod
- **Database Lokal**: Drift (SQLite)
- **Navigasi**: GoRouter

## Cara Menjalankan

1. Install dependensi:
   ```bash
   flutter pub get
   ```

2. Generate kode (Drift & Riverpod):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. Jalankan aplikasi:
   ```bash
   flutter run
   ```
