import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/controllers/base_controller.dart';
import 'package:tenantsnap/features/inspection/controllers/inspection_controller.dart';

class PropertyDetailsController extends GetxController {
  final selectedRole = 'tenant'.obs;
  final showPhoneInPdf = true.obs;

  late final TextEditingController idCodeController;
  late final TextEditingController tenantController;
  late final TextEditingController landlordController;
  late final TextEditingController tenantPhoneController;
  late final TextEditingController landlordPhoneController;
  late final TextEditingController addressController;
  late final TextEditingController possessionDateController;
  late final TextEditingController leaseDateController;
  late final TextEditingController cityController;
  late final TextEditingController stateController;
  late final TextEditingController zipController;
  late final TextEditingController countryController;

  final InspectionController _inspectionController = Get.find<InspectionController>();

  void initializeData({required String initialRole, String? initialUserName}) {
    selectedRole.value = initialRole;

    idCodeController = TextEditingController(
      text: BaseController.idCode.value.isNotEmpty ? BaseController.idCode.value : _inspectionController.idCode.value,
    );

    tenantController = TextEditingController(
      text: (selectedRole.value == 'tenant' && BaseController.name.value.isNotEmpty)
          ? BaseController.name.value
          : _inspectionController.tenantName.value,
    );

    landlordController = TextEditingController(
      text: (selectedRole.value == 'landlord' && BaseController.name.value.isNotEmpty)
          ? BaseController.name.value
          : _inspectionController.landlordName.value,
    );

    tenantPhoneController = TextEditingController(
      text: (selectedRole.value == 'tenant' && BaseController.phone.value.isNotEmpty)
          ? BaseController.phone.value
          : _inspectionController.tenantPhone.value,
    );

    landlordPhoneController = TextEditingController(
      text: (selectedRole.value == 'landlord' && BaseController.phone.value.isNotEmpty)
          ? BaseController.phone.value
          : _inspectionController.landlordPhone.value,
    );

    showPhoneInPdf.value = _inspectionController.showPhoneInPdf.value;

    addressController = TextEditingController(text: _inspectionController.propertyAddress.value);
    cityController = TextEditingController(text: _inspectionController.city.value);
    stateController = TextEditingController(text: _inspectionController.state.value);
    zipController = TextEditingController(text: _inspectionController.zipcode.value);
    countryController = TextEditingController(text: _inspectionController.country.value);
    possessionDateController = TextEditingController(text: _inspectionController.possessionDate.value);
    leaseDateController = TextEditingController(text: _inspectionController.agreementDate.value);

    if (initialUserName != null && initialUserName.isNotEmpty) {
      if (selectedRole.value == 'tenant') {
        tenantController.text = initialUserName;
      } else {
        landlordController.text = initialUserName;
      }
    }
  }

  @override
  void onClose() {
    idCodeController.dispose();
    tenantController.dispose();
    landlordController.dispose();
    tenantPhoneController.dispose();
    landlordPhoneController.dispose();
    addressController.dispose();
    possessionDateController.dispose();
    leaseDateController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    countryController.dispose();
    super.onClose();
  }

  Future<void> selectDate(BuildContext context, TextEditingController dateFieldController) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF007BFF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2C3E50),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dateFieldController.text = "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  void updateAddress({
    required String street,
    required String city,
    required String state,
    required String zip,
    required String country,
  }) {
    cityController.text = city;
    stateController.text = state;
    zipController.text = zip;
    countryController.text = country;
    
    final List<String> addressParts = [];
    if (street.isNotEmpty) addressParts.add(street);
    if (city.isNotEmpty) addressParts.add(city);
    if (state.isNotEmpty) {
      if (zip.isNotEmpty) {
        addressParts.add("$state $zip");
      } else {
        addressParts.add(state);
      }
    } else if (zip.isNotEmpty) {
      addressParts.add(zip);
    }
    if (country.isNotEmpty) addressParts.add(country);

    addressController.text = addressParts.join(', ');
  }

  void updateSelectedRole(String role) {
    selectedRole.value = role.toLowerCase();
  }

  void toggleShowPhoneInPdf(bool value) {
    showPhoneInPdf.value = value;
  }

  bool submitMetadata() {
    final String idCodeVal = idCodeController.text.trim();
    final String tenantNameVal = tenantController.text.trim();
    final String landlordNameVal = landlordController.text.trim();
    final String tenantPhoneVal = tenantPhoneController.text.trim();
    final String landlordPhoneVal = landlordPhoneController.text.trim();
    final String addressVal = addressController.text.trim();
    final String cityVal = cityController.text.trim();
    final String stateVal = stateController.text.trim();
    final String zipVal = zipController.text.trim();
    final String countryVal = countryController.text.trim();
    final String possessionDateVal = possessionDateController.text.trim();
    final String agreementDateVal = leaseDateController.text.trim();

    if (tenantNameVal.isEmpty || landlordNameVal.isEmpty || addressVal.isEmpty) {
      return false;
    }

    _inspectionController.updateMetadata(
      id: idCodeVal,
      tenant: tenantNameVal,
      landlord: landlordNameVal,
      address: addressVal,
      cityVal: cityVal,
      stateVal: stateVal,
      zipVal: zipVal,
      countryVal: countryVal,
      possession: possessionDateVal.isNotEmpty ? possessionDateVal : '06/20/2026',
      agreement: agreementDateVal.isNotEmpty ? agreementDateVal : '06/15/2026',
      tenantPh: tenantPhoneVal,
      landlordPh: landlordPhoneVal,
      showPhone: showPhoneInPdf.value,
    );

    return true;
  }
}
