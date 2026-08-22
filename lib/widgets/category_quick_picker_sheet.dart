import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../providers/inventory_provider.dart';

class CategoryQuickPickerSheet extends ConsumerStatefulWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final ProductSortOption selectedSort;
  final ValueChanged<ProductSortOption> onSortSelected;

  const CategoryQuickPickerSheet({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.selectedSort,
    required this.onSortSelected,
  });

  static void show({
    required BuildContext context,
    required String selectedCategory,
    required ValueChanged<String> onCategorySelected,
    required ProductSortOption selectedSort,
    required ValueChanged<ProductSortOption> onSortSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryQuickPickerSheet(
        selectedCategory: selectedCategory,
        onCategorySelected: onCategorySelected,
        selectedSort: selectedSort,
        onSortSelected: onSortSelected,
      ),
    );
  }

  @override
  ConsumerState<CategoryQuickPickerSheet> createState() =>
      _CategoryQuickPickerSheetState();
}

class _CategoryQuickPickerSheetState
    extends ConsumerState<CategoryQuickPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late ProductSortOption _activeSort;

  @override
  void initState() {
    super.initState();
    _activeSort = widget.selectedSort;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getSortIcon(ProductSortOption option) {
    switch (option) {
      case ProductSortOption.namaAsc:
      case ProductSortOption.namaDesc:
        return Icons.sort_by_alpha;
      case ProductSortOption.hargaAsc:
        return Icons.arrow_downward;
      case ProductSortOption.hargaDesc:
        return Icons.arrow_upward;
      case ProductSortOption.stokAsc:
      case ProductSortOption.stokDesc:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.tune_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Filter & Urutkan Produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SECTION 1: URUTKAN BERDASARKAN
          Row(
            children: [
              Icon(Icons.sort_rounded,
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              const Text(
                'Urutkan Berdasarkan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ProductSortOption.values.map((option) {
              final isSelected = _activeSort == option;
              return FilterChip(
                avatar: Icon(
                  _getSortIcon(option),
                  size: 16,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                label: Text(option.label),
                selected: isSelected,
                showCheckmark: false,
                onSelected: (_) {
                  setState(() {
                    _activeSort = option;
                  });
                  widget.onSortSelected(option);
                  Navigator.pop(context);
                },
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                selectedColor: theme.colorScheme.primaryContainer,
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  width: isSelected ? 1.5 : 1,
                ),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // SECTION 2: PILIH KATEGORI
          Row(
            children: [
              Icon(Icons.category_outlined,
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              const Text(
                'Pilih Kategori',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Search Bar untuk Kategori (Tampil jika kategori > 6)
          categoriesAsync.maybeWhen(
            data: (list) {
              if (list.length > 6) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Cari nama kategori...',
                    leading: Icon(Icons.search,
                        color: theme.colorScheme.onSurfaceVariant),
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStatePropertyAll(
                        theme.colorScheme.surfaceContainerHighest),
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 14.0)),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase().trim();
                      });
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),

          // Chips Grid Kategori
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35,
            ),
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Gagal memuat kategori: $err')),
              data: (categoriesList) {
                final allCategoryNames = [
                  'Semua',
                  ...categoriesList.map((c) => c.nama)
                ];

                final filteredNames = allCategoryNames
                    .where((nama) => nama.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredNames.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('Kategori tidak ditemukan.')),
                  );
                }

                return SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filteredNames.map((kategoriNama) {
                      final isSelected =
                          widget.selectedCategory == kategoriNama;
                      return FilterChip(
                        avatar: Icon(
                          kategoriNama == 'Semua'
                              ? Icons.apps
                              : Icons.label_outline,
                          size: 16,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        label: Text(kategoriNama),
                        selected: isSelected,
                        showCheckmark: false,
                        onSelected: (_) {
                          widget.onCategorySelected(kategoriNama);
                          Navigator.pop(context);
                        },
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        selectedColor: theme.colorScheme.primaryContainer,
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                          width: isSelected ? 1.5 : 1,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
