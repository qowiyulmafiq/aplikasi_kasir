import 'package:flutter/material.dart';
import '../data/database/app_database.dart';
import 'product_image_widget.dart';
import '../utils/currency_formatter.dart';

class InventoryItemCard extends StatelessWidget {
  final BarangData barang;
  final VoidCallback onTap;

  const InventoryItemCard({
    super.key,
    required this.barang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Area Gambar
            Expanded(
              flex: 3,
              child: ProductImageWidget(
                imagePath: barang.gambarPath,
                namaBarang: barang.nama,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Area Teks Detail
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nama Barang
                    Text(
                      barang.nama,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Kategori
                    Text(
                      barang.kategori,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Harga (Ditebalkan dan diberi warna utama aplikasi)
                    Text(
                      CurrencyFormatter.formatRupiah(barang.harga),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
