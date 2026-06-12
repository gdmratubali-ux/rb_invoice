import 'package:flutter/material.dart';
// Menghubungkan halaman utama dengan mesin database
import 'package:rb_invoice/database/db_helper.dart';
// Menghubungkan halaman utama dengan halaman riwayat
import 'package:rb_invoice/history_screen.dart';

void main() {
  runApp(const RBInvoiceApp());
}

class RBInvoiceApp extends StatelessWidget {
  const RBInvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RB Invoice',
      // STEP 1 — SET THEME GLOBAL PREMIUM (WHITE + GOLD)
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFFD4AF37), // GOLD ACCENT

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD4AF37),
          foregroundColor: Colors.black,
          elevation: 0,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFD4AF37),
          foregroundColor: Colors.black,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),

        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> items = [];
  int total = 0;

  List<Map<String, dynamic>> productList = [];
  TextEditingController searchC = TextEditingController();
  List<Map<String, dynamic>> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await DBHelper.db;
    return await db.query('products');
  }

  void loadProducts() async {
    final data = await getProducts();
    setState(() {
      productList = data;
      filteredProducts = data;
    });
  }

  Future<void> addProduct(String name, int price) async {
    final db = await DBHelper.db;
    await db.insert('products', {
      'name': name,
      'price': price,
    });
    loadProducts();
  }

  void showAddProduct() {
    TextEditingController nameC = TextEditingController();
    TextEditingController priceC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Produk Baru"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: "Nama Produk"),
              ),
              TextField(
                controller: priceC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Harga"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                addProduct(nameC.text, int.parse(priceC.text));
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  void searchProduct(String query) {
    setState(() {
      filteredProducts = productList
          .where((item) =>
              item['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void hitungTotal() {
    total = 0;
    for (var item in items) {
      total += item['total'];
    }
    setState(() {});
  }

  void tambahItem() {
    TextEditingController namaC = TextEditingController();
    TextEditingController qtyC = TextEditingController();
    TextEditingController hargaC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Item Manual"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaC,
                decoration: const InputDecoration(labelText: "Nama Produk"),
              ),
              TextField(
                controller: qtyC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Qty"),
              ),
              TextField(
                controller: hargaC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Harga"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                int qty = int.parse(qtyC.text);
                int harga = int.parse(hargaC.text);
                setState(() {
                  items.add({
                    "nama": namaC.text,
                    "qty": qty,
                    "harga": harga,
                    "total": qty * harga,
                  });
                  hitungTotal();
                });
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<int> saveInvoice(String customer, int total) async {
    final db = await DBHelper.db;
    String invoiceNumber = "RB-${DateTime.now().millisecondsSinceEpoch}";
    return await db.insert('invoices', {
      'invoice_number': invoiceNumber,
      'customer_name': customer,
      'total': total,
    });
  }

  Future<void> saveInvoiceItems(int invoiceId) async {
    final db = await DBHelper.db;
    for (var item in items) {
      await db.insert('invoice_items', {
        'invoice_id': invoiceId,
        'product_name': item['nama'],
        'qty': item['qty'],
        'price': item['harga'],
        'total': item['total'],
      });
    }
  }

  void finalSaveInvoice() async {
    if (items.isEmpty) return;
    TextEditingController customerC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Simpan"),
          content: TextField(
            controller: customerC,
            decoration: const InputDecoration(labelText: "Nama Pembeli / Customer"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                int invoiceId = await saveInvoice(customerC.text, total);
                await saveInvoiceItems(invoiceId);
                setState(() {
                  items.clear();
                  total = 0;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invoice berhasil disimpan!")),
                );
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RB Invoice", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // TOMBOL TAMBAH DATA PRODUK UTAMA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: showAddProduct,
                child: const Text(
                  "+ Tambah Produk ke Database",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // STEP 3 — UPDATE DESAIN KOTAK PENCARIAN (SEARCH BOX ACCENT)
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchC,
              onChanged: searchProduct,
              decoration: InputDecoration(
                hintText: "Cari produk...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
            ),
          ),

          // HASIL DAFTAR PENCARIAN PRODUK
          SizedBox(
            height: 130,
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final item = filteredProducts[index];
                return ListTile(
                  title: Text(item['name'] ?? ''),
                  subtitle: Text("Rp ${item['price'] ?? 0}"),
                  trailing: const Icon(Icons.add_shopping_cart, color: Color(0xFFD4AF37), size: 20),
                  onTap: () {
                    setState(() {
                      items.add({
                        "nama": item['name'] ?? '',
                        "qty": 1,
                        "harga": item['price'] ?? 0,
                        "total": item['price'] ?? 0,
                      });
                      hitungTotal();
                    });
                  },
                );
              },
            ),
          ),

          const Divider(thickness: 1.5, color: Color(0xFFD4AF37)),

          // STEP 2 — UPDATE DAFTAR ITEM DI NOTA (POS CARD STYLE)
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: ListTile(
                    title: Text(
                      item['nama'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${item['qty']} x Rp ${item['harga']}"),
                    trailing: Text(
                      "Rp ${item['total']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // STEP 5 — KOTAK TOTAL BELANJA MODERN STYLE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TOTAL TRANSAKSI:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Text(
                  "Rp $total",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // TOMBOL UTAMA SIMPAN TRANSAKSI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: finalSaveInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "SIMPAN INVOICE",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ),

          // TOMBOL NAVIGASI KE RIWAYAT NOTA
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Lihat Riwayat Nota / Invoice",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      // STEP 4 — FLOATING BUTTON OTOMATIS IKUT DESIGN THEME GLOBAL
      floatingActionButton: FloatingActionButton(
        onPressed: tambahItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
