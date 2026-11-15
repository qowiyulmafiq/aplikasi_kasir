import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile_app/core/layout/cashier_breakpoints.dart';

void main() {
  test('resolves the five acceptance sizes to the planned variant', () {
    expect(
      resolveCashierLayout(const Size(360, 640)),
      CashierLayout.compactPortrait,
    );
    expect(
      resolveCashierLayout(const Size(640, 360)),
      CashierLayout.compactLandscape,
    );
    expect(
      resolveCashierLayout(const Size(411, 891)),
      CashierLayout.compactPortrait,
    );
    expect(
      resolveCashierLayout(const Size(800, 1280)),
      CashierLayout.tablet,
    );
    expect(
      resolveCashierLayout(const Size(1280, 800)),
      CashierLayout.tablet,
    );
  });

  test('wide but short screens never become tablets', () {
    expect(
      resolveCashierLayout(const Size(1280, 360)),
      CashierLayout.compactLandscape,
    );
    expect(
      resolveCashierLayout(const Size(700, 519)),
      CashierLayout.compactLandscape,
    );
  });

  test('landscape below the compact-landscape width stays portrait', () {
    expect(
      resolveCashierLayout(const Size(540, 400)),
      CashierLayout.compactPortrait,
    );
  });

  test('suggests cashier mode for wide or landscape screens only', () {
    expect(shouldSuggestCashierMode(const Size(360, 640)), isFalse);
    expect(shouldSuggestCashierMode(const Size(411, 891)), isFalse);
    expect(shouldSuggestCashierMode(const Size(599, 899)), isFalse);
    expect(shouldSuggestCashierMode(const Size(600, 900)), isTrue);
    expect(shouldSuggestCashierMode(const Size(640, 360)), isTrue);
    expect(shouldSuggestCashierMode(const Size(1280, 800)), isTrue);
  });
}
