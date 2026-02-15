// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import '../core/utils/helpers.dart';
// import '../data/models/client_model.dart';
// import '../data/models/reading_model.dart';
//
// class InvoiceWidget {
//   static Future<void> printInvoice({
//     required ClientModel client,
//     required ReadingModel reading,
//     required BuildContext context,
//   }) async {
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               // Header
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text('فاتورة استهلاك المياه',
//                           style: pw.TextStyle(
//                               fontSize: 24, fontWeight: pw.FontWeight.bold)),
//                       pw.Text('نظام إدارة مشروع المياه',
//                           style: pw.TextStyle(fontSize: 14)),
//                     ],
//                   ),
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.end,
//                     children: [
//                       pw.Text('رقم الفاتورة: ${reading.id}',
//                           style: pw.TextStyle(fontSize: 12)),
//                       pw.Text('التاريخ: ${Helpers.formatDate(DateTime.now())}',
//                           style: pw.TextStyle(fontSize: 12)),
//                     ],
//                   ),
//                 ],
//               ),
//               pw.SizedBox(height: 20),
//
//               // Client Information
//               pw.Container(
//                 padding: const pw.EdgeInsets.all(10),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(width: 1),
//                   borderRadius: pw.BorderRadius.circular(5),
//                 ),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text('معلومات العميل',
//                         style: pw.TextStyle(
//                             fontSize: 16, fontWeight: pw.FontWeight.bold)),
//                     pw.SizedBox(height: 10),
//                     _buildInvoiceRow('اسم العميل:', client.name),
//                     _buildInvoiceRow('رقم الهاتف:', client.phone),
//                     _buildInvoiceRow('العنوان:', client.address),
//                     _buildInvoiceRow('رقم العداد:', client.meterNumber),
//                   ],
//                 ),
//               ),
//               pw.SizedBox(height: 20),
//
//               // Reading Details
//               pw.Container(
//                 padding: const pw.EdgeInsets.all(10),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(width: 1),
//                   borderRadius: pw.BorderRadius.circular(5),
//                 ),
//                 child: pw.Column(
//                   children: [
//                     pw.Text('تفاصيل الاستهلاك',
//                         style: pw.TextStyle(
//                             fontSize: 16, fontWeight: pw.FontWeight.bold)),
//                     pw.SizedBox(height: 10),
//                     pw.Table(
//                       border: pw.TableBorder.all(),
//                       children: [
//                         pw.TableRow(
//                           children: [
//                             _buildTableCell('البيان', true),
//                             _buildTableCell('القيمة', true),
//                           ],
//                         ),
//                         pw.TableRow(
//                           children: [
//                             _buildTableCell('القراءة السابقة'),
//                             _buildTableCell('${reading.previousReading} م³'),
//                           ],
//                         ),
//                         pw.TableRow(
//                           children: [
//                             _buildTableCell('القراءة الحالية'),
//                             _buildTableCell('${reading.currentReading} م³'),
//                           ],
//                         ),
//                         pw.TableRow(
//                           children: [
//                             _buildTableCell('كمية الاستهلاك'),
//                             _buildTableCell('${reading.consumption} م³'),
//                           ],
//                         ),
//                         pw.TableRow(
//                           children: [
//                             _buildTableCell('سعر المتر المكعب'),
//                             _buildTableCell(
//                                 '${reading.ratePerUnit.toStringAsFixed(2)} د.ع'),
//                           ],
//                         ),
//                         pw.TableRow(
//                           children: [
//                             _buildTableCell('إجمالي الفاتورة', true),
//                             _buildTableCell(
//                                 '${reading.totalAmount!.toStringAsFixed(2)} د.ع',
//                                 true),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               pw.SizedBox(height: 20),
//
//               // Footer
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Column(
//                     children: [
//                       pw.Text('توقيع العميل',
//                           style: pw.TextStyle(fontSize: 12)),
//                       pw.SizedBox(height: 50),
//                       pw.Container(
//                         width: 150,
//                         height: 1,
//                         color: PdfColors.black,
//                       ),
//                     ],
//                   ),
//                   pw.Column(
//                     children: [
//                       pw.Text('توقيع المسؤول',
//                           style: pw.TextStyle(fontSize: 12)),
//                       pw.SizedBox(height: 50),
//                       pw.Container(
//                         width: 150,
//                         height: 1,
//                         color: PdfColors.black,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               pw.SizedBox(height: 20),
//               pw.Center(
//                 child: pw.Text(
//                   'شكراً لتعاملكم معنا',
//                   style: pw.TextStyle(
//                     fontSize: 14,
//                     fontStyle: pw.FontStyle.italic,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//
//     // await Printing.layoutPdf(
//     //   onLayout: (PdfPageFormat format) async => pdf.save(),
//     // );
//   }
//
//   static pw.Widget _buildInvoiceRow(String label, String value) {
//     return pw.Row(
//       children: [
//         pw.Text(label,
//             style:  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//         pw.SizedBox(width: 10),
//         pw.Text(value),
//       ],
//     );
//   }
//
//   static pw.Widget _buildTableCell(String text, [bool isHeader = false]) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
//         ),
//       ),
//     );
//   }
// }