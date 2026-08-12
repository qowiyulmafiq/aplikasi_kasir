import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/operational_settings_provider.dart';
import '../../widgets/section_header.dart';

class OperationalSettingsScreen extends ConsumerStatefulWidget {
  const OperationalSettingsScreen({super.key});

  @override
  ConsumerState<OperationalSettingsScreen> createState() =>
      _OperationalSettingsScreenState();
}

class _OperationalSettingsScreenState
    extends ConsumerState<OperationalSettingsScreen> {
  late TextEditingController _taxController;

  @override
  void initState() {
    super.initState();
    _taxController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(operationalSettingsNotifierProvider);
      _taxController.text = settings.taxPercentage.toString();
    });
  }

  @override
  void dispose() {
    _taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(operationalSettingsNotifierProvider);
    final notifier = ref.read(operationalSettingsNotifierProvider.notifier);

    // Sinkronkan text jika controller belum diisi / berbeda
    if (_taxController.text.isEmpty && settings.taxPercentage > 0) {
      _taxController.text = settings.taxPercentage.toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Operasional'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. PAJAK TRANSAKSI
          _buildSectionHeader('Pajak & Biaya Transaksi'),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      Icons.receipt_long_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text(
                      'Pajak Transaksi (PPN / PB1)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Aktifkan jika ingin menambahkan persentase pajak pada total belanja',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: settings.enableTax,
                    onChanged: (val) {
                      notifier.updateSettings(enableTax: val);
                    },
                  ),
                  if (settings.enableTax) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Persentase Pajak',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Contoh standar di Indonesia: 11%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 110,
                          child: TextField(
                            controller: _taxController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              suffixText: '%',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (val) {
                              final parsed = double.tryParse(val);
                              if (parsed != null && parsed >= 0) {
                                notifier.updateSettings(taxPercentage: parsed);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 2. MANAJEMEN STOK
          _buildSectionHeader('Manajemen Stok'),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  Icons.inventory_2_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Izinkan Penjualan Stok Kosong',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Memperbolehkan kasir memasukkan produk ke keranjang meskipun stoknya 0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                value: settings.allowZeroStockSales,
                onChanged: (val) {
                  notifier.updateSettings(allowZeroStockSales: val);
                },
              ),
            ),
          ),

          // 3. PENCETAKAN STRUK
          _buildSectionHeader('Pencetakan Struk'),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  Icons.print_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Cetak Struk Otomatis',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Otomatis mencetak struk setelah transaksi pembayaran berhasil diproses',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                value: settings.autoPrintReceipt,
                onChanged: (val) {
                  notifier.updateSettings(autoPrintReceipt: val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SectionHeader(title: title);
  }
}
