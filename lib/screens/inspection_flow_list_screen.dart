import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/inspection_model.dart';
import 'room_detail_screen.dart';

class InspectionFlowListScreen extends StatefulWidget {
  const InspectionFlowListScreen({super.key});

  @override
  State<InspectionFlowListScreen> createState() => _InspectionFlowListScreenState();
}

class _InspectionFlowListScreenState extends State<InspectionFlowListScreen> {
  // Local state for the dynamic inspection rooms list
  late List<RoomInspection> _roomsList;

  @override
  void initState() {
    super.initState();
    // Pre-populate with the exact list from the mockup screenshot
    _roomsList = [
      RoomInspection(
        id: 1,
        number: "1",
        name: "Bedroom 1",
        icon: Icons.bed_outlined,
        progress: 0.0,
        checklist: [
          InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
          InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
          InspectionItem(name: "Floor / Carpet / Tiles", status: RoomItemStatus.neutral),
        ],
      ),
      RoomInspection(
        id: 2,
        number: "2",
        name: "Living Room",
        icon: Icons.chair_outlined,
        progress: 0.0,
        checklist: [
          InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
          InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
          InspectionItem(name: "Floor / Carpet / Tiles", status: RoomItemStatus.neutral),
        ],
      ),
      RoomInspection(
        id: 3,
        number: "3",
        name: "Living Room",
        icon: Icons.tungsten_outlined, // floor lamp / light bulb icon
        progress: 0.0,
        checklist: [
          InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
          InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        ],
      ),
      RoomInspection(
        id: 4,
        number: "4",
        name: "Kitchen",
        icon: Icons.kitchen_outlined,
        progress: 0.0,
        checklist: [
          InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
          InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
          InspectionItem(name: "Appliances", status: RoomItemStatus.neutral),
        ],
      ),
      RoomInspection(
        id: 5,
        number: "5",
        name: "Bathroom",
        icon: Icons.bathtub_outlined,
        progress: 0.0,
        checklist: [
          InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
          InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        ],
      ),
      RoomInspection(
        id: 6,
        number: "6",
        name: "Washroom",
        icon: Icons.local_laundry_service_outlined,
        progress: 0.0,
        checklist: [
          InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
          InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        ],
      ),
    ];
  }

  // Handle callback updates from detail screen
  void _updateRoomState(RoomInspection updatedRoom) {
    setState(() {
      int index = _roomsList.indexWhere((r) => r.id == updatedRoom.id);
      if (index != -1) {
        _roomsList[index] = updatedRoom;
        _roomsList[index].recalculateProgress();
      }
    });
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
                      setState(() {
                        final int newId = _roomsList.length + 1;
                        _roomsList.add(
                          RoomInspection(
                            id: newId,
                            number: "$newId",
                            name: name,
                            icon: selectedIcon,
                            progress: 0.0,
                            checklist: [
                              InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
                              InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
                              InspectionItem(name: "Floor", status: RoomItemStatus.neutral),
                            ],
                          ),
                        );
                      });
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
                  // Center-positioned elegant mockup card
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row with Header title & an elegant close/back button at top-right
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tell Us About Your\nNew Home',
                              style: TextStyle(
                                color: Color(0xFF2C3E50),
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w800,
                                fontSize: 23,
                                height: 1.25,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF2F4F7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF7F8C8D),
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // List of spaces exactly matching the mock list layout
                        Column(
                          children: _roomsList.map((room) => _buildRoomTile(context, room)).toList(),
                        ),
                        
                        const SizedBox(height: 20),

                        // Add Custom Room Button
                        _buildAddRoomButton(),
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

  Widget _buildRoomTile(BuildContext context, RoomInspection room) {
    // Determine dynamic photos subtitle
    String? subtitle = "No photos captured";
    if (room.name == "Bathroom") {
      subtitle = "00";
    } else if (room.name == "Washroom") {
      subtitle = null; // No subtitle layout spacing for Washroom to align exactly with mockup screenshot
    } else {
      int photoCount = 0;
      for (var item in room.checklist) {
        photoCount += item.photos.length;
      }
      if (photoCount > 0) {
        subtitle = photoCount == 1 ? "1 photo captured" : "$photoCount photos captured";
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RoomDetailScreen(
                  room: room,
                  onUpdated: _updateRoomState,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7), // Light-grey cards
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                // Custom Slate Icon
                Icon(
                  room.icon,
                  color: const Color(0xFF2C3E50),
                  size: 22,
                ),
                const SizedBox(width: 16),
                
                // Name and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          color: Color(0xFF2C3E50),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF8F9CA9),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
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
            color: const Color(0xFFF2F4F7), // Match mockup background
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular blue plus icon
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
      ),
    );
  }
}
