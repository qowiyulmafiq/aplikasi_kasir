import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/dialog_helper.dart';
import '../../providers/history_provider.dart';
import '../../providers/database_provider.dart';
import '../../data/database/app_database.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final revenue = ref.watch(filteredRevenueProvider);
    final count = ref.watch(filteredTransactionCountProvider);
    final dateFilter = ref.watch(historyDateFilterProvider);

    String omzetLabel = 'Total Omzet';
    switch (dateFilter) {
      case DateFilter.today:
        omzetLabel = 'Total Omzet (Hari Ini)';
        break;
      case DateFilter.last7Days:
        omzetLabel = 'Total Omzet (7 Hari)';
        break;
      case DateFilter.thisMonth:
        omzetLabel = 'Total Omzet (Bulan Ini)';
        break;
      case DateFilter.all:
        omzetLabel = 'Total Omzet (Semua)';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSummaryHeader(context, revenue, count, omzetLabel),
          _buildFilterSection(context, ref),
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada transaksi',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final trx = transactions[index];
                      return _buildTransactionCard(context, ref, trx);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, int revenue, int count, String omzetLabel) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context,
              omzetLabel,
              CurrencyFormatter.formatRupiah(revenue),
              Icons.monetization_on,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Total Transaksi',
              count.toString(),
              Icons.receipt_long,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(historyDateFilterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari ID Transaksi...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                ref.read(historySearchQueryProvider.notifier).setQuery(value);
              },
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<DateFilter>(
                value: currentFilter,
                icon: const Icon(Icons.filter_list),
                onChanged: (DateFilter? newValue) {
                  if (newValue != null) {
                    ref.read(historyDateFilterProvider.notifier).setFilter(newValue);
                  }
                },
                items: const [
                  DropdownMenuItem(value: DateFilter.today, child: Text('Hari Ini')),
                  DropdownMenuItem(value: DateFilter.last7Days, child: Text('7 Hari Terakhir')),
                  DropdownMenuItem(value: DateFilter.thisMonth, child: Text('Bulan Ini')),
                  DropdownMenuItem(value: DateFilter.all, child: Text('Semua')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, WidgetRef ref, TransaksiData trx) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(Icons.receipt, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          '#TRX-${trx.id.toString().padLeft(4, '0')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(dateFormat.format(trx.tanggalTransaksi)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatRupiah(trx.totalHarga),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text(
                  'Selesai',
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                _konfirmasiHapus(context, ref, trx);
              },
              tooltip: 'Hapus Transaksi',
            ),
          ],
        ),
        onTap: () {
          _showTransactionDetail(context, ref, trx);
        },
      ),
    );
  }

  void _konfirmasiHapus(BuildContext context, WidgetRef ref, TransaksiData trx) {
    final trxId = '#TRX-${trx.id.toString().padLeft(4, '0')}';
    DialogHelper.showDeleteConfirm(
      context: context,
      title: 'Hapus Riwayat Transaksi',
      itemName: trxId,
      onConfirm: () async {
        final db = ref.read(appDatabaseProvider);
        await db.deleteTransaksi(trx.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transaksi $trxId berhasil dihapus!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _showTransactionDetail(BuildContext context, WidgetRef ref, TransaksiData trx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            final db = ref.read(appDatabaseProvider);
            return FutureBuilder<List<DetailTransaksiWithBarang>>(
              future: db.getDetailTransaksi(trx.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Gagal memuat detail transaksi'));
                }

                final details = snapshot.data ?? [];
                
                return _buildDetailSheet(context, ref, trx, details, scrollController);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSheet(BuildContext context, WidgetRef ref, TransaksiData trx, List<DetailTransaksiWithBarang> details, ScrollController scrollController) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Center(
            child: Text(
              'Detail Transaksi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ID Transaksi: #TRX-${trx.id.toString().padLeft(4, '0')}'),
              Text(dateFormat.format(trx.tanggalTransaksi)),
            ],
          ),
          const Divider(height: 30, thickness: 1),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: details.length,
              itemBuilder: (context, index) {
                final item = details[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.barang.nama,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.detail.kuantitas} x ${CurrencyFormatter.formatRupiah(item.detail.hargaSatuan)}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          CurrencyFormatter.formatRupiah(item.detail.subtotal),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 30, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                CurrencyFormatter.formatRupiah(trx.totalHarga),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _konfirmasiHapus(context, ref, trx);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Simulasi Cetak Struk Berhasil')),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Cetak Struk'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
