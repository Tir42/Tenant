import 'package:flutter/material.dart';

enum RoomItemStatus { happy, sad, neutral }

class InspectionItem {
  final String name;
  RoomItemStatus status;
  List<String> photos; // list of image paths/placeholders

  InspectionItem({
    required this.name,
    this.status = RoomItemStatus.neutral,
    List<String>? photos,
  }) : photos = photos ?? [];
}

class RoomInspection {
  final int id;
  final String number;
  final String name;
  final IconData icon;
  double progress; // 0 to 100
  final List<InspectionItem> checklist;
  String comment;

  RoomInspection({
    required this.id,
    required this.number,
    required this.name,
    required this.icon,
    required this.progress,
    required this.checklist,
    this.comment = '',
  });

  // Calculate dynamic progress based on checked items (either happy or sad counts as answered)
  void recalculateProgress() {
    if (checklist.isEmpty) {
      progress = 0.0;
      return;
    }
    int answered = checklist.where((item) => item.status != RoomItemStatus.neutral || item.photos.isNotEmpty).length;
    progress = (answered / checklist.length) * 100.0;
  }
}

// Initial Mock Inspection State
List<RoomInspection> getMockInspectionData() {
  return [
    RoomInspection(
      id: 1,
      number: "1",
      name: "Entry / Mudroom",
      icon: Icons.door_front_door_outlined,
      progress: 100.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.happy),
        InspectionItem(name: "Walls", status: RoomItemStatus.happy),
        InspectionItem(name: "Floor / Carpet / Tiles", status: RoomItemStatus.happy),
        InspectionItem(name: "Doors / Door Frames", status: RoomItemStatus.happy),
      ],
    ),
    RoomInspection(
      id: 2,
      number: "2",
      name: "Living Room",
      icon: Icons.chair_outlined,
      progress: 70.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.happy),
        InspectionItem(name: "Walls", status: RoomItemStatus.happy),
        InspectionItem(name: "Floor / Carpet / Tiles", status: RoomItemStatus.neutral),
        InspectionItem(name: "Windows / Blinds / Curtains", status: RoomItemStatus.sad),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.happy),
      ],
    ),
    RoomInspection(
      id: 3,
      number: "3",
      name: "Dining Room",
      icon: Icons.restaurant_menu_outlined,
      progress: 80.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.happy),
        InspectionItem(name: "Walls", status: RoomItemStatus.happy),
        InspectionItem(name: "Floor / Carpet / Tiles", status: RoomItemStatus.happy),
        InspectionItem(name: "Furniture & Table", status: RoomItemStatus.neutral),
      ],
    ),
    RoomInspection(
      id: 4,
      number: "4",
      name: "Bedroom 1",
      icon: Icons.bed_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor / Carpet / Tiles", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Door Frames", status: RoomItemStatus.neutral),
        InspectionItem(name: "Closets / Wardrobes", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
      ],
    ),
    RoomInspection(
      id: 5,
      number: "5",
      name: "Kitchen",
      icon: Icons.kitchen_outlined,
      progress: 90.0,
      comment: "Minor scuff marks near refrigerator base panel.",
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.happy),
        InspectionItem(name: "Walls", status: RoomItemStatus.happy),
        InspectionItem(name: "Floor / Carpet / Tiles", status: RoomItemStatus.happy),
        InspectionItem(name: "Doors / Door Frames", status: RoomItemStatus.happy, photos: ["assets/kitchen_door.jpg"]),
        InspectionItem(name: "Closets / Cupboards", status: RoomItemStatus.happy),
        InspectionItem(name: "Shelving", status: RoomItemStatus.happy),
        InspectionItem(name: "Windows / Blinds / Curtains", status: RoomItemStatus.happy),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.happy),
        InspectionItem(name: "Electrical Outlets", status: RoomItemStatus.sad, photos: ["assets/kitchen_outlet.jpg"]),
      ],
    ),
    RoomInspection(
      id: 6,
      number: "6",
      name: "Bathroom",
      icon: Icons.bathtub_outlined,
      progress: 30.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.happy),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor / Tiles", status: RoomItemStatus.neutral),
        InspectionItem(name: "Plumbing / Sink / Toilet", status: RoomItemStatus.neutral),
      ],
    ),
  ];
}
