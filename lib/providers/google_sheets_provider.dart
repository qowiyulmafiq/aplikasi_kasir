import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/google_sheets_service.dart';
import 'database_provider.dart';

class GoogleSheetsSyncState {
  final String webAppUrl;
  final bool isSyncing;
  final String? lastSyncTime;
  final String? lastError;
  final String? lastMessage;

  GoogleSheetsSyncState({
    this.webAppUrl = '',
    this.isSyncing = false,
    this.lastSyncTime,
    this.lastError,
    this.lastMessage,
  });

  GoogleSheetsSyncState copyWith({
    String? webAppUrl,
    bool? isSyncing,
    String? lastSyncTime,
    String? lastError,
    String? lastMessage,
  }) {
    return GoogleSheetsSyncState(
      webAppUrl: webAppUrl ?? this.webAppUrl,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastError: lastError,
      lastMessage: lastMessage,
    );
  }
}

class GoogleSheetsSyncNotifier extends StateNotifier<GoogleSheetsSyncState> {
  final Ref ref;
  SharedPreferences? _prefs;

  GoogleSheetsSyncNotifier(this.ref) : super(GoogleSheetsSyncState()) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs != null) {
      state = state.copyWith(
        webAppUrl: _prefs!.getString('google_sheets_web_app_url') ?? '',
        lastSyncTime: _prefs!.getString('google_sheets_last_sync_time'),
      );
    }
  }

  Future<void> saveWebAppUrl(String url) async {
    final cleanUrl = url.trim();
    state = state.copyWith(webAppUrl: cleanUrl);
    if (_prefs != null) {
      await _prefs!.setString('google_sheets_web_app_url', cleanUrl);
    }
  }

  Future<GoogleSheetsSyncResult> syncNow() async {
    if (state.webAppUrl.isEmpty) {
      const msg = 'URL Web App Google Sheets belum diatur.';
      state = state.copyWith(lastError: msg);
      return GoogleSheetsSyncResult(success: false, message: msg);
    }

    state = state.copyWith(isSyncing: true, lastError: null, lastMessage: null);

    final db = ref.read(appDatabaseProvider);
    final result = await GoogleSheetsService.performFullSync(
      webAppUrl: state.webAppUrl,
      db: db,
    );

    final nowStr = DateTime.now().toString().substring(0, 16);

    if (result.success) {
      if (_prefs != null) {
        await _prefs!.setString('google_sheets_last_sync_time', nowStr);
      }
      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: nowStr,
        lastMessage: result.message,
      );
    } else {
      state = state.copyWith(
        isSyncing: false,
        lastError: result.message,
      );
    }

    return result;
  }
}

final googleSheetsSyncProvider =
    StateNotifierProvider<GoogleSheetsSyncNotifier, GoogleSheetsSyncState>((ref) {
  return GoogleSheetsSyncNotifier(ref);
});
