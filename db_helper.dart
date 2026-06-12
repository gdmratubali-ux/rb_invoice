import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    // Mengambil lokasi penyimpanan database di perangkat Android/iOS
    String path = await getDbPath();
    
    // Membuka database dan membuat tabel jika belum ada
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabel Utama Produk Jualan
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price INTEGER
          )
        ''');

        // Tabel Utama Nota / Invoice
        await db.execute('''
          CREATE TABLE invoices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoice_number TEXT,
            customer_name TEXT,
            total INTEGER
          )
        ''');

        // Tabel Detail Barang yang Dibeli per Invoice
        await db.execute('''
          CREATE TABLE invoice_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoice_id INTEGER,
            product_name TEXT,
            qty INTEGER,
            price INTEGER,
            total INTEGER
          )
        ''');
      },
    );
  }

  // STEP 1 — FUNGSI UNTUK MENDAPATKAN JALUR LOKASI DATABASE UTAMA
  static Future<String> getDbPath() async {
    return join(await getDatabasesPath(), 'rb_invoice.db');
  }
}
