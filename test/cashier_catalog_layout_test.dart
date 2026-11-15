import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pos_mobile_app/core/layout/cashier_breakpoints.dart';
import 'package:pos_mobile_app/data/database/app_database.dart';
import 'package:pos_mobile_app/providers/category_provider.dart';
import 'package:pos_mobile_app/providers/inventory_provider.dart';
import 'package:pos_mobile_app/screens/cashier/widgets/cashier_catalog_pane.dart';

class _FakeInventory extends Inventory {
  final List<BarangData> items;

  _FakeInventory(this.items);

  @override
  Stream<List<BarangData>> build() => Stream.value(items);
}

class _FakeCategoryList extends CategoryList {
  @override
  Stream<List<KategoriData>> build() => Stream.value(const []);
}

BarangData _barang(int id) => BarangData(
      id: id,
      nama: id == 12
          ? 'Produk Dengan Nama Sangat Panjang Untuk Uji Overflow'
          : 'Barang $id',
      kategori: 'Umum',
      harga: 10000 * id,
      stok: 100,
      stokMinimal: 5,
      kelolaStok: true,
      isSynced: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

Future<void> _pumpCatalog(
  WidgetTester tester,
  Size size,
  CashierLayout layout,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        inventoryProvider
            .overrideWith(() => _FakeInventory(List.generate(12, _barang))),
        categoryListProvider.overrideWith(_FakeCategoryList.new),
      ],
      child: MaterialApp(
        home: Scaffold(body: CashierCatalogPane(layout: layout)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const cases = [
    (Size(640, 360), CashierLayout.compactLandscape, 96.0),
    (Size(800, 360), CashierLayout.compactLandscape, 96.0),
    (Size(1280, 800), CashierLayout.tablet, 110.0),
  ];

  for (final (size, layout, cardHeight) in cases) {
    testWidgets('catalog fits ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      await _pumpCatalog(tester, size, layout);

      expect(tester.takeException(), isNull);
      expect(find.text('Barang 1'), findsWidgets);
      expect(tester.getSize(find.byType(Card).first).height, cardHeight);

      final headerHeight = tester
          .getSize(find.byKey(const ValueKey('cashierCatalogHeader')))
          .height;
      expect(headerHeight, lessThanOrEqualTo(56));
      expect(headerHeight, lessThanOrEqualTo(size.height * 0.25));
    });
  }
}
