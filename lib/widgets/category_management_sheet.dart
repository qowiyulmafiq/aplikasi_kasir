import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../data/database/app_database.dart';

class CategoryManagementSheet extends ConsumerStatefulWidget {
  const CategoryManagementSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CategoryManagementSheet(),
    );
  }

  @override
  ConsumerState<CategoryManagementSheet> createState() =>
      _CategoryManagementSheetState();
}

class _CategoryManagementSheetState
    extends ConsumerState<CategoryManagementSheet> {
  final TextEditingController _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _handleTambah() async {
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

  void _handleEdit(KategoriData kategori) {
    final editController = TextEditingController(text: kategori.nama);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Kategori'),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nama Kategori',
            hintText: 'Masukkan nama kategori',
          ),
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

  void _handleHapus(KategoriData kategori) {
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

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.category_outlined,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Kelola Kategori Barang',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // INPUT TAMBAH KATEGORI
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addController,
                  decoration: InputDecoration(
                    hintText: 'Tambah kategori baru...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => _handleTambah(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _handleTambah,
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
          // DAFTAR KATEGORI
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: categoriesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Gagal memuat kategori: $err')),
              data: (categories) {
                if (categories.isEmpty) {
                  return const Center(
                    child: Text('Belum ada kategori.'),
                  );
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
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        child: Text(
                          item.nama.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
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
                            onPressed: () => _handleEdit(item),
                            tooltip: 'Edit Kategori',
                          ),
                          if (!isDefault)
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 20, color: Colors.red),
                              onPressed: () => _handleHapus(item),
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
        ],
      ),
    );
  }
}
