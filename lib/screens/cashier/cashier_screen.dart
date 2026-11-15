import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/cashier_breakpoints.dart';
import 'widgets/cashier_catalog_pane.dart';
import 'widgets/cashier_order_pane.dart';

/// Cashier Mode entry point.
///
/// The catalog header carries the exit action so the screen has no separate
/// title bar. Tablet and compact landscape render the catalog and order panes
/// side by side. Compact portrait keeps the catalog only until the portrait
/// order sheet from the plan lands.
class CashierScreen extends ConsumerWidget {
  const CashierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = resolveCashierLayout(MediaQuery.sizeOf(context));

    return Scaffold(
      body: SafeArea(
        child: layout == CashierLayout.compactPortrait
            ? CashierCatalogPane(layout: layout)
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = layout == CashierLayout.tablet;
                  final orderWidth =
                      (constraints.maxWidth * (isTablet ? 0.36 : 0.40))
                          .clamp(
                            CashierBreakpoints.orderPaneMin,
                            isTablet ? CashierBreakpoints.orderPaneMax : 320.0,
                          )
                          .toDouble();

                  return Row(
                    children: [
                      Expanded(child: CashierCatalogPane(layout: layout)),
                      const VerticalDivider(width: 1),
                      SizedBox(
                        width: orderWidth,
                        child: const CashierOrderPane(),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
