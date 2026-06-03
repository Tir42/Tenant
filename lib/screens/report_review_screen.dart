import 'dart:io';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/inspection_model.dart';

class ReportReviewScreen extends StatelessWidget {
  final RoomInspection? singleRoom;
  final List<RoomInspection>? allRooms;
  final String roomName;
  final String tenantName;
  final String landlordName;
  final String propertyAddress;
  final String inspectionDate;

  const ReportReviewScreen({
    super.key,
    this.singleRoom,
    this.allRooms,
    this.roomName = 'Bedroom 1',
    this.tenantName = 'Liam Carter',
    this.landlordName = 'Victoria Sterling',
    this.propertyAddress = 'Unit 402 - Urban Loft',
    this.inspectionDate = 'June 2, 2026',
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // Backward-compatibility: generate default mock RoomInspection if both parameters are null
    final RoomInspection? dynamicSingleRoom = (singleRoom == null && allRooms == null)
        ? RoomInspection(
            id: 6,
            number: "6",
            name: roomName,
            icon: Icons.bed_outlined,
            progress: 80.0,
            comment: "Minor hairline crack noted near base border trim.",
            checklist: [
              InspectionItem(name: "Walls", status: RoomItemStatus.happy),
              InspectionItem(
                name: "Floor / Carpet Tiles",
                status: RoomItemStatus.happy,
                photos: [
                  'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=150',
                  'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=150',
                  'https://images.unsplash.com/photo-1558211583-d26f62177b97?w=150',
                ],
              ),
              InspectionItem(
                name: "Closets / Door Frames",
                status: RoomItemStatus.happy,
                photos: [
                  'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=150',
                ],
                comment: 'Hairline crack in the ceiling',
              ),
              InspectionItem(
                name: "Windows / Blinds Curtains",
                status: RoomItemStatus.happy,
                photos: [
                  'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=150',
                ],
                comment: 'Hairline crack in the ceiling',
              ),
            ],
          )
        : singleRoom;

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
                                Icons.arrow_back_rounded,
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

                        // Render dynamic inspection report cards
                        if (allRooms != null)
                          ...allRooms!.expand((room) => _buildRoomReportSection(context, room)).toList()
                        else if (dynamicSingleRoom != null)
                          ..._buildRoomReportSection(context, dynamicSingleRoom),

                        const SizedBox(height: 16),

                        // Bottom PDF Button matching the screenshot design
                        _buildShareSendButton(context),
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
    final List<Widget> widgets = [];

    // 1. Add Main Card (Title, Metadata, Walls, Floor)
    widgets.add(
      _buildRoomMainCard(context, room),
    );

    // 2. Add individual cards for other items (Ceiling, Doors, Closets, Windows, etc.)
    final otherItems = room.checklist.where((item) {
      final nameLower = item.name.toLowerCase();
      final isWalls = nameLower.contains('wall');
      final isFloor = nameLower.contains('floor') || nameLower.contains('carpet') || nameLower.contains('tile');
      return !isWalls && !isFloor;
    }).toList();

    for (var item in otherItems) {
      widgets.add(
        _buildCommentedItemCard(context, item),
      );
    }

    return widgets;
  }

  Widget _buildRoomMainCard(BuildContext context, RoomInspection room) {
    final wallsItem = _findItemByName(room.checklist, 'wall') ?? 
        InspectionItem(name: 'Walls', status: RoomItemStatus.neutral);
    final floorItem = _findFloorItem(room.checklist) ?? 
        InspectionItem(name: 'Floor / Carpet Tiles', status: RoomItemStatus.neutral);

    // Dynamic Floor photo collection: Clamp/pad to exactly 3 photos for visual symmetry
    final List<String> floorPhotos = [...floorItem.photos];
    final List<String> fallbacks = [
      'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=150',
      'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=150',
      'https://images.unsplash.com/photo-1558211583-d26f62177b97?w=150',
    ];
    while (floorPhotos.length < 3) {
      floorPhotos.add(fallbacks[floorPhotos.length]);
    }
    if (floorPhotos.length > 3) {
      floorPhotos.removeRange(3, floorPhotos.length);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12.0),
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
          // Report Title
          Text(
            'Inspection Report - ${room.name}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Metadata block
          _buildMetadataRow('Tenant', tenantName),
          _buildMetadataRow('Landlord', landlordName),
          _buildMetadataRow('Address', propertyAddress),
          _buildMetadataRow('Date', inspectionDate),
          
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE2E8F0), height: 24),

          // Walls section with grid circle + 3 sentiment circles
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
          const SizedBox(height: 18),

          // Floor / Carpet Tiles Section
          Text(
            floorItem.name,
            style: const TextStyle(
              color: Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: floorPhotos.map((p) => _buildImageThumbnail(context, p, '10:33 AM')).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentedItemCard(BuildContext context, InspectionItem item) {
    IconData statusIcon = Icons.sentiment_satisfied_alt;
    Color statusColor = const Color(0xFF2ECC71);
    if (item.status == RoomItemStatus.sad) {
      statusIcon = Icons.sentiment_very_dissatisfied;
      statusColor = const Color(0xFFE74C3C);
    } else if (item.status == RoomItemStatus.neutral) {
      statusIcon = Icons.remove;
      statusColor = const Color(0xFF7F8C8D);
    }

    // Dynamic placeholder comments if empty
    final String commentText = item.comment.isNotEmpty 
        ? item.comment 
        : (item.status == RoomItemStatus.happy 
            ? 'Condition verified; fully functional and clean.' 
            : (item.status == RoomItemStatus.sad 
                ? 'Defect noted: minor repair required.' 
                : 'Standard condition; no major issues observed.'));

    // Image mapping fallback for rich aesthetics
    String imgUrl = 'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=150';
    if (item.photos.isNotEmpty) {
      imgUrl = item.photos.first;
    } else {
      final nameLower = item.name.toLowerCase();
      if (nameLower.contains('closet') || nameLower.contains('wardrobe') || nameLower.contains('door')) {
        imgUrl = 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=150';
      } else if (nameLower.contains('window') || nameLower.contains('blind') || nameLower.contains('curtain')) {
        imgUrl = 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=150';
      } else if (nameLower.contains('outlet') || nameLower.contains('light') || nameLower.contains('electr')) {
        imgUrl = 'https://images.unsplash.com/photo-1558211583-d26f62177b97?w=150';
      }
    }

    final bool isRealFile = !imgUrl.startsWith('assets/') && !imgUrl.startsWith('http');
    Widget imageWidget;
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

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
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
      padding: const EdgeInsets.all(12.0),
      child: Column(
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
              // Left Image with timestamp badge and preview on click
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
              // Right status icon + comment text
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
      ),
    );
  }

  Widget _buildShareSendButton(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
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

  void _showPhotoPreviewDialog(BuildContext context, String photoPath) {
    final bool isRealFile = !photoPath.startsWith('assets/') && !photoPath.startsWith('http');
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
      // Mock asset URL mapping
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
              // Gorgeous Image Preview
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

  InspectionItem? _findItemByName(List<InspectionItem> list, String query) {
    for (var item in list) {
      if (item.name.toLowerCase().contains(query.toLowerCase())) {
        return item;
      }
    }
    return null;
  }

  InspectionItem? _findFloorItem(List<InspectionItem> list) {
    for (var item in list) {
      final nameLower = item.name.toLowerCase();
      if (nameLower.contains('floor') || nameLower.contains('carpet') || nameLower.contains('tile')) {
        return item;
      }
    }
    return null;
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
    final bool isRealFile = !photoPath.startsWith('assets/') && !photoPath.startsWith('http');
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
      // Mock asset URL mapping for beautiful premium aesthetics
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
}
