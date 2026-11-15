import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pos_mobile_app/data/database/app_database.dart';
import 'package:pos_mobile_app/providers/cart_provider.dart';
import 'package:pos_mobile_app/screens/pos/widgets/cart_bottom_sheet.dart';

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

Future<void> _openSheet(
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
        testWidgets(
          'cart sheet ${size.width.toInt()}x${size.height.toInt()} '
          '$itemCount items ${brightness.name}',
          (tester) async {
            await _openSheet(
              tester,
              size,
              itemCount: itemCount,
              brightness: brightness,
            );

            expect(tester.takeException(), isNull);

            final sheetHeight =
                tester.getSize(find.byType(CartBottomSheet)).height;
            expect(sheetHeight, lessThanOrEqualTo(size.height * 0.9 + 1));

            final confirm = find.text('Selesaikan Transaksi');
            expect(confirm, findsOneWidget);
            expect(
              tester.getRect(confirm).bottom,
              lessThanOrEqualTo(size.height),
            );

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

  for (final size in const [Size(640, 360), Size(360, 640)]) {
    testWidgets(
      'keyboard keeps confirm reachable at '
      '${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        await _openSheet(
          tester,
          size,
          itemCount: 15,
          brightness: Brightness.light,
        );

        tester.view.viewInsets = FakeViewPadding(
          bottom: size.height < 480 ? 200 : 300,
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final confirm = find.text('Selesaikan Transaksi');
        expect(confirm, findsOneWidget);
        expect(tester.getRect(confirm).bottom, lessThanOrEqualTo(size.height));
      },
    );
  }
}
