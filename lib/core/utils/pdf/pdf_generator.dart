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
            fontSize: 12.0,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              color: PdfColor.fromInt(0xFF2C3E50),
              fontWeight: pw.FontWeight.bold,
              fontSize: 12.0,
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
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: pw.BoxDecoration(
      color: bgColor,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
    ),
    width: 48,
    alignment: pw.Alignment.center,
    child: pw.Text(
      text,
      style: pw.TextStyle(
        color: PdfColor.fromInt(0xFFFFFFFF),
        fontSize: 9.0,
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

  // Fetch app icon logo bytes
  final logoBytes = await fetchImageBytes('assets/app_icon.png');

  // Create layout page
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      header: (pw.Context context) {
        if (context.pageNumber == 1) {
          return pw.Container();
        }
        return pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 12),
          padding: const pw.EdgeInsets.only(bottom: 4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'TenantSnap Inspection Report',
                style: pw.TextStyle(
                  color: PdfColor.fromInt(0xFF94A3B8),
                  fontSize: 9.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'ID: ${idCode.isNotEmpty ? idCode : "TS-402-URBL"}',
                style: pw.TextStyle(
                  color: PdfColor.fromInt(0xFF94A3B8),
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        );
      },
      footer: (pw.Context context) {
        return pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 12),
          padding: const pw.EdgeInsets.only(top: 4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Confidential Document • Generated via TenantSnap',
                style: pw.TextStyle(
                  color: PdfColor.fromInt(0xFF94A3B8),
                  fontSize: 9.5,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(
                  color: PdfColor.fromInt(0xFF64748B),
                  fontSize: 9.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
      build: (pw.Context context) {
        final List<pw.Widget> content = [];

        // 1. Header with Logo styling
        content.add(
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  if (logoBytes.isNotEmpty) ...[
                    pw.Container(
                      width: 36,
                      height: 36,
                      decoration: const pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.ClipRRect(
                        horizontalRadius: 8,
                        verticalRadius: 8,
                        child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.cover),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                  ] else ...[
                    pw.Container(
                      width: 32,
                      height: 32,
                      decoration: const pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFF007BFF),
                        shape: pw.BoxShape.circle,
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        'TS',
                        style: pw.TextStyle(
                          color: PdfColor.fromInt(0xFFFFFFFF),
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                  ],
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TenantSnap',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF007BFF),
                        ),
                      ),
                      pw.Text(
                        'STREAMLINED PROPERTY INSPECTION',
                        style: pw.TextStyle(
                          fontSize: 9.0,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'INSPECTION REPORT',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(0xFF1E293B),
                      letterSpacing: 1.2,
                    ),
                  ),
                  pw.Text(
                    'CONFIDENTIAL',
                    style: pw.TextStyle(
                      fontSize: 9.0,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(0xFFE74C3C),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        content.add(pw.SizedBox(height: 8));
        content.add(pw.Divider(color: PdfColor.fromInt(0xFFE2E8F0), thickness: 1.0));
        content.add(pw.SizedBox(height: 12));

        // 2. Metadata Card
        content.add(
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
                    pw.Text(
                      'Report ID: ${idCode.isNotEmpty ? idCode : "TS-402-URBL"}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12.5, color: PdfColor.fromInt(0xFF1E293B)),
                    ),
                    pw.Text(
                      'Date: $inspectionDate',
                      style: const pw.TextStyle(fontSize: 12.5, color: PdfColor.fromInt(0xFF1E293B)),
                    ),
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
        );
        content.add(pw.SizedBox(height: 20));

        // 3. Section Title
        content.add(
          pw.Text(
            'SPATIAL INSPECTION DETAILS',
            style: pw.TextStyle(
              fontSize: 15.0,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF1E293B),
              letterSpacing: 1.0,
            ),
          ),
        );
        content.add(pw.SizedBox(height: 10));

        // 4. Rooms and checklist mapping
        for (var room in rooms) {
          // Room Header Card
          content.add(
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 12, bottom: 8),
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF1F5F9),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.5),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    room.name,
                    style: pw.TextStyle(
                      fontSize: 14.0,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(0xFF1E293B),
                    ),
                  ),
                  pw.Text(
                    '${room.progress.toStringAsFixed(0)}% Completed',
                    style: pw.TextStyle(
                      fontSize: 12.5,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(0xFF007BFF),
                    ),
                  ),
                ],
              ),
            ),
          );

          if (room.comment.isNotEmpty) {
            content.add(
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 8, bottom: 8),
                child: pw.Text(
                  'Comment: ${room.comment}',
                  style: pw.TextStyle(
                    fontSize: 11.5,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColor.fromInt(0xFF64748B),
                  ),
                ),
              ),
            );
          }

          // Individual checklist items
          for (var item in room.checklist) {
            content.add(
              pw.Inseparable(
                child: pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFFFFFFF),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildPdfStatusBadge(item.status),
                          pw.SizedBox(width: 10),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  item.name,
                                  style: pw.TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromInt(0xFF1E293B),
                                  ),
                                ),
                                pw.SizedBox(height: 3),
                                pw.Text(
                                  item.comment.isNotEmpty
                                      ? item.comment
                                      : (item.status == RoomItemStatus.happy
                                          ? 'Condition verified; fully functional and clean.'
                                          : (item.status == RoomItemStatus.sad
                                              ? 'Defect noted; repair required.'
                                              : 'Standard condition; no major issues observed.')),
                                  style: pw.TextStyle(
                                    fontSize: 11.5,
                                    color: PdfColor.fromInt(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (item.photos.isNotEmpty) ...[
                        pw.SizedBox(height: 10),
                        pw.Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: item.photos.map((photoPath) {
                            final bytes = loadedImages[photoPath];
                            if (bytes != null && bytes.isNotEmpty) {
                              try {
                                final pdfImage = pw.MemoryImage(bytes);
                                return pw.Container(
                                  width: 230,
                                  height: 172,
                                  decoration: pw.BoxDecoration(
                                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                                    border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0), width: 1.0),
                                  ),
                                  child: pw.ClipRRect(
                                    horizontalRadius: 6,
                                    verticalRadius: 6,
                                    child: pw.Image(pdfImage, fit: pw.BoxFit.cover),
                                  ),
                                );
                              } catch (e) {
                                debugPrint("Error creating PDF MemoryImage: $e");
                              }
                            }
                            return pw.Container(
                              width: 230,
                              height: 172,
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromInt(0xFFF1F5F9),
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                                border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0), width: 1.0),
                              ),
                              child: pw.Center(
                                child: pw.Text('[IMAGE]', style: const pw.TextStyle(fontSize: 10)),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }
        }

        return content;
      },
    ),
  );

  return pdf.save();
}
