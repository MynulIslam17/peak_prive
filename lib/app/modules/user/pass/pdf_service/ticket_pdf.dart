import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class PdfHelper {
  static Future<pw.ThemeData?> _theme() async {
    try {
      final regular = await rootBundle.load('assets/fonts/pdf/Roboto-Regular.ttf');
      final bold = await rootBundle.load('assets/fonts/pdf/Roboto-Bold.ttf');
      return pw.ThemeData.withFont(base: pw.Font.ttf(regular), bold: pw.Font.ttf(bold));
    } catch (_) {
      return null;
    }
  }

  /// Builds the ticket PDF, saves it in the app's documents folder and opens
  /// it in the system viewer (from where the user can save/share it).
  ///
  /// Returns the saved file path. Throws if the file could not be written.
  static Future<String> generateTicket({
    required String title,
    required String date,
    required String time,
    required String person,
    required String ticketId,
    required String? imageUrl,
    String? total,
  }) async {
    // Built-in Helvetica has no € sign; Roboto (bundled for PDFs) does.
    final theme = await _theme();
    final pdf = pw.Document(theme: theme);
    if (theme == null && total != null) total = total.replaceAll('€', 'EUR ');
    Uint8List? imageBytes;

    // No storage permission needed: writing to the public Download folder
    // fails silently on Android 11+ (scoped storage), so the ticket is saved
    // in app storage and opened in the system viewer instead.

    // Optional cover image.
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          imageBytes = response.bodyBytes;
        }
      } catch (e) {
        // Image is optional; build the ticket without it.
      }
    }

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
                          if (time.isNotEmpty && time != "__")
                            _pdfInfoRow("Time", time),
                          _pdfInfoRow("Person", person),
                          if (total != null && total.isNotEmpty)
                            _pdfInfoRow("Total paid", total),
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

    // Save & open
    final dir = await getApplicationDocumentsDirectory();
    final safeId = ticketId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final path = "${dir.path}/Ticket_$safeId.pdf";
    await File(path).writeAsBytes(await pdf.save());
    await OpenFile.open(path);
    return path;
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