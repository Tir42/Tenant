import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/controllers/base_controller.dart';
import 'package:tenantsnap/features/inspection/controllers/inspection_controller.dart';
import '../models/tenant_model.dart';

class PropertyDetailsController extends BaseController {
  final selectedRole = 'tenant'.obs;
  final showPhoneInPdf = true.obs;
  final inspectionType = 'Move-In'.obs;

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
  InspectionController get inspectionController =>
      _inspectionController;
  Worker? _idWorker;
  Worker? _nameWorker;
  Worker? _phoneWorker;
  Worker? _inspectIdWorker;
  Worker? _inspectTenantWorker;
  Worker? _inspectLandlordWorker;

  void initializeData({required String initialRole, String? initialUserName}) {
    final savedPerformedBy =
    _inspectionController.inspectionPerformedBy.value
        .trim()
        .toLowerCase();

    if (savedPerformedBy == 'tenant' ||
        savedPerformedBy == 'landlord') {
      selectedRole.value = savedPerformedBy;
    } else {
      selectedRole.value =
      initialRole.toLowerCase() == 'landlord'
          ? 'landlord'
          : 'tenant';
    }

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

    _idWorker = ever(BaseController.idCode, (String val) {
      if (val.isNotEmpty && idCodeController.text.isEmpty) {
        idCodeController.text = val;
      }
    });

    _nameWorker = ever(BaseController.name, (String val) {
      if (val.isNotEmpty) {
        if (selectedRole.value == 'tenant' && tenantController.text.isEmpty) {
          tenantController.text = val;
        } else if (selectedRole.value == 'landlord' && landlordController.text.isEmpty) {
          landlordController.text = val;
        }
      }
    });

    _phoneWorker = ever(BaseController.phone, (String val) {
      if (val.isNotEmpty) {
        if (selectedRole.value == 'tenant' && tenantPhoneController.text.isEmpty) {
          tenantPhoneController.text = val;
        } else if (selectedRole.value == 'landlord' && landlordPhoneController.text.isEmpty) {
          landlordPhoneController.text = val;
        }
      }
    });

    _inspectIdWorker = ever(_inspectionController.idCode, (String val) {
      if (val.isNotEmpty && idCodeController.text.isEmpty) {
        idCodeController.text = val;
      }
    });

    _inspectTenantWorker = ever(_inspectionController.tenantName, (String val) {
      if (val.isNotEmpty && tenantController.text.isEmpty) {
        tenantController.text = val;
      }
    });

    _inspectLandlordWorker = ever(_inspectionController.landlordName, (String val) {
      if (val.isNotEmpty && landlordController.text.isEmpty) {
        landlordController.text = val;
      }
    });
  }

  @override
  void onClose() {
    _idWorker?.dispose();
    _nameWorker?.dispose();
    _phoneWorker?.dispose();
    _inspectIdWorker?.dispose();
    _inspectTenantWorker?.dispose();
    _inspectLandlordWorker?.dispose();

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
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dateFieldController.text = "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  /// Builds the combined address string from the five separate fields.
  ///
  /// Bug fix: previously this simply appended `street` as-is, then
  /// appended `city`, `state zip`, and `country` on top of it. Since the
  /// Street Address field (`AddressPopupField`) is a completely free-form
  /// `TextField` with no validation, nothing stops someone from typing or
  /// pasting the *entire* formatted address into the Street box (e.g.
  /// "12356, fgj, Ca 134568, USA") instead of just the street line. When
  /// that happened, this method faithfully re-appended city/state/zip/
  /// country a second time, producing a visibly duplicated address like:
  ///   "12356, fgj, Ca 134568, USA, fgj, Ca 134568, USA"
  ///
  /// Now, before joining, we strip any comma-separated segment out of
  /// `street` that exactly matches (case-insensitively) the city, state,
  /// zip, "state zip", or country values. This keeps the join logic
  /// working normally for a clean street value, while making it robust
  /// against a street value that already contains the other parts.
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

    final String stateZip = (state.isNotEmpty && zip.isNotEmpty)
        ? "$state $zip"
        : '';

    final Set<String> segmentsToStrip = {
      city.trim().toLowerCase(),
      state.trim().toLowerCase(),
      zip.trim().toLowerCase(),
      stateZip.trim().toLowerCase(),
      country.trim().toLowerCase(),
    }..removeWhere((s) => s.isEmpty);

    final String cleanedStreet = street
        .split(',')
        .map((part) => part.trim())
        .where((part) =>
    part.isNotEmpty && !segmentsToStrip.contains(part.toLowerCase()))
        .join(', ');

    final List<String> addressParts = [];
    if (cleanedStreet.isNotEmpty) addressParts.add(cleanedStreet);
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

  Future<bool> submitMetadata() async {
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

    isLoading.value = true;
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
      inspectionType: inspectionType.value,
      performedBy: selectedRole.value == 'landlord'
          ? 'Landlord'
          : 'Tenant',
    );

    // POST property registration details to backend REST API
    try {
      await restClient.dio.post(
        '/property/create',
        data: {
          'idCode': idCodeVal,
          'registerAs': selectedRole.value == 'tenant' ? 'Tenant' : 'Landlord',
          'tenantName': tenantNameVal,
          'propertyAddress': addressVal,
          'landName': landlordNameVal,
          'possessionDate': possessionDateVal.isNotEmpty ? possessionDateVal : '06/20/2026',
          'agreementDate': agreementDateVal.isNotEmpty ? agreementDateVal : '06/15/2026',
        },
      );
    } catch (e) {
      debugPrint("API Error saving property: $e");
    } finally {
      isLoading.value = false;
    }

    return true;
  }
}