import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Mengambil foto dari galeri/kamera, mengkompresnya, lalu menyimpannya secara permanen.
  /// Mengembalikan path lokal yang aman untuk disimpan ke database.
  static Future<String?> pickAndSaveImage({ImageSource source = ImageSource.gallery}) async {
    try {
      // 1. Ambil foto dari sumber (otomatis dikompresi)
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (pickedFile == null) return null;

      // 2. Dapatkan folder internal permanen milik aplikasi
      final Directory appDir = await getApplicationDocumentsDirectory();

      // 3. Buat nama file baru yang unik (misal: product_1722849200.jpg)
      final String fileName = 'product_${DateTime.now().millisecondsSinceEpoch}${p.extension(pickedFile.path)}';
      final String permanentPath = p.join(appDir.path, fileName);

      // 4. SALIN (COPY) file ke folder permanen
      final File savedImage = await File(pickedFile.path).copy(permanentPath);

      // 5. Kembalikan path permanen
      return savedImage.path;
    } catch (e) {
      // Jika terjadi error, kembalikan null
      print('Error picking image: $e');
      return null;
    }
  }
}
