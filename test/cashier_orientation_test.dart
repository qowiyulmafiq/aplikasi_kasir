import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_mobile_app/core/layout/cashier_orientation.dart';

void main() {
  test('phone normal mode locks to portrait', () {
    expect(
      preferredOrientationsFor(isPhone: true, cashierMode: false),
      [DeviceOrientation.portraitUp],
    );
  });

  test('phone in cashier mode allows portrait and both landscapes', () {
    final orientations =
        preferredOrientationsFor(isPhone: true, cashierMode: true);

    expect(
      orientations,
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
  });

  test('exiting cashier mode returns a phone to the portrait lock', () {
    preferredOrientationsFor(isPhone: true, cashierMode: true);

    expect(
      preferredOrientationsFor(isPhone: true, cashierMode: false),
      [DeviceOrientation.portraitUp],
    );
  });

  test('tablets allow all orientations in both modes', () {
    for (final cashierMode in [false, true]) {
      expect(
        preferredOrientationsFor(isPhone: false, cashierMode: cashierMode),
        DeviceOrientation.values,
      );
    }
  });
}
