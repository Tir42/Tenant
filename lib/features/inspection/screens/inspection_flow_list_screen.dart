import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/features/inspection/models/inspection_model.dart';
import 'package:tenantsnap/features/inspection/controllers/inspection_controller.dart';
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
      {'icon': Icons.home_outlined, 'name': 'Utils'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Add Custom Room',
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter room name...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF95A5A6),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F4F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SELECT ICON',
                      style: TextStyle(
                        color: Color(0xFF95A5A6),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: iconsList.map((iconMap) {
                        final bool isSel = selectedIcon == iconMap['icon'];
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedIcon = iconMap['icon'];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF007BFF).withOpacity(0.08) : const Color(0xFFF2F4F7),
                              border: Border.all(
                                color: isSel ? const Color(0xFF007BFF) : Colors.transparent,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              iconMap['icon'],
                              color: isSel ? const Color(0xFF007BFF) : const Color(0xFF2C3E50),
                              size: 24,
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
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF95A5A6),
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text(
                    'Add Room',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

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
                  Container(
                    width: size.width * 0.9,
                    constraints: const BoxConstraints(maxWidth: 380),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
                    child: Obx(() {
                      final roomsList = controller.roomsList;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tell Us About Your\nNew Home',
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (roomsList.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF2F4F7),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFBDC3C7).withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.holiday_village_outlined,
                                        color: Color(0xFF8F9CA9),
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No Spaces Added Yet',
                                      style: TextStyle(
                                        color: Color(0xFF2C3E50),
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Begin your property inspection by adding rooms or checklist areas.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF7F8C8D),
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: size.height * 0.42,
                              ),
                              child: Scrollbar(
                                controller: _listScrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                thickness: 5.0,
                                radius: const Radius.circular(10),
                                child: SingleChildScrollView(
                                  controller: _listScrollController,
                                  physics: const BouncingScrollPhysics(),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Column(
                                      children: roomsList.map((room) => _buildRoomTile(context, room)).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 20),
                          _buildAddRoomButton(),

                          if (roomsList.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildReviewReportButton(context),
                          ],
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, RoomInspection room) {
    int photoCount = 0;
    for (var item in room.checklist) {
      photoCount += item.photos.length;
    }

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

    String subtitleText = "";
    if (room.name == "Bathroom") {
      subtitleText = "00";
    } else if (room.name == "Washroom") {
      subtitleText = "";
    } else {
      subtitleText = photoCount > 0 ? "$photoCount photos" : "No photos captured";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7), 
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            Get.to(() => RoomDetailScreen(roomId: room.id));
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                Icon(
                  room.icon,
                  color: const Color(0xFF2C3E50),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayLeftName,
                        style: const TextStyle(
                          color: Color(0xFF2C3E50),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      if (subtitleText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitleText,
                          style: const TextStyle(
                            color: Color(0xFF8F9CA9),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8F9CA9),
                  size: 20,
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
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7), 
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF007BFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Add Custom Room',
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildReviewReportButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final address = '${controller.propertyAddress.value}${controller.city.value.isNotEmpty ? ", ${controller.city.value}" : ""}${controller.state.value.isNotEmpty ? ", ${controller.state.value}" : ""}${controller.zipcode.value.isNotEmpty ? " ${controller.zipcode.value}" : ""}${controller.country.value.isNotEmpty ? ", ${controller.country.value}" : ""}';
          Get.to(() => ReportReviewScreen(
            allRooms: controller.roomsList,
            tenantName: controller.tenantName.value,
            landlordName: controller.landlordName.value,
            propertyAddress: address,
            inspectionDate: controller.agreementDate.value.isNotEmpty ? controller.agreementDate.value : controller.possessionDate.value,
            idCode: controller.idCode.value,
          ));
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF007BFF), 
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007BFF).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_turned_in_outlined,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Review & Send Report',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
