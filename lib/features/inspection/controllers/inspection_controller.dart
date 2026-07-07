import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/inspection_model.dart';

class InspectionController extends GetxController {
  // Property Details Metadata
  final idCode = ''.obs;
  final tenantName = ''.obs;
  final tenantPhone = ''.obs;
  final landlordName = ''.obs;
  final landlordPhone = ''.obs;
  final propertyAddress = ''.obs;
  final city = ''.obs;
  final state = ''.obs;
  final zipcode = ''.obs;
  final country = ''.obs;
  final possessionDate = ''.obs;
  final agreementDate = ''.obs;
  final inspectionType = ''.obs;
  final showPhoneInPdf = true.obs;


  // Active rooms list
  final roomsList = <RoomInspection>[].obs;

  final availableUtilities = <String>[
    'Furniture',
    'TV',
    'Refrigerator',
    'Microwave',
    'Washing Machine',
    'Air Conditioner',
    'Oven',
    'Dishwasher',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    initializeDefaultRooms();
  }

  void initializeDefaultRooms() {
    roomsList.assignAll(getDefaultInspectionData());
    syncAvailableUtilitiesFromChecklist();
  }

  void syncAvailableUtilitiesFromChecklist() {
    int utilsIndex = roomsList.indexWhere((r) => r.name.toLowerCase() == 'utils');
    if (utilsIndex != -1) {
      for (var item in roomsList[utilsIndex].checklist) {
        if (!availableUtilities.contains(item.name)) {
          availableUtilities.add(item.name);
        }
      }
    }
  }

  // Set metadata
  void updateMetadata({
    required String id,
    required String tenant,
    required String landlord,
    required String address,
    required String cityVal,
    required String stateVal,
    required String zipVal,
    required String countryVal,
    required String possession,
    required String agreement,
    required String inspectionType,
    String? tenantPh,
    String? landlordPh,
    bool? showPhone,
  }) {
    idCode.value = id;
    tenantName.value = tenant;
    landlordName.value = landlord;
    propertyAddress.value = address;
    city.value = cityVal;
    state.value = stateVal;
    zipcode.value = zipVal;
    country.value = countryVal;
    possessionDate.value = possession;
    agreementDate.value = agreement;
    if (tenantPh != null) tenantPhone.value = tenantPh;
    if (landlordPh != null) landlordPhone.value = landlordPh;
    if (showPhone != null) showPhoneInPdf.value = showPhone;
    this.inspectionType.value = inspectionType;

  }

  // Update a whole room state
  void updateRoom(RoomInspection updatedRoom) {
    int index = roomsList.indexWhere((r) => r.id == updatedRoom.id);
    if (index != -1) {
      roomsList[index] = updatedRoom;
      roomsList[index].recalculateProgress();
      roomsList.refresh();
    }
  }

  // Add custom room
  void addRoom(String name, IconData icon) {
    final int newId = roomsList.length + 1;
    final List<InspectionItem> customChecklist;
    if (name.toLowerCase() == 'utils') {
      customChecklist = [
        InspectionItem(name: "Furniture", status: RoomItemStatus.neutral),
        InspectionItem(name: "TV", status: RoomItemStatus.neutral),
        InspectionItem(name: "Refrigerator", status: RoomItemStatus.neutral),
      ];
    } else {
      customChecklist = [
        InspectionItem(name: "Ceiling", status: RoomItemStatus.neutral),
        InspectionItem(name: "Walls", status: RoomItemStatus.neutral),
        InspectionItem(name: "Floor", status: RoomItemStatus.neutral),
        InspectionItem(name: "Doors / Windows", status: RoomItemStatus.neutral),
        InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
        InspectionItem(name: "Outlets", status: RoomItemStatus.neutral),
      ];
    }

    roomsList.add(
      RoomInspection(
        id: newId,
        number: newId < 10 ? "0$newId" : "$newId",
        name: name,
        icon: icon,
        progress: 0.0,
        checklist: customChecklist,
      ),
    );
    roomsList.refresh();
  }

  // Update item status in a specific room
  void updateItemStatus(int roomId, String itemName, RoomItemStatus status) {
    int rIdx = roomsList.indexWhere((r) => r.id == roomId);
    if (rIdx != -1) {
      int iIdx = roomsList[rIdx].checklist.indexWhere((i) => i.name.toLowerCase() == itemName.toLowerCase());
      if (iIdx != -1) {
        roomsList[rIdx].checklist[iIdx].status = status;
        roomsList[rIdx].recalculateProgress();
        roomsList.refresh();
      }
    }
  }

  // Add a photo to a specific item
  void addPhotoToItem(int roomId, String itemName, String photoPath) {
    int rIdx = roomsList.indexWhere((r) => r.id == roomId);
    if (rIdx != -1) {
      int iIdx = roomsList[rIdx].checklist.indexWhere((i) => i.name.toLowerCase() == itemName.toLowerCase());
      if (iIdx != -1) {
        roomsList[rIdx].checklist[iIdx].photos.add(photoPath);
        roomsList[rIdx].recalculateProgress();
        roomsList.refresh();
      }
    }
  }

  // Add comment to a specific item
  void updateItemComment(int roomId, String itemName, String comment) {
    int rIdx = roomsList.indexWhere((r) => r.id == roomId);
    if (rIdx != -1) {
      int iIdx = roomsList[rIdx].checklist.indexWhere((i) => i.name.toLowerCase() == itemName.toLowerCase());
      if (iIdx != -1) {
        roomsList[rIdx].checklist[iIdx].comment = comment;
        roomsList.refresh();
      }
    }
  }

  // Add a new utility item to 'utils' room checklist dynamically
  void addUtilityItem(String itemName) {
    int utilsIndex = roomsList.indexWhere((r) => r.name.toLowerCase() == 'utils');
    if (utilsIndex != -1) {
      // Check if it already exists
      bool exists = roomsList[utilsIndex].checklist.any((i) => i.name.toLowerCase() == itemName.toLowerCase());
      if (!exists) {
        roomsList[utilsIndex].checklist.add(
          InspectionItem(name: itemName, status: RoomItemStatus.happy),
        );
        roomsList[utilsIndex].recalculateProgress();
        roomsList.refresh();
      }
      if (!availableUtilities.contains(itemName)) {
        availableUtilities.add(itemName);
      }
    }
  }

  // Remove utility item entirely from 'utils' room checklist dynamically
  void removeUtilityItem(String itemName) {
    int utilsIndex = roomsList.indexWhere((r) => r.name.toLowerCase() == 'utils');
    if (utilsIndex != -1) {
      roomsList[utilsIndex].checklist.removeWhere((i) => i.name.toLowerCase() == itemName.toLowerCase());
      roomsList[utilsIndex].recalculateProgress();
      roomsList.refresh();
    }
  }

  // Export current state to dynamic JSON
  Map<String, dynamic> exportToJson() {
    return {
      'idCode': idCode.value,
      'tenantName': tenantName.value,
      'tenantPhone': tenantPhone.value,
      'landlordName': landlordName.value,
      'landlordPhone': landlordPhone.value,
      'propertyAddress': propertyAddress.value,
      'city': city.value,
      'state': state.value,
      'zipcode': zipcode.value,
      'country': country.value,
      'possessionDate': possessionDate.value,
      'agreementDate': agreementDate.value,
      'showPhoneInPdf': showPhoneInPdf.value,
      'rooms': roomsList.map((r) => r.toJson()).toList(),
    };
  }

  // Import state from JSON
  void importFromJson(Map<String, dynamic> json) {
    idCode.value = json['idCode'] ?? '';
    tenantName.value = json['tenantName'] ?? '';
    tenantPhone.value = json['tenantPhone'] ?? '+1 (555) 012-3456';
    landlordName.value = json['landlordName'] ?? '';
    landlordPhone.value = json['landlordPhone'] ?? '+1 (555) 019-2834';
    propertyAddress.value = json['propertyAddress'] ?? '';
    city.value = json['city'] ?? '';
    state.value = json['state'] ?? '';
    zipcode.value = json['zipcode'] ?? '';
    country.value = json['country'] ?? '';
    possessionDate.value = json['possessionDate'] ?? '';
    agreementDate.value = json['agreementDate'] ?? '';
    showPhoneInPdf.value = json['showPhoneInPdf'] ?? true;

    if (json['rooms'] != null) {
      final List roomsJson = json['rooms'];
      roomsList.assignAll(roomsJson.map((r) => RoomInspection.fromJson(r)).toList());
    }
  }
}
