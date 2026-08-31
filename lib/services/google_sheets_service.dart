import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import '../data/database/app_database.dart';

class GoogleSheetsSyncResult {
  final bool success;
  final String message;
  final int pulledCount;
  final int pushedCount;

  GoogleSheetsSyncResult({
    required this.success,
    required this.message,
    this.pulledCount = 0,
    this.pushedCount = 0,
  });
}

class GoogleSheetsService {
  static const String appsScriptTemplate = '''
function doGet(e) {
  try {
    var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    var data = sheet.getDataRange().getValues();
    var result = [];
    
    if (data.length > 1) {
      var headers = data[0].map(function(h) { 
        var s = String(h).toLowerCase().trim();
        if (s === "id") return "id";
        if (s === "stok minimal") return "stokminimal";
        if (s === "kelola stok") return "kelolastok";
        return s;
      });
      for (var i = 1; i < data.length; i++) {
        var row = data[i];
        if (!row[0] && !row[1]) continue;
        var item = {};
        for (var j = 0; j < headers.length; j++) {
          item[headers[j]] = row[j];
        }
        result.push(item);
      }
    }
    
    return ContentService.createTextOutput(JSON.stringify({ status: "success", data: result }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (err) {
    return ContentService.createTextOutput(JSON.stringify({ status: "error", message: err.toString() }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

function doPost(e) {
  try {
    var postData = (e && e.postData && e.postData.contents) ? e.postData.contents : '{}';
    var contents = JSON.parse(postData);
    var items = contents.items || [];
    var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    var data = sheet.getDataRange().getValues();
    
    if (data.length === 0 || data[0].length === 0 || !data[0][0]) {
      sheet.appendRow(["ID", "Nama", "Kategori", "Harga", "Stok", "Stok Minimal", "Kelola Stok"]);
      data = sheet.getDataRange().getValues();
    }
    
    var existingIds = {};
    var existingNames = {};
    for (var i = 1; i < data.length; i++) {
      var rowId = String(data[i][0]).trim();
      var rowNama = String(data[i][1]).toLowerCase().trim();
      if (rowId && rowId !== '0') existingIds[rowId] = i + 1;
      if (rowNama) existingNames[rowNama] = i + 1;
    }
    
    for (var k = 0; k < items.length; k++) {
      var item = items[k];
      var itemId = String(item.id || '').trim();
      var namaKey = String(item.nama || '').toLowerCase().trim();
      if (!namaKey && (!itemId || itemId === '0')) continue;
      
      var rowData = [
        item.id || '',
        item.nama || '',
        item.kategori || 'Umum',
        item.harga || 0,
        item.stok || 0,
        item.stokMinimal !== undefined ? item.stokMinimal : 5,
        item.kelolaStok !== undefined ? item.kelolaStok : true
      ];
      
      var targetRow = 0;
      if (itemId && itemId !== '0' && existingIds[itemId]) {
        targetRow = existingIds[itemId];
      } else if (namaKey && existingNames[namaKey]) {
        targetRow = existingNames[namaKey];
      }
      
      if (targetRow > 0) {
        sheet.getRange(targetRow, 1, 1, rowData.length).setValues([rowData]);
      } else {
        sheet.appendRow(rowData);
      }
    }
    
    return ContentService.createTextOutput(JSON.stringify({ status: "success", message: "Synced " + items.length + " items" }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (err) {
    return ContentService.createTextOutput(JSON.stringify({ status: "error", message: err.toString() }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
''';

  static int _parseNumber(dynamic input, {int defaultValue = 0}) {
    if (input == null) return defaultValue;
    final str = input.toString().replaceAll(RegExp(r'[^\d]'), '');
    if (str.isEmpty) return defaultValue;
    return int.tryParse(str) ?? defaultValue;
  }

  static Future<http.Response> _fetchWithRedirects(
    String url, {
    String method = 'GET',
    Map<String, String>? headers,
    String? body,
  }) async {
    final client = http.Client();
    try {
      final uri = Uri.parse(url);
      final request = http.Request(method, uri);
      if (headers != null) request.headers.addAll(headers);
      if (body != null) request.body = body;
      request.followRedirects = false;

      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 15));
      if (streamedResponse.statusCode == 302 ||
          streamedResponse.statusCode == 301 ||
          streamedResponse.statusCode == 307 ||
          streamedResponse.statusCode == 308) {
        final redirectUrl = streamedResponse.headers['location'];
        if (redirectUrl != null) {
          final redirectedResponse = await client.get(Uri.parse(redirectUrl)).timeout(const Duration(seconds: 15));
          return redirectedResponse;
        }
      }
      return await http.Response.fromStream(streamedResponse);
    } finally {
      client.close();
    }
  }

  /// Performs PULL first (fetching remote sheet data and updating local database),
  /// then PUSH second (sending remaining unsynced local items to Web App).
  static Future<GoogleSheetsSyncResult> performFullSync({
    required String webAppUrl,
    required AppDatabase db,
  }) async {
    final cleanUrl = webAppUrl.trim();
    if (cleanUrl.isEmpty || !cleanUrl.startsWith('http')) {
      return GoogleSheetsSyncResult(
        success: false,
        message: 'URL Google Apps Script Web App tidak valid.',
      );
    }

    try {
      int pushedCount = 0;
      int pulledCount = 0;

      // 1. PULL FIRST: Fetch all items from Google Sheet & update local DB
      final getResponse = await _fetchWithRedirects(cleanUrl, method: 'GET');
      if (getResponse.statusCode == 200) {
        final resJson = jsonDecode(getResponse.body);
        if (resJson['status'] == 'success' && resJson['data'] is List) {
          final List rawList = resJson['data'];
          final List<BarangCompanion> remoteCompanions = [];

          for (final raw in rawList) {
            if (raw is Map) {
              final nama = (raw['nama'] ?? raw['Nama'] ?? '').toString().trim();
              if (nama.isEmpty) continue; // Skip blank/empty rows

              final rawId = raw['id'] ?? raw['ID'];
              final intId = _parseNumber(rawId, defaultValue: 0);

              final kategori = (raw['kategori'] ?? raw['Kategori'] ?? 'Umum').toString().trim();
              final harga = _parseNumber(raw['harga'] ?? raw['Harga'], defaultValue: 0);
              final stok = _parseNumber(raw['stok'] ?? raw['Stok'], defaultValue: 0);
              final stokMinimal = _parseNumber(
                raw['stokminimal'] ?? raw['stokMinimal'] ?? raw['Stok Minimal'],
                defaultValue: 5,
              );
              final kelolaStokVal = raw['kelolastok'] ?? raw['kelolaStok'] ?? raw['Kelola Stok'];
              final bool kelolaStok = kelolaStokVal is bool 
                  ? kelolaStokVal 
                  : (kelolaStokVal.toString().toLowerCase() != 'false');

              remoteCompanions.add(BarangCompanion.insert(
                id: intId > 0 ? Value(intId) : const Value.absent(),
                nama: nama,
                kategori: kategori,
                harga: harga,
                stok: Value(stok),
                stokMinimal: Value(stokMinimal),
                kelolaStok: Value(kelolaStok),
                isSynced: const Value(true),
              ));
            }
          }

          if (remoteCompanions.isNotEmpty) {
            await db.upsertBarangFromSync(remoteCompanions);
            pulledCount = remoteCompanions.length;
          }
        }
      }

      // 2. PUSH SECOND: Fetch remaining unsynced local items (e.g. added locally while offline)
      var itemsToPush = await db.getUnsyncedBarang();
      // If local DB has items but Google Sheet is totally empty (pulledCount == 0), fallback to pushing all local items
      if (itemsToPush.isEmpty && pulledCount == 0) {
        itemsToPush = await (db.select(db.barang)).get();
      }

      if (itemsToPush.isNotEmpty) {
        final payload = {
          'action': 'push',
          'items': itemsToPush.map((b) => {
            'id': b.id,
            'nama': b.nama,
            'kategori': b.kategori,
            'harga': b.harga,
            'stok': b.stok,
            'stokMinimal': b.stokMinimal,
            'kelolaStok': b.kelolaStok,
          }).toList(),
        };

        final response = await _fetchWithRedirects(
          cleanUrl,
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          final resJson = jsonDecode(response.body);
          if (resJson['status'] == 'success') {
            await db.markBarangAsSynced(itemsToPush.map((e) => e.id).toList());
            pushedCount = itemsToPush.length;
          }
        }
      }

      return GoogleSheetsSyncResult(
        success: true,
        message: 'Sinkronisasi berhasil! ($pulledCount ditarik/diperbarui, $pushedCount barang terkirim)',
        pulledCount: pulledCount,
        pushedCount: pushedCount,
      );
    } catch (e) {
      return GoogleSheetsSyncResult(
        success: false,
        message: 'Gagal melakukan sinkronisasi: $e',
      );
    }
  }


}

