import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Orientation rule for both app start and live mode changes.
///
/// Phone = shortest side < 600dp. Phones stay portrait in normal mode and may
/// rotate while Cashier Mode is on; tablets may rotate in both modes.
List<DeviceOrientation> preferredOrientationsFor({
  required bool isPhone,
  required bool cashierMode,
}) {
  if (!isPhone) return DeviceOrientation.values;
  if (cashierMode) {
    return const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ];
  }
  return const [DeviceOrientation.portraitUp];
}

/// Applies [preferredOrientationsFor] whenever the device class or mode changes.
///
/// Placed once under `MaterialApp` (which owns the MediaQuery), so screens never
/// call `SystemChrome` themselves. Exiting Cashier Mode reapplies the phone
/// portrait lock automatically.
class CashierOrientationController extends StatefulWidget {
  final bool isPhone;
  final bool cashierMode;
  final Widget child;

  const CashierOrientationController({
    super.key,
    required this.isPhone,
    required this.cashierMode,
    required this.child,
  });

  @override
  State<CashierOrientationController> createState() =>
      _CashierOrientationControllerState();
}

class _CashierOrientationControllerState
    extends State<CashierOrientationController> {
  List<DeviceOrientation>? _applied;

  @override
  void initState() {
    super.initState();
    _apply();
  }

  @override
  void didUpdateWidget(covariant CashierOrientationController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPhone != widget.isPhone ||
        oldWidget.cashierMode != widget.cashierMode) {
      _apply();
    }
  }

  void _apply() {
    final next = preferredOrientationsFor(
      isPhone: widget.isPhone,
      cashierMode: widget.cashierMode,
    );
    if (listEquals(next, _applied)) return;

    _applied = next;
    SystemChrome.setPreferredOrientations(next);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
