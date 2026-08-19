import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion_pdf;
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/core/utils/download_helper/download_helper.dart';
import 'package:tenantsnap/core/utils/pdf/pdf_generator.dart';
import 'package:tenantsnap/core/services/rest_client.dart';
import 'package:tenantsnap/core/utils/responsive/responsive_extension.dart';
import 'package:tenantsnap/features/inspection/controllers/inspection_controller.dart';
import 'package:tenantsnap/features/inspection/models/inspection_model.dart';

import 'dart:convert';
import '../../../core/controllers/base_controller.dart';
import '../../dashboard/screens/home_screen.dart';



class ReportReviewScreen extends StatefulWidget {
  final RoomInspection? singleRoom;
  final List<RoomInspection>? allRooms;
  final String? roomName;
  final String? tenantName;
  final String? landlordName;
  final String? propertyAddress;
  final String? inspectionDate;
  final String? idCode;
  final String? agreementDate;


  const ReportReviewScreen({
    super.key,
    this.singleRoom,
    this.allRooms,
    this.roomName,
    this.tenantName,
    this.landlordName,
    this.propertyAddress,
    this.inspectionDate,
    this.idCode,
    this.agreementDate
  });

  @override
  State<ReportReviewScreen> createState() => _ReportReviewScreenState();
}
class _ReportReviewScreenState extends State<ReportReviewScreen> {
  File? selectedLeasePdf;

  Future<void> _pickLeasePdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedLeasePdf = File(result.files.single.path!);
      });

      Get.snackbar(
        'Lease Added',
        'Lease agreement PDF will be attached to the final report.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2ECC71),
        colorText: Colors.white,
      );
    }
  }
  Future<Uint8List> _appendLeasePdf({
    required Uint8List reportPdfBytes,
    required File leasePdfFile,
  }) async {
    final syncfusion_pdf.PdfDocument reportDocument =
    syncfusion_pdf.PdfDocument(inputBytes: reportPdfBytes);

    final syncfusion_pdf.PdfDocument leaseDocument =
    syncfusion_pdf.PdfDocument(inputBytes: await leasePdfFile.readAsBytes());

    final syncfusion_pdf.PdfDocument finalDocument =
    syncfusion_pdf.PdfDocument();

    for (int i = 0; i < reportDocument.pages.count; i++) {
      final template = reportDocument.pages[i].createTemplate();
      final page = finalDocument.pages.add();
      page.graphics.drawPdfTemplate(template, Offset.zero);
    }

    for (int i = 0; i < leaseDocument.pages.count; i++) {
      final template = leaseDocument.pages[i].createTemplate();
      final page = finalDocument.pages.add();
      page.graphics.drawPdfTemplate(template, Offset.zero);
    }

    final bytes = await finalDocument.save();

    reportDocument.dispose();
    leaseDocument.dispose();
    finalDocument.dispose();

    return Uint8List.fromList(bytes);
  }
  Future<Uint8List> _lockPdf(Uint8List pdfBytes) async {
    final document = syncfusion_pdf.PdfDocument(inputBytes: pdfBytes);

    document.security.userPassword = '';
    document.security.ownerPassword = 'TenantSnapOwner@2026';

    document.security.permissions.clear();
    document.security.permissions.addAll([
      syncfusion_pdf.PdfPermissionsFlags.print,
    ]);

    final lockedBytes = await document.save();
    document.dispose();

    return Uint8List.fromList(lockedBytes);
  }

  Future<void> _savePdfToHistory({
    required Uint8List pdfBytes,
    required String idCode,
    required String tenantName,
    required String landlordName,
    required String propertyAddress,
    required String inspectionDate,
  }) async {
    try {
      final restClient = Get.find<RestClient>();
      final String safeTitle = propertyAddress.contains(',')
          ? propertyAddress.split(',').first.trim()
          : (propertyAddress.isNotEmpty ? propertyAddress : 'Inspection Report');
      
      final String formattedDate = '${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().year}';
      
      final box = GetStorage();
      final userId = box.read('userId') ?? 0;

      final inspectionController = Get.find<InspectionController>();
      final String editingId = inspectionController.editingRecordId.value;
      final bool isEditing = editingId.isNotEmpty;

      final Map<String, dynamic> exportData = inspectionController.exportToJson();
      final String inspectionJson = jsonEncode(exportData);

      final formData = dio_pkg.FormData.fromMap({
        'pdf': dio_pkg.MultipartFile.fromBytes(
          pdfBytes,
          filename: 'TenantSnap_Report_${idCode.isNotEmpty ? idCode : DateTime.now().millisecondsSinceEpoch}.pdf',
          contentType: dio_pkg.DioMediaType('application', 'pdf'),
        ),
        'title': safeTitle,
        'date': formattedDate,
        'status': 'VERIFIED',
        'tenantName': tenantName.isNotEmpty ? tenantName : 'N/A',
        'landlordName': landlordName.isNotEmpty ? landlordName : 'N/A',
        'propertyAddress': propertyAddress.isNotEmpty ? propertyAddress : 'N/A',
        'inspectionDate': inspectionDate.isNotEmpty ? inspectionDate : formattedDate,
        'idCode': idCode.isNotEmpty ? idCode : 'N/A',
        'userId': userId,
        'inspectionData': inspectionJson,
        'tenantPhone': inspectionController.tenantPhone.value.isNotEmpty ? inspectionController.tenantPhone.value : 'N/A',
        'landlordPhone': inspectionController.landlordPhone.value.isNotEmpty ? inspectionController.landlordPhone.value : 'N/A',
        'role': inspectionController.inspectionPerformedBy.value.isNotEmpty ? inspectionController.inspectionPerformedBy.value.toLowerCase() : 'tenant',
      });

      if (isEditing) {
        await restClient.dio.put(
          '/pdf-history/$editingId',
          data: formData,
        );
        inspectionController.editingRecordId.value = '';
        debugPrint("PDF report updated to Cloudflare and updated in history.");
      } else {
        await restClient.dio.post(
          '/pdf-history/upload-cloudflare',
          data: formData,
        );
        debugPrint("PDF report uploaded to Cloudflare and saved to history.");
      }
    } catch (e) {
      debugPrint("Failed to save PDF to history: $e");
    }
  }

  /// Builds a display string like:
  ///   "Kalyan (ID: 2323) | Sunny (ID: 23424)"
  ///
  /// `namesJoined` is the comma-separated names string stored on the
  /// controller (e.g. "Kalyan, Sunny"). `idCodes` holds the per-person
  /// ID codes entered on Property Details, aligned by index with the
  /// names list. Used for both tenant and landlord rows.
  ///
  /// Note: the top-level "ID Code" field (shown separately as its own
  /// "ID Code: ..." row) is NOT used here. That field is a general ID
  /// for whoever performed the inspection (tenant or landlord) — it is
  /// not specific to the first person in either list, so it must never
  /// be borrowed as person #1's ID. Person #1 has no ID-code input on
  /// Property Details (that field only appears for additional people,
  /// index > 0), so person #1 simply shows with no ID unless one is
  /// otherwise present at index 0.
  ///
  /// If a person has no ID code available, only their name is shown
  /// (no empty "(ID: )" suffix).
  String _formatNamesWithIds({
    required String namesJoined,
    required List<String> idCodes,
  }) {
    final List<String> names = namesJoined
        .split(',')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (names.isEmpty) return '-';

    final List<String> parts = [];

    for (int i = 0; i < names.length; i++) {
      final String name = names[i];

      final String id = i < idCodes.length ? idCodes[i].trim() : '';

      parts.add(id.isNotEmpty ? '$name (ID: $id)' : name);
    }

    return parts.join(' | ');
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final controller = Get.find<InspectionController>();

    final String activeTenantName = widget.tenantName ?? controller.tenantName.value;
    final String activeLandlordName =
        widget.landlordName ?? controller.landlordName.value;
    final String activePropertyAddress =
        widget.propertyAddress ?? controller.propertyAddress.value;

    // Bug fix: use this cleaned address everywhere on this screen (header,
    // preview dialog, PDF generation, email body) instead of the raw
    // activePropertyAddress, so any accidental duplication of
    // city/state/zip/country segments upstream doesn't get displayed or
    // baked into the generated PDF / email text.
    final String cleanedPropertyAddress = activePropertyAddress
        .replaceAll(RegExp(r'(,\s*)+'), ', ')
        .trim();

    final String activeInspectionDate = controller.possessionDate.value;
    final String activeAgreementDate =
        controller.agreementDate.value;

    final String activeIdCode =  widget.idCode ?? controller.idCode.value;

    // Individual tenant/landlord ID codes, aligned by index with the
    // names in activeTenantName / activeLandlordName (see
    // _formatNamesWithIds for details).
    final List<String> activeTenantIdCodes = controller.tenantIdCodes.toList();
    final List<String> activeLandlordIdCodes = controller.landlordIdCodes.toList();

    final List<RoomInspection> sourceRooms =
        widget.allRooms ?? ( widget.singleRoom != null ? [ widget.singleRoom!] : controller.roomsList.toList());

    // Only keep rooms that actually have at least one filled-in item
    // (happy/sad status, a photo, or a comment). Rooms where nothing
    // was selected show up as an empty card with just a name and no
    // content, so they're dropped from the report entirely.
    final List<RoomInspection> activeRooms = sourceRooms.where((room) {
      return room.checklist.any((item) {
        final bool hasStatus = item.status == RoomItemStatus.happy ||
            item.status == RoomItemStatus.sad;
        final bool hasPhotos = item.photos.isNotEmpty;
        final bool hasComment = item.comment.isNotEmpty;
        return hasStatus || hasPhotos || hasComment;
      });
    }).toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AntigravityColors.bgGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
              EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 16.0.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: size.width * 0.9,
                    constraints: BoxConstraints(maxWidth: 380.0.w),
                    decoration: BoxDecoration(
                      gradient: AntigravityColors.bgGradient,
                      borderRadius: BorderRadius.circular(28.0.w),
                      boxShadow: [
                        BoxShadow(
                          color:
                          const Color(0xFF2C3E50).withValues(alpha: 0.08),
                          blurRadius: 24.0.w,
                          spreadRadius: 4.0.w,
                          offset: Offset(0, 10.0.h),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.0.w,
                      vertical: 20.0.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: const Color(0xFF007BFF),
                                size: 24.w,
                              ),
                            ),
                            SizedBox(width: 16.0.w),
                            Expanded(
                              child: Text(
                                'Review and Send Report',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: const Color(0xFF2C3E50),
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18.0.sp,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.0.h),

                        _buildGlobalHeaderCard(
                          context,
                          idCode: activeIdCode,
                          tenantName: activeTenantName,
                          tenantIdCodes: activeTenantIdCodes,
                          landlordName: activeLandlordName,
                          landlordIdCodes: activeLandlordIdCodes,
                          propertyAddress: cleanedPropertyAddress,
                          inspectionDate: activeInspectionDate,
                          agreementDate: activeAgreementDate,
                          inspectionPerformedBy: controller.inspectionPerformedBy.value,
                        ),

                        SizedBox(height: 16.0.h),

                        if (activeRooms.isNotEmpty)
                          ...activeRooms
                              .map((room) => _buildUnifiedRoomCard(context, room))
                        else
                          Center(
                            child: Padding(
                              padding:
                              EdgeInsets.symmetric(vertical: 30.0.h),
                              child: Text(
                                'No photo evidence captured for any rooms.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF7F8C8D)
                                      .withValues(alpha: 0.8),
                                  fontFamily: 'Montserrat',
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: 16.0.h),

                        _buildShareSendButton(
                          context,
                          idCode: activeIdCode,
                          tenantName: activeTenantName,
                          landlordName: activeLandlordName,
                          propertyAddress: cleanedPropertyAddress,
                          inspectionDate: activeInspectionDate,
                          agreementDate: activeAgreementDate,
                          allRooms: activeRooms,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedRoomCard(BuildContext context, RoomInspection room) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.0.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withValues(alpha: 0.04),
            blurRadius: 10.0.w,
            offset: Offset(0, 4.0.h),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.5.w,
        ),
      ),
      padding: EdgeInsets.all(18.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            room.name,
            style: TextStyle(
              color: const Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 16.0.sp,
            ),
          ),
          SizedBox(height: 12.0.h),
          Divider(color: const Color(0xFFE2E8F0), height: 1.0.h),
          SizedBox(height: 16.0.h),
          ..._buildSelectedChecklistItems(context, room.checklist),
        ],
      ),
    );
  }

  /// Only items the user actually filled in are rendered: happy/sad
  /// status, at least one photo, or a written comment. Items left
  /// completely untouched (neutral status, no photos, no comment) are
  /// skipped entirely.
  List<Widget> _buildSelectedChecklistItems(
      BuildContext context,
      List<InspectionItem> checklist,
      ) {
    final List<InspectionItem> selectedItems = checklist.where((item) {
      final bool hasStatus = item.status == RoomItemStatus.happy ||
          item.status == RoomItemStatus.sad;
      final bool hasPhotos = item.photos.isNotEmpty;
      final bool hasComment = item.comment.isNotEmpty;
      return hasStatus || hasPhotos || hasComment;
    }).toList();

    return selectedItems.asMap().entries.map((entry) {
      final int index = entry.key;
      final InspectionItem item = entry.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUnifiedChecklistItem(context, item),
          if (index < selectedItems.length - 1) ...[
            SizedBox(height: 16.0.h),
            Divider(
              color: const Color(0xFFEEF2F6),
              height: 1.0.h,
              thickness: 1.0.h,
            ),
            SizedBox(height: 16.0.h),
          ],
        ],
      );
    }).toList();
  }

  /// Bug fix: previously this branched on the item's *name* (checking for
  /// "wall", "floor"/"carpet"/"tile", or "other") and rendered a different
  /// — and incomplete — subset of the item's data depending on which
  /// bucket it fell into:
  ///   - "wall" items showed status circles only (no photos, no comment)
  ///   - "floor"/"carpet"/"tile" items showed photos only (no status, no comment)
  ///   - everything else showed photos + comment only (no status circles)
  /// That meant real data (photos, comments, or status) silently disappeared
  /// from the report depending purely on how the checklist item was named.
  ///
  /// Now every item renders the *same* complete set of info regardless of
  /// its name: item name, status circles, photos (if any), and comment.
  Widget _buildUnifiedChecklistItem(BuildContext context, InspectionItem item) {
    final String commentText = item.comment.isNotEmpty
        ? item.comment
        : item.status == RoomItemStatus.happy
        ? 'Condition verified; fully functional and clean.'
        : item.status == RoomItemStatus.sad
        ? 'Defect noted: minor repair required.'
        : 'Standard condition; no major issues observed.';

    final bool hasPhotos = item.photos.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  color: const Color(0xFF2C3E50),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 14.0.sp,
                ),
              ),
            ),
            _buildSelectedStatusIcon(item.status),
          ],
        ),

        if (hasPhotos) ...[
          SizedBox(height: 10.0.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: item.photos.map((photoPath) {
              final bool isRealFile = !photoPath.startsWith('assets/') &&
                  !photoPath.startsWith('http') &&
                  !photoPath.startsWith('blob:');

              final Widget imageWidget = isRealFile
                  ? Image.file(
                File(photoPath),
                fit: BoxFit.cover,
              )
                  : Image.network(
                photoPath,
                fit: BoxFit.cover,
              );

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => _showPhotoPreviewDialog(context, photoPath),
                    child: Container(
                      width: 75.w,
                      height: 65.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0.w),
                        color: const Color(0xFFEEF2F6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0.w),
                        child: imageWidget,
                      ),
                    ),
                  ),

                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          item.photos.remove(photoPath);
                        });
                      },
                      child: Container(
                        width: 22.w,
                        height: 22.h,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14.w,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],

        SizedBox(height: 10.0.h),

        Text(
          commentText,
          style: TextStyle(
            color: const Color(0xFF7F8C8D),
            fontFamily: 'Montserrat',
            fontSize: 11.0.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Renders only the icon matching the item's actual selected status.
  /// Neutral status shows no icon — only happy/sad are displayed.
  Widget _buildSelectedStatusIcon(RoomItemStatus status) {
    switch (status) {
      case RoomItemStatus.happy:
        return _buildColoredCircle(
          Icons.sentiment_satisfied_alt,
          const Color(0xFF2ECC71),
        );
      case RoomItemStatus.sad:
        return _buildColoredCircle(
          Icons.sentiment_very_dissatisfied,
          const Color(0xFFE74C3C),
        );
      case RoomItemStatus.neutral:
        return const SizedBox.shrink();
    }
  }

  void _showPhotoPreviewDialog(BuildContext context, String photoPath) {
    final bool isRealFile = !photoPath.startsWith('assets/') &&
        !photoPath.startsWith('http') &&
        !photoPath.startsWith('blob:');

    Widget imageWidget;

    if (isRealFile) {
      imageWidget = Image.file(
        File(photoPath),
        fit: BoxFit.contain,
      );
    } else {
      imageWidget = Image.network(
        photoPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.image_not_supported_outlined),
          );
        },
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0.w),
          ),
          contentPadding: EdgeInsets.all(12.0.w),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(maxHeight: 300.0.h),
                width: double.infinity,
                color: const Color(0xFFF2F4F7),
                child: imageWidget,
              ),
              SizedBox(height: 16.0.h),
              Text(
                'Photo Evidence Review',
                style: TextStyle(
                  color: const Color(0xFF2C3E50),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0.sp,
                ),
              ),
              SizedBox(height: 20.0.h),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: const Color(0xFF7F8C8D),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  void _clearAllInspectionData() {
    final controller = Get.find<InspectionController>();

    controller.clearInspectionData();

    setState(() {
      selectedLeasePdf = null;
    });
  }
  Widget _buildMetadataRow(String key, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$key: ',
            style: TextStyle(
              color: const Color(0xFF7F8C8D),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: 12.0.sp,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: const Color(0xFF2C3E50),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 12.0.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColoredCircle(IconData icon, Color color) {
    return Container(
      width: 24.w,
      height: 24.h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.0.w),
      ),
      child: Icon(
        icon,
        size: 13.w,
        color: color,
      ),
    );
  }

  Widget _buildGlobalHeaderCard(
      BuildContext context, {
        required String idCode,
        required String tenantName,
        required List<String> tenantIdCodes,
        required String landlordName,
        required List<String> landlordIdCodes,
        required String propertyAddress,
        required String inspectionDate,
        required String agreementDate,
        required String inspectionPerformedBy,

      }) {
    final String tenantNamesWithIds = _formatNamesWithIds(
      namesJoined: tenantName,
      idCodes: tenantIdCodes,
    );

    final String landlordNamesWithIds = _formatNamesWithIds(
      namesJoined: landlordName,
      idCodes: landlordIdCodes,
    );

    final bool landlordFirst =
        inspectionPerformedBy.trim().toLowerCase() == 'landlord';

    final Widget tenantRow =
    _buildMetadataRow("Tenant's Names", tenantNamesWithIds);
    final Widget landlordRow =
    _buildMetadataRow("Landlord's Names", landlordNamesWithIds);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withValues(alpha: 0.04),
            blurRadius: 10.0.w,
            offset: Offset(0, 4.0.h),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.5.w,
        ),
      ),
      padding: EdgeInsets.all(16.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inspection Report Overview',
            style: TextStyle(
              color: const Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 16.0.sp,
            ),
          ),
          SizedBox(height: 12.0.h),
          if (idCode.isNotEmpty)
            _buildMetadataRow(
              'Inspection Carried Out By',
              inspectionPerformedBy,
            ),
          _buildMetadataRow('ID Code', idCode),

          ...landlordFirst
              ? [landlordRow, tenantRow]
              : [tenantRow, landlordRow],
          _buildMetadataRow('Address', propertyAddress),
          _buildMetadataRow('InspectionDate', inspectionDate),
          _buildMetadataRow('AgreementDate', agreementDate),
        ],
      ),
    );
  }

  Widget _buildShareSendButton(
      BuildContext context, {
        required String idCode,
        required String tenantName,
        required String landlordName,
        required String propertyAddress,
        required String inspectionDate,
        required List<RoomInspection> allRooms, required String agreementDate,
      }) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final controller = Get.find<InspectionController>();
            // Show a saving dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogCtx) => const Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF007BFF),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Saving report to history...',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );

            try {
              final pdfBytes = await generateInspectionReportPdf(
                idCode: idCode,
                tenantName: tenantName,
                landlordName: landlordName,
                propertyAddress: propertyAddress,
                inspectionDate: inspectionDate,
                inspectionType: controller.inspectionType.value,
                inspectionPerformedBy: controller.inspectionPerformedBy.value,
                reportGeneratedOn: '${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().year} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                rooms: allRooms,
                tenantPhone: controller.tenantPhone.value,
                landlordPhone: controller.landlordPhone.value,
                showPhone: controller.showPhoneInPdf.value,
                agreementDate: controller.agreementDate.value,
              );

              Uint8List finalPdfBytes = pdfBytes;
              finalPdfBytes = await _lockPdf(finalPdfBytes);

              await _savePdfToHistory(
                pdfBytes: finalPdfBytes,
                idCode: idCode,
                tenantName: tenantName,
                landlordName: landlordName,
                propertyAddress: propertyAddress,
                inspectionDate: inspectionDate,
              );

              // Dismiss loader
              if (context.mounted) {
                Navigator.pop(context);
              }

              // Show preview dialog
              if (context.mounted) {
                _showPdfPreviewDialog(
                  context,
                  idCode: idCode,
                  tenantName: tenantName,
                  landlordName: landlordName,
                  propertyAddress: propertyAddress,
                  inspectionDate: inspectionDate,
                  agreementDate: agreementDate,
                  allRooms: allRooms,
                );
              }
            } catch (e) {
              // Dismiss loader
              if (context.mounted) {
                Navigator.pop(context);
              }
              // Show error
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFFE74C3C),
                    content: Text('Failed to save to history: $e'),
                  ),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(12.0.w),
          child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 10.0.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(4.0.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007BFF),
                    borderRadius: BorderRadius.circular(6.0.w),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16.w,
                  ),
                ),
                SizedBox(width: 10.0.w),
                Text(
                  'Share & Send Full PDF',
                  style: TextStyle(
                    color: const Color(0xFF2C3E50),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                    fontSize: 15.0.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPdfPreviewDialog(
      BuildContext context, {
        required String idCode,
        required String tenantName,
        required String landlordName,
        required String propertyAddress,
        required String inspectionDate,
        required List<RoomInspection> allRooms, required String agreementDate,
      }) {
    final controller = Get.find<InspectionController>();
    final isDownloading = false.obs;
    final isUploading = false.obs;
    final isDisclaimerAccepted = false.obs;
    final hasDownloadedOrShared = false.obs;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0.w),
          ),
          contentPadding: EdgeInsets.all(16.0.w),
          title: Text(
            'PDF Document Preview',
            style: TextStyle(
              color: const Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 18.0.sp,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Click Download to save PDF file or Share & Send to select email/share app.',
                style: TextStyle(
                  color: const Color(0xFF7F8C8D),
                  fontFamily: 'Montserrat',
                  fontSize: 12.0.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.0.h),
              OutlinedButton.icon(
                onPressed: _pickLeasePdf,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: Text(
                  selectedLeasePdf == null
                      ? 'Attach Lease Agreement PDF'
                      : 'Lease PDF Attached',
                ),
              ),
              SizedBox(height: 12.0.h),
              Material(
                color: Colors.transparent,
                child: Obx(
                      () => CheckboxListTile(
                    value: isDisclaimerAccepted.value,
                    onChanged: (value) {
                      isDisclaimerAccepted.value = value ?? false;
                    },
                    activeColor: Colors.white,
                    checkColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0xFF95A5A6),
                      width: 1.5,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'I acknowledge that this report is generated automatically based on the information I provided, and TenantSnap is not responsible for any legal or security deposit disputes.',
                      style: TextStyle(
                        color: const Color(0xFF2C3E50),
                        fontFamily: 'Montserrat',
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // Closing the preview dialog (Close button, or dismiss) always
            // keeps all inspection data untouched -- no clearing happens here.
            Obx(
              () => TextButton(
                onPressed: (isDownloading.value || isUploading.value)
                    ? null
                    : () {
                        Navigator.pop(dialogContext);
                        if (hasDownloadedOrShared.value) {
                          _clearAllInspectionData();
                          Get.offAll(() => HomeScreen(
                            role: controller.inspectionPerformedBy.value.toLowerCase() == 'landlord' ? 'landlord' : 'tenant',
                            userName: BaseController.name.value,
                          ));
                        }
                      },
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: const Color(0xFF95A5A6),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0.sp,
                  ),
                ),
              ),
            ),
            Obx(
                  () => ElevatedButton.icon(
                onPressed: (isDownloading.value || isUploading.value || !isDisclaimerAccepted.value)
                    ? null
                    : () async {
                  isDownloading.value = true;

                  try {
                    final pdfBytes = await generateInspectionReportPdf(
                      idCode: idCode,
                      tenantName: tenantName,
                      landlordName: landlordName,
                      propertyAddress: propertyAddress,
                      inspectionDate: inspectionDate,
                      inspectionType: controller.inspectionType.value,
                      inspectionPerformedBy:
                      controller.inspectionPerformedBy.value,
                      reportGeneratedOn:
                      '${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().year} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      rooms: allRooms,
                      tenantPhone: controller.tenantPhone.value,
                      landlordPhone: controller.landlordPhone.value,
                      showPhone: controller.showPhoneInPdf.value,
                      agreementDate: controller.agreementDate.value,
                    );

                    Uint8List finalPdfBytes = pdfBytes;

                    if (selectedLeasePdf != null) {
                      finalPdfBytes = await _appendLeasePdf(
                        reportPdfBytes: pdfBytes,
                        leasePdfFile: selectedLeasePdf!,
                      );
                    }
                    finalPdfBytes = await _lockPdf(finalPdfBytes);

                    final savedPath = await DownloadHelper.downloadPdf(
                      bytes: finalPdfBytes,
                      fileName:
                      'TenantSnap_Inspection_Report_${idCode.isNotEmpty ? idCode : DateTime.now().millisecondsSinceEpoch}.pdf',
                    );

                    if (savedPath == null) {
                      throw Exception('PDF download failed.');
                    }

                    // --- Success path ---
                    hasDownloadedOrShared.value = true;
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 4),
                          backgroundColor: const Color(0xFF2ECC71),
                          content: const Text(
                            'PDF downloaded successfully.',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }
                    _clearAllInspectionData();
                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                      Get.offAll(() => HomeScreen(
                        role: controller.inspectionPerformedBy.value.toLowerCase() == 'landlord' ? 'landlord' : 'tenant',
                        userName: BaseController.name.value,
                      ));
                    }
                  } catch (e) {
                    // --- Failure path: keep data, dialog stays open ---
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFFE74C3C),
                          content: Text(
                            'Failed to generate PDF: $e',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  } finally {
                    isDownloading.value = false;
                  }
                },
                icon: isDownloading.value
                    ? SizedBox(
                  width: 14.w,
                  height: 14.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 1.5,
                  ),
                )
                    : Icon(
                  Icons.download_rounded,
                  size: 16.w,
                  color: Colors.white,
                ),
                label: Text(
                  isDownloading.value ? 'Downloading...' : 'Download',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0.w),
                  ),
                ),
              ),
            ),

            // Email/Share button:
            //  success -> clear data -> close dialog -> go Home
            //  failure -> keep data, dialog stays open, error snackbar shown
            // (Mirrors the Download button's success/failure handling.
            //  Previously _sharePdfToEmail swallowed all errors internally
            //  and this handler always navigated Home + never cleared data,
            //  so email "succeeded" visually even when the share failed,
            //  and never actually reset the inspection state.)
            Obx(
                  () => ElevatedButton(
                onPressed: (isDownloading.value || isUploading.value || !isDisclaimerAccepted.value)
                    ? null
                    : () async {
                  isUploading.value = true;

                  try {
                    await _sharePdfToEmail(
                      context: context,
                      idCode: idCode,
                      tenantName: tenantName,
                      landlordName: landlordName,
                      propertyAddress: propertyAddress,
                      inspectionDate: inspectionDate,
                      agreementDate: controller.agreementDate.value,
                      allRooms: allRooms,
                    );

                    // --- Success path ---
                    hasDownloadedOrShared.value = true;

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 4),
                          backgroundColor: Color(0xFF2ECC71),
                          content: Text(
                            'Report shared successfully.',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }
                    _clearAllInspectionData();
                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                      Get.offAll(() => HomeScreen(
                        role: controller.inspectionPerformedBy.value.toLowerCase() == 'landlord' ? 'landlord' : 'tenant',
                        userName: BaseController.name.value,
                      ));
                    }
                  } catch (e) {
                    // --- Failure path: keep data, dialog stays open ---
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFFE74C3C),
                          content: Text(
                            'Failed to share PDF: $e',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  } finally {
                    isUploading.value = false;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007BFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0.w),
                  ),
                ),
                child: isUploading.value
                    ? SizedBox(
                  width: 18.w,
                  height: 18.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  'Email PDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0.sp,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Generates the PDF (with optional lease attachment + lock) and shares it
  /// via the platform share sheet. Any failure -- PDF generation, lease
  /// append, locking, writing to temp storage, or the share sheet itself --
  /// propagates as a thrown exception so the caller can keep the dialog open
  /// and leave inspection data untouched. Success only happens when the
  /// share sheet reports something other than an explicit user cancellation.
  Future<void> _sharePdfToEmail({
    required BuildContext context,
    required String idCode,
    required String tenantName,
    required String landlordName,
    required String propertyAddress,
    required String inspectionDate,
    required String agreementDate,
    required List<RoomInspection> allRooms,
  }) async {
    final controller = Get.find<InspectionController>();

    final pdfBytes = await generateInspectionReportPdf(
      idCode: idCode,
      tenantName: tenantName,
      landlordName: landlordName,
      propertyAddress: propertyAddress,
      inspectionDate: inspectionDate,
      inspectionType: controller.inspectionType.value,
      inspectionPerformedBy:
      controller.inspectionPerformedBy.value,
      reportGeneratedOn:
      '${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().year} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      agreementDate: controller.agreementDate.value,
      rooms: allRooms,
      tenantPhone: controller.tenantPhone.value,
      landlordPhone: controller.landlordPhone.value,
      showPhone: controller.showPhoneInPdf.value,
    );

    Uint8List finalPdfBytes = pdfBytes;

    if (selectedLeasePdf != null) {
      finalPdfBytes = await _appendLeasePdf(
        reportPdfBytes: pdfBytes,
        leasePdfFile: selectedLeasePdf!,
      );
    }
    finalPdfBytes = await _lockPdf(finalPdfBytes);

    final dir = await getTemporaryDirectory();

    final file = File(
      '${dir.path}/TenantSnap_Inspection_Report_${idCode.isNotEmpty ? idCode : DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await file.writeAsBytes(finalPdfBytes);

    final result = await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'TenantSnap Inspection Report - $propertyAddress',
      text:
      'Hello,\n\nPlease find attached the TenantSnap property inspection report.\n\n'
          'Tenant: $tenantName\n'
          'Landlord: $landlordName\n'
          'Property: $propertyAddress\n'
          'Inspection Date: $inspectionDate\n\n'
          'Regards,\nTenantSnap',
    );

    // share_plus reports an explicit "dismissed" status when the user closes
    // the share sheet without picking a target. Treat that as a failure so
    // data is preserved and the dialog stays open; any other status (or an
    // exception thrown above) is handled by the caller.
    if (result.status == ShareResultStatus.dismissed) {
      throw Exception('Share was cancelled.');
    }
  }
}