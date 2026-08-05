import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database/app_database.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  // Menginisialisasi dan mengembalikan instance dari database kita
  return AppDatabase();
}
