import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'store_settings_provider.g.dart';

class StoreSettings {
  final String namaToko;
  final String alamat;
  final String telepon;
  final String pesanFooter;
  final String ukuranKertas;
  final bool tampilkanNamaKasir;

  StoreSettings({
    this.namaToko = 'Toko Kopi Berkah',
    this.alamat = 'Jl. Merdeka No. 45',
    this.telepon = '0812-3456-7890',
    this.pesanFooter = 'Terima kasih atas kunjungan Anda!',
    this.ukuranKertas = '58mm',
    this.tampilkanNamaKasir = true,
  });

  StoreSettings copyWith({
    String? namaToko,
    String? alamat,
    String? telepon,
    String? pesanFooter,
    String? ukuranKertas,
    bool? tampilkanNamaKasir,
  }) {
    return StoreSettings(
      namaToko: namaToko ?? this.namaToko,
      alamat: alamat ?? this.alamat,
      telepon: telepon ?? this.telepon,
      pesanFooter: pesanFooter ?? this.pesanFooter,
      ukuranKertas: ukuranKertas ?? this.ukuranKertas,
      tampilkanNamaKasir: tampilkanNamaKasir ?? this.tampilkanNamaKasir,
    );
  }
}

@riverpod
class StoreSettingsNotifier extends _$StoreSettingsNotifier {
  SharedPreferences? _prefs;

  @override
  StoreSettings build() {
    _initPrefs();
    return StoreSettings();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs != null) {
      state = StoreSettings(
        namaToko: _prefs!.getString('namaToko') ?? state.namaToko,
        alamat: _prefs!.getString('alamat') ?? state.alamat,
        telepon: _prefs!.getString('telepon') ?? state.telepon,
        pesanFooter: _prefs!.getString('pesanFooter') ?? state.pesanFooter,
        ukuranKertas: _prefs!.getString('ukuranKertas') ?? state.ukuranKertas,
        tampilkanNamaKasir: _prefs!.getBool('tampilkanNamaKasir') ?? state.tampilkanNamaKasir,
      );
    }
  }

  void updateSettings({
    String? namaToko,
    String? alamat,
    String? telepon,
    String? pesanFooter,
    String? ukuranKertas,
    bool? tampilkanNamaKasir,
  }) {
    state = state.copyWith(
      namaToko: namaToko,
      alamat: alamat,
      telepon: telepon,
      pesanFooter: pesanFooter,
      ukuranKertas: ukuranKertas,
      tampilkanNamaKasir: tampilkanNamaKasir,
    );
    _saveToPrefs();
  }

  void _saveToPrefs() {
    if (_prefs == null) return;
    _prefs!.setString('namaToko', state.namaToko);
    _prefs!.setString('alamat', state.alamat);
    _prefs!.setString('telepon', state.telepon);
    _prefs!.setString('pesanFooter', state.pesanFooter);
    _prefs!.setString('ukuranKertas', state.ukuranKertas);
    _prefs!.setBool('tampilkanNamaKasir', state.tampilkanNamaKasir);
  }
}
