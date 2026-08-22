import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/app_database.dart';
import '../providers/operational_settings_provider.dart';
import 'product_image_widget.dart';
import '../utils/currency_formatter.dart';

class InventoryItemCard extends ConsumerWidget {
  final BarangData barang;
  final VoidCallback onTap;
  final bool isGridMode;
  final bool showImage;

  const InventoryItemCard({
    super.key,
    required this.barang,
    required this.onTap,
    this.isGridMode = true,
    this.showImage = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isGridMode) {
      return Card(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                if (showImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: ProductImageWidget(
                        imagePath: barang.gambarPath,
                        namaBarang: barang.nama,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (showImage) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barang.nama,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        barang.kategori,
                        style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildStockBadge(context, ref, barang),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.formatRupiah(barang.harga),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showImage)
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ProductImageWidget(
                      imagePath: barang.gambarPath,
                      namaBarang: barang.nama,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _buildStockBadge(context, ref, barang),
                    ),
                  ],
                ),
              ),
            Expanded(
              flex: showImage ? 2 : 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      barang.nama,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            barang.kategori,
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!showImage)
                          _buildStockBadge(context, ref, barang),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      CurrencyFormatter.formatRupiah(barang.harga),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
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

  Widget _buildStockBadge(BuildContext context, WidgetRef ref, BarangData barang) {
    final opSettings = ref.watch(operationalSettingsNotifierProvider);
    if (!opSettings.enableStockManagement) {
      return const SizedBox.shrink();
    }

    Color color = Colors.green.shade700;
    String text = 'Stok: ${barang.stok}';
    if (barang.stok <= 0) {
      color = Colors.red.shade700;
      text = 'Stok: 0';
    } else if (barang.stok <= barang.stokMinimal) {
      color = Colors.orange.shade800;
      text = 'Stok: ${barang.stok}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
