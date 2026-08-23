import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/inventory_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/system_settings_provider.dart';
import '../../providers/operational_settings_provider.dart';
import '../../data/database/app_database.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/product_image_widget.dart';
import 'widgets/cart_bottom_sheet.dart';

import '../../providers/category_provider.dart';
import '../../widgets/category_quick_picker_sheet.dart';

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

  void _handleAddItem(BuildContext context, BarangData barang,
      int quantityInCart, OperationalSettings opSettings, Cart cartNotifier) {
    if (opSettings.enableStockManagement &&
        !opSettings.allowZeroStockSales &&
        (quantityInCart + 1) > barang.stok) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok "${barang.nama}" tidak mencukupi! (Sisa: ${barang.stok})'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    cartNotifier.addItem(barang);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryState = ref.watch(filteredPosCatalogProvider);
    final searchQuery = ref.watch(posSearchQueryProvider);
    final selectedCategory = ref.watch(posSelectedCategoryProvider);
    final selectedSort = ref.watch(posSortOptionProvider);

    final systemSettings = ref.watch(systemSettingsNotifierProvider);
    final opSettings = ref.watch(operationalSettingsNotifierProvider);

    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final totalItemsInCart = cart.fold(0, (sum, item) => sum + item.kuantitas);

    final kategoriOptions = ref.watch(categoryNamesProvider);


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
          // AREA SEARCH BAR & FILTER BUTTON
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    hintText: 'Cari produk kasir...',
                    leading: Icon(Icons.search,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStatePropertyAll(Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest),
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onChanged: (value) {
                      ref.read(posSearchQueryProvider.notifier).state = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () {
                    CategoryQuickPickerSheet.show(
                      context: context,
                      selectedCategory: selectedCategory,
                      onCategorySelected: (cat) {
                        ref.read(posSelectedCategoryProvider.notifier).state =
                            cat;
                      },
                      selectedSort: selectedSort,
                      onSortSelected: (sort) {
                        ref.read(posSortOptionProvider.notifier).state = sort;
                      },
                    );
                  },
                  icon: const Icon(Icons.tune_outlined),
                  tooltip: 'Filter & Urutkan',
                ),
              ],
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
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: selectedCategory == kategori
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
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
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty || selectedCategory != 'Semua'
                              ? 'Produk tidak ditemukan.'
                              : 'Belum ada produk di katalog.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }

                if (systemSettings.posLayoutMode == 'list') {
                  return ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: daftarBarang.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final barang = daftarBarang[index];
                      final cartItemIndex = cart.indexWhere((item) => item.barang.id == barang.id);
                      final quantityInCart = cartItemIndex >= 0 ? cart[cartItemIndex].kuantitas : 0;

                      return Card(
                        elevation: 1,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: quantityInCart > 0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            width: quantityInCart > 0 ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            _handleAddItem(context, barang, quantityInCart,
                                opSettings, cartNotifier);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                if (systemSettings.showItemImage)
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
                                if (systemSettings.showItemImage)
                                  const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                      const SizedBox(height: 4),
                                      Text(
                                        barang.kategori,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.formatRupiah(barang.harga),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (quantityInCart > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
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
                                      )
                                    else
                                      Icon(
                                        Icons.add_shopping_cart,
                                        size: 18,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                // Default Grid Mode
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: systemSettings.showItemImage ? 0.8 : 1.4,
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
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          width: quantityInCart > 0 ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          _handleAddItem(context, barang, quantityInCart,
                              opSettings, cartNotifier);
                        },
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (systemSettings.showItemImage)
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
                                Expanded(
                                  flex: systemSettings.showItemImage ? 2 : 5,
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
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                            Icon(
                                              Icons.add_shopping_cart,
                                              size: 18,
                                              color: Theme.of(context).colorScheme.primary,
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
                                    color: Theme.of(context).colorScheme.primary,
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
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
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
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatRupiah(
                                cartNotifier.getGrandTotal(opSettings)),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showCartBottomSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
