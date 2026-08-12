import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../providers/inventory_provider.dart';
import '../../providers/system_settings_provider.dart';
import '../../services/excel_import_service.dart';
import '../../widgets/inventory_item_card.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryState = ref.watch(filteredInventoryProvider);

    // Membaca status pencarian dan kategori saat ini khusus Inventaris
    final searchQuery = ref.watch(inventorySearchQueryProvider);
    final selectedCategory = ref.watch(inventorySelectedCategoryProvider);
    final systemSettings = ref.watch(systemSettingsNotifierProvider);

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
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 12,
        spaceBetweenChildren: 8,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.edit),
            label: 'Tambah Manual',
            onTap: () {
              context.push('/inventory/add');
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.file_upload_outlined),
            label: 'Import Excel',
            onTap: () => _handleImportExcel(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // AREA SEARCH BAR (Sticky)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              hintText: 'Cari nama barang...',
              leading: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
              elevation: const WidgetStatePropertyAll(0), // Flat design
              backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surfaceContainerHighest),
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
                            color: Theme.of(context).colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty || selectedCategory != 'Semua'
                              ? 'Barang tidak ditemukan.'
                              : 'Belum ada barang di inventaris.',
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
                      return InventoryItemCard(
                        barang: barang,
                        isGridMode: false,
                        showImage: systemSettings.showItemImage,
                        onTap: () {
                          context.push('/inventory/edit', extra: barang);
                        },
                      );
                    },
                  );
                }

                // Tampilan jika data tersedia (Grid)
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
                    return InventoryItemCard(
                      barang: barang,
                      isGridMode: true,
                      showImage: systemSettings.showItemImage,
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

  Future<void> _handleImportExcel(BuildContext context, WidgetRef ref) async {
    // Langsung buka Intent File Picker sistem tanpa membuka dialog Flutter terlebih dahulu
    // untuk mencegah konflik overlay Activity di Android (layar hitam).
    final result = await ExcelImportService.pickAndParseExcel();

    if (!context.mounted) return;

    if (result.error != null) {
      if (result.error != 'Pemilihan file dibatalkan.') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Dialog Konfirmasi sebelum Batch Insert
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.file_upload, color: Colors.green),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Konfirmasi Impor',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ditemukan ${result.sukses} barang valid dari file Excel.',
              style: const TextStyle(fontSize: 16),
            ),
            if (result.dilewati > 0) ...[
              const SizedBox(height: 6),
              Text(
                '${result.dilewati} baris dilewati (kosong / header / data tidak valid).',
                style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Apakah Anda yakin ingin menambahkan data ini ke inventaris?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Impor Sekarang'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await ref.read(inventoryProvider.notifier).batchAddBarang(result.items);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Berhasil mengimpor ${result.sukses} barang ke inventaris!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan data ke database: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
