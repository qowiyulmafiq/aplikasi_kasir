import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final totalQuantity =
        cart.fold<int>(0, (sum, item) => sum + item.kuantitas);

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
            _buildHeader(
              context,
              cart,
              cartNotifier,
              scheme,
              totalQuantity: totalQuantity,
              dense: isDense,
            ),
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
                                keyboardOpen: viewInsetsBottom > 0,
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
                                maxHeight: constraints.maxHeight * 0.75,
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
                                keyboardOpen: viewInsetsBottom > 0,
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
    required int totalQuantity,
    bool dense = false,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    // Keep the text label only when there is room for it; on a phone the
    // clear action stays as an icon with a tooltip so nothing overflows.
    final showClearLabel = !dense && width >= 560;

    return Padding(
      padding: dense
          ? const EdgeInsets.fromLTRB(12, 2, 2, 2)
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
                size: dense ? 18 : 22,
              ),
              const SizedBox(width: 6),
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
              // Count + clear are one compact group pinned to the
              // top-right corner instead of stretching into the middle.
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width * 0.55),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        key: const ValueKey('itemCountChip'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${cart.length} jenis · $totalQuantity pcs',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: dense ? 11 : 12,
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showClearLabel)
                      TextButton.icon(
                        key: const ValueKey('clearCartAction'),
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
                      )
                    else
                      IconButton(
                        key: const ValueKey('clearCartAction'),
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
                      ),
                  ],
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

    final scheme = Theme.of(context).colorScheme;

    return ListView.separated(
      key: const ValueKey('cartItemList'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: cart.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = cart[index];
        return Container(
          key: ValueKey('cartItemRow_$index'),
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Kontrol kuantitas: setiap tombol punya target sentuh 40dp.
              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  border: Border.all(color: scheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _quantityButton(
                      icon: Icons.remove,
                      color: scheme.error,
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
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 28),
                      alignment: Alignment.center,
                      child: Text(
                        '${item.kuantitas}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _quantityButton(
                      icon: Icons.add,
                      color: scheme.primary,
                      onTap: () {
                        cartNotifier.addItem(item.barang);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Subtotal
              SizedBox(
                width: 64,
                child: FittedBox(
                  alignment: Alignment.centerRight,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    CurrencyFormatter.formatRupiah(item.subtotal),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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

  Widget _quantityButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: InkWell(
        onTap: onTap,
        child: Icon(icon, size: 18, color: color),
      ),
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
    bool keyboardOpen = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TOTAL is pinned: it never participates in the scrollable area.
            _buildPinnedTotal(
              context,
              grandTotal: grandTotal,
              subtotal: subtotal,
              taxAmount: taxAmount,
              opSettings: opSettings,
              compact: compact,
              dense: dense,
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            // Field, quick amounts and change scroll independently so the
            // confirm button below stays pinned above the keyboard.
            Flexible(
              child: SingleChildScrollView(
                key: const ValueKey('checkoutPaymentScroll'),
                padding: EdgeInsets.fromLTRB(
                  dense ? 12 : 16,
                  dense ? 6 : 12,
                  dense ? 12 : 16,
                  dense ? 4 : 8,
                ),
                child: _buildPaymentDetails(
                  context: context,
                  grandTotal: grandTotal,
                  kembalian: kembalian,
                  isKurang: isKurang,
                  compact: compact,
                  dense: dense,
                  showQuickAmounts: !keyboardOpen && !dense,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                dense ? 12 : 16,
                dense ? 2 : 6,
                dense ? 12 : 16,
                dense ? 2 : 8,
              ),
              child: confirmButton,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedTotal(
    BuildContext context, {
    required int grandTotal,
    required int subtotal,
    required int taxAmount,
    required OperationalSettings opSettings,
    required bool compact,
    required bool dense,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final amount = Text(
      CurrencyFormatter.formatRupiah(grandTotal),
      maxLines: 1,
      style: TextStyle(
        fontSize: dense ? 20 : (compact ? 26 : 30),
        fontWeight: FontWeight.w900,
        color: scheme.primary,
        height: 1.1,
      ),
    );

    if (dense) {
      // Very short sheet (keyboard open in landscape): one compact line.
      return Padding(
        key: const ValueKey('pinnedTotal'),
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
        child: Row(
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: amount,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      key: const ValueKey('pinnedTotal'),
      padding: EdgeInsets.fromLTRB(16, compact ? 6 : 10, 16, compact ? 6 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Total Pembayaran',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: amount,
            ),
          ),
          if (opSettings.enableTax) ...[
            const SizedBox(height: 2),
            Text(
              'Subtotal ${CurrencyFormatter.formatRupiah(subtotal)}  •  '
              'Pajak ${CurrencyFormatter.formatRupiah(taxAmount)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentDetails({
    required BuildContext context,
    required int grandTotal,
    required int kembalian,
    required bool isKurang,
    required bool compact,
    required bool dense,
    required bool showQuickAmounts,
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
        SizedBox(height: dense ? 6 : 10),

        // INPUT NOMINAL & KEMBALIAN (Hanya Tampil Jika Tunai)
        if (_metodePembayaran == MetodePembayaran.tunai) ...[
          CustomTextField(
            label: 'Uang Dibayar Pelanggan',
            controller: _bayarController,
            keyboardType: TextInputType.number,
            hintText: '0',
            prefixText: 'Rp ',
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              const _ThousandsSeparatorInputFormatter(),
            ],
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
          if (showQuickAmounts) ...[
            const SizedBox(height: 8),
            // Equal-width chips: never clipped, never off-screen.
            Row(
              children: [
                _quickAmountChip(
                  context,
                  label: 'Uang pas',
                  highlighted: true,
                  onTap: () => _setBayarValue(grandTotal),
                ),
                const SizedBox(width: 6),
                _quickAmountChip(
                  context,
                  label: '20rb',
                  onTap: () => _setBayarValue(20000),
                ),
                const SizedBox(width: 6),
                _quickAmountChip(
                  context,
                  label: '50rb',
                  onTap: () => _setBayarValue(50000),
                ),
                const SizedBox(width: 6),
                _quickAmountChip(
                  context,
                  label: '100rb',
                  onTap: () => _setBayarValue(100000),
                ),
              ],
            ),
          ],
          if (_bayarController.text.isNotEmpty) ...[
            SizedBox(height: dense ? 6 : 10),
            // KEMBALIAN ATAU PERINGATAN KURANG
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: dense ? 10 : 12,
                vertical: dense ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color:
                    isKurang ? scheme.errorContainer : scheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isKurang ? scheme.error : scheme.primary,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isKurang ? 'Uang kurang' : 'Kembalian',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: dense ? 12 : 13,
                        fontWeight: FontWeight.bold,
                        color: isKurang
                            ? scheme.onErrorContainer
                            : scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        CurrencyFormatter.formatRupiah(kembalian.abs()),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: dense ? 14 : 16,
                          fontWeight: FontWeight.w900,
                          color: isKurang
                              ? scheme.onErrorContainer
                              : scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  Widget _quickAmountChip(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Material(
        key: ValueKey('quickAmount_$label'),
        color: highlighted
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 34,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: highlighted
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setBayarValue(int value) {
    final text = CurrencyFormatter.formatRupiah(value, withSymbol: false);
    _bayarController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() {});
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

/// Digits-only cash input formatter that inserts Indonesian thousand
/// separators (e.g. `250000` -> `250.000`) while typing.
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const _ThousandsSeparatorInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue();
    }
    // Drop leading zeros (but keep a single zero).
    final normalized = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final value = int.tryParse(normalized);
    if (value == null) {
      return oldValue;
    }
    final text = CurrencyFormatter.formatRupiah(value, withSymbol: false);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
