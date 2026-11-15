import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pos_mobile_app/data/database/app_database.dart';
import 'package:pos_mobile_app/providers/cart_provider.dart';
import 'package:pos_mobile_app/providers/category_provider.dart';
import 'package:pos_mobile_app/providers/inventory_provider.dart';
import 'package:pos_mobile_app/screens/cashier/cashier_screen.dart';
import 'package:pos_mobile_app/screens/cashier/widgets/cashier_order_pane.dart';

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

BarangData _barang(int id, [String? nama]) => BarangData(
      id: id,
      nama: nama ?? 'Barang $id',
      kategori: 'Umum',
      harga: 10000 * id,
      stok: 100,
      stokMinimal: 5,
      kelolaStok: true,
      isSynced: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const cases = [Size(640, 360), Size(800, 360), Size(1280, 800)];

  for (final size in cases) {
    testWidgets('order pane fits ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryProvider.overrideWith(
              () => _FakeInventory(List.generate(12, _barang)),
            ),
            categoryListProvider.overrideWith(_FakeCategoryList.new),
          ],
          child: const MaterialApp(home: CashierScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CashierOrderPane), findsOneWidget);
      expect(find.text('Belum ada item'), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CashierScreen)),
      );
      for (var id = 1; id <= 6; id++) {
        container.read(cartProvider.notifier).addItem(
              _barang(
                id,
                id == 1
                    ? 'Produk Dengan Nama Sangat Panjang Untuk Uji Overflow'
                    : null,
              ),
            );
      }
      container.read(cartProvider.notifier).addItem(_barang(2));
      await tester.pumpAndSettle();

      expect(find.textContaining('2 x '), findsOneWidget);
      expect(find.textContaining('Bayar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
