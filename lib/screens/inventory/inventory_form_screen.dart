import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/inventory_provider.dart';
import '../../data/database/app_database.dart';
import '../../utils/dialog_helper.dart';

class InventoryFormScreen extends ConsumerStatefulWidget {
  final BarangData? barangToEdit;

  const InventoryFormScreen({super.key, this.barangToEdit});

  @override
  ConsumerState<InventoryFormScreen> createState() =>
      _InventoryFormScreenState();
}

class _InventoryFormScreenState extends ConsumerState<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();

  String _selectedKategori = 'Umum';
  final List<String> _kategoriOptions = [
    'Umum',
    'Sembako',
    'Makanan',
    'Minuman',
    'Lainnya'
  ];

  bool get isEditMode => widget.barangToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _namaController.text = widget.barangToEdit!.nama;
      _hargaController.text = widget.barangToEdit!.harga.toString();

      if (_kategoriOptions.contains(widget.barangToEdit!.kategori)) {
        _selectedKategori = widget.barangToEdit!.kategori;
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  void _simpanData() {
    if (_formKey.currentState!.validate()) {
      final inputHarga =
          int.parse(_hargaController.text.replaceAll(RegExp(r'[^0-9]'), ''));

      if (isEditMode) {
        // Mode Edit: Tanpa memproses gambar
        final barangDiupdate = widget.barangToEdit!.copyWith(
          nama: _namaController.text,
          harga: inputHarga,
          kategori: _selectedKategori,
        );
        ref.read(inventoryProvider.notifier).updateBarang(barangDiupdate);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Barang diperbarui!'),
              backgroundColor: Colors.blue),
        );
      } else {
        // Mode Tambah: Gunakan BarangCompanion (tanpa 's')
        final barangBaru = BarangCompanion.insert(
          nama: _namaController.text,
          kategori: _selectedKategori,
          harga: inputHarga,
        );
        ref.read(inventoryProvider.notifier).addBarang(barangBaru);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Barang ditambahkan!'),
              backgroundColor: Colors.green),
        );
      }
      context.pop();
    }
  }

  void _konfirmasiHapus() {
    DialogHelper.showDeleteConfirm(
      context: context,
      itemName: widget.barangToEdit!.nama,
      onConfirm: () {
        ref.read(inventoryProvider.notifier).deleteBarang(widget.barangToEdit!);
        context.pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Barang dihapus!'), backgroundColor: Colors.red),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Barang' : 'Tambah Barang'),
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _konfirmasiHapus,
            )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                  labelText: 'Nama Barang', hintText: 'Masukkan nama produk'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Nama tidak boleh kosong'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hargaController,
              decoration: const InputDecoration(
                  labelText: 'Harga (Rp)', hintText: '0', prefixText: 'Rp '),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Harga tidak boleh kosong';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Harga tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedKategori,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: _kategoriOptions
                  .map((kategori) =>
                      DropdownMenuItem(value: kategori, child: Text(kategori)))
                  .toList(),
              onChanged: (newValue) =>
                  setState(() => _selectedKategori = newValue!),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _simpanData,
                child: Text(isEditMode ? 'Perbarui Barang' : 'Simpan Barang',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
