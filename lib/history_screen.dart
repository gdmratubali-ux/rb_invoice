import 'package:flutter/material.dart';
import 'database/db_helper.dart';
// Menghubungkan halaman riwayat dengan halaman detail yang baru dibuat
import 'invoice_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  List<Map<String, dynamic>> invoices = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final db = await DBHelper.db;

    final data = await db.query(
      'invoices',
      orderBy: 'id DESC',
    );

    setState(() {
      invoices = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Invoice"),
        backgroundColor: Colors.amber,
      ),

      body: ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (context, i) {

          final inv = invoices[i];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(inv['invoice_number'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Pelanggan: ${inv['customer_name']}"),
              trailing: Text(
                "Rp ${inv['total']}",
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              // STEP 3 — SEKARANG KALAU DIKLIK AKAN MASUK KE DETAIL BARANG
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvoiceDetailScreen(invoice: inv),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
