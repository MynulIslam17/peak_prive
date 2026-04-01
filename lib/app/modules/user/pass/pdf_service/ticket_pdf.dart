import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfHelper {
  static Future<void> generateTicket({
    required String title,
    required String date,
    required String time,
    required String person,
    required String ticketId,
    required String? imageUrl,
  }) async {
    final pdf = pw.Document();
    Uint8List? imageBytes;

    // ১. পারমিশন চেক (Android 10+)
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
    }

    // ২. নেটওয়ার্ক ইমেজ লোড করা (যদি থাকে)
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          imageBytes = response.bodyBytes;
        }
      } catch (e) {
        print("Image load error: $e");
      }
    }

    // ৩. PDF ডিজাইন
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Booking Ticket",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),

              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  children: [
                    // ইমেজ সেকশন
                    if (imageBytes != null)
                      pw.Container(
                        height: 150,
                        width: double.infinity,
                        child: pw.Image(pw.MemoryImage(imageBytes), fit: pw.BoxFit.cover),
                      ),

                    pw.Padding(
                      padding: const pw.EdgeInsets.all(15),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 10),
                          pw.Divider(color: PdfColors.grey300),
                          pw.SizedBox(height: 10),
                          _pdfInfoRow("Ticket ID", ticketId),
                          _pdfInfoRow("Date", date),
                          _pdfInfoRow("Person", person),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // ৪. ফাইল সেভ এবং ওপেন করা
    try {
      final Directory? downloadsDir = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();

      final String path = "${downloadsDir!.path}/Ticket_$ticketId.pdf";
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      // ওপেন করা
      await OpenFile.open(path);
    } catch (e) {
      print("Save Error: $e");
    }
  }

  static pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("$label: ", style: pw.TextStyle(color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}