import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/store_settings_provider.dart';

class StoreSettingsScreen extends ConsumerStatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  ConsumerState<StoreSettingsScreen> createState() =>
      _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends ConsumerState<StoreSettingsScreen> {
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _teleponController;
  late TextEditingController _footerController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan nilai sementara, nanti diupdate di build pertama
    _namaController = TextEditingController();
    _alamatController = TextEditingController();
    _teleponController = TextEditingController();
    _footerController = TextEditingController();

    // Memberikan delay sedikit agar provider selesai inisialisasi dari shared_prefs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(storeSettingsNotifierProvider);
      _namaController.text = settings.namaToko;
      _alamatController.text = settings.alamat;
      _teleponController.text = settings.telepon;
      _footerController.text = settings.pesanFooter;
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _updateSettings() {
    ref.read(storeSettingsNotifierProvider.notifier).updateSettings(
          namaToko: _namaController.text,
          alamat: _alamatController.text,
          telepon: _teleponController.text,
          pesanFooter: _footerController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(storeSettingsNotifierProvider);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko & Struk'),
        elevation: 0,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KIRI: Form Pengaturan
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Toko',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Nama Toko', _namaController, Icons.store),
                  const SizedBox(height: 12),
                  _buildTextField(
                      'Alamat', _alamatController, Icons.location_on),
                  const SizedBox(height: 12),
                  _buildTextField(
                      'No. Telepon / WA', _teleponController, Icons.phone),

                  const Divider(height: 48),

                  const Text(
                    'Pengaturan Struk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Pesan Footer Struk', _footerController,
                      Icons.text_snippet),
                  const SizedBox(height: 16),

                  // Dropdown Ukuran Kertas
                  Row(
                    children: [
                      const Icon(Icons.print, color: Colors.grey),
                      const SizedBox(width: 16),
                      const Text('Ukuran Kertas: ',
                          style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: settings.ukuranKertas,
                        items: const [
                          DropdownMenuItem(
                              value: '58mm', child: Text('58mm (Kecil)')),
                          DropdownMenuItem(
                              value: '80mm', child: Text('80mm (Besar)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref
                                .read(storeSettingsNotifierProvider.notifier)
                                .updateSettings(ukuranKertas: val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Switch Nama Kasir
                  SwitchListTile(
                    title: const Text('Tampilkan Nama Kasir'),
                    subtitle:
                        const Text('Mencetak nama kasir di bagian atas struk'),
                    value: settings.tampilkanNamaKasir,
                    onChanged: (val) {
                      ref
                          .read(storeSettingsNotifierProvider.notifier)
                          .updateSettings(tampilkanNamaKasir: val);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Pengaturan berhasil disimpan!'),
                              backgroundColor: Colors.green),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Pengaturan'),
                    ),
                  )
                ],
              ),
            ),
          ),

          // KANAN: Live Preview Struk
          if (isDesktop)
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey[100],
                child: Center(
                  child: _buildReceiptPreview(settings),
                ),
              ),
            ),
        ],
      ),
      // Jika Mobile, preview bisa pakai FloatingActionButton atau BottomSheet,
      // tapi untuk kesederhanaan kita tampilkan di paling bawah scroll jika tidak desktop
      bottomNavigationBar: !isDesktop
          ? Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      decoration: const BoxDecoration(
                        color:
                            Color(0xFFEEEEEE), // Warna abu-abu background struk
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          // Drag indicator bar
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Preview Struk',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: _buildReceiptPreview(settings),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text('Lihat Preview Struk'),
              ),
            )
          : null,
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
      onChanged: (val) => _updateSettings(),
    );
  }

  Widget _buildReceiptPreview(StoreSettings settings) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final now = DateTime.now();
    final double paperWidth = settings.ukuranKertas == '58mm' ? 250 : 350;

    return Container(
      width: paperWidth,
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LOGO PLACEHOLDER
            Icon(Icons.storefront, size: 48, color: Colors.grey[800]),
            const SizedBox(height: 8),

            // NAMA TOKO
            Text(
              settings.namaToko.isEmpty
                  ? 'NAMA TOKO'
                  : settings.namaToko.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),

            // ALAMAT
            Text(
              settings.alamat.isEmpty ? 'Alamat Toko' : settings.alamat,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),

            // TELEPON
            Text(
              settings.telepon.isEmpty ? '-' : settings.telepon,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 12),
            const Text('----------------------------------------',
                maxLines: 1, overflow: TextOverflow.clip),
            const SizedBox(height: 4),

            // INFO TRANSAKSI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateFormat.format(now),
                    style: const TextStyle(fontSize: 10)),
                Text('#TRX-0001', style: const TextStyle(fontSize: 10)),
              ],
            ),
            if (settings.tampilkanNamaKasir)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Kasir: Admin', style: TextStyle(fontSize: 10)),
              ),

            const SizedBox(height: 4),
            const Text('----------------------------------------',
                maxLines: 1, overflow: TextOverflow.clip),
            const SizedBox(height: 8),

            // ITEM DUMMY
            _buildReceiptItem('Kopi Susu Gula Aren', '2 x 15.000', '30.000'),
            _buildReceiptItem('Roti Bakar Coklat', '1 x 12.000', '12.000'),

            const SizedBox(height: 8),
            const Text('----------------------------------------',
                maxLines: 1, overflow: TextOverflow.clip),
            const SizedBox(height: 8),

            // TOTAL DUMMY
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Rp 42.000',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TUNAI', style: TextStyle(fontSize: 12)),
                Text('Rp 50.000', style: TextStyle(fontSize: 12)),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('KEMBALI', style: TextStyle(fontSize: 12)),
                Text('Rp 8.000', style: TextStyle(fontSize: 12)),
              ],
            ),

            const SizedBox(height: 16),

            // FOOTER
            Text(
              settings.pesanFooter.isEmpty
                  ? 'Terima Kasih'
                  : settings.pesanFooter,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptItem(String name, String qtyAndPrice, String total) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(qtyAndPrice, style: const TextStyle(fontSize: 11)),
              Text(total, style: const TextStyle(fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }
}
