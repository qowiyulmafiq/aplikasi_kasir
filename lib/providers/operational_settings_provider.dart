import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'operational_settings_provider.g.dart';

class OperationalSettings {
  final bool enableTax;
  final double taxPercentage;
  final bool enableStockManagement;
  final bool allowZeroStockSales;
  final bool autoPrintReceipt;

  OperationalSettings({
    this.enableTax = false,
    this.taxPercentage = 11.0,
    this.enableStockManagement = true,
    this.allowZeroStockSales = true,
    this.autoPrintReceipt = false,
  });

  OperationalSettings copyWith({
    bool? enableTax,
    double? taxPercentage,
    bool? enableStockManagement,
    bool? allowZeroStockSales,
    bool? autoPrintReceipt,
  }) {
    return OperationalSettings(
      enableTax: enableTax ?? this.enableTax,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      enableStockManagement:
          enableStockManagement ?? this.enableStockManagement,
      allowZeroStockSales: allowZeroStockSales ?? this.allowZeroStockSales,
      autoPrintReceipt: autoPrintReceipt ?? this.autoPrintReceipt,
    );
  }
}

@riverpod
class OperationalSettingsNotifier extends _$OperationalSettingsNotifier {
  SharedPreferences? _prefs;

  @override
  OperationalSettings build() {
    _initPrefs();
    return OperationalSettings();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs != null) {
      state = OperationalSettings(
        enableTax: _prefs!.getBool('enableTax') ?? state.enableTax,
        taxPercentage:
            _prefs!.getDouble('taxPercentage') ?? state.taxPercentage,
        enableStockManagement: _prefs!.getBool('enableStockManagement') ??
            state.enableStockManagement,
        allowZeroStockSales:
            _prefs!.getBool('allowZeroStockSales') ?? state.allowZeroStockSales,
        autoPrintReceipt:
            _prefs!.getBool('autoPrintReceipt') ?? state.autoPrintReceipt,
      );
    }
  }

  void updateSettings({
    bool? enableTax,
    double? taxPercentage,
    bool? enableStockManagement,
    bool? allowZeroStockSales,
    bool? autoPrintReceipt,
  }) {
    state = state.copyWith(
      enableTax: enableTax,
      taxPercentage: taxPercentage,
      enableStockManagement: enableStockManagement,
      allowZeroStockSales: allowZeroStockSales,
      autoPrintReceipt: autoPrintReceipt,
    );
    _saveToPrefs();
  }

  void _saveToPrefs() {
    if (_prefs == null) return;
    _prefs!.setBool('enableTax', state.enableTax);
    _prefs!.setDouble('taxPercentage', state.taxPercentage);
    _prefs!.setBool('enableStockManagement', state.enableStockManagement);
    _prefs!.setBool('allowZeroStockSales', state.allowZeroStockSales);
    _prefs!.setBool('autoPrintReceipt', state.autoPrintReceipt);
  }
}
