import 'dart:typed_data';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart' show debugPrint;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

import 'package:tenantsnap/features/inspection/models/inspection_model.dart';
import 'package:tenantsnap/core/utils/image_loader/image_byte_loader.dart';

import '../responsive/responsive_extension.dart';

Uint8List _optimizeImageForPdf(Uint8List bytes) {
  try {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;
    final orientedImage = img.bakeOrientation(image);

    const int maxDim = 1200;
    img.Image finalImage = orientedImage;
    if (orientedImage.width > maxDim || orientedImage.height > maxDim) {
      if (orientedImage.width > orientedImage.height) {
        finalImage = img.copyResize(orientedImage, width: maxDim);
      } else {
        finalImage = img.copyResize(orientedImage, height: maxDim);
      }
    }

    return Uint8List.fromList(img.encodeJpg(finalImage, quality: 80));
  } catch (e) {
    debugPrint('Failed to optimize image for PDF: $e');
    return bytes;
  }
}

Future<Uint8List> _processImageBytes(Uint8List bytes) async {
  try {
    return await compute(_optimizeImageForPdf, bytes);
  } catch (e) {
    return _optimizeImageForPdf(bytes);
  }
}

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
final String currentDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
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
    decoration: pw.BoxDecoration(color: PdfTheme.dark),
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

pw.Widget _statusIcon(RoomItemStatus status) {
  if (status == RoomItemStatus.neutral) {
    return pw.SizedBox();
  }

  final bool isGood = status == RoomItemStatus.happy;

  return pw.Container(
    width: 13,
    height: 13,
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      shape: pw.BoxShape.circle,
      color: isGood ? PdfTheme.green : PdfTheme.red,
    ),
    child: pw.Text(
      isGood ? ':)' : ':(',
      style: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 5.5,
        fontWeight: pw.FontWeight.bold,
      ),
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
    child: pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        if (status != RoomItemStatus.neutral) ...[
          _statusIcon(status),
          pw.SizedBox(width: 5),
        ],
        pw.Text(
          _statusText(status),
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 12.sp,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _imageBlock(Uint8List? bytes) {
  if (bytes != null && bytes.isNotEmpty) {
    try {
      return pw.Container(
        width: double.infinity,
        height: 260,
        decoration: pw.BoxDecoration(
          color: PdfTheme.bgGrey,
          border: pw.Border.all(color: PdfTheme.lightGrey, width: 0.8),
        ),
        child: pw.Image(
          pw.MemoryImage(bytes),
          fit: pw.BoxFit.contain,
        ),
      );
    } catch (e) {
      debugPrint('PDF Image Error: $e');
    }
  }

  return pw.Container(
    width: double.infinity,
    height: 210,
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

pw.Widget _detailsWidget(InspectionItem item) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(
              item.name,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfTheme.black,
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          _statusBadge(item.status),
        ],
      ),

      pw.SizedBox(height: 12),

      pw.Text(
        'Observation',
        style: pw.TextStyle(
          fontSize: 9,
          color: PdfTheme.grey,
          fontWeight: pw.FontWeight.bold,
        ),
      ),

      pw.SizedBox(height: 4),

      pw.Text(
        _defaultComment(item),
        style: pw.TextStyle(
          fontSize: 10.5,
          color: PdfTheme.black,
          lineSpacing: 2,
        ),
      ),

      pw.SizedBox(height: 10),

      pw.Text(
        'Photos Attached: ${item.photos.length}',
        style: pw.TextStyle(
          fontSize: 9.5,
          color: PdfTheme.grey,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    ],
  );
}

pw.Widget _imageThumb(Uint8List? bytes) {
  if (bytes != null && bytes.isNotEmpty) {
    try {
      return pw.Container(
        width: double.infinity,
        height: 160,
        decoration: pw.BoxDecoration(
          color: PdfTheme.bgGrey,
          border: pw.Border.all(color: PdfTheme.lightGrey, width: 0.8),
        ),
        child: pw.Image(
          pw.MemoryImage(bytes),
          fit: pw.BoxFit.contain,
        ),
      );
    } catch (e) {
      debugPrint('PDF Image Error: $e');
    }
  }

  return pw.Container(
    width: double.infinity,
    height: 130,
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      color: PdfTheme.bgGrey,
      border: pw.Border.all(color: PdfTheme.lightGrey, width: 0.8),
    ),
    child: pw.Text(
      'Image not available',
      style: pw.TextStyle(color: PdfTheme.grey, fontSize: 8),
    ),
  );
}

pw.Widget _imageGrid(List<Uint8List?> images) {
  if (images.isEmpty) {
    return _imageThumb(null);
  }

  if (images.length == 1) {
    return _imageThumb(images[0]);
  }

  if (images.length == 2) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: _imageThumb(images[0])),
        pw.SizedBox(width: 6),
        pw.Expanded(child: _imageThumb(images[1])),
      ],
    );
  }

  // 3+ images: wrap into rows of 2
  final List<pw.Widget> rows = [];
  for (int i = 0; i < images.length; i += 2) {
    final bool hasSecond = i + 1 < images.length;
    rows.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: _imageThumb(images[i])),
            pw.SizedBox(width: 6),
            pw.Expanded(
              child: hasSecond ? _imageThumb(images[i + 1]) : pw.SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: rows,
  );
}

pw.Widget _featureBlock({
  required InspectionItem item,
  required Map<String, Uint8List> loadedImages,
}) {
  final List<Uint8List?> allImages = item.photos
      .map((path) => loadedImages[path])
      .where((bytes) => bytes != null && bytes.isNotEmpty)
      .toList();

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 14),
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfTheme.lightGrey, width: 0.8),
      color: PdfColors.white,
    ),
    child: pw.Wrap(
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _detailsWidget(item),
            if (allImages.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              _imageGrid(allImages),
            ],
          ],
        ),
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
  required String inspectionType,
  required String inspectionPerformedBy,
  required String reportGeneratedOn,
  required List<RoomInspection> rooms,
  String? tenantPhone,
  String? landlordPhone,
  bool showPhone = true, required String agreementDate,
}) async {
  final pdf = pw.Document();
  final Map<String, Uint8List> loadedImages = {};
  Uint8List? logoBytes;

  try {
    logoBytes = await fetchImageBytes('assets/app_icon.png');
  } catch (e) {
    debugPrint('Logo load failed: $e');
  }

  final Set<String> uniquePhotoPaths = {};
  for (final room in rooms) {
    for (final item in room.checklist) {
      for (final photoPath in item.photos) {
        if (photoPath.isNotEmpty) {
          uniquePhotoPaths.add(photoPath);
        }
      }
    }
  }

  await Future.wait(
    uniquePhotoPaths.map((photoPath) async {
      try {
        final bytes = await fetchImageBytes(photoPath);
        if (bytes.isNotEmpty) {
          final processed = await _processImageBytes(bytes);
          loadedImages[photoPath] = processed;
        }
      } catch (e) {
        debugPrint('Image load/process failed: $photoPath $e');
      }
    }),
  );

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
              pw.SizedBox(height: 6),
              pw.Text(
                'Generated on: $currentDate',
                style: pw.TextStyle(
                  fontSize: 8.5,
                  color: PdfTheme.grey,
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
                if (logoBytes != null) ...[
                  pw.Image(
                    pw.MemoryImage(logoBytes),
                    width: 70,
                    height: 70,
                  ),
                  pw.SizedBox(height: 8),
                ],
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
                _metadataRow(
                  'Inspection Carried Out By',
                  inspectionPerformedBy,
                ),
                _metadataRow('ID Code', idCode),
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
                _metadataRow('Inspection Type', inspectionType),

                _metadataRow('Inspection Date', inspectionDate),
                _metadataRow('Report Generated On', reportGeneratedOn),
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
              _featureBlock(
                item: item,
                loadedImages: loadedImages,
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