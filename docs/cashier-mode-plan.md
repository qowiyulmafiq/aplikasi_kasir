# Cashier Mode — Phase 0 Plan (aplikasi_kasir)

> Plan-only. No app files modified. Written here because Plan mode permits plan files only under `C:\Users\lenov\.opencode\plan`; the requested `docs/cashier-mode-plan.md` would be a repo change, so it is intentionally not created.

## 1. Architecture findings

### Stack / structure
- Flutter 3.44.6, Dart 3.12.2, Android-only (`android/` only; web removed).
- Riverpod 2 codegen (`@riverpod` notifiers), Drift/SQLite v4, go_router 13 with a `ShellRoute` (`MainLayout` + bottom nav), Material 3 + `google_fonts`.
- Real storage for preferences is **`shared_preferences`**, wrapped by notifiers that load async in `build()`:
  - `lib/providers/system_settings_provider.dart` (`themeMode`, `posLayoutMode`, `showItemImage`)
  - `lib/providers/operational_settings_provider.dart` (tax, stock rules, auto print)
  - `lib/providers/user_profile_provider.dart`
- No new package is needed for persistence: extend `SystemSettings`.

### POS data flow
- `lib/screens/pos/pos_screen.dart` (522 lines) owns catalog + cart bar:
  - catalog: `filteredPosCatalogProvider` (`inventory_provider.dart`) ← `inventoryProvider` (Drift stream) + `posSearchQueryProvider` / `posSelectedCategoryProvider` / `posSortOptionProvider`.
  - categories: `categoryNamesProvider` (`category_provider.dart`).
  - cart: `cartProvider` in `lib/providers/cart_provider.dart`, **`@Riverpod(keepAlive: true)`** → survives rebuilds, rotation, and (because we will not recreate `ProviderScope`) mode switching.
  - stock guard + add-to-cart currently lives inside `PosScreen._handleAddItem`.
  - layout mode/image toggle read from `SystemSettings`.
- Payment lives in `lib/screens/pos/widgets/cart_bottom_sheet.dart` (738 lines): cart list, qty stepper, Tunai/QRIS `SegmentedButton`, quick cash chips, change box, success `AlertDialog`. `Cart.checkout()` writes header+detail and decrements stock. **Payment metadata is still not persisted** (known project TODO) — out of scope here.
- Theme is `AppTheme` (Material 3, seeded blue). Existing screens mix `colorScheme` with hardcoded `Colors.*`.
- Navigation: `MainLayout` is a plain `StatelessWidget`; bottom nav always visible; `/pos` builds `PosScreen`. Full-screen sub-routes use the root navigator.

### Baseline health (verified)
- `flutter analyze`: **11 issues, all pre-existing** — 4 warnings in `app_database.g.dart`, 6 deprecated-ref infos in generated providers, 1 `avoid_print` in `image_picker_helper.dart`. Target: add zero new issues.
- `flutter test`: fails with `Test directory "test" not found`. Phase 1 will create `test/`.
- `git status`: clean.

### Known-issue checks
1. **Images/icons “fail to bind from data”**
   - Product image path is `Barang.gambarPath` → `ProductImageWidget` → `Image.file(..., errorBuilder: fallback)`.
   - Data path is wired correctly in POS grid/list, inventory grid/list, and the add/edit form (`pos_screen.dart:236/360`, `inventory_item_card.dart:44/108`, `inventory_form_screen.dart:184`).
   - No `Image.asset`/`AssetImage`/`NetworkImage` anywhere; no dynamic `IconData`/icon font logic; `pubspec.yaml` declares no assets.
   - **No hard data-binding defect found statically.** Two real weaknesses, though:
     - `ProductImageWidget.namaBarang` is required but **never used**; every missing photo shows the same generic `Icons.image_outlined` (`product_image_widget.dart:51-63`). The intended “bind placeholder to product data” was never finished.
     - The file-exists check was removed in commit `4637b4a`; missing/corrupt files now rely on the async `errorBuilder`.
   - Proposed small fix (only if you confirm the symptom): fallback = initials from `namaBarang` + stable color derived from the name, using theme colors; keep `errorBuilder`. This fixes all screens at once (POS, inventory, form), and Cashier Mode gets the same thumbnails for free.
   - Also note: the cart and history detail intentionally render **no** product images. If your symptom is “images missing in cart/history”, that is a missing feature, not a broken binding.
   - **I need the actual symptom (screen + expected vs actual, screenshot) before changing shared image behavior.**
2. **Inconsistent selected-state styles**
   - Confirmed. Main catalog rows use `ChoiceChip` with `primary @ 20%` + no border (`pos_screen.dart:141`, `inventory_screen.dart:140`), while the filter modal uses `FilterChip` with `primaryContainer` + `primary` border + `showCheckmark: false` (`category_quick_picker_sheet.dart:355/469`). Sort icons also reuse the same glyph for asc/desc (`_getSortIcon`, line 74).
   - Fix: one `AppChoiceChip` widget (selected = `primaryContainer` fill + `primary` 1.5dp border + `onPrimaryContainer` bold label + same avatar tint), used by the modal and Cashier Mode; migrate the POS/Inventory category rows too (small, 2 call sites each).
3. **“Selected customer”** — no customer feature/state exists in this app, so there is nothing to preserve or build. Only the cart and in-progress checkout matter.

---

## 2. Proposed file changes

### New files
| File | Purpose |
|---|---|
| `lib/core/layout/cashier_breakpoints.dart` | Named breakpoints + `resolveCashierLayout(Size)` + `shouldSuggestCashierMode(Size)`; single source of truth, pure Dart (unit-testable). |
| `lib/widgets/app_choice_chip.dart` | One selected-state pattern for category/sort chips (modal + POS + inventory + cashier). |
| `lib/utils/cart_helpers.dart` | `addBarangToCart(context, ref, barang)` extracted from `PosScreen._handleAddItem`; one stock rule for both modes. |
| `lib/services/keep_awake_service.dart` | `KeepAwake.setEnabled(bool)` over `MethodChannel('aplikasi_kasir/keep_awake')`, swallows `MissingPluginException` (tests/unsupported). |
| `lib/widgets/transaction_success_dialog.dart` | Interchange `AlertDialog` extracted from `cart_bottom_sheet.dart` (scrollable content so it cannot overflow at 360dp height). Used by normal and cashier checkout. |
| `lib/screens/cashier/cashier_screen.dart` | Mode entry point: AppBar, menu sheet, layout switch, keep-awake lifecycle; reuses `SystemSettings`, `Cart`, catalog providers. |
| `lib/screens/cashier/widgets/cashier_catalog_pane.dart` | Search + category rail/chips + product grid/card. |
| `lib/screens/cashier/widgets/cashier_order_pane.dart` | Line items, qty ±, subtotal/tax/total, pinned Pay button (also used inside the portrait order sheet). |
| `lib/screens/cashier/widgets/cashier_payment_sheet.dart` | Tunai/QRIS, quick cash, numeric keypad, change, confirm; responsive short-landscape variant. |
| `test/cashier_breakpoints_test.dart` | Breakpoint/suggestion unit tests. |
| `test/cashier_layout_test.dart` | Widget smoke tests at the 5 acceptance sizes, cart-preservation test. |

### Modified files
| File | Change |
|---|---|
| `lib/providers/system_settings_provider.dart` | Add `cashierMode` (persisted `cashierMode`), `cashierModePromptDismissed` (persisted), `isLoaded` (not persisted), extend `copyWith`/`updateSettings`/`_initPrefs`/`_saveToPrefs`. No codegen needed (no annotation change). |
| `lib/screens/pos/pos_screen.dart` | Normal branch: `if (settings.cashierMode) return const CashierScreen();`; AppBar action to enter mode; one-shot non-blocking suggestion when `width >= 600 || landscape`; replace `_handleAddItem` body with shared helper; use `AppChoiceChip`. |
| `lib/screens/main_layout.dart` | Become `ConsumerWidget`; hide `CustomBottomNav` only while `cashierMode && location.startsWith('/pos')` (nav returns on management tabs, so there is always a way back). |
| `lib/screens/profile/system_settings_screen.dart` | `SwitchListTile` “Mode Kasir” under Tampilan Katalog (also exits mode). |
| `lib/screens/pos/widgets/cart_bottom_sheet.dart` | Replace private `_showSuccessDialog` body with shared `TransactionSuccessDialog`; no logic change. |
| `lib/widgets/category_quick_picker_sheet.dart` | Use `AppChoiceChip` for sort + category chips (fix known inconsistency); fix asc/desc sort icons. |
| `lib/screens/inventory/inventory_screen.dart` | Use `AppChoiceChip` for its category row. |
| `lib/widgets/product_image_widget.dart` | **Not planned for now** — symptom not confirmed. Cashier Mode reuses the current widget as-is. If you later confirm “missing photo shows generic icon”, add initials/stable-color fallback using `namaBarang` + theme colors. |
| `android/app/src/main/kotlin/com/example/aplikasi_kasir/MainActivity.kt` | Handle `setKeepScreenOn` via `FLAG_KEEP_SCREEN_ON` (add/clear). |
| `PROJECT_STATUS.md` | Phase status: done / next step, cashier checklist, updated known issues. |

### Explicitly unchanged
- **`pubspec.yaml`**: no new dependency. Keep-awake uses the native Android flag over a MethodChannel (~25 Kotlin lines + tiny Dart wrapper). If you prefer `wakelock_plus`, say so and I will add it + justify the pubspec change.
- Drift schema, `Cart.checkout` semantics, Google Sheets sync, inventory/history features.

---

## 3. Breakpoints and layout decision (width **and** height)

```dart
enum CashierLayout { tablet, compactLandscape, compactPortrait }

class CashierBreakpoints {
  static const double tabletMinWidth = 700;
  static const double tabletMinHeight = 520;   // avoids "wide but 360 tall"
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
  if (size.width >= 700 && size.height >= 520) return CashierLayout.tablet;
  if (size.width > size.height && size.width >= 560) return CashierLayout.compactLandscape;
  return CashierLayout.compactPortrait;
}

bool shouldSuggestCashierMode(Size size) =>
    size.width >= 600 || size.width > size.height;
```

| Size | Variant | Panes |
|---|---|---|
| 360×640 | compactPortrait | 1 (grid + sticky bar) |
| 640×360 | compactLandscape | 2 (72 rail + grid \| ±256 order) |
| 411×891 | compactPortrait | 1 |
| 800×1280 | tablet | 2 (96 rail + grid \| ±300 order) |
| 1280×800 | tablet | 2 (96 rail + grid \| 420 order) |

Use `MediaQuery.sizeOf(context)` for variant choice (stable when the keyboard opens) and `LayoutBuilder` for pane widths. Pane widths: `clamp(width * (tablet ? .36 : .40), 240, (tablet ? 420 : 320))`; grids use `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 180/160)`, so column count adapts instead of hardcoding 2.

No overflow strategy: AppBar `toolbarHeight: 48` in cashier; each pane owns `Expanded` scroll view; totals/pay pinned in a `Column` (no `Spacer` inside unbounded scroll); all prices `maxLines: 1` + `FittedBox`; qty/total rows use `Flexible`; `SafeArea(top: false)` around the panes; payment/success content scrollable.

---

## 4. Widget tree sketches

### A. Tablet / wide landscape (two panes)
```
CashierScreen (ConsumerStatefulWidget; enable keep-awake in initState, disable in dispose)
└ Scaffold
  ├ AppBar(toolbarHeight: 48)  "Kasir"            [menu] [exit]
  └ SafeArea(top: false)
    └ LayoutBuilder
      └ Row
        ├ Expanded (catalog)
        │  └ Column
        │    ├ SearchBar (48–52; writes posSearchQueryProvider)
        │    └ Expanded
        │      └ Row
        │        ├ CategoryRail (w 96; vertical ListView; items ≥56 tall)
        │        ├ VerticalDivider
        │        └ Expanded
        │          └ GridView.builder (maxExtent 180) → CashierProductCard
        └ SizedBox(w = clamp(w*.36, 300, 420))
          └ CashierOrderPane
             └ Column
               ├ Header: "Pesanan (n)"                [clear]
               ├ Expanded(ListView of lines: name, price, − qty +, subtotal)
               ├ Divider
               ├ Subtotal / Pajak (if enabled) / Total
               ├ PayButton (h 56: "Bayar • Rp …")
               └ SafeArea(bottom)
```
Category rail item: icon-less short label + count, selected = `primaryContainer` fill + `primary` left bar; tooltip for compact. Product card: thumbnail (`ProductImageWidget`), name (1 line ellipsis), price, qty badge; whole card is the tap target (≥ 88 dp tall), selected border when in cart.

### B. Compact phone landscape (640×360): same tree, tighter
- AppBar 48; outer padding 8.
- Rail 72, labels shortened (or icon + 2 letters) but 56 dp tall.
- Order pane `clamp(w*.40, 240, 320)`; line rows 52–56 dp; totals font 12/16.
- Catalog keeps its own scroll; order list keeps its own scroll. No shared scroll view, so nothing pushes the Pay button off-screen.

### C. Compact phone portrait
```
Scaffold
├ AppBar(toolbarHeight: 48)  "Kasir"            [menu] [exit]
└ SafeArea(top: false)
  └ Column
    ├ SearchBar (48)
    ├ Horizontal AppChoiceChip row (48 tall, scrolls sideways)
    ├ Expanded GridView (maxExtent 200; 2 cols on 360/411)
    └ StickyBar (64 + bottom inset)
       ├ "n item" + Total
       └ [Lihat Pesanan →]  (≥56 dp)
          onTap → showModalBottomSheet(isScrollControlled, useSafeArea)
                   └ 75%-height sheet: CashierOrderPane + Pay
```
Pay from the sheet → `CashierPaymentSheet`; after success the sheet closes, cart clears, success dialog appears.

### D. Payment sheet (used by both modes)
```
showModalBottomSheet(isScrollControlled, useSafeArea, constraints: maxWidth 560)
└ AnimatedPadding(viewInsets)
  └ LayoutBuilder(
      short landscape (h < 480 && w > h)
        ? Row[ Summary + quick cash | keypad ] + pinned Confirm
        : Column[ Summary, Tunai/QRIS segmented, quick cash, amount,
                  change / "kurang", keypad (Tunai only) ] in scroll + pinned Confirm
    )
```
- Tunai: quick amounts = Uang Pas, rounded-up suggestions (nearest 5k/10k/50k/100k) + 10k/20k/50k/100k; keypad 1–9, 000, 0, backspace; buttons ≥56×48; change box turns error when `paid < total`.
- QRIS: exact total, instruction box (existing wording), no keypad.
- Confirm calls `cartNotifier.checkout(opSettings)` then shared `TransactionSuccessDialog` (Metode, Subtotal, Pajak, Total, Dibayar, Kembalian; scrollable) — same behavior as today.
- `Cetak Struk` remains the existing placeholder SnackBar (printer is still out of scope).

### E. Mode toggle / suggestion / menu
- Enter: normal POS AppBar icon (`Icons.point_of_sale`) + System Settings switch. Exit: cashier AppBar icon (`Icons.close_fullscreen`) + menu sheet + System Settings switch.
- Toggle only calls `SystemSettingsNotifier.updateSettings(cashierMode: …)`; it never touches `cartProvider`, routes, or `ProviderScope`.
- Suggestion: one-shot floating `SnackBar` (“Layar lebar — aktifkan Mode Kasir?” [Aktifkan] [Nanti]) when `isLoaded && !cashierMode && !promptDismissed && shouldSuggestCashierMode(size)`. `Nanti` persists `cashierModePromptDismissed`; no automatic switching.
- Cashier menu (single entry for management): bottom sheet with `Riwayat`, `Inventaris`, `Pengaturan Toko`, `Sistem & Tampilan`, `Keluar Mode Kasir`. Navigation via `context.go('/history' | '/inventory')` or `context.push('/profile/...')`.

---

## 5. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Losing the cart on toggle/rotation | Cart is keepAlive; no provider disposal, no `ProviderScope` rebuild. Explicit widget test toggles mode with a non-empty cart. |
| Overflow at 360 dp height / short landscape | Height-aware resolver, 48 dp AppBar, per-pane scrolling, `FittedBox`, adaptive grid extents; tests at all 5 sizes (overflow throws in widget tests). |
| Async prefs flash showing the wrong mode | `isLoaded` flag; cashier branch only after settings load; suggestion requires `isLoaded`; never auto-switch. |
| Suggestion nagging | Persisted `cashierModePromptDismissed`; only shown in normal mode. |
| Bottom sheet + keyboard overflow | `isScrollControlled`, `useSafeArea`, `viewInsets` padding, pinned confirm outside the scroll area. |
| MethodChannel breaks tests/other platforms | Dart wrapper catches `MissingPluginException`; Android-only flag; no pubspec change. Clear the flag on dispose. |
| Refactoring `CartBottomSheet` regressions | Only extract the success dialog markup; keep checkout logic/validation identical. |
| Shared chip migration changes existing UI | Same selected style already used by the filter modal; verify on POS/Inventory and keep sizes ≥48 dp. |
| Image fallback change alters every screen | Gated on your confirmation of the actual symptom. |
| Hardcoded colors break dark mode | New UI uses `Theme.of(context).colorScheme` only. |
| Text scaling causes clipping | `maxLines` + `FittedBox` on prices; not testing extreme scales in v1. |
| `go_router` and mode state diverging | Mode stays on `/pos`; nav is hidden only there; management tabs keep the nav so back navigation is obvious. |
| Checkout still drops payment metadata | Pre-existing known issue, documented in PROJECT_STATUS; not silently “fixed” here. |

---

## 6. Phase checklist (stop after each for review)

### Phase 0 — this plan
- [x] Read AGENTS/rules, README, lib/, git log, providers, storage, screens.
- [x] Baseline `flutter analyze` / `flutter test` recorded.
- [ ] **Your approval + answers to the open decisions below.**

### Phase 1 — breakpoints + mode state + persistence + toggle (no cashier UI)
- [ ] `cashier_breakpoints.dart` + unit tests (all 5 sizes + suggestion rule).
- [ ] `SystemSettings`: `cashierMode`, `cashierModePromptDismissed`, `isLoaded`, prefs keys.
- [ ] POS AppBar entry toggle + “Mode Kasir” switch in System Settings; hide bottom nav on `/pos` when active.
- [ ] Suggestion SnackBar (non-blocking, dismissible).
- [ ] `KeepAwake` MethodChannel + `MainActivity` flag plumbing (not wired to UI until Phase 2).
- [ ] `AppChoiceChip` + migrate filter modal/POS/inventory category chips.
- [ ] Optional (only if you confirm the image symptom): `ProductImageWidget` initials fallback. **Skipped by default.**
- [ ] `flutter analyze` (no new issues), `flutter test` (green), update `PROJECT_STATUS.md`, summary <10 lines, stop.

### Phase 2 — Cashier screen for tablet / wide landscape
- [ ] `CashierScreen` + catalog pane (rail + grid) + order pane; shared cart helper.
- [ ] Payment sheet (Tunai/QRIS, keypad, quick cash, change) + shared success dialog.
- [ ] Menu sheet + exit toggle; keep-awake wired to screen lifecycle.
- [ ] Non-tablet sizes temporarily fall back to the normal POS (mode still persisted) — no crash/overflow.
- [ ] Tests: tablet 1280×800 and 800×1280 render two panes; add-to-cart works.
- [ ] analyze / test / status update / summary, stop.

### Phase 3 — compact portrait + landscape + payment polish
- [ ] Compact landscape tuning (72 rail, tighter order pane, 48 dp controls).
- [ ] Portrait sticky bar + order bottom sheet.
- [ ] Payment sheet short-landscape two-column layout; success dialog scroll safety.
- [ ] Tests at 360×640, 640×360, 411×891; no overflow, correct pane presence.
- [ ] analyze / test / status update / summary, stop.

### Phase 4 — tests + cleanup
- [ ] Full matrix test (5 sizes), cart preservation across mode toggle, breakpoint unit tests.
- [ ] Remove dead code/duplication; confirm no new dependencies; re-run `flutter analyze` (11 pre-existing issues only) and `flutter test`.
- [ ] Final `PROJECT_STATUS.md` update + summary.

### Commands after every phase
```
flutter analyze
flutter test
```
Never `flutter run` (you run it). No file deletions. No pubspec changes without approval.

---

## 7. Decisions and remaining question

**Resolved**
1. **Discount — deferred.** Order pane shows Subtotal / Pajak (if enabled) / Total. No Cart/schema/receipt changes. Discount becomes a separate feature later.
2. **Keep-awake — MethodChannel + Android `FLAG_KEEP_SCREEN_ON`.** No pubspec change.
3. **Suggestion — “Nanti” persists forever** via `cashierModePromptDismissed`. Toggle always remains available in the AppBar and System Settings.

**Still open**
4. **Image/icon symptom**: unanswered, so no shared image change is planned. Cashier Mode will use `ProductImageWidget` exactly as today. If the symptom is “products without a photo all show the same generic icon”, tell me and I’ll add the initials/stable-color fallback in Phase 1; if it’s “wrong/blank image”, I’ll trace the file/path flow before Phase 2.

**Approval**: reply “approved” (plus the image answer if you have it) and I’ll start Phase 1. Plan file: `C:\Users\lenov\.opencode\plan\cashier-mode-plan.md`.

