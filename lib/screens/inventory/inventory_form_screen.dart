import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:drift/drift.dart' hide Column; // Needed for Value()
import '../../providers/inventory_provider.dart';
import '../../data/database/app_database.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/image_picker_helper.dart';
import '../../widgets/product_image_widget.dart';

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
  final _stokController = TextEditingController(text: '0');
  final _stokMinimalController = TextEditingController(text: '5');

  String _selectedKategori = 'Umum';
  final List<String> _kategoriOptions = [
    'Umum',
    'Sembako',
    'Makanan',
    'Minuman',
    'Lainnya'
  ];

  String? _gambarPath;

  bool get isEditMode => widget.barangToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _namaController.text = widget.barangToEdit!.nama;
      _hargaController.text = widget.barangToEdit!.harga.toString();
      _stokController.text = widget.barangToEdit!.stok.toString();
      _stokMinimalController.text = widget.barangToEdit!.stokMinimal.toString();
      _gambarPath = widget.barangToEdit!.gambarPath;

      if (_kategoriOptions.contains(widget.barangToEdit!.kategori)) {
        _selectedKategori = widget.barangToEdit!.kategori;
      }
    }
  }

  Future<void> _pickImage() async {
    final newPath = await ImagePickerHelper.pickAndSaveImage();
    if (newPath != null) {
      setState(() {
        _gambarPath = newPath;
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _stokMinimalController.dispose();
    super.dispose();
  }

  void _simpanData() {
    if (_formKey.currentState!.validate()) {
      final inputHarga =
          int.parse(_hargaController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      final inputStok = int.tryParse(_stokController.text) ?? 0;
      final inputStokMin = int.tryParse(_stokMinimalController.text) ?? 5;

      if (isEditMode) {
        // Mode Edit
        final barangDiupdate = widget.barangToEdit!.copyWith(
          nama: _namaController.text,
          harga: inputHarga,
          stok: inputStok,
          stokMinimal: inputStokMin,
          kategori: _selectedKategori,
          gambarPath: Value(_gambarPath),
        );
        ref.read(inventoryProvider.notifier).updateBarang(barangDiupdate);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Barang diperbarui!'),
              backgroundColor: Colors.blue),
        );
      } else {
        // Mode Tambah
        final barangBaru = BarangCompanion.insert(
          nama: _namaController.text,
          kategori: _selectedKategori,
          harga: inputHarga,
          stok: Value(inputStok),
          stokMinimal: Value(inputStokMin),
          gambarPath: Value(_gambarPath),
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
            Center(
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400, width: 1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _gambarPath != null
                          ? ProductImageWidget(
                              imagePath: _gambarPath,
                              namaBarang: _namaController.text.isNotEmpty ? _namaController.text : '?',
                              fit: BoxFit.cover,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade600),
                                const SizedBox(height: 8),
                                Text('Tambah Foto', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                              ],
                            ),
                    ),
                  ),
                  if (_gambarPath != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _gambarPath = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                  labelText: 'Nama Barang', hintText: 'Masukkan nama produk'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Nama tidak boleh kosong'
                  : null,
              onChanged: (val) {
                if (_gambarPath == null) setState(() {});
              },
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stokController,
                    decoration: const InputDecoration(
                      labelText: 'Stok Saat Ini',
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stokMinimalController,
                    decoration: const InputDecoration(
                      labelText: 'Stok Minimal (Alert)',
                      hintText: '5',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
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
