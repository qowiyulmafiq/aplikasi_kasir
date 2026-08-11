import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'system_settings_provider.g.dart';

class SystemSettings {
  final String themeMode; // 'system', 'light', 'dark'
  final String posLayoutMode; // 'grid', 'list'
  final bool showItemImage;

  SystemSettings({
    this.themeMode = 'system',
    this.posLayoutMode = 'grid',
    this.showItemImage = true,
  });

  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  SystemSettings copyWith({
    String? themeMode,
    String? posLayoutMode,
    bool? showItemImage,
  }) {
    return SystemSettings(
      themeMode: themeMode ?? this.themeMode,
      posLayoutMode: posLayoutMode ?? this.posLayoutMode,
      showItemImage: showItemImage ?? this.showItemImage,
    );
  }
}

@riverpod
class SystemSettingsNotifier extends _$SystemSettingsNotifier {
  SharedPreferences? _prefs;

  @override
  SystemSettings build() {
    _initPrefs();
    return SystemSettings();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs != null) {
      state = SystemSettings(
        themeMode: _prefs!.getString('themeMode') ?? state.themeMode,
        posLayoutMode: _prefs!.getString('posLayoutMode') ?? state.posLayoutMode,
        showItemImage: _prefs!.getBool('showItemImage') ?? state.showItemImage,
      );
    }
  }

  void updateSettings({
    String? themeMode,
    String? posLayoutMode,
    bool? showItemImage,
  }) {
    state = state.copyWith(
      themeMode: themeMode,
      posLayoutMode: posLayoutMode,
      showItemImage: showItemImage,
    );
    _saveToPrefs();
  }

  void _saveToPrefs() {
    if (_prefs == null) return;
    _prefs!.setString('themeMode', state.themeMode);
    _prefs!.setString('posLayoutMode', state.posLayoutMode);
    _prefs!.setBool('showItemImage', state.showItemImage);
  }
}
