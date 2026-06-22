import 'dart:typed_data';
import 'package:flutter/material.dart' show debugPrint;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:tenantsnap/features/inspection/models/inspection_model.dart';
import 'package:tenantsnap/core/utils/image_loader/image_byte_loader.dart';

class PdfTheme {
  static final black = PdfColor.fromInt(0xFF111827);
  static final dark = PdfColor.fromInt(0xFF1F2937);
  static final grey = PdfColor.fromInt(0xFF6B7280);
  static final lightGrey = PdfColor.fromInt(0xFFE5E7EB);
  static final bgGrey = PdfColor.fromInt(0xFFF9FAFB);
  static final blue = PdfColor.fromInt(0xFF2563EB);
  static final green = PdfColor.fromInt(0xFF16A34A);
  static final red = PdfColor.fromInt(0xFFDC2626);
  static final orange = PdfColor.fromInt(0xFFF59E0B);
}

String _statusText(RoomItemStatus status) {
  if (status == RoomItemStatus.happy) return 'GOOD CONDITION';
  if (status == RoomItemStatus.sad) return 'NEEDS REPAIR';
  return 'NOT APPLICABLE';
}

PdfColor _statusColor(RoomItemStatus status) {
  if (status == RoomItemStatus.happy) return PdfTheme.green;
  if (status == RoomItemStatus.sad) return PdfTheme.red;
  return PdfTheme.orange;
}

String _defaultComment(InspectionItem item) {
  if (item.comment.trim().isNotEmpty) return item.comment.trim();

  if (item.status == RoomItemStatus.happy) {
    return 'Condition verified. No visible issue observed.';
  }

  if (item.status == RoomItemStatus.sad) {
    return 'Issue observed. Repair or further review may be required.';
  }

  return 'No major issue observed.';
}

pw.Widget _sectionTitle(String title) {
  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(top: 18, bottom: 10),
    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    decoration: pw.BoxDecoration(
      color: PdfTheme.dark,
    ),
    child: pw.Text(
      title.toUpperCase(),
      style: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        letterSpacing: 0.8,
      ),
    ),
  );
}

pw.Widget _metadataRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              color: PdfTheme.grey,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value.trim().isEmpty ? '-' : value.trim(),
            style: pw.TextStyle(
              color: PdfTheme.black,
              fontSize: 10.5,
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _statusBadge(RoomItemStatus status) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: pw.BoxDecoration(
      color: _statusColor(status),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
    ),
    child: pw.Text(
      _statusText(status),
      style: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 8.5,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );
}

pw.Widget _imageBlock(Uint8List? bytes) {
  if (bytes != null && bytes.isNotEmpty) {
    try {
      return pw.Container(
        width: 240,
        height: 170,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfTheme.lightGrey, width: 0.8),
        ),
        child: pw.Image(
          pw.MemoryImage(bytes),
          fit: pw.BoxFit.cover,
        ),
      );
    } catch (e) {
      debugPrint('PDF Image Error: $e');
    }
  }

  return pw.Container(
    width: 240,
    height: 170,
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      color: PdfTheme.bgGrey,
      border: pw.Border.all(color: PdfTheme.lightGrey, width: 0.8),
    ),
    child: pw.Text(
      'Image not available',
      style: pw.TextStyle(
        color: PdfTheme.grey,
        fontSize: 9,
      ),
    ),
  );
}

pw.Widget _featureBlock({
  required InspectionItem item,
  required Map<String, Uint8List> loadedImages,
}) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 16),
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfTheme.lightGrey, width: 0.8),
      color: PdfColors.white,
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                item.name,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfTheme.black,
                ),
              ),
            ),
            _statusBadge(item.status),
          ],
        ),

        pw.SizedBox(height: 8),

        pw.Text(
          'Observation',
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfTheme.grey,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          _defaultComment(item),
          style: pw.TextStyle(
            fontSize: 10.5,
            color: PdfTheme.black,
            lineSpacing: 2,
          ),
        ),

        if (item.photos.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text(
            'Photo Evidence',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfTheme.grey,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: item.photos.map((photoPath) {
              return _imageBlock(loadedImages[photoPath]);
            }).toList(),
          ),
        ],
      ],
    ),
  );
}

pw.TableRow _summaryRow(String label, String value) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          label,
          style: pw.TextStyle(
            color: PdfTheme.black,
            fontSize: 10.5,
          ),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          value,
          style: pw.TextStyle(
            color: PdfTheme.black,
            fontSize: 10.5,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

pw.Widget _signatureBox(String title) {
  return pw.Container(
    height: 75,
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfTheme.lightGrey, width: 0.8),
    ),
    child: pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(color: PdfTheme.grey),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfTheme.grey,
          ),
        ),
      ],
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

  final Map<String, Uint8List> loadedImages = {};

  for (final room in rooms) {
    for (final item in room.checklist) {
      for (final photoPath in item.photos) {
        if (photoPath.isNotEmpty && !loadedImages.containsKey(photoPath)) {
          final bytes = await fetchImageBytes(photoPath);
          if (bytes.isNotEmpty) {
            loadedImages[photoPath] = bytes;
          }
        }
      }
    }
  }

  final int totalRooms = rooms.length;

  final int totalItems = rooms.fold<int>(
    0,
        (sum, room) => sum + room.checklist.length,
  );

  final int goodItems = rooms.fold<int>(
    0,
        (sum, room) =>
    sum + room.checklist.where((i) => i.status == RoomItemStatus.happy).length,
  );

  final int repairItems = rooms.fold<int>(
    0,
        (sum, room) =>
    sum + room.checklist.where((i) => i.status == RoomItemStatus.sad).length,
  );

  final int photoCount = rooms.fold<int>(
    0,
        (sum, room) =>
    sum + room.checklist.fold<int>(0, (s, item) => s + item.photos.length),
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(34, 30, 34, 30),
      footer: (context) {
        return pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(
                color: PdfTheme.lightGrey,
                width: 0.7,
              ),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'TenantSnap Property Inspection Report',
                style: pw.TextStyle(
                  color: PdfTheme.grey,
                  fontSize: 8.5,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(
                  color: PdfTheme.grey,
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
      build: (context) {
        final List<pw.Widget> content = [];

        content.add(
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.only(bottom: 14),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfTheme.black, width: 1),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'TENANTSNAP',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfTheme.blue,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'PROPERTY INSPECTION REPORT',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfTheme.black,
                    letterSpacing: 1.1,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Professional Move-In / Move-Out Condition Documentation',
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    color: PdfTheme.grey,
                  ),
                ),
              ],
            ),
          ),
        );

        content.add(_sectionTitle('Property Information'));

        content.add(
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfTheme.bgGrey,
              border: pw.Border.all(color: PdfTheme.lightGrey, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _metadataRow('Report ID', idCode),
                _metadataRow(
                  'Tenant Name',
                  showPhone && tenantPhone != null && tenantPhone.isNotEmpty
                      ? '$tenantName | $tenantPhone'
                      : tenantName,
                ),
                _metadataRow(
                  'Landlord Name',
                  showPhone && landlordPhone != null && landlordPhone.isNotEmpty
                      ? '$landlordName | $landlordPhone'
                      : landlordName,
                ),
                _metadataRow('Property Address', propertyAddress),
                _metadataRow('Inspection Date', inspectionDate),
              ],
            ),
          ),
        );

        content.add(_sectionTitle('Inspection Summary'));

        content.add(
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfTheme.lightGrey,
              width: 0.7,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              _summaryRow('Total Rooms', '$totalRooms'),
              _summaryRow('Total Checklist Features', '$totalItems'),
              _summaryRow('Good Condition Features', '$goodItems'),
              _summaryRow('Features Needing Repair', '$repairItems'),
              _summaryRow('Total Photos Attached', '$photoCount'),
            ],
          ),
        );

        content.add(_sectionTitle('Room Wise Inspection'));

        for (final room in rooms) {
          content.add(
            pw.Container(
              width: double.infinity,
              margin: const pw.EdgeInsets.only(top: 10, bottom: 8),
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFEFF6FF),
                border: pw.Border.all(
                  color: PdfColor.fromInt(0xFFBFDBFE),
                  width: 0.8,
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    room.name.toUpperCase(),
                    style: pw.TextStyle(
                      color: PdfTheme.blue,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${room.progress.toStringAsFixed(0)}% Completed',
                    style: pw.TextStyle(
                      color: PdfTheme.grey,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );

          if (room.comment.trim().isNotEmpty) {
            content.add(
              pw.Container(
                width: double.infinity,
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfTheme.bgGrey,
                  border: pw.Border.all(color: PdfTheme.lightGrey, width: 0.7),
                ),
                child: pw.Text(
                  'Room Notes: ${room.comment.trim()}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfTheme.grey,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            );
          }

          for (final item in room.checklist) {
            content.add(
              pw.Inseparable(
                child: _featureBlock(
                  item: item,
                  loadedImages: loadedImages,
                ),
              ),
            );
          }

          content.add(pw.SizedBox(height: 8));
        }

        content.add(_sectionTitle('Signatures'));

        content.add(
          pw.Row(
            children: [
              pw.Expanded(child: _signatureBox('Tenant Signature')),
              pw.SizedBox(width: 18),
              pw.Expanded(child: _signatureBox('Landlord Signature')),
            ],
          ),
        );

        content.add(pw.SizedBox(height: 14));

        content.add(
          pw.Text(
            'This inspection report documents the visible condition of the property and attached photo evidence at the time of inspection.',
            style: pw.TextStyle(
              color: PdfTheme.grey,
              fontSize: 9.5,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        );

        return content;
      },
    ),
  );

  return pdf.save();
}