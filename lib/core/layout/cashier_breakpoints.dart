import 'dart:ui';

/// Layout variants for Cashier Mode.
enum CashierLayout { tablet, compactLandscape, compactPortrait }

/// Single source of truth for Cashier Mode sizing rules.
class CashierBreakpoints {
  static const double tabletMinWidth = 700;
  static const double tabletMinHeight = 520; // avoids "wide but 360 tall"
  static const double compactLandscapeMinWidth = 560;
  static const double suggestMinWidth = 600;
  static const double minTouch = 48;
  static const double primaryActionHeight = 56;
  static const double railWide = 96;
  static const double railCompact = 72;
  static const double orderPaneMin = 240;
  static const double orderPaneMax = 420;
  static const double productCardMaxExtent = 180;
}

CashierLayout resolveCashierLayout(Size size) {
  if (size.width >= CashierBreakpoints.tabletMinWidth &&
      size.height >= CashierBreakpoints.tabletMinHeight) {
    return CashierLayout.tablet;
  }
  if (size.width > size.height &&
      size.width >= CashierBreakpoints.compactLandscapeMinWidth) {
    return CashierLayout.compactLandscape;
  }
  return CashierLayout.compactPortrait;
}

bool shouldSuggestCashierMode(Size size) =>
    size.width >= CashierBreakpoints.suggestMinWidth ||
    size.width > size.height;
