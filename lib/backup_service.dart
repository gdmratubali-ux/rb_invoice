import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart'; // Impor tambahan agar fungsi getDatabasesPath() aktif
import '../database/db_helper.dart';

class BackupService {

  static Future<File> exportDB() async {
    // Mencari lokasi file database utama
    final path = await DBHelper.getDbPath();
    final dbFile = File(path);

    // Menentukan lokasi file cadangan/backup
    final backupPath = join(await getDatabasesPath(), 'backup_rb_invoice.db');

    // Menyalin file database utama menjadi file cadangan
    return dbFile.copy(backupPath);
  }
}
