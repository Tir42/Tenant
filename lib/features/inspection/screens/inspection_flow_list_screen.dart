import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/core/utils/responsive/responsive_extension.dart';
import 'package:tenantsnap/features/inspection/models/inspection_model.dart';
import 'package:tenantsnap/features/inspection/controllers/inspection_controller.dart';
import 'package:tenantsnap/features/dashboard/screens/tenant_dashboard_screen.dart';
import '../../property/screens/property_details_screen.dart';
import 'room_detail_screen.dart';
import 'report_review_screen.dart';

class InspectionFlowListScreen extends StatefulWidget {
  const InspectionFlowListScreen({super.key});

  @override
  State<InspectionFlowListScreen> createState() => _InspectionFlowListScreenState();
}

class _InspectionFlowListScreenState extends State<InspectionFlowListScreen> {
  final ScrollController _listScrollController = ScrollController();
  final InspectionController controller = Get.find<InspectionController>();



  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  // Launch dialog to add custom rooms
  void _showAddRoomDialog() {
    final TextEditingController nameController = TextEditingController();
    IconData selectedIcon = Icons.home_outlined;

    final List<Map<String, dynamic>> iconsList = [
      {'icon': Icons.bed_outlined, 'name': 'Bedroom'},
      {'icon': Icons.chair_outlined, 'name': 'Living'},
      {'icon': Icons.tungsten_outlined, 'name': 'Lamp'},
      {'icon': Icons.kitchen_outlined, 'name': 'Kitchen'},
      {'icon': Icons.bathtub_outlined, 'name': 'Bath'},
      {'icon': Icons.local_laundry_service_outlined, 'name': 'Washer'},
      {'icon': Icons.door_front_door_outlined, 'name': 'Door'},
      {'icon': Icons.balcony_outlined, 'name': 'Balcony'},
      {'icon': Icons.home_outlined, 'name': 'Utilities'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0.w),
              ),
              title: Text(
                'Add Custom Room',
                style: TextStyle(
                  color: const Color(0xFF2C3E50),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0.sp,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      style: TextStyle(
                        color: const Color(0xFF2C3E50),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter room name...',
                        hintStyle: TextStyle(
                          color: const Color(0xFF95A5A6),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontSize: 13.0.sp,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F4F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0.w),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 14.0.h),
                      ),
                    ),
                    SizedBox(height: 20.0.h),
                    Text(
                      'SELECT ICON',
                      style: TextStyle(
                        color: const Color(0xFF95A5A6),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 10.0.sp,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 10.0.h),
                    Wrap(
                      spacing: 10.0.w,
                      runSpacing: 10.0.h,
                      children: iconsList.map((iconMap) {
                        final bool isSel = selectedIcon == iconMap['icon'];
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedIcon = iconMap['icon'];
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(10.0.w),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF007BFF).withValues(alpha: 0.08) : const Color(0xFFF2F4F7),
                              border: Border.all(
                                color: isSel ? const Color(0xFF007BFF) : Colors.transparent,
                                width: 1.5.w,
                              ),
                              borderRadius: BorderRadius.circular(12.0.w),
                            ),
                            child: Icon(
                              iconMap['icon'],
                              color: isSel ? const Color(0xFF007BFF) : const Color(0xFF2C3E50),
                              size: 24.w,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: const Color(0xFF95A5A6),
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0.sp,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      controller.addRoom(name, selectedIcon);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0.w),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 10.0.h),
                  ),
                  child: Text(
                    'Add Room',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 14.0.sp,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.offAll(() => const PropertyDetailsScreen());
            }
          },
          child: Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6.0.w,
                  offset: Offset(0, 2.0.h),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_rounded,
                color: const Color(0xFF2C3E50),
                size: 20.w,
              ),
            ),
          ),
        ),
        SizedBox(width: 14.0.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell Us About Your Home',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF2C3E50),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 18.0.sp,
                ),
              ),
              SizedBox(height: 2.0.h),
              Text(
                'Configure room checklist structures',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF7F8C8D),
                  fontFamily: 'Montserrat',
                  fontSize: 12.0.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0.h, horizontal: 16.0.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.0.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFBDC3C7).withValues(alpha: 0.2),
                  width: 1.0.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6.0.w,
                    offset: Offset(0, 2.0.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.holiday_village_outlined,
                color: const Color(0xFF8F9CA9),
                size: 40.w,
              ),
            ),
            SizedBox(height: 16.0.h),
            Text(
              'No Spaces Added Yet',
              style: TextStyle(
                color: const Color(0xFF2C3E50),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w800,
                fontSize: 16.0.sp,
              ),
            ),
            SizedBox(height: 8.0.h),
            Text(
              'Begin your property inspection by adding rooms or checklist areas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF7F8C8D),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                fontSize: 12.0.sp,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AntigravityColors.bgGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 16.0.h),
            child: Obx(() {
              final roomsList = controller.roomsList;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 24.0.h),
                  Text(
                    'PROPERTY SPACES',
                    style: TextStyle(
                      color: const Color(0xFF7F8C8D),
                      fontFamily: 'Montserrat',
                      fontSize: 11.0.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: 16.0.h),
                  Expanded(
                    child: roomsList.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: roomsList.length,
                      itemBuilder: (context, index) {
                        return _buildRoomTile(context, roomsList[index]);
                      },
                    ),
                  ),
                  SizedBox(height: 20.0.h),
                  _buildAddRoomButton(),
                  if (roomsList.isNotEmpty) ...[
                    SizedBox(height: 12.0.h),
                    _buildReviewReportButton(context),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Emoji-status count chip (😊 / 😢 / ➖)
  // ---------------------------------------------------------------------------

  Widget _buildStatusChip({
    required IconData icon,
    required Color color,
    required int count,
  }) {
    if (count == 0) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(right: 10.0.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.0.w, color: color),
          SizedBox(width: 3.0.w),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 11.0.sp,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStarRating(double rating) {
    final List<Widget> stars = [];

    for (int i = 1; i <= 5; i++) {
      IconData icon;
      if (rating >= i) {
        icon = Icons.star_rounded;
      } else if (rating >= i - 0.5) {
        icon = Icons.star_half_rounded;
      } else {
        icon = Icons.star_border_rounded;
      }

      stars.add(Icon(
        icon,
        size: 13.0.w,
        color: const Color(0xFFF5A623),
      ));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  Widget _buildRoomTile(BuildContext context, RoomInspection room) {
    int photoCount = 0;
    int happyCount = 0;
    int sadCount = 0;
    int neutralCount = 0;
    int itemsWithPhotos = 0;

    for (var item in room.checklist) {
      photoCount += item.photos.length;

      if (item.photos.isNotEmpty) {
        itemsWithPhotos++;
      }

      switch (item.status) {
        case RoomItemStatus.happy:
          happyCount++;
          break;
        case RoomItemStatus.sad:
          sadCount++;
          break;
        case RoomItemStatus.neutral:
          neutralCount++;
          break;
      }
    }

    final int totalItems = room.checklist.length;

    final bool hasInspectionData =
        happyCount > 0 ||
            sadCount > 0 ||
            photoCount > 0 ||
            room.checklist.any((item) => item.comment.trim().isNotEmpty);


    final int ratedItems = happyCount + sadCount;

    double rating = 0;

    if (ratedItems > 0) {
      rating = 5 * happyCount / ratedItems;
    }

    // final bool hasInspectionData =
    //     ratedItems > 0 ||
    //         photoCount > 0 ||
    //         room.checklist.any(
    //               (item) => item.comment.trim().isNotEmpty,
    //         );

    String displayLeftName = room.name;
    if (displayLeftName == "Utility / Laundry Room") displayLeftName = "Laundry";
    if (displayLeftName == "Pantry / Storage Room") displayLeftName = "Pantry";
    if (displayLeftName == "Balcony / Terrace") displayLeftName = "Balcony";
    if (displayLeftName == "Garage / Carport") displayLeftName = "Garage";
    if (displayLeftName == "Study / Office Room") displayLeftName = "Study";
    if (displayLeftName == "Basement / Cellar") displayLeftName = "Basement";
    if (displayLeftName == "Attic / Loft") displayLeftName = "Attic";
    if (displayLeftName == "Sunroom / Conservatory") displayLeftName = "Sunroom";
    if (displayLeftName == "Workshop / Hobby Room") displayLeftName = "Workshop";
    if (displayLeftName == "Living Room / Lounge") displayLeftName = "Living Room";
    if (displayLeftName == "Entry / Mudroom") displayLeftName = "Entry";

    final String subtitleText =
    photoCount > 0 ? "$photoCount photos" : "No photos captured";

    return Padding(
      padding: EdgeInsets.only(bottom: 12.0.h),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0.w),
          border: Border.all(
            color: const Color(0xFFBDC3C7).withValues(alpha: 0.2),
            width: 1.0.w,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C3E50).withValues(alpha: 0.04),
              blurRadius: 8.0.w,
              offset: Offset(0, 4.0.h),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Get.to(() => RoomDetailScreen(roomId: room.id));
          },
          borderRadius: BorderRadius.circular(16.0.w),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 14.0.h),
            child: Row(
              children: [
                Icon(
                  room.icon,
                  color: const Color(0xFF2C3E50),
                  size: 22.w,
                ),
                SizedBox(width: 16.0.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayLeftName,
                        style: TextStyle(
                          color: const Color(0xFF2C3E50),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w800,
                          fontSize: 14.0.sp,
                        ),
                      ),
                      SizedBox(height: 4.0.h),
                      Row(
                        children: [
                          if (subtitleText.isNotEmpty) ...[
                            Text(
                              subtitleText,
                              style: TextStyle(
                                color: const Color(0xFF8F9CA9),
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                fontSize: 11.0.sp,
                              ),
                            ),
                            SizedBox(width: 10.0.w),
                          ],
                          _buildStatusChip(
                            icon: Icons.sentiment_satisfied_alt,
                            color: const Color(0xFF2ECC71),
                            count: happyCount,
                          ),
                          _buildStatusChip(
                            icon: Icons.sentiment_very_dissatisfied,
                            color: const Color(0xFFE74C3C),
                            count: sadCount,
                          ),
                        ],
                      ),
                      if (hasInspectionData) ...[
                        SizedBox(height: 4.0.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStarRating(rating),
                            SizedBox(width: 6.0.w),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: const Color(0xFF8F9CA9),
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 10.0.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFF8F9CA9),
                  size: 20.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddRoomButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showAddRoomDialog,
        borderRadius: BorderRadius.circular(25.0.w),
        child: Container(
          height: 50.0.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(25.0.w),
            border: Border.all(
              color: const Color(0xFF007BFF),
              width: 1.5.w,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007BFF).withValues(alpha: 0.05),
                blurRadius: 8.0.w,
                offset: Offset(0, 3.0.h),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(4.0.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF007BFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 12.w,
                ),
              ),
              SizedBox(width: 10.0.w),
              Text(
                'Add Custom Room',
                style: TextStyle(
                  color: const Color(0xFF007BFF),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewReportButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // propertyAddress already contains the complete address
          final String address =
          controller.propertyAddress.value.trim();

          Get.to(
                () => ReportReviewScreen(
              allRooms: controller.roomsList,
              tenantName: controller.tenantName.value,
              landlordName: controller.landlordName.value,
              propertyAddress: address,
              inspectionDate:
              controller.agreementDate.value.isNotEmpty
                  ? controller.agreementDate.value
                  : controller.possessionDate.value,
              idCode: controller.idCode.value,
            ),
          );
        },
        borderRadius: BorderRadius.circular(25.0.w),
        child: Container(
          height: 50.0.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF007BFF),
                Color(0xFF0056B3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25.0.w),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007BFF)
                    .withValues(alpha: 0.3),
                blurRadius: 12.0.w,
                offset: Offset(0, 4.0.h),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_turned_in_outlined,
                color: Colors.white,
                size: 18.w,
              ),
              SizedBox(width: 8.0.w),
              Text(
                'Review & Send Report',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}