import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../providers/inventory_provider.dart';
import '../data/database/app_database.dart';
import 'custom_text_field.dart';

class CategoryQuickPickerSheet extends ConsumerStatefulWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final ProductSortOption selectedSort;
  final ValueChanged<ProductSortOption> onSortSelected;
  final bool initialManageMode;

  const CategoryQuickPickerSheet({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.selectedSort,
    required this.onSortSelected,
    this.initialManageMode = false,
  });

  static void show({
    required BuildContext context,
    required String selectedCategory,
    required ValueChanged<String> onCategorySelected,
    required ProductSortOption selectedSort,
    required ValueChanged<ProductSortOption> onSortSelected,
    bool initialManageMode = false,
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
        initialManageMode: initialManageMode,
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
  final TextEditingController _addController = TextEditingController();

  String _searchQuery = '';
  late ProductSortOption _activeSort;
  late bool _isManageMode;

  @override
  void initState() {
    super.initState();
    _activeSort = widget.selectedSort;
    _isManageMode = widget.initialManageMode;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _addController.dispose();
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

  Future<void> _handleTambahKategori() async {
    final text = _addController.text.trim();
    if (text.isEmpty) return;

    await ref.read(categoryListProvider.notifier).addKategori(text);
    _addController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kategori "$text" berhasil ditambahkan!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleEditKategori(KategoriData kategori) {
    final editController = TextEditingController(text: kategori.nama);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Kategori'),
        content: CustomTextField(
          label: 'Nama Kategori',
          controller: editController,
          autofocus: true,
          hintText: 'Masukkan nama kategori',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = editController.text.trim();
              if (newName.isNotEmpty && newName != kategori.nama) {
                await ref
                    .read(categoryListProvider.notifier)
                    .updateKategori(kategori.copyWith(nama: newName));
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _handleHapusKategori(KategoriData kategori) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text(
          'Apakah Anda yakin ingin menghapus kategori "${kategori.nama}"?\n\n'
          'Barang yang memiliki kategori ini akan dialihkan ke kategori "Umum".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref
                  .read(categoryListProvider.notifier)
                  .deleteKategori(kategori);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
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
          // Drag Indicator
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

          // Header Row with Mode Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isManageMode ? 'Kelola Kategori' : 'Filter & Urutkan Produk',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isManageMode
                          ? Icons.filter_alt_outlined
                          : Icons.edit_note_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: _isManageMode ? 'Mode Filter' : 'Mode Kelola',
                    onPressed: () {
                      setState(() {
                        _isManageMode = !_isManageMode;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // MODE 1: KELOLA KATEGORI (MANAGE MODE)
          if (_isManageMode) ...[
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _addController,
                    hintText: 'Tambah kategori baru...',
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _handleTambahKategori,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: categoriesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('Gagal memuat kategori: $err')),
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Center(child: Text('Belum ada kategori.'));
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      final isDefault = item.nama == 'Umum';

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          child: Text(
                            item.nama.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        title: Text(
                          item.nama,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDefault ? Colors.grey.shade600 : null,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => _handleEditKategori(item),
                              tooltip: 'Edit Kategori',
                            ),
                            if (!isDefault)
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 20, color: Colors.red),
                                onPressed: () => _handleHapusKategori(item),
                                tooltip: 'Hapus Kategori',
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ]

          // MODE 2: PILIH & URUTKAN (FILTER & SORT MODE)
          else ...[
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
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
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

            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: categoriesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('Gagal memuat kategori: $err')),
                data: (categoriesList) {
                  final allCategoryNames = [
                    'Semua',
                    ...categoriesList.map((c) => c.nama)
                  ];

                  final filteredNames = allCategoryNames
                      .where(
                          (nama) => nama.toLowerCase().contains(_searchQuery))
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
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
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
        ],
      ),
    );
  }
}
