import 'package:flutter/services.dart';

/// Toggles the Android keep-screen-on flag.
///
/// The channel has no handler in tests or on non-Android platforms, so
/// [MissingPluginException] is intentionally treated as "not supported".
class KeepAwake {
  KeepAwake._();

  static const MethodChannel _channel =
      MethodChannel('aplikasi_kasir/keep_awake');

  static Future<void> setEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setKeepScreenOn', enabled);
    } on MissingPluginException {
      // Nothing to do: keep-awake is Android-only and absent under tests.
    }
  }
}
