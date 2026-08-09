import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/cart_provider.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/dialog_helper.dart';

class CartBottomSheet extends ConsumerStatefulWidget {
  const CartBottomSheet({super.key});

  @override
  ConsumerState<CartBottomSheet> createState() => _CartBottomSheetState();
}

enum MetodePembayaran { tunai, qris }

class _CartBottomSheetState extends ConsumerState<CartBottomSheet> {
  final TextEditingController _bayarController = TextEditingController();
  MetodePembayaran _metodePembayaran = MetodePembayaran.tunai;

  @override
  void dispose() {
    _bayarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final grandTotal = cartNotifier.grandTotal;

    // Menghitung uang yang dimasukkan (jika QRIS, otomatis uang pas = grandTotal)
    final int uangDibayar = _metodePembayaran == MetodePembayaran.qris 
        ? grandTotal 
        : (int.tryParse(_bayarController.text.replaceAll('.', '').replaceAll(',', '')) ?? 0);
    
    final int kembalian = uangDibayar - grandTotal;
    final bool isKurang = _metodePembayaran == MetodePembayaran.tunai && _bayarController.text.isNotEmpty && kembalian < 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            // Header Keranjang
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Keranjang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${cart.length} Item',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (cart.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      DialogHelper.showDeleteConfirm(
                        context: context,
                        title: 'Kosongkan Keranjang',
                        itemName: 'semua item di keranjang',
                        onConfirm: () {
                          _bayarController.clear();
                          cartNotifier.clearCart();
                        },
                      );
                    },
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: Colors.red),
                    label: const Text(
                      'Kosongkan',
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            // Daftar Item Keranjang
            if (cart.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  children: [
                    Icon(Icons.remove_shopping_cart_outlined,
                        size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'Keranjang masih kosong',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            else ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: cart.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.barang.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.formatRupiah(item.barang.harga),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Kontrol Kuantitas (- / +) Pill
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (item.kuantitas == 1) {
                                      DialogHelper.showDeleteConfirm(
                                        context: context,
                                        title: 'Hapus Item',
                                        itemName: item.barang.nama,
                                        onConfirm: () {
                                          cartNotifier.decreaseItem(item.barang);
                                        },
                                      );
                                    } else {
                                      cartNotifier.decreaseItem(item.barang);
                                    }
                                  },
                                  borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(7)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 4),
                                    child: Icon(Icons.remove,
                                        size: 16, color: Colors.red.shade400),
                                  ),
                                ),
                                Container(
                                  constraints:
                                      const BoxConstraints(minWidth: 20),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${item.kuantitas}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () =>
                                      cartNotifier.addItem(item.barang),
                                  borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(7)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 4),
                                    child: Icon(Icons.add,
                                        size: 16, color: Colors.green.shade600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Subtotal
                          SizedBox(
                            width: 70,
                            child: FittedBox(
                              alignment: Alignment.centerRight,
                              fit: BoxFit.scaleDown,
                              child: Text(
                                CurrencyFormatter.formatRupiah(item.subtotal),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 24),
              
              // PILIHAN METODE PEMBAYARAN
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<MetodePembayaran>(
                  segments: const [
                    ButtonSegment(
                      value: MetodePembayaran.tunai,
                      label: Text('Tunai (Cash)'),
                      icon: Icon(Icons.payments_outlined),
                    ),
                    ButtonSegment(
                      value: MetodePembayaran.qris,
                      label: Text('QRIS / Transfer'),
                      icon: Icon(Icons.qr_code_2),
                    ),
                  ],
                  selected: {_metodePembayaran},
                  onSelectionChanged: (Set<MetodePembayaran> newSelection) {
                    setState(() {
                      _metodePembayaran = newSelection.first;
                      // Bersihkan input tunai jika pindah ke QRIS
                      if (_metodePembayaran == MetodePembayaran.qris) {
                        _bayarController.clear();
                        FocusScope.of(context).unfocus(); // Tutup keyboard
                      }
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.grey.shade50,
                    selectedForegroundColor: Colors.white,
                    selectedBackgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Grand Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatRupiah(grandTotal),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // INPUT NOMINAL & KEMBALIAN (Hanya Tampil Jika Tunai)
              if (_metodePembayaran == MetodePembayaran.tunai) ...[
                TextField(
                  controller: _bayarController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Uang Dibayar Pelanggan',
                    hintText: '0',
                    prefixText: 'Rp ',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isKurang
                            ? Colors.red
                            : Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    suffixIcon: _bayarController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _bayarController.clear();
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    setState(() {}); // Refresh kalkulasi kembalian
                  },
                ),
                const SizedBox(height: 8),
                // PRESET CHIPS NOMINAL CEPAT
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        label: const Text('Uang Pas'),
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold),
                        onPressed: () {
                          setState(() {
                            _bayarController.text = grandTotal.toString();
                          });
                        },
                      ),
                      const SizedBox(width: 6),
                      ...[10000, 20000, 50000, 100000].map((nominal) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ActionChip(
                            label: Text(CurrencyFormatter.formatRupiah(nominal)),
                            onPressed: () {
                              setState(() {
                                _bayarController.text = nominal.toString();
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // KEMBALIAN ATAU PERINGATAN KURANG
                if (_bayarController.text.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isKurang ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            isKurang ? Colors.red.shade200 : Colors.green.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isKurang ? 'Uang Pembayaran Kurang' : 'Kembalian',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isKurang
                                ? Colors.red.shade800
                                : Colors.green.shade800,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatRupiah(kembalian.abs()),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isKurang
                                ? Colors.red.shade800
                                : Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],
              
              // TAMPILAN INSTRUKSI JIKA QRIS
              if (_metodePembayaran == MetodePembayaran.qris) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.qr_code_scanner, size: 40, color: Colors.blue.shade700),
                      const SizedBox(height: 8),
                      const Text(
                        'Arahkan pelanggan untuk men-scan QRIS pada meja kasir.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pastikan uang senilai ${CurrencyFormatter.formatRupiah(grandTotal)} masuk sebelum menekan tombol Selesai.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // TOMBOL SELESAIKAN TRANSAKSI
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isKurang
                      ? null
                      : () async {
                          if (_metodePembayaran == MetodePembayaran.tunai && 
                              uangDibayar < grandTotal &&
                              _bayarController.text.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nominal uang kurang!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Pastikan kasir mengisi nominal jika metode Tunai
                          if (_metodePembayaran == MetodePembayaran.tunai && _bayarController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Masukkan nominal uang yang dibayar!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          final nominalBayarAkhir =
                              uangDibayar == 0 ? grandTotal : uangDibayar;
                          final kembalianAkhir =
                              nominalBayarAkhir - grandTotal;

                          await cartNotifier.checkout();

                          if (context.mounted) {
                            Navigator.pop(context); // Tutup bottom sheet

                            // Dialog Struk Konfirmasi Berhasil
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green, size: 28),
                                    SizedBox(width: 8),
                                    Text('Transaksi Berhasil!'),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Detail Transaksi:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Metode:'),
                                        Text(
                                          _metodePembayaran == MetodePembayaran.qris 
                                              ? 'QRIS / Transfer' 
                                              : 'Tunai',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total:'),
                                        Text(CurrencyFormatter.formatRupiah(grandTotal),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    if (_metodePembayaran == MetodePembayaran.tunai) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Dibayar:'),
                                          Text(CurrencyFormatter.formatRupiah(nominalBayarAkhir)),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Kembalian:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          Text(
                                            CurrencyFormatter.formatRupiah(kembalianAkhir),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color:
                                                  Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Fitur cetak struk segera hadir!'),
                                          backgroundColor: Colors.blue,
                                        ),
                                      );
                                    },
                                    child: const Text('Cetak Struk'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Selesai'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.point_of_sale),
                  label: const Text(
                    'Selesaikan Transaksi',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
