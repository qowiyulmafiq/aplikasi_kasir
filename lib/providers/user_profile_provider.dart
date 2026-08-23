import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_profile_provider.g.dart';

class UserProfile {
  final String namaKasir;
  final String peran;
  final String namaShift;
  final String? avatarPath;

  UserProfile({
    this.namaKasir = 'Budi (Kasir)',
    this.peran = 'Admin / Kasir Utama',
    this.namaShift = 'Shift Pagi',
    this.avatarPath,
  });

  UserProfile copyWith({
    String? namaKasir,
    String? peran,
    String? namaShift,
    String? avatarPath,
  }) {
    return UserProfile(
      namaKasir: namaKasir ?? this.namaKasir,
      peran: peran ?? this.peran,
      namaShift: namaShift ?? this.namaShift,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}

@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  SharedPreferences? _prefs;

  @override
  UserProfile build() {
    _initPrefs();
    return UserProfile();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs != null) {
      state = UserProfile(
        namaKasir: _prefs!.getString('profile_namaKasir') ?? state.namaKasir,
        peran: _prefs!.getString('profile_peran') ?? state.peran,
        namaShift: _prefs!.getString('profile_namaShift') ?? state.namaShift,
        avatarPath: _prefs!.getString('profile_avatarPath'),
      );
    }
  }

  void updateProfile({
    String? namaKasir,
    String? peran,
    String? namaShift,
    String? avatarPath,
  }) {
    state = state.copyWith(
      namaKasir: namaKasir,
      peran: peran,
      namaShift: namaShift,
      avatarPath: avatarPath,
    );
    _saveToPrefs();
  }

  void _saveToPrefs() {
    if (_prefs == null) return;
    _prefs!.setString('profile_namaKasir', state.namaKasir);
    _prefs!.setString('profile_peran', state.peran);
    _prefs!.setString('profile_namaShift', state.namaShift);
    if (state.avatarPath != null) {
      _prefs!.setString('profile_avatarPath', state.avatarPath!);
    } else {
      _prefs!.remove('profile_avatarPath');
    }
  }
}
