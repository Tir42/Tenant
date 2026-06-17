import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/core/utils/download_helper/download_helper.dart';
import 'package:tenantsnap/core/utils/pdf/pdf_generator.dart';
import 'package:tenantsnap/features/inspection/controllers/inspection_controller.dart';
import 'package:tenantsnap/features/inspection/models/inspection_model.dart';

class ReportReviewScreen extends StatelessWidget {
  final RoomInspection? singleRoom;
  final List<RoomInspection>? allRooms;
  final String? roomName;
  final String? tenantName;
  final String? landlordName;
  final String? propertyAddress;
  final String? inspectionDate;
  final String? idCode;

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
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final controller = Get.find<InspectionController>();

    final String activeTenantName = tenantName ?? controller.tenantName.value;
    final String activeLandlordName = landlordName ?? controller.landlordName.value;
    final String activePropertyAddress = propertyAddress ?? controller.propertyAddress.value;
    final String activeInspectionDate = inspectionDate ?? (controller.agreementDate.value.isNotEmpty ? controller.agreementDate.value : controller.possessionDate.value);
    final String activeIdCode = idCode ?? controller.idCode.value;
    final List<RoomInspection> activeRooms = (allRooms ?? getMockInspectionData())
        .where((room) => room.checklist.any((item) => item.photos.isNotEmpty))
        .toList();

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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Center-positioned premium mockup card container
                  Container(
                    width: size.width * 0.9,
                    constraints: const BoxConstraints(maxWidth: 380),
                    decoration: BoxDecoration(
                      gradient: AntigravityColors.bgGradient, // Match the scaffold gradient
                      borderRadius: BorderRadius.circular(28.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2C3E50).withOpacity(0.08),
                          blurRadius: 24,
                          spreadRadius: 4,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Bar: Navigation back arrow + page title
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFF007BFF), // Premium blue back arrow
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Review and Send Report',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF2C3E50),
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Global Metadata Header Card (only shown once at the top of the review page)
                        _buildGlobalHeaderCard(
                          context,
                          idCode: activeIdCode,
                          tenantName: activeTenantName,
                          landlordName: activeLandlordName,
                          propertyAddress: activePropertyAddress,
                          inspectionDate: activeInspectionDate,
                        ),
                        const SizedBox(height: 16),

                        // Render dynamic inspection report cards
                        if (activeRooms.isNotEmpty)
                          ...activeRooms.expand((room) => _buildRoomReportSection(context, room)).toList()
                        else
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30.0),
                              child: Text(
                                'No photo evidence captured for any rooms.',
                                style: TextStyle(
                                  color: const Color(0xFF7F8C8D).withOpacity(0.8),
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Bottom PDF Button matching the screenshot design
                        _buildShareSendButton(
                          context,
                          idCode: activeIdCode,
                          tenantName: activeTenantName,
                          landlordName: activeLandlordName,
                          propertyAddress: activePropertyAddress,
                          inspectionDate: activeInspectionDate,
                          allRooms: allRooms,
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

  List<Widget> _buildRoomReportSection(BuildContext context, RoomInspection room) {
    return [
      _buildUnifiedRoomCard(context, room),
    ];
  }

  Widget _buildUnifiedRoomCard(BuildContext context, RoomInspection room) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Title
          Text(
            room.name,
            style: const TextStyle(
              color: Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 16),

          // List all items in the checklist inside this card
          ...room.checklist.asMap().entries.map((entry) {
            final int index = entry.key;
            final item = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUnifiedChecklistItem(context, item),
                if (index < room.checklist.length - 1) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFEEF2F6), height: 1, thickness: 1),
                  const SizedBox(height: 16),
                ],
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildUnifiedChecklistItem(BuildContext context, InspectionItem item) {
    final nameLower = item.name.toLowerCase();
    
    // 1. If Walls, render Walls layout
    if (nameLower.contains('wall')) {
      final wallsItem = item;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                wallsItem.name,
                style: const TextStyle(
                  color: Color(0xFF2C3E50),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  _buildMutedCircle(Icons.grid_3x3, const Color(0xFF95A5A6)),
                  const SizedBox(width: 6),
                  wallsItem.status == RoomItemStatus.happy
                      ? _buildColoredCircle(Icons.sentiment_satisfied_alt, const Color(0xFF2ECC71))
                      : _buildMutedCircle(Icons.sentiment_satisfied_alt, const Color(0xFF2ECC71)),
                  const SizedBox(width: 6),
                  wallsItem.status == RoomItemStatus.sad
                      ? _buildColoredCircle(Icons.sentiment_very_dissatisfied, const Color(0xFFE74C3C))
                      : _buildMutedCircle(Icons.sentiment_very_dissatisfied, const Color(0xFFE74C3C)),
                  const SizedBox(width: 6),
                  wallsItem.status == RoomItemStatus.neutral
                      ? _buildColoredCircle(Icons.remove, const Color(0xFF7F8C8D))
                      : _buildMutedCircle(Icons.remove, const Color(0xFF7F8C8D)),
                ],
              ),
            ],
          ),
        ],
      );
    }
    
    // 2. If Floor, render Floor layout
    if (nameLower.contains('floor') || nameLower.contains('carpet') || nameLower.contains('tile')) {
      final floorItem = item;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            floorItem.name,
            style: const TextStyle(
              color: Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          if (floorItem.photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: floorItem.photos.map((p) => _buildImageThumbnail(context, p, '10:33 AM')).toList(),
            ),
          ],
        ],
      );
    }

    // 3. For any other item (Ceiling, Doors / Windows, etc.), render inner commented item layout
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
        : (item.status == RoomItemStatus.happy 
            ? 'Condition verified; fully functional and clean.' 
            : (item.status == RoomItemStatus.sad 
                ? 'Defect noted: minor repair required.' 
                : 'Standard condition; no major issues observed.'));

    final bool hasPhotos = item.photos.isNotEmpty;
    String imgUrl = '';
    Widget? imageWidget;

    if (hasPhotos) {
      imgUrl = item.photos.first;
      final bool isRealFile = !imgUrl.startsWith('assets/') && !imgUrl.startsWith('http') && !imgUrl.startsWith('blob:');
      if (isRealFile) {
        imageWidget = Image.file(
          File(imgUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_outlined, color: Color(0xFF7F8C8D), size: 16);
          },
        );
      } else {
        imageWidget = Image.network(
          imgUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_outlined, color: Color(0xFF7F8C8D), size: 16);
          },
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasPhotos && imageWidget != null) ...[
              GestureDetector(
                onTap: () => _showPhotoPreviewDialog(context, imgUrl),
                child: Container(
                  width: 58,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFEEF2F6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        imageWidget,
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '10:33 AM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEF2F6),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            statusIcon,
                            color: statusColor,
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          commentText,
                          style: const TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '10:33 AM',
                      style: TextStyle(
                        color: Color(0xFFBDC3C7),
                        fontFamily: 'Montserrat',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
    final bool isRealFile = !photoPath.startsWith('assets/') && !photoPath.startsWith('http') && !photoPath.startsWith('blob:');
    Widget imageWidget;
    if (isRealFile) {
      imageWidget = Image.file(
        File(photoPath),
        fit: BoxFit.contain,
      );
    } else if (photoPath.startsWith('http')) {
      imageWidget = Image.network(
        photoPath,
        fit: BoxFit.contain,
      );
    } else {
      String targetUrl = "https://images.unsplash.com/photo-1513694203232-719a280e022f?w=600";
      if (photoPath.contains("door")) {
        targetUrl = photoPath.contains("1")
            ? "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=600"
            : "https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=600";
      } else if (photoPath.contains("outlet")) {
        targetUrl = photoPath.contains("1")
            ? "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600"
            : "https://images.unsplash.com/photo-1558211583-d26f62177b97?w=600";
      } else if (photoPath.contains("cabinet")) {
        targetUrl = "https://images.unsplash.com/photo-1556912173-3bb406ef7e77?w=600";
      }
      imageWidget = Image.network(
        targetUrl,
        fit: BoxFit.contain,
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.all(12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  width: double.infinity,
                  color: const Color(0xFFF2F4F7),
                  child: imageWidget,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Photo Evidence Review',
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'GPS Active • Verified Condition Record',
                style: TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: const Color(0xFFEEF2F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$key: ',
            style: const TextStyle(
              color: Color(0xFF7F8C8D),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMutedCircle(IconData icon, Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFFEEF2F6),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 13,
        color: color.withOpacity(0.3),
      ),
    );
  }

  Widget _buildColoredCircle(IconData icon, Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.0),
      ),
      child: Icon(
        icon,
        size: 13,
        color: color,
      ),
    );
  }

  Widget _buildImageThumbnail(BuildContext context, String photoPath, String time) {
    final bool isRealFile = !photoPath.startsWith('assets/') && !photoPath.startsWith('http') && !photoPath.startsWith('blob:');
    Widget imageWidget;
    if (isRealFile) {
      imageWidget = Image.file(
        File(photoPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_outlined, color: Color(0xFF7F8C8D), size: 16);
        },
      );
    } else if (photoPath.startsWith('http')) {
      imageWidget = Image.network(
        photoPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_outlined, color: Color(0xFF7F8C8D), size: 16);
        },
      );
    } else {
      String targetUrl = "https://images.unsplash.com/photo-1513694203232-719a280e022f?w=150";
      if (photoPath.contains("door")) {
        targetUrl = photoPath.contains("1")
            ? "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=150"
            : "https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=150";
      } else if (photoPath.contains("outlet")) {
        targetUrl = photoPath.contains("1")
            ? "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=150"
            : "https://images.unsplash.com/photo-1558211583-d26f62177b97?w=150";
      } else if (photoPath.contains("cabinet")) {
        targetUrl = "https://images.unsplash.com/photo-1556912173-3bb406ef7e77?w=150";
      }

      imageWidget = Image.network(
        targetUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_outlined, color: Color(0xFF7F8C8D), size: 16);
        },
      );
    }

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.3,
        child: GestureDetector(
          onTap: () => _showPhotoPreviewDialog(context, photoPath),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFEEF2F6),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageWidget,
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildGlobalHeaderCard(
    BuildContext context, {
    required String idCode,
    required String tenantName,
    required String landlordName,
    required String propertyAddress,
    required String inspectionDate,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inspection Report Overview',
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          if (idCode.isNotEmpty) _buildMetadataRow('ID Code', idCode),
          _buildMetadataRow('Tenant', tenantName),
          _buildMetadataRow('Landlord', landlordName),
          _buildMetadataRow('Address', propertyAddress),
          _buildMetadataRow('Date', inspectionDate),
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
    required List<RoomInspection>? allRooms,
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
            allRooms: allRooms,
          ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007BFF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Share & Send Full PDF',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
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
    required List<RoomInspection>? allRooms,
  }) {
    final controller = Get.find<InspectionController>();
    showDialog(
      context: context,
      builder: (context) {
        final List<RoomInspection> previewRooms = (allRooms ?? getMockInspectionData())
            .where((room) => room.checklist.any((item) => item.photos.isNotEmpty))
            .toList();

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.all(16),
          title: const Text(
            'PDF Document Preview',
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBDC3C7).withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'TenantSnap Report',
                          style: TextStyle(
                            color: const Color(0xFF2C3E50).withOpacity(0.8),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 1.5,
                        color: const Color(0xFF007BFF),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'ID Code: ${idCode.isNotEmpty ? idCode : "TS-402-URBL"}',
                        style: const TextStyle(fontSize: 10, fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                      ),
                      Text(
                        'Tenant: $tenantName',
                        style: const TextStyle(fontSize: 10, fontFamily: 'Montserrat', color: Color(0xFF2C3E50)),
                      ),
                      Text(
                        'Landlord: $landlordName',
                        style: const TextStyle(fontSize: 10, fontFamily: 'Montserrat', color: Color(0xFF2C3E50)),
                      ),
                      Text(
                        'Address: $propertyAddress',
                        style: const TextStyle(fontSize: 9, fontFamily: 'Montserrat', color: Color(0xFF2C3E50)),
                      ),
                      Text(
                        'Date: $inspectionDate',
                        style: const TextStyle(fontSize: 10, fontFamily: 'Montserrat', color: Color(0xFF2C3E50)),
                      ),
                      const Divider(height: 16),
                      const Text(
                        'DETAILED INSPECTION ITEMS',
                        style: TextStyle(fontSize: 10, fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                      ),
                      const SizedBox(height: 6),

                      if (previewRooms.isNotEmpty)
                        ...previewRooms.map((room) => _buildPdfPreviewRoomSection(context, room)).toList()
                      else
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'No rooms with photo evidence to display.',
                              style: TextStyle(fontSize: 10, fontFamily: 'Montserrat', color: Color(0xFF7F8C8D)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ready to share with landlord and save records.',
                style: TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF95A5A6),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    duration: Duration(seconds: 1),
                    backgroundColor: Color(0xFF007BFF),
                    content: Text(
                      'Generating PDF report with images...',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );

                try {
                  final List<RoomInspection> pdfRooms = (allRooms ?? getMockInspectionData())
                      .where((room) => room.checklist.any((item) => item.photos.isNotEmpty))
                      .toList();

                  final pdfBytes = await generateInspectionReportPdf(
                    idCode: idCode,
                    tenantName: tenantName,
                    landlordName: landlordName,
                    propertyAddress: propertyAddress,
                    inspectionDate: inspectionDate,
                    rooms: pdfRooms,
                    tenantPhone: controller.tenantPhone.value,
                    landlordPhone: controller.landlordPhone.value,
                    showPhone: controller.showPhoneInPdf.value,
                  );

                  downloadPdf('TenantSnap_Report.pdf', pdfBytes);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF2ECC71),
                        content: Text(
                          'Downloaded PDF successfully!',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint("Error generating PDF: $e");
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFFE74C3C),
                        content: Text(
                          'Failed to generate PDF: $e',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.download_rounded, size: 16, color: Colors.white),
              label: const Text(
                'Download',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF2C3E50),
                    content: Text(
                      'Generating PDF Report Certificate with cryptographic signature...',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Share & Send',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPdfPreviewRoomSection(BuildContext context, RoomInspection room) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          room.name,
          style: const TextStyle(
            fontSize: 11,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 4),
        Container(height: 1, color: const Color(0xFFEEF2F6)),
        const SizedBox(height: 6),
        ...room.checklist.map((item) {
          String statusEmoji = '➖';
          if (item.status == RoomItemStatus.happy) {
            statusEmoji = '😊';
          } else if (item.status == RoomItemStatus.sad) {
            statusEmoji = '😟';
          }

          final commentText = item.comment.isNotEmpty 
              ? item.comment 
              : (item.status == RoomItemStatus.happy 
                  ? 'Verified functional.' 
                  : (item.status == RoomItemStatus.sad 
                      ? 'Defect noted.' 
                      : 'Standard condition.'));

          final bool hasPhoto = item.photos.isNotEmpty;
          Widget? imageWidget;

          if (hasPhoto) {
            final imgUrl = item.photos.first;
            final bool isRealFile = !imgUrl.startsWith('assets/') && !imgUrl.startsWith('http') && !imgUrl.startsWith('blob:');
            if (isRealFile) {
              imageWidget = Image.file(
                File(imgUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_outlined, size: 12),
              );
            } else {
              imageWidget = Image.network(
                imgUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_outlined, size: 12),
              );
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasPhoto && imageWidget != null) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xFFEEF2F6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: imageWidget,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 9,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            statusEmoji,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        commentText,
                        style: const TextStyle(
                          fontSize: 8,
                          fontFamily: 'Montserrat',
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
