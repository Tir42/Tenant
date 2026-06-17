import 'dart:typed_data';
import 'package:flutter/material.dart' show debugPrint;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tenantsnap/features/inspection/models/inspection_model.dart';
import 'package:tenantsnap/core/utils/image_loader/image_byte_loader.dart';

// Helper to build a metadata detail row in PDF
pw.Widget _buildPdfMetadataRow(String key, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '$key: ',
          style: pw.TextStyle(
            color: PdfColor.fromInt(0xFF7F8C8D),
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              color: PdfColor.fromInt(0xFF2C3E50),
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
          ),
        ),
      ],
    ),
  );
}

// Helper to build status badges in PDF without emoji font issues
pw.Widget _buildPdfStatusBadge(RoomItemStatus status) {
  PdfColor bgColor;
  String text;
  if (status == RoomItemStatus.happy) {
    bgColor = PdfColor.fromInt(0xFF2ECC71); // Green
    text = 'GOOD';
  } else if (status == RoomItemStatus.sad) {
    bgColor = PdfColor.fromInt(0xFFE74C3C); // Red
    text = 'DEFECT';
  } else {
    bgColor = PdfColor.fromInt(0xFF95A5A6); // Grey
    text = 'N/A';
  }

  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: pw.BoxDecoration(
      color: bgColor,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
    ),
    width: 44,
    alignment: pw.Alignment.center,
    child: pw.Text(
      text,
      style: pw.TextStyle(
        color: PdfColor.fromInt(0xFFFFFFFF),
        fontSize: 7,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );
}

Future<Uint8List> generateInspectionReportPdf({
  required String idCode,
  required String tenantName,
  required String landlordName,
  required String propertyAddress,
  required String inspectionDate,
  required List<RoomInspection> rooms,
  String? tenantPhone,
  String? landlordPhone,
  bool showPhone = true,
}) async {
  final pdf = pw.Document();

  // Asynchronously fetch all photo bytes beforehand
  final Map<String, Uint8List> loadedImages = {};
  for (var room in rooms) {
    for (var item in room.checklist) {
      for (var photoPath in item.photos) {
        if (photoPath.isNotEmpty && !loadedImages.containsKey(photoPath)) {
          final bytes = await fetchImageBytes(photoPath);
          if (bytes.isNotEmpty) {
            loadedImages[photoPath] = bytes;
          }
        }
      }
    }
  }

  // Create layout page
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (pw.Context context) {
        return [
          // Header title
          pw.Center(
            child: pw.Text(
              'TenantSnap Inspection Report',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF2C3E50),
              ),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Container(
            height: 2,
            color: PdfColor.fromInt(0xFF007BFF),
          ),
          pw.SizedBox(height: 14),

          // Metadata Table
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF8FAFC),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Report ID: ${idCode.isNotEmpty ? idCode : "TS-402-URBL"}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text('Date: $inspectionDate', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Divider(color: PdfColor.fromInt(0xFFE2E8F0), thickness: 0.5),
                pw.SizedBox(height: 6),
                _buildPdfMetadataRow('Tenant', showPhone && tenantPhone != null && tenantPhone.isNotEmpty ? '$tenantName ($tenantPhone)' : tenantName),
                _buildPdfMetadataRow('Landlord', showPhone && landlordPhone != null && landlordPhone.isNotEmpty ? '$landlordName ($landlordPhone)' : landlordName),
                _buildPdfMetadataRow('Property Address', propertyAddress),
              ],
            ),
          ),
          pw.SizedBox(height: 18),

          pw.Text(
            'SPATIAL INSPECTION DETAILS',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF2C3E50),
            ),
          ),
          pw.SizedBox(height: 8),

          // Rooms checklist loop
          ...rooms.map((room) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFFFFFFF),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Room title & progress
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        room.name,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF2C3E50),
                        ),
                      ),
                      pw.Text(
                        '${room.progress.toStringAsFixed(0)}% Completed',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF007BFF),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Divider(color: PdfColor.fromInt(0xFFEEF2F6), thickness: 0.5),
                  pw.SizedBox(height: 6),

                  // Room Comment if exists
                  if (room.comment.isNotEmpty) ...[
                    pw.Text(
                      'Comment: ${room.comment}',
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColor.fromInt(0xFF7F8C8D),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                  ],

                  // Checklist items
                  ...room.checklist.map((item) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              // Status Badge
                              _buildPdfStatusBadge(item.status),
                              pw.SizedBox(width: 8),
                              // Details (Name + Comment)
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      item.name,
                                      style: pw.TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromInt(0xFF2C3E50),
                                      ),
                                    ),
                                    pw.SizedBox(height: 2),
                                    pw.Text(
                                      item.comment.isNotEmpty
                                          ? item.comment
                                          : (item.status == RoomItemStatus.happy
                                              ? 'Condition verified; fully functional and clean.'
                                              : (item.status == RoomItemStatus.sad
                                                  ? 'Defect noted; repair required.'
                                                  : 'Standard condition; no major issues observed.')),
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        color: PdfColor.fromInt(0xFF7F8C8D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Display photos if any
                          if (item.photos.isNotEmpty) ...[
                            pw.SizedBox(height: 6),
                            pw.Row(
                              children: item.photos.map((photoPath) {
                                final bytes = loadedImages[photoPath];
                                if (bytes != null && bytes.isNotEmpty) {
                                  try {
                                    final pdfImage = pw.MemoryImage(bytes);
                                    return pw.Container(
                                      width: 60,
                                      height: 45,
                                      margin: const pw.EdgeInsets.only(right: 6),
                                      decoration: pw.BoxDecoration(
                                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                                        border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.5),
                                      ),
                                      child: pw.ClipRRect(
                                        horizontalRadius: 4,
                                        verticalRadius: 4,
                                        child: pw.Image(pdfImage, fit: pw.BoxFit.cover),
                                      ),
                                    );
                                  } catch (e) {
                                    debugPrint("Error creating PDF MemoryImage: $e");
                                  }
                                }
                                // Fallback outline if loading failed
                                return pw.Container(
                                  width: 60,
                                  height: 45,
                                  margin: const pw.EdgeInsets.only(right: 6),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColor.fromInt(0xFFEEF2F6),
                                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                                    border: pw.Border.all(color: PdfColor.fromInt(0xFFBDC3C7), width: 0.5),
                                  ),
                                  child: pw.Center(
                                    child: pw.Text('[IMAGE]', style: const pw.TextStyle(fontSize: 6)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }).toList(),
        ];
      },
    ),
  );

  return pdf.save();
}
