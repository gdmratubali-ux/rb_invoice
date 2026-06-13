import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrinterService {

  static Future<void> printInvoice({
    required String invoiceNumber,
    required String customerName,
    required List<Map<String, dynamic>> items,
    required int total,
  }) async {

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    List<int> bytes = [];

    bytes += generator.text(
      "RATU BALI",
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );

    bytes += generator.text(
      "Gudang Daster Makassar",
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.hr();

    bytes += generator.text("No: $invoiceNumber");
    bytes += generator.text("Customer: $customerName");

    bytes += generator.hr();

    for (var item in items) {
      bytes += generator.text(
        "${item['name']}",
      );

      bytes += generator.text(
        "${item['qty']} x ${item['price']} = ${item['total']}",
      );
    }

    bytes += generator.hr();

    bytes += generator.text(
      "TOTAL: $total",
      styles: const PosStyles(bold: true),
    );

    bytes += generator.cut();

    await PrintBluetoothThermal.writeBytes(bytes);
  }
}
