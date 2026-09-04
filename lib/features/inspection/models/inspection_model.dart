import 'package:flutter/material.dart';

enum RoomItemStatus { happy, sad, neutral }

class InspectionItem {
  final String name;
  RoomItemStatus status;
  List<String> photos; // list of image paths/placeholders
  String comment;

  InspectionItem({
    required this.name,
    this.status = RoomItemStatus.neutral,
    List<String>? photos,
    this.comment = '',
  }) : photos = photos ?? [];

  factory InspectionItem.fromJson(Map<String, dynamic> json) {
    return InspectionItem(
      name: json['name'] as String,
      status: RoomItemStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RoomItemStatus.neutral,
      ),
      photos: List<String>.from(json['photos'] ?? []),
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status.name,
      'photos': photos,
      'comment': comment,
    };
  }
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

  static IconData _getStaticIcon(String name, int codePoint) {
    final cleanName = name.toLowerCase().trim();
    if (cleanName.contains('entry') || cleanName.contains('mudroom')) {
      return Icons.door_front_door_outlined;
    } else if (cleanName.contains('hallway') || cleanName.contains('corridor')) {
      return Icons.alt_route_outlined;
    } else if (cleanName.contains('living room') || cleanName.contains('lounge') || cleanName.contains('dining')) {
      if (cleanName.contains('dining')) {
        return Icons.local_dining_outlined;
      }
      return Icons.chair_outlined;
    } else if (cleanName.contains('kitchen')) {
      return Icons.kitchen_outlined;
    } else if (cleanName.contains('bedroom') || cleanName.contains('bed room')) {
      return Icons.bed_outlined;
    } else if (cleanName.contains('guest room')) {
      return Icons.bedroom_child_outlined;
    } else if (cleanName.contains('bathroom') || cleanName.contains('bath room')) {
      return Icons.bathtub_outlined;
    } else if (cleanName.contains('laundry') || cleanName.contains('utility') || cleanName.contains('washroom')) {
      return Icons.local_laundry_service_outlined;
    } else if (cleanName.contains('pantry') || cleanName.contains('storage')) {
      return Icons.inventory_2_outlined;
    } else if (cleanName.contains('balcony') || cleanName.contains('terrace')) {
      return Icons.balcony_outlined;
    } else if (cleanName.contains('garage') || cleanName.contains('carport')) {
      return Icons.garage_outlined;
    } else if (cleanName.contains('study') || cleanName.contains('office')) {
      return Icons.desktop_mac_outlined;
    } else if (cleanName.contains('basement') || cleanName.contains('cellar')) {
      return Icons.foundation_outlined;
    } else if (cleanName.contains('attic') || cleanName.contains('loft')) {
      return Icons.roofing_outlined;
    } else if (cleanName.contains('sunroom') || cleanName.contains('conservatory')) {
      return Icons.wb_sunny_outlined;
    } else if (cleanName.contains('gym') || cleanName.contains('fitness')) {
      return Icons.fitness_center_outlined;
    } else if (cleanName.contains('workshop') || cleanName.contains('hobby') || cleanName.contains('build')) {
      return Icons.build_outlined;
    }

    switch (codePoint) {
      case 0xf0809:
        return Icons.door_front_door_outlined;
      case 0xf552:
        return Icons.alt_route_outlined;
      case 0xe14c:
        return Icons.chair_outlined;
      case 0xf193:
        return Icons.local_dining_outlined;
      case 0xf15d:
        return Icons.kitchen_outlined;
      case 0xf57c:
        return Icons.bed_outlined;
      case 0xe0cc:
        return Icons.bedroom_child_outlined;
      case 0xf5a5:
        return Icons.bathtub_outlined;
      case 0xf1a1:
        return Icons.local_laundry_service_outlined;
      case 0xe349:
        return Icons.inventory_2_outlined;
      case 0xe0a0:
        return Icons.balcony_outlined;
      case 0xf10d:
        return Icons.garage_outlined;
      case 0xf6ca:
        return Icons.desktop_mac_outlined;
      case 0xe2c6:
        return Icons.foundation_outlined;
      case 0xf0178:
        return Icons.roofing_outlined;
      case 0xf4b7:
        return Icons.wb_sunny_outlined;
      case 0xf07a:
        return Icons.fitness_center_outlined;
      case 0xf5e3:
        return Icons.build_outlined;
      case 0xf107:
        return Icons.home_outlined;
      default:
        return Icons.home_outlined;
    }
  }

  factory RoomInspection.fromJson(Map<String, dynamic> json) {
    final iconData = json['icon'] as Map<String, dynamic>;
    final name = json['name'] as String;
    return RoomInspection(
      id: json['id'] as int,
      number: json['number'] as String,
      name: name,
      icon: _getStaticIcon(name, iconData['codePoint'] as int),
      progress: (json['progress'] as num).toDouble(),
      checklist: (json['checklist'] as List)
          .map((item) => InspectionItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'icon': {
        'codePoint': icon.codePoint,
        'fontFamily': icon.fontFamily,
        'fontPackage': icon.fontPackage,
      },
      'progress': progress,
      'checklist': checklist.map((item) => item.toJson()).toList(),
      'comment': comment,
    };
  }
}

// Initial Mock Inspection State
List<RoomInspection> getMockInspectionData() {
  final List<RoomInspection> mockData = [
    // 1. Entry / Mudroom
    RoomInspection(
      id: 1,
      number: "1",
      name: "Entry / Mudroom",
      icon: Icons.door_front_door_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Entry (Main Door)", status: RoomItemStatus.happy),
        InspectionItem(name: "Ceiling", status: RoomItemStatus.happy),
        InspectionItem(name: "Walls", status: RoomItemStatus.happy),
        InspectionItem(name: "Floor", status: RoomItemStatus.happy),
        InspectionItem(name: "Doors / Locks", status: RoomItemStatus.happy),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.happy),
        InspectionItem(name: "Storage / Hooks / Shelves", status: RoomItemStatus.neutral),
      ],
    ),
    // 2. Hallways / Corridors
    RoomInspection(
      id: 2,
      number: "2",
      name: "Hallways / Corridors",
      icon: Icons.alt_route_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.happy),
        InspectionItem(name: "Walls", status: RoomItemStatus.happy),
        InspectionItem(name: "Floor / Carpet", status: RoomItemStatus.happy),
        InspectionItem(name: "Doors / Door Frames", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.happy),
      ],
    ),
    // 3. Living Room / Lounge
    RoomInspection(
      id: 3,
      number: "3",
      name: "Living Room / Lounge",
      icon: Icons.chair_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.happy),
        InspectionItem(name: "Walls", status: RoomItemStatus.happy),
        InspectionItem(name: "Floor / Carpet / Tiles", status: RoomItemStatus.happy),
        InspectionItem(name: "Windows / Blinds / Curtains", status: RoomItemStatus.sad),
        InspectionItem(name: "Doors / Frames", status: RoomItemStatus.happy),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.happy),
        InspectionItem(name: "Electrical Outlets", status: RoomItemStatus.happy),
        InspectionItem(name: "Built-in Storage / Fireplace / Shelves", status: RoomItemStatus.neutral),
      ],
    ),
    // 4. Dining Room
    RoomInspection(
      id: 4,
      number: "4",
      name: "Dining Room",
      icon: Icons.local_dining_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor / Carpet / Tiles", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures / Chandeliers", status: RoomItemStatus.neutral),
        InspectionItem(name: "Windows / Blinds / Curtains", status: RoomItemStatus.neutral),
      ],
    ),
    // 5. Kitchen
    RoomInspection(
      id: 5,
      number: "5",
      name: "Kitchen",
      icon: Icons.kitchen_outlined,
      progress: 0.0,
      comment: "Excellent countertops; slight electrical outlet cover wiggle.",
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.happy),
        InspectionItem(name: "Walls / Backsplash", status: RoomItemStatus.happy),
        InspectionItem(name: "Floor / Tiles", status: RoomItemStatus.happy),
        InspectionItem(name: "Cabinets / Drawers / Handles", status: RoomItemStatus.happy),
        InspectionItem(name: "Countertops", status: RoomItemStatus.happy),
        InspectionItem(name: "Sink / Faucet", status: RoomItemStatus.happy),
        InspectionItem(name: "Appliances (Stove, Fridge, Oven, Dishwasher)", status: RoomItemStatus.happy),
        InspectionItem(name: "Electrical Outlets / Lights", status: RoomItemStatus.sad),
        InspectionItem(name: "Windows / Blinds", status: RoomItemStatus.happy),
      ],
    ),
    // 6. Bedroom 1
    RoomInspection(
      id: 6,
      number: "6",
      name: "Bedroom 1",
      icon: Icons.bed_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.happy),
        InspectionItem(name: "Walls", status: RoomItemStatus.sad),
        InspectionItem(name: "Floor / Carpet / Tiles", status: RoomItemStatus.happy),
        InspectionItem(name: "Doors / Door Frames", status: RoomItemStatus.happy),
        InspectionItem(name: "Closets / Wardrobes / Shelving", status: RoomItemStatus.happy),
        InspectionItem(name: "Windows / Blinds / Curtains", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.happy),
        InspectionItem(name: "Electrical Outlets", status: RoomItemStatus.happy),
      ],
    ),
    // 7. Bedroom 2
    RoomInspection(
      id: 7,
      number: "7",
      name: "Bedroom 2",
      icon: Icons.bed_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor / Carpet / Tiles", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Door Frames", status: RoomItemStatus.neutral),
        InspectionItem(name: "Closets / Wardrobes / Shelving", status: RoomItemStatus.neutral),
        InspectionItem(name: "Windows / Blinds / Curtains", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
        InspectionItem(name: "Electrical Outlets", status: RoomItemStatus.neutral),
      ],
    ),
    // 8. Guest Room
    RoomInspection(
      id: 8,
      number: "8",
      name: "Guest Room",
      icon: Icons.bedroom_child_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor / Carpet / Tiles", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Door Frames", status: RoomItemStatus.neutral),
        InspectionItem(name: "Closets / Wardrobes / Shelving", status: RoomItemStatus.neutral),
        InspectionItem(name: "Windows / Blinds / Curtains", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
        InspectionItem(name: "Electrical Outlets", status: RoomItemStatus.neutral),
      ],
    ),
    // 9. Bathroom 1
    RoomInspection(
      id: 9,
      number: "9",
      name: "Bathroom 1",
      icon: Icons.bathtub_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.happy),
        InspectionItem(name: "Walls / Tiles / Paint", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor / Tiles", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Door Frames", status: RoomItemStatus.neutral),
        InspectionItem(name: "Sink / Faucet / Cabinet", status: RoomItemStatus.neutral),
        InspectionItem(name: "Toilet / Flush", status: RoomItemStatus.neutral),
        InspectionItem(name: "Shower / Bathtub / Showerhead", status: RoomItemStatus.neutral),
        InspectionItem(name: "Mirror", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures / Exhaust Fan", status: RoomItemStatus.neutral),
        InspectionItem(name: "Windows / Blinds / Curtains", status: RoomItemStatus.neutral),
      ],
    ),
    // 10. Bathroom 2
    RoomInspection(
      id: 10,
      number: "10",
      name: "Bathroom 2",
      icon: Icons.bathtub_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls / Tiles / Paint", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor / Tiles", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Door Frames", status: RoomItemStatus.neutral),
        InspectionItem(name: "Sink / Faucet / Cabinet", status: RoomItemStatus.neutral),
        InspectionItem(name: "Toilet / Flush", status: RoomItemStatus.neutral),
        InspectionItem(name: "Shower / Bathtub / Showerhead", status: RoomItemStatus.neutral),
        InspectionItem(name: "Mirror", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures / Exhaust Fan", status: RoomItemStatus.neutral),
        InspectionItem(name: "Windows / Blinds / Curtains", status: RoomItemStatus.neutral),
      ],
    ),
    // 11. Utility / Laundry Room
    RoomInspection(
      id: 11,
      number: "11",
      name: "Utility / Laundry Room",
      icon: Icons.local_laundry_service_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor", status: RoomItemStatus.neutral),
        InspectionItem(name: "Washer / Dryer", status: RoomItemStatus.neutral),
        InspectionItem(name: "Cabinets / Shelves", status: RoomItemStatus.neutral),
        InspectionItem(name: "Sink / Faucet", status: RoomItemStatus.neutral),
        InspectionItem(name: "Electrical Outlets", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
      ],
    ),
    // 12. Pantry / Storage Room
    RoomInspection(
      id: 12,
      number: "12",
      name: "Pantry / Storage Room",
      icon: Icons.inventory_2_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor", status: RoomItemStatus.neutral),
        InspectionItem(name: "Shelving / Storage Units", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Handles", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
      ],
    ),
    // 13. Balcony / Terrace
    RoomInspection(
      id: 13,
      number: "13",
      name: "Balcony / Terrace",
      icon: Icons.balcony_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Floor / Tiles / Decking", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls / Railings", status: RoomItemStatus.neutral),
        InspectionItem(name: "Ceiling / Overhead", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Windows", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
      ],
    ),
    // 14. Garage / Carport
    RoomInspection(
      id: 14,
      number: "14",
      name: "Garage / Carport",
      icon: Icons.garage_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Garage Mechanism", status: RoomItemStatus.neutral),
        InspectionItem(name: "Storage Units / Shelving", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures / Electrical Outlets", status: RoomItemStatus.neutral),
      ],
    ),
    // 15. Study / Office Room
    RoomInspection(
      id: 15,
      number: "15",
      name: "Study / Office Room",
      icon: Icons.desktop_mac_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Door Frames", status: RoomItemStatus.neutral),
        InspectionItem(name: "Windows / Blinds / Curtains", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
        InspectionItem(name: "Electrical Outlets", status: RoomItemStatus.neutral),
      ],
    ),
    // 16. Basement / Cellar
    RoomInspection(
      id: 16,
      number: "16",
      name: "Basement / Cellar",
      icon: Icons.foundation_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling / Pipes", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls / Paint / Moisture Signs", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor / Tiles / Concrete", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Locks", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
        InspectionItem(name: "Storage Units", status: RoomItemStatus.neutral),
      ],
    ),
    // 17. Attic / Loft
    RoomInspection(
      id: 17,
      number: "17",
      name: "Attic / Loft",
      icon: Icons.roofing_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling / Beams", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls / Insulation", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor / Boards", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Hatch", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
      ],
    ),
    // 18. Sunroom / Conservatory
    RoomInspection(
      id: 18,
      number: "18",
      name: "Sunroom / Conservatory",
      icon: Icons.wb_sunny_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling / Roof / Glass Panels", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls / Windows", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor / Tiles / Wood", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Frames", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
      ],
    ),
    // 19. Home Gym
    RoomInspection(
      id: 19,
      number: "19",
      name: "Home Gym",
      icon: Icons.fitness_center_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor / Mats", status: RoomItemStatus.neutral),
        InspectionItem(name: "Equipment / Fixtures", status: RoomItemStatus.neutral),
        InspectionItem(name: "Windows / Blinds / Curtains", status: RoomItemStatus.neutral),
        InspectionItem(name: "Electrical Outlets", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
      ],
    ),
    // 20. Workshop / Hobby Room
    RoomInspection(
      id: 20,
      number: "20",
      name: "Workshop / Hobby Room",
      icon: Icons.build_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor", status: RoomItemStatus.neutral),
        InspectionItem(name: "Workbenches / Shelves", status: RoomItemStatus.neutral),
        InspectionItem(name: "Tools / Equipment", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
        InspectionItem(name: "Electrical Outlets", status: RoomItemStatus.neutral),
      ],
    ),
  ];

  for (var room in mockData) {
    room.recalculateProgress();
  }
  return mockData;
}

List<RoomInspection> getDefaultInspectionData() {
  return [
    RoomInspection(
      id: 1,
      number: "01",
      name: "Bedroom 1",
      icon: Icons.bed_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Windows", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
        InspectionItem(name: "Outlets", status: RoomItemStatus.neutral),
      ],
    ),
    RoomInspection(
      id: 2,
      number: "02",
      name: "Bedroom 2",
      icon: Icons.chair_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Windows", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
        InspectionItem(name: "Outlets", status: RoomItemStatus.neutral),
      ],
    ),
    RoomInspection(
      id: 3,
      number: "03",
      name: "Living Room",
      icon: Icons.chair_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Windows", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
        InspectionItem(name: "Outlets", status: RoomItemStatus.neutral),
      ],
    ),
    RoomInspection(
      id: 4,
      number: "04",
      name: "Kitchen",
      icon: Icons.kitchen_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls / Backsplash", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor / Tiles", status: RoomItemStatus.neutral),
        InspectionItem(name: "Cabinets / Countertops", status: RoomItemStatus.neutral),
        InspectionItem(name: "Sink / Faucet", status: RoomItemStatus.neutral),
        InspectionItem(name: "Appliances", status: RoomItemStatus.neutral),
        InspectionItem(name: "Outlets", status: RoomItemStatus.neutral),
      ],
    ),
    RoomInspection(
      id: 5,
      number: "05",
      name: "Bathroom",
      icon: Icons.bathtub_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls / Tiles", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor / Tiles", status: RoomItemStatus.neutral),
        InspectionItem(name: "Sink / Faucet", status: RoomItemStatus.neutral),
        InspectionItem(name: "Toilet", status: RoomItemStatus.neutral),
        InspectionItem(name: "Shower / Tub", status: RoomItemStatus.neutral),
      ],
    ),
    RoomInspection(
      id: 6,
      number: "06",
      name: "Washroom",
      icon: Icons.local_laundry_service_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor", status: RoomItemStatus.neutral),
        InspectionItem(name: "Washer / Dryer", status: RoomItemStatus.neutral),
        InspectionItem(name: "Sink / Faucet", status: RoomItemStatus.neutral),
      ],
    ),
    RoomInspection(
      id: 7,
      number: "07",
      name: "Utilities",
      icon: Icons.home_outlined,
      progress: 0.0,
      checklist: [
        InspectionItem(name: "Furniture", status: RoomItemStatus.neutral),
        InspectionItem(name: "TV", status: RoomItemStatus.neutral),
        InspectionItem(name: "Refrigerator", status: RoomItemStatus.neutral),
      ],
    ),
  ];
}
