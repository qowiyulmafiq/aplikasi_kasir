import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/cashier_breakpoints.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../providers/system_settings_provider.dart';
import '../../../utils/cart_helpers.dart';
import '../../../utils/currency_formatter.dart';
import '../../../widgets/app_choice_chip.dart';
import '../../../widgets/category_quick_picker_sheet.dart';
import '../../../widgets/product_image_widget.dart';

/// Catalog (search + chips + product grid) for Cashier Mode.
///
/// The header is a single row (search, filter, category chips) so it stays
/// under 25% of a 360dp-tall landscape screen. The grid uses fixed-extent
/// cards instead of `childAspectRatio`, so cards never become taller than
/// the viewport.
class CashierCatalogPane extends ConsumerWidget {
  final CashierLayout layout;

  const CashierCatalogPane({super.key, required this.layout});

  void _openFilterSheet(BuildContext context, WidgetRef ref) {
    CategoryQuickPickerSheet.show(
      context: context,
      selectedCategory: ref.read(posSelectedCategoryProvider),
      onCategorySelected: (cat) {
        ref.read(posSelectedCategoryProvider.notifier).state = cat;
      },
      selectedSort: ref.read(posSortOptionProvider),
      onSortSelected: (sort) {
        ref.read(posSortOptionProvider.notifier).state = sort;
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final inventoryState = ref.watch(filteredPosCatalogProvider);
    final searchQuery = ref.watch(posSearchQueryProvider);
    final selectedCategory = ref.watch(posSelectedCategoryProvider);
    final categories = ref.watch(categoryNamesProvider);
    final showItemImage =
        ref.watch(systemSettingsNotifierProvider).showItemImage;
    final cart = ref.watch(cartProvider);

    final isCompact = layout == CashierLayout.compactLandscape;
    final maxCardExtent =
        isCompact ? 160.0 : CashierBreakpoints.productCardMaxExtent;
    final cardHeight = isCompact ? 96.0 : 110.0;

    return Column(
      children: [
        Padding(
          key: const ValueKey('cashierCatalogHeader'),
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: SearchBar(
                  hintText: 'Cari produk...',
                  leading: Icon(Icons.search, color: scheme.onSurfaceVariant),
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor:
                      WidgetStatePropertyAll(scheme.surfaceContainerHighest),
                  padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 12)),
                  onChanged: (value) {
                    ref.read(posSearchQueryProvider.notifier).state = value;
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () => _openFilterSheet(context, ref),
                icon: const Icon(Icons.tune_outlined),
                tooltip: 'Filter & Urutkan',
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final kategori = categories[index];
                      return AppChoiceChip(
                        label: kategori,
                        selected: selectedCategory == kategori,
                        onSelected: (selected) {
                          if (selected) {
                            ref
                                .read(posSelectedCategoryProvider.notifier)
                                .state = kategori;
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: inventoryState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('Terjadi kesalahan: $error')),
            data: (daftarBarang) {
              if (daftarBarang.isEmpty) {
                return Center(
                  child: Text(
                    searchQuery.isNotEmpty || selectedCategory != 'Semua'
                        ? 'Produk tidak ditemukan.'
                        : 'Belum ada produk di katalog.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCardExtent,
                  mainAxisExtent: cardHeight,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: daftarBarang.length,
                itemBuilder: (context, index) {
                  final barang = daftarBarang[index];
                  final quantityInCart = cart
                      .where((item) => item.barang.id == barang.id)
                      .fold(0, (sum, item) => sum + item.kuantitas);

                  return _CashierProductCard(
                    barang: barang,
                    quantityInCart: quantityInCart,
                    showImage: showItemImage,
                    onTap: () => addBarangToCart(context, ref, barang),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CashierProductCard extends StatelessWidget {
  final BarangData barang;
  final int quantityInCart;
  final bool showImage;
  final VoidCallback onTap;

  const _CashierProductCard({
    required this.barang,
    required this.quantityInCart,
    required this.showImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = quantityInCart > 0;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? scheme.primary : scheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              if (showImage) ...[
                ProductImageWidget(
                  imagePath: barang.gambarPath,
                  namaBarang: barang.nama,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  borderRadius: 6,
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      barang.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      barang.kategori,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        CurrencyFormatter.formatRupiah(barang.harga),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (quantityInCart > 0) ...[
                const SizedBox(width: 4),
                _CartQtyBadge(quantity: quantityInCart),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CartQtyBadge extends StatelessWidget {
  final int quantity;

  const _CartQtyBadge({required this.quantity});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$quantity',
        style: TextStyle(
          color: scheme.onPrimary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
