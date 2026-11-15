import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/operational_settings_provider.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/dialog_helper.dart';
import '../../../widgets/custom_text_field.dart';

class CartBottomSheet extends ConsumerStatefulWidget {
  const CartBottomSheet({super.key});

  /// Shared entry point for normal POS and Cashier Mode.
  ///
  /// The sheet is scroll-controlled and capped at ~90% of the screen. The
  /// widget itself re-checks the available height when the keyboard opens.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      builder: (context) => const CartBottomSheet(),
    );
  }

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
    final opSettings = ref.watch(operationalSettingsNotifierProvider);
    final scheme = Theme.of(context).colorScheme;

    final subtotal = cartNotifier.subtotal;
    final taxAmount = cartNotifier.getTaxAmount(opSettings);
    final grandTotal = cartNotifier.getGrandTotal(opSettings);

    // Menghitung uang yang dimasukkan (jika QRIS, otomatis uang pas = grandTotal)
    final int uangDibayar = _metodePembayaran == MetodePembayaran.qris
        ? grandTotal
        : (int.tryParse(_bayarController.text
                .replaceAll('.', '')
                .replaceAll(',', '')) ??
            0);

    final int kembalian = uangDibayar - grandTotal;
    final bool isKurang = _metodePembayaran == MetodePembayaran.tunai &&
        _bayarController.text.isNotEmpty &&
        kembalian < 0;

    final media = MediaQuery.of(context);
    final viewInsetsBottom = media.viewInsets.bottom;
    // The sheet itself is capped at 90% of the screen by `show()`. The
    // keyboard padding is applied *inside* that cap, so the usable content
    // height is the cap minus the inset (never the full screen minus inset).
    final sheetMaxHeight = media.size.height * 0.9;
    final maxHeight =
        (sheetMaxHeight - viewInsetsBottom).clamp(0.0, sheetMaxHeight);
    final isShortLandscape =
        media.size.width > media.size.height && media.size.height < 480;
    // With very little room left (keyboard open on a short phone) the sheet
    // switches to dense chrome so the pinned confirm button still fits.
    final isDense = maxHeight < 240;

    final confirmButton = _buildConfirmButton(
      context: context,
      opSettings: opSettings,
      cartNotifier: cartNotifier,
      grandTotal: grandTotal,
      subtotal: subtotal,
      taxAmount: taxAmount,
      uangDibayar: uangDibayar,
      isKurang: isKurang,
      dense: isDense,
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsetsBottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHeader(context, cart, cartNotifier, scheme, dense: isDense),
            const Divider(height: 1),
            Expanded(
              child: isShortLandscape
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        final paymentWidth =
                            (constraints.maxWidth * 0.42).clamp(300.0, 360.0);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _buildItemList(
                                context,
                                cart,
                                cartNotifier,
                              ),
                            ),
                            const VerticalDivider(width: 1),
                            SizedBox(
                              width: paymentWidth,
                              child: _buildFooter(
                                context: context,
                                opSettings: opSettings,
                                grandTotal: grandTotal,
                                subtotal: subtotal,
                                taxAmount: taxAmount,
                                kembalian: kembalian,
                                isKurang: isKurang,
                                confirmButton: confirmButton,
                                compact: true,
                                dense: isDense,
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          children: [
                            Expanded(
                              child: _buildItemList(
                                context,
                                cart,
                                cartNotifier,
                              ),
                            ),
                            const Divider(height: 1),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: constraints.maxHeight * 0.62,
                              ),
                              child: _buildFooter(
                                context: context,
                                opSettings: opSettings,
                                grandTotal: grandTotal,
                                subtotal: subtotal,
                                taxAmount: taxAmount,
                                kembalian: kembalian,
                                isKurang: isKurang,
                                confirmButton: confirmButton,
                                compact: false,
                                dense: isDense,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    List<CartItem> cart,
    Cart cartNotifier,
    ColorScheme scheme, {
    bool dense = false,
  }) {
    return Padding(
      padding: dense
          ? const EdgeInsets.fromLTRB(16, 4, 4, 4)
          : const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!dense) ...[
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                color: scheme.primary,
                size: dense ? 20 : 24,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Keranjang',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${cart.length} Item',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // In dense mode (keyboard open on a short screen) the clear
              // action collapses to its icon to save horizontal space.
              if (dense)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Kosongkan Keranjang',
                  onPressed: cart.isEmpty
                      ? null
                      : () => _confirmClearCart(context, cartNotifier),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: cart.isEmpty ? null : scheme.error,
                  ),
                )
              else
                TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: cart.isEmpty
                      ? null
                      : () => _confirmClearCart(context, cartNotifier),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: cart.isEmpty ? null : scheme.error,
                  ),
                  label: Text(
                    'Kosongkan',
                    style: TextStyle(
                      color: cart.isEmpty ? null : scheme.error,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmClearCart(BuildContext context, Cart cartNotifier) {
    DialogHelper.showDeleteConfirm(
      context: context,
      title: 'Kosongkan Keranjang',
      itemName: 'semua item di keranjang',
      onConfirm: () {
        _bayarController.clear();
        cartNotifier.clearCart();
      },
    );
  }

  Widget _buildItemList(
    BuildContext context,
    List<CartItem> cart,
    Cart cartNotifier,
  ) {
    if (cart.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.remove_shopping_cart_outlined,
                size: 60,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Keranjang masih kosong',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      key: const ValueKey('cartItemList'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: cart.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
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
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 20),
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
                      onTap: () {
                        cartNotifier.addItem(item.barang);
                      },
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(7)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
    );
  }

  Widget _buildFooter({
    required BuildContext context,
    required OperationalSettings opSettings,
    required int grandTotal,
    required int subtotal,
    required int taxAmount,
    required int kembalian,
    required bool isKurang,
    required Widget confirmButton,
    required bool compact,
    bool dense = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: dense
              ? const EdgeInsets.fromLTRB(16, 4, 16, 4)
              : const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: _buildPaymentDetails(
                    context: context,
                    opSettings: opSettings,
                    grandTotal: grandTotal,
                    subtotal: subtotal,
                    taxAmount: taxAmount,
                    kembalian: kembalian,
                    isKurang: isKurang,
                    compact: compact,
                  ),
                ),
              ),
              SizedBox(height: dense ? 4 : 6),
              confirmButton,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetails({
    required BuildContext context,
    required OperationalSettings opSettings,
    required int grandTotal,
    required int subtotal,
    required int taxAmount,
    required int kembalian,
    required bool isKurang,
    required bool compact,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // PILIHAN METODE PEMBAYARAN
        FittedBox(
          fit: BoxFit.scaleDown,
          child: SegmentedButton<MetodePembayaran>(
            segments: compact
                ? const [
                    ButtonSegment(
                      value: MetodePembayaran.tunai,
                      label: Text('Tunai'),
                    ),
                    ButtonSegment(
                      value: MetodePembayaran.qris,
                      label: Text('QRIS'),
                    ),
                  ]
                : const [
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
              visualDensity: compact ? VisualDensity.compact : null,
              backgroundColor: scheme.surfaceContainerHighest,
              selectedForegroundColor: scheme.onPrimary,
              selectedBackgroundColor: scheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (opSettings.enableTax) ...[
          _summaryRow(
            context,
            label: 'Subtotal',
            amount: subtotal,
          ),
          const SizedBox(height: 4),
          _summaryRow(
            context,
            label:
                'Pajak (${opSettings.taxPercentage.toStringAsFixed(opSettings.taxPercentage.truncateToDouble() == opSettings.taxPercentage ? 0 : 1)}%)',
            amount: taxAmount,
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
        ],
        // Grand Total
        _summaryRow(
          context,
          label: 'Total Pembayaran',
          amount: grandTotal,
          isTotal: true,
        ),
        const SizedBox(height: 16),

        // INPUT NOMINAL & KEMBALIAN (Hanya Tampil Jika Tunai)
        if (_metodePembayaran == MetodePembayaran.tunai) ...[
          CustomTextField(
            label: 'Uang Dibayar Pelanggan',
            controller: _bayarController,
            keyboardType: TextInputType.number,
            hintText: '0',
            prefixText: 'Rp ',
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
                  backgroundColor: scheme.primaryContainer,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isKurang ? scheme.errorContainer : scheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isKurang ? scheme.error : scheme.primary,
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
                          ? scheme.onErrorContainer
                          : scheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatRupiah(kembalian.abs()),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isKurang
                          ? scheme.onErrorContainer
                          : scheme.onPrimaryContainer,
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
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.primary),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 40,
                  color: scheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Arahkan pelanggan untuk men-scan QRIS pada meja kasir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pastikan uang senilai ${CurrencyFormatter.formatRupiah(grandTotal)} masuk sebelum menekan tombol Selesai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _summaryRow(
    BuildContext context, {
    required String label,
    required int amount,
    bool isTotal = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? scheme.onSurface : scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: isTotal ? 170 : 120,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              CurrencyFormatter.formatRupiah(amount),
              maxLines: 1,
              style: TextStyle(
                fontSize: isTotal ? 20 : 14,
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500,
                color: isTotal ? scheme.primary : scheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton({
    required BuildContext context,
    required OperationalSettings opSettings,
    required Cart cartNotifier,
    required int grandTotal,
    required int subtotal,
    required int taxAmount,
    required int uangDibayar,
    required bool isKurang,
    bool dense = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: dense ? 44 : 52,
      child: ElevatedButton.icon(
        onPressed: isKurang
            ? null
            : () => _processCheckout(
                  opSettings: opSettings,
                  cartNotifier: cartNotifier,
                  grandTotal: grandTotal,
                  subtotal: subtotal,
                  taxAmount: taxAmount,
                  uangDibayar: uangDibayar,
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.point_of_sale),
        label: const Text(
          'Selesaikan Transaksi',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _processCheckout({
    required OperationalSettings opSettings,
    required Cart cartNotifier,
    required int grandTotal,
    required int subtotal,
    required int taxAmount,
    required int uangDibayar,
  }) async {
    if (_metodePembayaran == MetodePembayaran.tunai) {
      if (_bayarController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Masukkan nominal uang yang dibayar!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      if (uangDibayar < grandTotal) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nominal uang kurang!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final nominalBayarAkhir =
        _metodePembayaran == MetodePembayaran.qris || uangDibayar == 0
            ? grandTotal
            : uangDibayar;
    final kembalianAkhir = nominalBayarAkhir - grandTotal;

    await cartNotifier.checkout(opSettings);

    if (!mounted) return;
    Navigator.pop(context);

    if (opSettings.autoPrintReceipt) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mencetak struk transaksi secara otomatis...'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    _showSuccessDialog(
      opSettings: opSettings,
      subtotal: subtotal,
      taxAmount: taxAmount,
      grandTotal: grandTotal,
      nominalBayarAkhir: nominalBayarAkhir,
      kembalianAkhir: kembalianAkhir,
    );
  }

  void _showSuccessDialog({
    required OperationalSettings opSettings,
    required int subtotal,
    required int taxAmount,
    required int grandTotal,
    required int nominalBayarAkhir,
    required int kembalianAkhir,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            if (opSettings.enableTax) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:'),
                  Text(CurrencyFormatter.formatRupiah(subtotal)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Pajak (${opSettings.taxPercentage.toStringAsFixed(opSettings.taxPercentage.truncateToDouble() == opSettings.taxPercentage ? 0 : 1)}%):'),
                  Text(CurrencyFormatter.formatRupiah(taxAmount)),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:'),
                Text(CurrencyFormatter.formatRupiah(grandTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (_metodePembayaran == MetodePembayaran.tunai) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dibayar:'),
                  Text(CurrencyFormatter.formatRupiah(nominalBayarAkhir)),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kembalian:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    CurrencyFormatter.formatRupiah(kembalianAkhir),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
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
                SnackBar(
                  content: const Text('Fitur cetak struk segera hadir!'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            child: const Text('Cetak Struk'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }
}
