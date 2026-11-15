import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../providers/cart_provider.dart';
import '../providers/operational_settings_provider.dart';

/// Adds [barang] once to the cart while enforcing the operational stock rule.
///
/// Shared by the normal POS and Cashier Mode so both use the same guard.
/// Returns `true` when the item was added.
bool addBarangToCart(BuildContext context, WidgetRef ref, BarangData barang) {
  final cart = ref.read(cartProvider);
  final quantityInCart = cart
      .where((item) => item.barang.id == barang.id)
      .fold(0, (sum, item) => sum + item.kuantitas);
  final opSettings = ref.read(operationalSettingsNotifierProvider);

  if (opSettings.enableStockManagement &&
      !opSettings.allowZeroStockSales &&
      (quantityInCart + 1) > barang.stok) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
            'Stok "${barang.nama}" tidak mencukupi! (Sisa: ${barang.stok})'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
    return false;
  }

  ref.read(cartProvider.notifier).addItem(barang);
  return true;
}
