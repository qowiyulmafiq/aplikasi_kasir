import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/inventory_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/currency_formatter.dart';
import 'widgets/cart_bottom_sheet.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CartBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryState = ref.watch(filteredPosCatalogProvider);
    final searchQuery = ref.watch(posSearchQueryProvider);
    final selectedCategory = ref.watch(posSelectedCategoryProvider);

    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final totalItemsInCart = cart.fold(0, (sum, item) => sum + item.kuantitas);

    final List<String> kategoriOptions = [
      'Semua',
      'Umum',
      'Sembako',
      'Makanan',
      'Minuman',
      'Lainnya'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kasir',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showCartBottomSheet(context),
            icon: Badge(
              label: Text('$totalItemsInCart'),
              isLabelVisible: totalItemsInCart > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // AREA SEARCH BAR
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              hintText: 'Cari produk kasir...',
              leading: const Icon(Icons.search, color: Colors.grey),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(Colors.grey.shade100),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16.0)),
              onChanged: (value) {
                ref.read(posSearchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // AREA FILTER KATEGORI
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: kategoriOptions.length,
              itemBuilder: (context, index) {
                final kategori = kategoriOptions[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(kategori),
                    selected: selectedCategory == kategori,
                    onSelected: (bool selected) {
                      if (selected) {
                        ref.read(posSelectedCategoryProvider.notifier).state =
                            kategori;
                      }
                    },
                    selectedColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: selectedCategory == kategori
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                      fontWeight: selectedCategory == kategori
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // AREA GRID PRODUK KATALOG
          Expanded(
            child: inventoryState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Terjadi kesalahan: $error')),
              data: (daftarBarang) {
                if (daftarBarang.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          searchQuery.isNotEmpty || selectedCategory != 'Semua'
                              ? Icons.search_off
                              : Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty || selectedCategory != 'Semua'
                              ? 'Produk tidak ditemukan.'
                              : 'Belum ada produk di katalog.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: daftarBarang.length,
                  itemBuilder: (context, index) {
                    final barang = daftarBarang[index];
                    final cartItemIndex =
                        cart.indexWhere((item) => item.barang.id == barang.id);
                    final quantityInCart =
                        cartItemIndex >= 0 ? cart[cartItemIndex].kuantitas : 0;

                    return Card(
                      elevation: 1,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: quantityInCart > 0
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade200,
                          width: quantityInCart > 0 ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          cartNotifier.addItem(barang);
                        },
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.grey.shade100,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          barang.nama,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          barang.kategori,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              CurrencyFormatter.formatRupiah(
                                                  barang.harga),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 13,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                            Icon(
                                              Icons.add_shopping_cart,
                                              size: 18,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (quantityInCart > 0)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$quantityInCart',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // PERSISTENT BOTTOM CART BAR (Jika keranjang berisi item)
          if (cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$totalItemsInCart Item di Keranjang',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatRupiah(
                                cartNotifier.grandTotal),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showCartBottomSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text(
                        'Lihat Keranjang',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
