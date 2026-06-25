import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/core/utils/download_helper/download_helper.dart';
import 'package:tenantsnap/core/utils/pdf/pdf_generator.dart';
import 'package:tenantsnap/core/services/rest_client.dart';
import 'package:tenantsnap/core/utils/responsive/responsive_extension.dart';
import 'package:tenantsnap/features/inspection/controllers/inspection_controller.dart';
import 'package:tenantsnap/features/inspection/models/inspection_model.dart';

import '../../../core/controllers/base_controller.dart';
import '../../dashboard/screens/home_screen.dart';

class ReportReviewScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final controller = Get.find<InspectionController>();

    final String activeTenantName = tenantName ?? controller.tenantName.value;
    final String activeLandlordName =
        landlordName ?? controller.landlordName.value;
    final String activePropertyAddress =
        propertyAddress ?? controller.propertyAddress.value;

    final String activeInspectionDate = controller.possessionDate.value;
    final String activeAgreementDate =
        controller.agreementDate.value;

    final String activeIdCode = idCode ?? controller.idCode.value;

    final List<RoomInspection> sourceRooms =
        allRooms ?? (singleRoom != null ? [singleRoom!] : controller.roomsList.toList());

    final List<RoomInspection> activeRooms = sourceRooms;

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
                          landlordName: activeLandlordName,
                          propertyAddress: activePropertyAddress,
                          inspectionDate: activeInspectionDate,
                            agreementDate: activeAgreementDate
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
                          propertyAddress: activePropertyAddress,
                          inspectionDate: activeInspectionDate,
                          agreementDate: activeAgreementDate,
                          allRooms: sourceRooms,
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
          ...room.checklist.asMap().entries.map((entry) {
            final int index = entry.key;
            final item = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUnifiedChecklistItem(context, item),
                if (index < room.checklist.length - 1) ...[
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
          }),
        ],
      ),
    );
  }

  Widget _buildUnifiedChecklistItem(BuildContext context, InspectionItem item) {
    final nameLower = item.name.toLowerCase();

    if (nameLower.contains('wall')) {
      return Row(
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
          Row(
            children: [
              item.status == RoomItemStatus.happy
                  ? _buildColoredCircle(
                Icons.sentiment_satisfied_alt,
                const Color(0xFF2ECC71),
              )
                  : _buildMutedCircle(
                Icons.sentiment_satisfied_alt,
                const Color(0xFF2ECC71),
              ),
              SizedBox(width: 6.0.w),
              item.status == RoomItemStatus.sad
                  ? _buildColoredCircle(
                Icons.sentiment_very_dissatisfied,
                const Color(0xFFE74C3C),
              )
                  : _buildMutedCircle(
                Icons.sentiment_very_dissatisfied,
                const Color(0xFFE74C3C),
              ),
              SizedBox(width: 6.0.w),
              item.status == RoomItemStatus.neutral
                  ? _buildColoredCircle(
                Icons.remove,
                const Color(0xFF7F8C8D),
              )
                  : _buildMutedCircle(
                Icons.remove,
                const Color(0xFF7F8C8D),
              ),
            ],
          ),
        ],
      );
    }

    if (nameLower.contains('floor') ||
        nameLower.contains('carpet') ||
        nameLower.contains('tile')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: TextStyle(
              color: const Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 14.0.sp,
            ),
          ),
          if (item.photos.isNotEmpty) ...[
            SizedBox(height: 10.0.h),
            Row(
              children: item.photos
                  .map((p) => _buildImageThumbnail(context, p, '10:33 AM'))
                  .toList(),
            ),
          ],
        ],
      );
    }

    return _buildInnerCommentedItem(context, item);
  }

  Widget _buildInnerCommentedItem(BuildContext context, InspectionItem item) {
    IconData statusIcon = Icons.sentiment_satisfied_alt;
    Color statusColor = const Color(0xFF2ECC71);

    if (item.status == RoomItemStatus.sad) {
      statusIcon = Icons.sentiment_very_dissatisfied;
      statusColor = const Color(0xFFE74C3C);
    } else if (item.status == RoomItemStatus.neutral) {
      statusIcon = Icons.remove;
      statusColor = const Color(0xFF7F8C8D);
    }

    final String commentText = item.comment.isNotEmpty
        ? item.comment
        : item.status == RoomItemStatus.happy
        ? 'Condition verified; fully functional and clean.'
        : item.status == RoomItemStatus.sad
        ? 'Defect noted: minor repair required.'
        : 'Standard condition; no major issues observed.';

    final bool hasPhotos = item.photos.isNotEmpty;
    String imgUrl = '';
    Widget? imageWidget;

    if (hasPhotos) {
      imgUrl = item.photos.first;

      final bool isRealFile = !imgUrl.startsWith('assets/') &&
          !imgUrl.startsWith('http') &&
          !imgUrl.startsWith('blob:');

      if (isRealFile) {
        imageWidget = Image.file(
          File(imgUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.image_outlined,
                color: const Color(0xFF7F8C8D),
                size: 16.w,
              ),
            );
          },
        );
      } else {
        imageWidget = Image.network(
          imgUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.image_outlined,
                color: const Color(0xFF7F8C8D),
                size: 16.w,
              ),
            );
          },
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: TextStyle(
            color: const Color(0xFF2C3E50),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
            fontSize: 14.0.sp,
          ),
        ),
        SizedBox(height: 10.0.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasPhotos && imageWidget != null) ...[
              GestureDetector(
                onTap: () {
                  _showPhotoPreviewDialog(context, imgUrl);
                },
                child: Container(
                  width: 58.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0.w),
                    color: const Color(0xFFEEF2F6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0.w),
                    child: imageWidget,
                  ),
                ),
              ),
              SizedBox(width: 10.0.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEF2F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          statusIcon,
                          color: statusColor,
                          size: 14.w,
                        ),
                      ),
                      SizedBox(width: 8.0.w),
                      Expanded(
                        child: Text(
                          commentText,
                          style: TextStyle(
                            color: const Color(0xFF7F8C8D),
                            fontFamily: 'Montserrat',
                            fontSize: 11.0.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
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

  Widget _buildMutedCircle(IconData icon, Color color) {
    return Container(
      width: 24.w,
      height: 24.h,
      decoration: const BoxDecoration(
        color: Color(0xFFEEF2F6),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 13.w,
        color: color.withValues(alpha: 0.3),
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

  Widget _buildImageThumbnail(
      BuildContext context,
      String photoPath,
      String time,
      ) {
    final bool isRealFile = !photoPath.startsWith('assets/') &&
        !photoPath.startsWith('http') &&
        !photoPath.startsWith('blob:');

    Widget imageWidget;

    if (isRealFile) {
      imageWidget = Image.file(
        File(photoPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.image_outlined,
              color: const Color(0xFF7F8C8D),
              size: 16.w,
            ),
          );
        },
      );
    } else {
      imageWidget = Image.network(
        photoPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.image_outlined,
              color: const Color(0xFF7F8C8D),
              size: 16.w,
            ),
          );
        },
      );
    }

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.3,
        child: GestureDetector(
          onTap: () {
            _showPhotoPreviewDialog(context, photoPath);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0.w),
              color: const Color(0xFFEEF2F6),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 0.5.w,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9.0.w),
              child: imageWidget,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalHeaderCard(
      BuildContext context, {
        required String idCode,
        required String tenantName,
        required String landlordName,
        required String propertyAddress,
        required String inspectionDate,
        required String agreementDate

      }) {
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
          if (idCode.isNotEmpty) _buildMetadataRow('ID Code', idCode),
          _buildMetadataRow('Tenant', tenantName),
          _buildMetadataRow('Landlord', landlordName),
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
          onTap: () => _showPdfPreviewDialog(
            context,
            idCode: idCode,
            tenantName: tenantName,
            landlordName: landlordName,
            propertyAddress: propertyAddress,
            inspectionDate: inspectionDate,
            agreementDate:agreementDate,
            allRooms: allRooms,
          ),
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

    showDialog(
      context: context,
      builder: (dialogContext) {
        final previewRooms = allRooms
            .where((room) => room.checklist.any((item) => item.photos.isNotEmpty))
            .toList();

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
              Container(
                width: double.infinity,
                height: 220.h,
                padding: EdgeInsets.all(12.0.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.0.w),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'TenantSnap Property Inspection Report',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF2C3E50),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w900,
                            fontSize: 14.0.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0.h),
                      const Divider(),
                      Text('ID Code: ${idCode.isNotEmpty ? idCode : "-"}'),
                      Text('Tenant: $tenantName'),
                      Text('Landlord: $landlordName'),
                      Text('Address: $propertyAddress'),
                      Text('inspectionDate: $inspectionDate'),
                      Text('agreementDate: $agreementDate'),
                      SizedBox(height: 10.0.h),
                      const Divider(),
                      Text('Rooms with evidence: ${previewRooms.length}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Obx(
                  () => TextButton(
                onPressed: (isDownloading.value || isUploading.value)
                    ? null
                    : () => Navigator.pop(dialogContext),
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
                onPressed: (isDownloading.value || isUploading.value)
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
                      rooms: allRooms,
                      tenantPhone: controller.tenantPhone.value,
                      landlordPhone: controller.landlordPhone.value,
                      showPhone: controller.showPhoneInPdf.value,
                        agreementDate: controller.agreementDate.value,
                    );

                    final savedPath = await DownloadHelper.downloadPdf(
                      bytes: pdfBytes,
                      fileName:
                      'TenantSnap_Inspection_Report_${idCode.isNotEmpty ? idCode : DateTime.now().millisecondsSinceEpoch}.pdf',
                    );

                    if (savedPath == null) {
                      throw Exception('PDF download failed.');
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 8),
                          backgroundColor: const Color(0xFF2ECC71),
                          content: Text(
                            'PDF saved here: $savedPath',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
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

            Obx(
                  () => ElevatedButton(
                onPressed: (isDownloading.value || isUploading.value)
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
                    if (context.mounted) {
                      // Navigator.pop(dialogContext); // close dialog
                      Get.offAll(() => HomeScreen(
                        role: 'tenant',
                        userName: BaseController.name.value,
                      ));
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
                  'Share & Send',
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

    try {
      final pdfBytes = await generateInspectionReportPdf(
        idCode: idCode,
        tenantName: tenantName,
        landlordName: landlordName,
        propertyAddress: propertyAddress,
        inspectionDate: inspectionDate,
        agreementDate: controller.agreementDate.value,
        rooms: allRooms,
        tenantPhone: controller.tenantPhone.value,
        landlordPhone: controller.landlordPhone.value,
        showPhone: controller.showPhoneInPdf.value,
      );

      final dir = await getTemporaryDirectory();

      final file = File(
        '${dir.path}/TenantSnap_Inspection_Report_${idCode.isNotEmpty ? idCode : DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'TenantSnap Inspection Report',
        text: 'Please find attached the TenantSnap property inspection report.',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share PDF: $e')),
        );
      }
    }
  }
  }

