import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/inventory_provider.dart';
import '../../widgets/inventory_item_card.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryState = ref.watch(filteredInventoryProvider);

    // Membaca status pencarian dan kategori saat ini khusus Inventaris
    final searchQuery = ref.watch(inventorySearchQueryProvider);
    final selectedCategory = ref.watch(inventorySelectedCategoryProvider);

    // Daftar kategori untuk Filter Chips
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
          'Inventaris',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/inventory/add');
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // AREA SEARCH BAR (Sticky)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              hintText: 'Cari nama barang...',
              leading: const Icon(Icons.search, color: Colors.grey),
              elevation: const WidgetStatePropertyAll(0), // Flat design
              backgroundColor: WidgetStatePropertyAll(Colors.grey.shade100),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16.0)),
              onChanged: (value) {
                // Update state pencarian setiap kali pengguna mengetik
                ref.read(inventorySearchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // AREA FILTER KATEGORI (Scroll Horizontal)
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
                        // Ubah state kategori jika chip ditekan
                        ref
                            .read(inventorySelectedCategoryProvider.notifier)
                            .state = kategori;
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

          // AREA GRID VIEW
          Expanded(
            child: inventoryState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Terjadi kesalahan: $error')),
              data: (daftarBarang) {
                // Tampilan jika data kosong (atau tidak ditemukan saat mencari)
                if (daftarBarang.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            searchQuery.isNotEmpty ||
                                    selectedCategory != 'Semua'
                                ? Icons.search_off
                                : Icons.inventory_2_outlined,
                            size: 80,
                            color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty || selectedCategory != 'Semua'
                              ? 'Barang tidak ditemukan.'
                              : 'Belum ada barang di inventaris.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                // Tampilan jika data tersedia
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: daftarBarang.length,
                  itemBuilder: (context, index) {
                    final barang = daftarBarang[index];
                    return InventoryItemCard(
                      barang: barang,
                      onTap: () {
                        context.push('/inventory/edit', extra: barang);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
