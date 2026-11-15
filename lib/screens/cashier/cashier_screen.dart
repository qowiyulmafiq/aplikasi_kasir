import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/cashier_breakpoints.dart';
import '../../providers/system_settings_provider.dart';
import 'widgets/cashier_catalog_pane.dart';

/// Cashier Mode entry point.
///
/// Phase 1 only persisted the mode; this shell adds the compact catalog
/// (grid + header). The order pane/payment sheet from the plan are still
/// pending, so they are intentionally absent.
class CashierScreen extends ConsumerWidget {
  const CashierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = resolveCashierLayout(MediaQuery.sizeOf(context));

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: const Text(
          'Kasir',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Keluar Mode Kasir',
            icon: const Icon(Icons.close_fullscreen),
            onPressed: () {
              ref
                  .read(systemSettingsNotifierProvider.notifier)
                  .updateSettings(cashierMode: false);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: CashierCatalogPane(layout: layout),
      ),
    );
  }
}
