# Aplikasi Kasir (POS) Mobile

Aplikasi Point of Sale (POS) mobile berbasis Flutter dengan pendekatan *offline-first* dan dukungan sinkronisasi cloud Google Sheets 2-arah.

---

## Fitur Utama

- **Point of Sale (POS)**: Transaksi penjualan cepat, filter & pencarian produk, serta kalkulasi kembalian otomatis.
- **Manajemen Inventaris**: Pengelolaan katalog produk, stok minimal, kelola stok, manajemen kategori, serta impor data via file Excel.
- **Sinkronisasi Google Sheets (2-Way Sync)**: Sinkronisasi 2-arah produk (PUSH & PULL) antara database SQLite lokal dan Google Spreadsheet secara gratis tanpa biaya cloud.
- **Riwayat Transaksi**: Pencatatan riwayat transaksi lengkap, rincian produk, dan opsi pembatalan/refund transaksi.
- **Profil & Pengaturan**: Pengelolaan profil toko, preferensi sistem (tema terang/gelap, mode tata letak), serta konfigurasi sinkronisasi cloud.

---

## Teknologi & Arsitektur

- **Framework**: Flutter (SDK `>=3.2.0 <4.0.0`)
- **State Management**: Flutter Riverpod & Riverpod Annotation
- **Database Lokal**: Drift & SQLite3 (Offline-First)
- **Navigasi**: GoRouter
- **Cloud Sync**: Google Apps Script Web App API (JSON over HTTP)

---

## Panduan Setup Sinkronisasi Google Sheets

Fitur sinkronisasi Google Sheets menggunakan integrasi **Google Apps Script Web App** (100% Gratis & tanpa perlu Google Cloud Console).

### 1. Buat Google Sheet & Pasang Apps Script
1. Buka [Google Sheets](https://sheets.new) di browser untuk membuat spreadsheet kosong baru.
2. Di Google Sheet, buka menu **Ekstensi** (*Extensions*) $\rightarrow$ **Apps Script**.
3. Hapus semua kode bawaan, lalu **Salin & Tempel** kode Apps Script berikut:

```javascript
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
```

4. Klik ikon **Simpan** (disket).

### 2. Deploy Web App
1. Klik **Deploy** $\rightarrow$ **New deployment**.
2. Pilih jenis **Web app**.
3. Atur **Execute as**: `Me` dan **Who has access**: `Anyone`.
4. Klik **Deploy** dan izinkan akses (*Authorize access*).
5. Salin **Web App URL** yang dihasilkan.

### 3. Hubungkan di Aplikasi
1. Di aplikasi Kasir, buka **Profil / Pengaturan** $\rightarrow$ **Sistem & Tampilan** $\rightarrow$ **Sinkronisasi Google Sheets**.
2. Tempel URL Web App pada kolom input, lalu tekan **Simpan & Sinkronkan Sekarang**.
3. Di layar **Inventaris**, gunakan ikon hijau **Sync** di AppBar untuk melakukan sinkronisasi cepat 1-klik kapan saja.

---

## Cara Menjalankan Project

1. Install dependensi:
   ```bash
   flutter pub get
   ```

2. Generate kode (Drift & Riverpod):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. Jalankan aplikasi:
   ```bash
   flutter run
   ```
