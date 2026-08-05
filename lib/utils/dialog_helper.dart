import 'package:flutter/material.dart';

class DialogHelper {
  // Fungsi statis untuk menampilkan dialog konfirmasi hapus
  static void showDeleteConfirm({
    required BuildContext context,
    required String itemName,
    required VoidCallback onConfirm,
    String title = 'Hapus Barang',
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text('Apakah Anda yakin ingin menghapus "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
