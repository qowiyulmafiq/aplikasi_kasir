import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pos_mobile_app/data/database/app_database.dart';
import 'package:pos_mobile_app/providers/cart_provider.dart';
import 'package:pos_mobile_app/providers/operational_settings_provider.dart';
import 'package:pos_mobile_app/screens/pos/widgets/cart_bottom_sheet.dart';
import 'package:pos_mobile_app/utils/currency_formatter.dart';

BarangData _barang(int id) => BarangData(
      id: id,
      nama: id == 1
          ? 'Produk Dengan Nama Sangat Panjang Untuk Uji Overflow'
          : 'Item $id',
      kategori: 'Umum',
      harga: 14000 * id,
      stok: 100,
      stokMinimal: 5,
      kelolaStok: true,
      isSynced: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

const _paymentScroll = ValueKey('checkoutPaymentScroll');
const _quickLabels = ['Uang pas', '20rb', '50rb', '100rb'];

/// Opens the shared sheet and returns the cart grand total.
Future<int> _openSheet(
  WidgetTester tester,
  Size size, {
  required int itemCount,
  required Brightness brightness,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  for (var id = 1; id <= itemCount; id++) {
    container.read(cartProvider.notifier).addItem(_barang(id));
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true, brightness: brightness),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => CartBottomSheet.show(context),
                child: const Text('Buka Keranjang'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Buka Keranjang'));
  await tester.pumpAndSettle();

  return container
      .read(cartProvider.notifier)
      .getGrandTotal(container.read(operationalSettingsNotifierProvider));
}

Future<void> _openKeyboard(WidgetTester tester, Size size) async {
  final field = find.byType(TextField).first;
  // Bring the cash field into view inside the right-column scroll area,
  // then focus it before simulating the keyboard inset.
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.tap(field);
  await tester.pump();
  tester.view.viewInsets = FakeViewPadding(
    bottom: size.height < 480 ? 200 : 300,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const sizes = [Size(640, 360), Size(800, 360), Size(360, 640)];
  const itemCounts = [1, 5, 15, 40];
  const themes = [Brightness.light, Brightness.dark];

  for (final size in sizes) {
    for (final itemCount in itemCounts) {
      for (final brightness in themes) {
        for (final keyboard in [false, true]) {
          testWidgets(
            'cart sheet ${size.width.toInt()}x${size.height.toInt()} '
            '$itemCount items ${brightness.name} '
            '${keyboard ? 'keyboard' : 'no keyboard'}',
            (tester) async {
              final grandTotal = await _openSheet(
                tester,
                size,
                itemCount: itemCount,
                brightness: brightness,
              );
              if (keyboard) {
                await _openKeyboard(tester, size);
              }

              expect(tester.takeException(), isNull);

              final sheetRect = tester.getRect(find.byType(CartBottomSheet));

              final sheetHeight =
                  tester.getSize(find.byType(CartBottomSheet)).height;
              expect(sheetHeight, lessThanOrEqualTo(size.height * 0.9 + 1));

              // Item count label is "N jenis · M pcs".
              expect(
                find.text('$itemCount jenis · $itemCount pcs'),
                findsOneWidget,
              );

              // Count chip + clear action form a group in the top-right.
              final countRect =
                  tester.getRect(find.byKey(const ValueKey('itemCountChip')));
              final clearRect =
                  tester.getRect(find.byKey(const ValueKey('clearCartAction')));
              expect(
                  clearRect.right, greaterThanOrEqualTo(sheetRect.right - 16));
              expect(countRect.right, lessThanOrEqualTo(clearRect.left + 1));
              expect(countRect.center.dx, greaterThan(sheetRect.center.dx));
              expect(
                countRect.bottom,
                lessThan(sheetRect.top + sheetRect.height * 0.3),
              );

              // Pinned total stays visible above the scrollable area.
              final totalText = CurrencyFormatter.formatRupiah(grandTotal);
              final pinnedTotal = find.byKey(const ValueKey('pinnedTotal'));
              expect(
                find.descendant(
                  of: pinnedTotal,
                  matching: find.text(totalText),
                ),
                findsOneWidget,
              );
              final totalRect = tester.getRect(pinnedTotal);
              expect(totalRect.top, greaterThanOrEqualTo(sheetRect.top));
              // Pinned total lives above the payment scroll viewport.
              expect(
                totalRect.bottom,
                lessThanOrEqualTo(
                  tester.getRect(find.byKey(_paymentScroll)).top + 1,
                ),
              );

              // Confirm button is always pinned and reachable.
              final confirm = find.text('Selesaikan Transaksi');
              expect(confirm, findsOneWidget);
              final keyboardInset =
                  keyboard ? tester.view.viewInsets.bottom : 0.0;
              expect(
                tester.getRect(confirm).bottom,
                lessThanOrEqualTo(size.height - keyboardInset + 1),
              );

              if (keyboard) {
                // Chips are hidden while the keyboard is open.
                for (final label in _quickLabels) {
                  expect(
                    find.byKey(ValueKey('quickAmount_$label')),
                    findsNothing,
                  );
                }
              } else {
                // Equal-width quick amount chips, fully inside the sheet.
                final widths = <double>[];
                for (final label in _quickLabels) {
                  final chip = find.byKey(ValueKey('quickAmount_$label'));
                  expect(chip, findsOneWidget);
                  final rect = tester.getRect(chip);
                  widths.add(rect.width);
                  expect(rect.left, greaterThanOrEqualTo(sheetRect.left));
                  expect(rect.right, lessThanOrEqualTo(sheetRect.right));
                }
                expect(widths.reduce((a, b) => a < b ? a : b),
                    closeTo(widths.reduce((a, b) => a > b ? a : b), 0.5));
              }

              // Card rows keep a >=56dp height and the list scrolls.
              final row = tester.getSize(
                find.byKey(const ValueKey('cartItemRow_0')),
              );
              expect(row.height, greaterThanOrEqualTo(56));

              if (itemCount > 1) {
                final list = find.byKey(const ValueKey('cartItemList'));
                expect(list, findsOneWidget);
                await tester.drag(list, const Offset(0, -10000));
                await tester.pumpAndSettle();
                expect(find.text('Item $itemCount'), findsOneWidget);
                expect(confirm, findsOneWidget);
                expect(tester.takeException(), isNull);
              }
            },
          );
        }
      }
    }
  }

  testWidgets('cash input is digits-only with thousand separators',
      (tester) async {
    final grandTotal = await _openSheet(
      tester,
      const Size(800, 360),
      itemCount: 5,
      brightness: Brightness.light,
    );

    await tester.enterText(find.byType(TextField).first, '250abc000');
    await tester.pumpAndSettle();
    expect(find.text('250.000'), findsOneWidget);

    await tester.drag(find.byKey(_paymentScroll), const Offset(0, -200));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('quickAmount_50rb')));
    await tester.pumpAndSettle();
    expect(find.text('50.000'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quickAmount_Uang pas')));
    await tester.pumpAndSettle();
    expect(
      find.text(CurrencyFormatter.formatRupiah(grandTotal, withSymbol: false)),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
