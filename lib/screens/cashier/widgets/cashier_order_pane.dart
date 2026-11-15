import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/cashier_breakpoints.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/operational_settings_provider.dart';
import '../../../utils/cart_helpers.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/dialog_helper.dart';
import '../../pos/widgets/cart_bottom_sheet.dart';

/// Order pane for Cashier Mode (tablet + compact landscape).
///
/// The line list owns its scroll while the totals and Pay button stay pinned
/// at the bottom, so the panes scroll independently and Pay never scrolls
/// off-screen. Pay reuses the existing cart/payment bottom sheet.
class CashierOrderPane extends ConsumerWidget {
  const CashierOrderPane({super.key});

  void _showPaymentSheet(BuildContext context) {
    CartBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final opSettings = ref.watch(operationalSettingsNotifierProvider);

    final subtotal = cartNotifier.subtotal;
    final taxAmount = cartNotifier.getTaxAmount(opSettings);
    final grandTotal = cartNotifier.getGrandTotal(opSettings);
    final itemCount = cart.fold<int>(0, (sum, item) => sum + item.kuantitas);

    return ColoredBox(
      color: scheme.surfaceContainerLow,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
            child: Row(
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 16, color: scheme.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Pesanan ($itemCount)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Kosongkan Pesanan',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: cart.isEmpty
                      ? null
                      : () => DialogHelper.showDeleteConfirm(
                            context: context,
                            title: 'Kosongkan Pesanan',
                            itemName: 'semua item di pesanan',
                            onConfirm: cartNotifier.clearCart,
                          ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 36,
                            color: scheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada item',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ketuk produk untuk menambah pesanan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.2,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    key: const ValueKey('cashierOrderList'),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    itemCount: cart.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return _OrderLine(
                        item: item,
                        onDecrease: () =>
                            cartNotifier.decreaseItem(item.barang),
                        onIncrease: () =>
                            addBarangToCart(context, ref, item.barang),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Container(
            color: scheme.surfaceContainerHigh,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TotalRow(label: 'Subtotal', amount: subtotal),
                    if (opSettings.enableTax)
                      _TotalRow(
                        label:
                            'Pajak (${opSettings.taxPercentage.toStringAsFixed(opSettings.taxPercentage.truncateToDouble() == opSettings.taxPercentage ? 0 : 1)}%)',
                        amount: taxAmount,
                      ),
                    const SizedBox(height: 4),
                    _TotalRow(
                      label: 'Total',
                      amount: grandTotal,
                      isTotal: true,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: CashierBreakpoints.primaryActionHeight,
                      child: ElevatedButton(
                        onPressed: cart.isEmpty
                            ? null
                            : () => _showPaymentSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Bayar Sekarang',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderLine extends StatelessWidget {
  final CartItem item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _OrderLine({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.barang.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 88,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    CurrencyFormatter.formatRupiah(item.subtotal),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: item.kuantitas > 1
                    ? Text(
                        '${item.kuantitas} x ${CurrencyFormatter.formatRupiah(item.barang.harga)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 6),
              _QtyStepper(
                quantity: item.kuantitas,
                onDecrease: onDecrease,
                onIncrease: onIncrease,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QtyStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            color: scheme.error,
            onTap: onDecrease,
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(6)),
          ),
          SizedBox(
            width: 32,
            child: Center(
              child: Text(
                '$quantity',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            color: scheme.primary,
            onTap: onIncrease,
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(6)),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _StepperButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final int amount;
  final bool isTotal;

  const _TotalRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTotal ? 2 : 1),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isTotal ? 14 : 12,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: isTotal ? 124 : 112,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                CurrencyFormatter.formatRupiah(amount),
                maxLines: 1,
                style: TextStyle(
                  fontSize: isTotal ? 23 : 12,
                  fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
                  color: isTotal ? scheme.primary : scheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
