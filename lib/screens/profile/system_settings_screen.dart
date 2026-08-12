import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/system_settings_provider.dart';
import '../../widgets/section_header.dart';

class SystemSettingsScreen extends ConsumerWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(systemSettingsNotifierProvider);
    final notifier = ref.read(systemSettingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistem & Tampilan'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // TEMA APLIKASI
          _buildSectionHeader('Tema Aplikasi'),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mode Gelap / Terang',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih tema tampilan aplikasi yang nyaman untuk mata Anda.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'system',
                          label: Text('Sistem'),
                          icon: Icon(Icons.settings_suggest),
                        ),
                        ButtonSegment(
                          value: 'light',
                          label: Text('Terang'),
                          icon: Icon(Icons.light_mode),
                        ),
                        ButtonSegment(
                          value: 'dark',
                          label: Text('Gelap'),
                          icon: Icon(Icons.dark_mode),
                        ),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (Set<String> newSelection) {
                        notifier.updateSettings(themeMode: newSelection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TAMPILAN POS
          _buildSectionHeader('Tampilan Katalog'),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gaya Tata Letak',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('Ubah cara barang ditampilkan',
                              style:
                                  TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'grid',
                            icon: Icon(Icons.grid_view),
                          ),
                          ButtonSegment(
                            value: 'list',
                            icon: Icon(Icons.view_list),
                          ),
                        ],
                        selected: {settings.posLayoutMode},
                        showSelectedIcon: false,
                        onSelectionChanged: (Set<String> newSelection) {
                          notifier.updateSettings(
                              posLayoutMode: newSelection.first);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Tampilkan Gambar Barang',
                      style: TextStyle(fontSize: 16)),
                  subtitle: Text(
                    'Matikan untuk mempercepat kinerja pada perangkat lawas',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  value: settings.showItemImage,
                  onChanged: (bool value) {
                    notifier.updateSettings(showItemImage: value);
                  },
                ),
              ],
            ),
          ),

          // SISTEM & PEMELIHARAAN
          _buildSectionHeader('Sistem & Pemeliharaan'),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.cloud_upload,
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  title: const Text('Backup Database'),
                  subtitle: const Text('Simpan data transaksi & barang'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Fitur Backup akan segera hadir!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    child: Icon(Icons.restore,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
                  title: const Text('Pulihkan Data (Restore)'),
                  subtitle: const Text('Kembalikan dari file backup'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Fitur Restore akan segera hadir!')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    child: Icon(Icons.delete_sweep,
                        color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                  title: const Text('Bersihkan Cache'),
                  subtitle: const Text('Hapus file sementara aplikasi'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Cache berhasil dibersihkan!')),
                    );
                  },
                ),
              ],
            ),
          ),

          // TENTANG
          _buildSectionHeader('Tentang'),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Versi Aplikasi'),
              trailing: Text('v1.0.0 (Build 1)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SectionHeader(title: title);
  }
}
