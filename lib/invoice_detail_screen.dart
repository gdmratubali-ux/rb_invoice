import 'package:flutter/material.dart';
import 'database/db_helper.dart';
// Menghubungkan halaman detail dengan layanan printer bluetooth
import 'services/printer_service.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Map invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {

  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void loadItems() async {
    final db = await DBHelper.db;

    final data = await db.query(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [widget.invoice['id']],
    );

    setState(() {
      items = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    final inv = widget.invoice;

    return Scaffold(
      appBar: AppBar(
        title: Text(inv['invoice_number']),
        backgroundColor: Colors.amber,
      ),

      body: Column(
        children: [

          ListTile(
            title: Text("Pelanggan: ${inv['customer_name']}"),
            subtitle: Text(
              "TOTAL NOTA: Rp ${inv['total']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),

          const Divider(thickness: 2),

          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {

                final item = items[i];

                return ListTile(
                  title: Text(item['product_name']),
                  subtitle: Text("${item['qty']} x Rp ${item['price']}"),
                  trailing: Text("Rp ${item['total']}"),
                );
              },
            ),
          ),

          // STEP 4 — TOMBOL "PRINT ULANG" DI BAGIAN BAWAH KODE
          Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await PrinterService.printInvoice(
                    invoiceNumber: inv['invoice_number'],
                    customerName: inv['customer_name'],
                    items: items.map((e) {
                      return {
                        "name": e['product_name'],
                        "qty": e['qty'],
                        "price": e['price'],
                        "total": e['total'],
                      };
                    }).toList(),
                    total: inv['total'],
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700], // Warna biru pro khusus cetak
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.print, color: Colors.white),
                label: const Text(
                  "Print Ulang Nota (Bluetooth)",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
