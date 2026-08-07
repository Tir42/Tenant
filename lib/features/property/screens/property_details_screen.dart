import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';

import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/core/utils/responsive/responsive_extension.dart';
import 'package:tenantsnap/features/inspection/screens/inspection_flow_list_screen.dart';
import 'package:tenantsnap/features/property/controllers/property_details_controller.dart';
import 'package:tenantsnap/features/property/widgets/property_form_text_field.dart';
import 'package:tenantsnap/features/property/widgets/address_popup_field.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final String role;
  final String? userName;

  const PropertyDetailsScreen({
    super.key,
    this.role = 'tenant',
    this.userName,
  });

  @override
  State<PropertyDetailsScreen> createState() =>
      _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  late final PropertyDetailsController _detailsController;

  final List<TextEditingController> _tenantControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _tenantIdCodeControllers = [
    TextEditingController(),
  ];

  final List<TextEditingController> _landlordControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _landlordIdCodeControllers = [
    TextEditingController(),
  ];

  final TextEditingController _roleController = TextEditingController();

  // Strict phone validation: exactly 10 digits.
  final RegExp _phoneRegex = RegExp(r'^\d{10}$');

  String? _idCodeError;
  String? _tenantError;
  String? _tenantPhoneError;
  String? _landlordError;
  String? _landlordPhoneError;
  String? _addressError;
  String? _possessionDateError;
  String? _leaseDateError;
  String? _submitError;

  @override
  void initState() {
    super.initState();

    _detailsController = Get.put(PropertyDetailsController());

    _detailsController.initializeData(
      initialRole: widget.role,
      initialUserName: widget.userName,
    );

    final inspectionController = _detailsController.inspectionController;
    if (inspectionController.editingRecordId.value.isNotEmpty) {
      _detailsController.idCodeController.text = inspectionController.idCode.value;
      _detailsController.tenantPhoneController.text = inspectionController.tenantPhone.value;
      _detailsController.landlordPhoneController.text = inspectionController.landlordPhone.value;
      _detailsController.addressController.text = inspectionController.propertyAddress.value;
      _detailsController.cityController.text = inspectionController.city.value;
      _detailsController.stateController.text = inspectionController.state.value;
      _detailsController.zipController.text = inspectionController.zipcode.value;
      _detailsController.countryController.text = inspectionController.country.value;
      _detailsController.possessionDateController.text = inspectionController.possessionDate.value;
      _detailsController.leaseDateController.text = inspectionController.agreementDate.value;
      
      _detailsController.selectedRole.value = inspectionController.inspectionPerformedBy.value == 'Landlord' ? 'Landlord' : 'Tenant';
      _roleController.text = _detailsController.selectedRole.value;

      _tenantControllers.clear();
      _tenantIdCodeControllers.clear();
      final List<String> tenants = inspectionController.tenantName.value.split(',').map((t) => t.trim()).toList();
      for (int i = 0; i < tenants.length; i++) {
        final controller = TextEditingController(text: tenants[i]);
        controller.addListener(_onTenantFieldChanged);
        _tenantControllers.add(controller);

        String idCode = '';
        if (i < inspectionController.tenantIdCodes.length) {
          idCode = inspectionController.tenantIdCodes[i];
        }
        _tenantIdCodeControllers.add(TextEditingController(text: idCode));
      }
      if (_tenantControllers.isEmpty) {
        _tenantControllers.add(TextEditingController()..addListener(_onTenantFieldChanged));
        _tenantIdCodeControllers.add(TextEditingController());
      }

      _landlordControllers.clear();
      _landlordIdCodeControllers.clear();
      final List<String> landlords = inspectionController.landlordName.value.split(',').map((l) => l.trim()).toList();
      for (int i = 0; i < landlords.length; i++) {
        final controller = TextEditingController(text: landlords[i]);
        controller.addListener(_onLandlordFieldChanged);
        _landlordControllers.add(controller);

        String idCode = '';
        if (i < inspectionController.landlordIdCodes.length) {
          idCode = inspectionController.landlordIdCodes[i];
        }
        _landlordIdCodeControllers.add(TextEditingController(text: idCode));
      }
      if (_landlordControllers.isEmpty) {
        _landlordControllers.add(TextEditingController()..addListener(_onLandlordFieldChanged));
        _landlordIdCodeControllers.add(TextEditingController());
      }
    } else {
      _detailsController.idCodeController.clear();
      _detailsController.tenantController.clear();
      _detailsController.tenantPhoneController.clear();
      _detailsController.landlordController.clear();
      _detailsController.landlordPhoneController.clear();
      _detailsController.addressController.clear();
      _detailsController.cityController.clear();
      _detailsController.stateController.clear();
      _detailsController.zipController.clear();
      _detailsController.countryController.clear();
      _detailsController.possessionDateController.clear();
      _detailsController.leaseDateController.clear();
      _detailsController.inspectionController.tenantIdCodes.clear();
      _detailsController.inspectionController.landlordIdCodes.clear();
      
      _tenantControllers.clear();
      _tenantControllers.add(TextEditingController()..addListener(_onTenantFieldChanged));
      _tenantIdCodeControllers.clear();
      _tenantIdCodeControllers.add(TextEditingController());

      _landlordControllers.clear();
      _landlordControllers.add(TextEditingController()..addListener(_onLandlordFieldChanged));
      _landlordIdCodeControllers.clear();
      _landlordIdCodeControllers.add(TextEditingController());

      _roleController.text = _detailsController.selectedRole.value == 'landlord' ? 'Landlord' : 'Tenant';
    }

    _roleController.addListener(_onRoleFieldChanged);



    _detailsController.idCodeController.addListener(_clearIdCodeError);
    _detailsController.tenantPhoneController
        .addListener(_clearTenantPhoneError);
    _detailsController.landlordPhoneController
        .addListener(_clearLandlordPhoneError);
    _detailsController.addressController.addListener(_clearAddressError);
  }

  @override
  void dispose() {
    for (final controller in _tenantControllers) {
      controller.removeListener(_onTenantFieldChanged);
      controller.dispose();
    }
    for (final controller in _tenantIdCodeControllers) {
      controller.dispose();
    }

    for (final controller in _landlordControllers) {
      controller.removeListener(_onLandlordFieldChanged);
      controller.dispose();
    }
    for (final controller in _landlordIdCodeControllers) {
      controller.dispose();
    }

    _roleController.removeListener(_onRoleFieldChanged);
    _roleController.dispose();

    _detailsController.idCodeController.removeListener(_clearIdCodeError);
    _detailsController.tenantPhoneController
        .removeListener(_clearTenantPhoneError);
    _detailsController.landlordPhoneController
        .removeListener(_clearLandlordPhoneError);
    _detailsController.addressController.removeListener(_clearAddressError);

    Get.delete<PropertyDetailsController>();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Error-clearing listeners
  // ---------------------------------------------------------------------------

  void _onTenantFieldChanged() {
    if (_tenantError != null || _submitError != null) {
      setState(() {
        _tenantError = null;
        _submitError = null;
      });
    }
  }

  void _onLandlordFieldChanged() {
    if (_landlordError != null || _submitError != null) {
      setState(() {
        _landlordError = null;
        _submitError = null;
      });
    }
  }

  void _onRoleFieldChanged() {
    _detailsController.updateSelectedRole(_roleController.text.trim());
  }

  void _clearIdCodeError() {
    if (_idCodeError != null || _submitError != null) {
      setState(() {
        _idCodeError = null;
        _submitError = null;
      });
    }
  }

  void _clearTenantPhoneError() {
    if (_tenantPhoneError != null || _submitError != null) {
      setState(() {
        _tenantPhoneError = null;
        _submitError = null;
      });
    }
  }

  void _clearLandlordPhoneError() {
    if (_landlordPhoneError != null || _submitError != null) {
      setState(() {
        _landlordPhoneError = null;
        _submitError = null;
      });
    }
  }

  void _clearAddressError() {
    if (_addressError != null || _submitError != null) {
      setState(() {
        _addressError = null;
        _submitError = null;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Tenant fields
  // ---------------------------------------------------------------------------

  void _addTenantField() {
    if (_tenantControllers.length >= 5) return;

    final tenantNameController = TextEditingController()
      ..addListener(_onTenantFieldChanged);

    final tenantIdCodeController =
    TextEditingController();

    setState(() {
      _tenantControllers.add(tenantNameController);
      _tenantIdCodeControllers.add(
        tenantIdCodeController,
      );

      _tenantError = null;
    });
  }

  void _removeTenantField(int index) {
    if (index <= 0 ||
        _tenantControllers.length <= 1) {
      return;
    }

    final tenantNameController =
    _tenantControllers[index];

    final tenantIdCodeController =
    _tenantIdCodeControllers[index];

    tenantNameController.removeListener(
      _onTenantFieldChanged,
    );

    setState(() {
      _tenantControllers.removeAt(index);
      _tenantIdCodeControllers.removeAt(index);
      _tenantError = null;
    });

    tenantNameController.dispose();
    tenantIdCodeController.dispose();
  }

  // ---------------------------------------------------------------------------
  // Landlord fields
  // ---------------------------------------------------------------------------

  void _addLandlordField() {
    if (_landlordControllers.length >= 5) return;

    final landlordNameController = TextEditingController()
      ..addListener(_onLandlordFieldChanged);

    final landlordIdCodeController =
    TextEditingController();

    setState(() {
      _landlordControllers.add(landlordNameController);
      _landlordIdCodeControllers.add(
        landlordIdCodeController,
      );

      _landlordError = null;
    });
  }

  void _removeLandlordField(int index) {
    if (index <= 0 || _landlordControllers.length <= 1) return;

    final landlordNameController =
    _landlordControllers[index];

    final landlordIdCodeController =
    _landlordIdCodeControllers[index];

    landlordNameController.removeListener(_onLandlordFieldChanged);

    setState(() {
      _landlordControllers.removeAt(index);
      _landlordIdCodeControllers.removeAt(index);
      _landlordError = null;
    });

    landlordNameController.dispose();
    landlordIdCodeController.dispose();
  }

  // ---------------------------------------------------------------------------
  // Address dialog
  // ---------------------------------------------------------------------------

  Future<void> _showAddressDialog() async {
    // Remove focus from the Full Address field before opening the dialog.
    FocusManager.instance.primaryFocus?.unfocus();

    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    String initialStreet = '';

    final fullAddress =
    _detailsController.addressController.text.trim();

    if (fullAddress.isNotEmpty) {
      final parts = fullAddress.split(',');

      if (parts.isNotEmpty) {
        initialStreet = parts.first.trim();
      }
    }

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) {
        return AddressDetailsDialog(
          initialStreet: initialStreet,
          initialCity: _detailsController.cityController.text,
          initialState: _detailsController.stateController.text,
          initialZip: _detailsController.zipController.text,
          initialCountry:
          _detailsController.countryController.text,
        );
      },
    );

    if (!mounted || result == null) return;

    _detailsController.updateAddress(
      street: result['street'] ?? '',
      city: result['city'] ?? '',
      state: result['state'] ?? '',
      zip: result['zip'] ?? '',
      country: result['country'] ?? '',
    );

    setState(() {
      _addressError = null;
      _submitError = null;
    });
  }

  // ---------------------------------------------------------------------------
  // Date pickers
  // ---------------------------------------------------------------------------

  Future<void> _pickPossessionDate() async {
    await _detailsController.selectDate(
      context,
      _detailsController.possessionDateController,
    );

    if (!mounted) return;

    if (_detailsController.possessionDateController.text.trim().isNotEmpty) {
      setState(() {
        _possessionDateError = null;
        _submitError = null;
      });
    }
  }

  Future<void> _pickLeaseDate() async {
    await _detailsController.selectDate(
      context,
      _detailsController.leaseDateController,
    );

    if (!mounted) return;

    if (_detailsController.leaseDateController.text.trim().isNotEmpty) {
      setState(() {
        _leaseDateError = null;
        _submitError = null;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    final List<String> tenantNames = [];
    final List<String> tenantIdCodes = [];

    for (int index = 0;
    index < _tenantControllers.length;
    index++) {
      final tenantName =
      _tenantControllers[index].text.trim();

      final tenantIdCode =
      _tenantIdCodeControllers[index].text.trim();

      if (tenantName.isNotEmpty) {
        tenantNames.add(tenantName);
        tenantIdCodes.add(tenantIdCode);
      }
    }

    final List<String> landlordNames = [];
    final List<String> landlordIdCodes = [];

    for (int index = 0;
    index < _landlordControllers.length;
    index++) {
      final landlordName =
      _landlordControllers[index].text.trim();

      final landlordIdCode =
      _landlordIdCodeControllers[index].text.trim();

      if (landlordName.isNotEmpty) {
        landlordNames.add(landlordName);
        landlordIdCodes.add(landlordIdCode);
      }
    }

    final idCode = _detailsController.idCodeController.text.trim();
    final tenantPhone =
    _detailsController.tenantPhoneController.text.trim();
    final landlordPhone =
    _detailsController.landlordPhoneController.text.trim();
    final address =
    _detailsController.addressController.text.trim();
    final possessionDate =
    _detailsController.possessionDateController.text.trim();
    final leaseDate =
    _detailsController.leaseDateController.text.trim();

    setState(() {
      _idCodeError =
      idCode.isEmpty ? 'Please enter the ID code.' : null;

      _tenantError = tenantNames.isEmpty
          ? 'Please enter at least one tenant name.'
          : null;

      _tenantPhoneError = tenantPhone.isEmpty
          ? 'Please enter the tenant phone number.'
          : (!_phoneRegex.hasMatch(tenantPhone)
          ? 'Phone number must be exactly 10 digits.'
          : null);

      _landlordError = landlordNames.isEmpty
          ? 'Please enter at least one landlord name.'
          : null;

      _landlordPhoneError = landlordPhone.isEmpty
          ? 'Please enter the landlord phone number.'
          : (!_phoneRegex.hasMatch(landlordPhone)
          ? 'Phone number must be exactly 10 digits.'
          : null);

      _addressError = address.isEmpty
          ? 'Please enter the full address.'
          : null;

      _possessionDateError = possessionDate.isEmpty
          ? 'Please select the possession date.'
          : null;

      _leaseDateError = leaseDate.isEmpty
          ? 'Please select the agreement date.'
          : null;

      _submitError = null;
    });

    if (_idCodeError != null ||
        _tenantError != null ||
        _tenantPhoneError != null ||
        _landlordError != null ||
        _landlordPhoneError != null ||
        _addressError != null ||
        _possessionDateError != null ||
        _leaseDateError != null) {
      return;
    }

    // Store all entered names using your existing controller fields.
    _detailsController.tenantController.text =
        tenantNames.join(', ');

    _detailsController.landlordController.text =
        landlordNames.join(', ');

    _detailsController
        .inspectionController
        .tenantIdCodes
        .assignAll(tenantIdCodes);

    // Landlord ID code is optional; whatever was entered (possibly blank
    // strings for landlords who skipped it) is stored aligned by index
    // with landlordNames, mirroring tenantIdCodes.
    _detailsController
        .inspectionController
        .landlordIdCodes
        .assignAll(landlordIdCodes);

    final success =
    await _detailsController.submitMetadata();

    if (!mounted) return;

    if (!success) {
      setState(() {
        _submitError =
        'Unable to save the property details. Please try again.';
      });
      return;
    }

    Get.off(() => const InspectionFlowListScreen());
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EEF5),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AntigravityColors.bgGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 20.0.w,
              vertical: 16.0.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 24.0.h),
                _buildFormCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 44.0.w,
            height: 44.0.h,
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
                size: 20.0.w,
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
                'Property Details',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF2C3E50),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 22.0.sp,
                ),
              ),
              SizedBox(height: 2.0.h),
              Text(
                'Register address & lease data',
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

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20.0.w,
        vertical: 28.0.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.0.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50)
                .withValues(alpha: 0.06),
            blurRadius: 24.0.w,
            offset: Offset(0, 10.0.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AddressPopupField(
            controller: _roleController,
            label: 'INSPECTION CARRIED OUT BY',
            hint: 'Enter Tenant or Landlord...',
          ),

          SizedBox(height: 5.0.h),

          PropertyFormTextField(
            controller:
            _detailsController.idCodeController,
            label: 'ID Code',
            hintText: 'Enter ID code...',
          ),

          if (_idCodeError != null) ...[
            SizedBox(height: 7.0.h),
            _buildErrorMessage(_idCodeError!),
          ],

          SizedBox(height: 8.0.h),

          _buildOrderedTenantLandlordSections(),

          SizedBox(height: 18.0.h),

          PropertyFormTextField(
            controller:
            _detailsController.addressController,
            label: 'Full Address',
            hintText: 'Enter address...',
            readOnly: true,
            onTap: _showAddressDialog,
          ),

          if (_addressError != null) ...[
            SizedBox(height: 7.0.h),
            _buildErrorMessage(_addressError!),
          ],

          SizedBox(height: 18.0.h),

          PropertyFormTextField(
            controller:
            _detailsController.possessionDateController,
            label: 'POSSESSION DATE',
            hintText: 'Select date...',
            isDatePicker: true,
            onTap: _pickPossessionDate,
          ),

          if (_possessionDateError != null) ...[
            SizedBox(height: 7.0.h),
            _buildErrorMessage(_possessionDateError!),
          ],

          SizedBox(height: 18.0.h),

          PropertyFormTextField(
            controller:
            _detailsController.leaseDateController,
            label: 'AGREEMENT Date',
            hintText: 'Select date...',
            isDatePicker: true,
            onTap: _pickLeaseDate,
          ),

          if (_leaseDateError != null) ...[
            SizedBox(height: 7.0.h),
            _buildErrorMessage(_leaseDateError!),
          ],

          SizedBox(height: 18.0.h),

          Obx(
                () => Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'SHOW PHONE NUMBERS IN PDF',
                    style: TextStyle(
                      color: const Color(0xFF7F8C8D),
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 11.0.sp,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Switch(
                  value: _detailsController
                      .showPhoneInPdf.value,
                  onChanged: (bool value) {
                    _detailsController
                        .toggleShowPhoneInPdf(value);
                  },
                  activeColor:
                  const Color(0xFF007BFF),
                ),
              ],
            ),
          ),

          if (_submitError != null) ...[
            SizedBox(height: 12.0.h),
            _buildErrorMessage(_submitError!),
          ],

          SizedBox(height: 28.0.h),

          _buildSubmitButton(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tenant / Landlord section ordering
  // ---------------------------------------------------------------------------

  Widget _buildTenantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDynamicNameSection(
          fieldLabel: 'Tenant Name',
          hintText: 'Enter tenant name...',
          controllers: _tenantControllers,
          idCodeControllers: _tenantIdCodeControllers,
          showIdCodeField: true,
          errorText: _tenantError,
          onAdd: _addTenantField,
          onRemove: _removeTenantField,
        ),

        SizedBox(height: 8.0.h),

        PropertyFormTextField(
          controller:
          _detailsController.tenantPhoneController,
          label: 'Tenant Phone',
          hintText: 'Enter tenant phone number...',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),

        if (_tenantPhoneError != null) ...[
          SizedBox(height: 7.0.h),
          _buildErrorMessage(_tenantPhoneError!),
        ],
      ],
    );
  }

  Widget _buildLandlordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDynamicNameSection(
          fieldLabel: 'Landlord Name',
          hintText: 'Enter landlord name...',
          controllers: _landlordControllers,
          idCodeControllers: _landlordIdCodeControllers,
          showIdCodeField: true,
          errorText: _landlordError,
          onAdd: _addLandlordField,
          onRemove: _removeLandlordField,
        ),

        SizedBox(height: 18.0.h),

        PropertyFormTextField(
          controller:
          _detailsController.landlordPhoneController,
          label: 'Landlord Phone',
          hintText: 'Enter landlord phone number...',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),

        if (_landlordPhoneError != null) ...[
          SizedBox(height: 7.0.h),
          _buildErrorMessage(_landlordPhoneError!),
        ],
      ],
    );
  }

  Widget _buildOrderedTenantLandlordSections() {
    return Obx(() {
      final role =
      _detailsController.selectedRole.value.trim().toLowerCase();
      final landlordFirst = role.contains('landlord');

      final tenantBlock = _buildTenantSection();
      final landlordBlock = _buildLandlordSection();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: landlordFirst
            ? [
          landlordBlock,
          SizedBox(height: 8.0.h),
          tenantBlock,
        ]
            : [
          tenantBlock,
          SizedBox(height: 8.0.h),
          landlordBlock,
        ],
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Dynamic name section
  // ---------------------------------------------------------------------------

  Widget _buildDynamicNameSection({
    required String fieldLabel,
    required String hintText,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    required ValueChanged<int> onRemove,
    List<TextEditingController>? idCodeControllers,
    bool showIdCodeField = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Only one label, with ADD button.
        Row(
          children: [
            Expanded(
              child: Text(
                fieldLabel,
                style: TextStyle(
                  color: const Color(0xFF7F8C8D),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 11.0.sp,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            if (controllers.length < 5)
              InkWell(
                onTap: onAdd,
                borderRadius:
                BorderRadius.circular(20.0.w),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0.w,
                    vertical: 7.0.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007BFF)
                        .withValues(alpha: 0.10),
                    borderRadius:
                    BorderRadius.circular(20.0.w),
                    border: Border.all(
                      color: const Color(0xFF007BFF)
                          .withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color:
                        const Color(0xFF007BFF),
                        size: 18.0.w,
                      ),
                      SizedBox(width: 4.0.w),
                      Text(
                        'ADD',
                        style: TextStyle(
                          color:
                          const Color(0xFF007BFF),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w800,
                          fontSize: 11.0.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        ...List.generate(
          controllers.length,
              (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom:
                index == controllers.length - 1
                    ? 0
                    : 15.0.h,
              ),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        if (index > 0) ...[
                          Text(
                            '${index + 1}. OPTIONAL',
                            style: TextStyle(
                              color:
                              const Color(0xFF95A5A6),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 9.0.sp,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],

                        // No repeated field name here.
                        PropertyFormTextField(
                          controller: controllers[index],
                          label: '',
                          hintText: index == 0
                              ? hintText
                              : 'Enter ${fieldLabel.toLowerCase()}...',
                        ),

                        if (showIdCodeField &&
                            idCodeControllers != null &&
                            index > 0) ...[
                          SizedBox(height: 8.0.h),

                          PropertyFormTextField(
                            controller: idCodeControllers[index],
                            label: '',
                            hintText: 'Enter ${fieldLabel.toLowerCase().replaceAll(' name', '')} ID code...',
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (index > 0) ...[
                    SizedBox(width: 8.0.w),
                    InkWell(
                      onTap: () => onRemove(index),
                      borderRadius:
                      BorderRadius.circular(24.0.w),
                      child: Container(
                        width: 44.0.w,
                        height: 44.0.h,
                        margin:
                        EdgeInsets.only(bottom: 2.0.h),
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFFFFF1F1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                            const Color(0xFFFFC9C9),
                          ),
                        ),
                        child: Icon(
                          Icons.remove_rounded,
                          color:
                          const Color(0xFFFA5252),
                          size: 20.0.w,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),

        SizedBox(height: 7.0.h),

        Text(
          '${controllers.length}/5 names',
          style: TextStyle(
            color: const Color(0xFF95A5A6),
            fontFamily: 'Montserrat',
            fontSize: 10.0.sp,
            fontWeight: FontWeight.w600,
          ),
        ),

        if (errorText != null) ...[
          SizedBox(height: 7.0.h),
          _buildErrorMessage(errorText),
        ],
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: const Color(0xFFFA5252),
          size: 16.0.w,
        ),
        SizedBox(width: 6.0.w),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: const Color(0xFFFA5252),
              fontFamily: 'Montserrat',
              fontSize: 11.0.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50.0.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0.w),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF2563EB),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6)
                .withValues(alpha: 0.35),
            blurRadius: 8.0.w,
            offset: Offset(0, 4.0.h),
          ),
        ],
      ),
      child: Obx(
            () => ElevatedButton(
          onPressed:
          _detailsController.isLoading.value
              ? null
              : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(25.0.w),
            ),
          ),
          child: _detailsController.isLoading.value
              ? SizedBox(
            width: 20.0.w,
            height: 20.0.h,
            child: CircularProgressIndicator(
              valueColor:
              const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
              strokeWidth: 2.0.w,
            ),
          )
              : Text(
            'Save & Continue',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              fontSize: 15.0.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class AddressDetailsDialog extends StatefulWidget {
  final String initialStreet;
  final String initialCity;
  final String initialState;
  final String initialZip;
  final String initialCountry;

  const AddressDetailsDialog({
    super.key,
    required this.initialStreet,
    required this.initialCity,
    required this.initialState,
    required this.initialZip,
    required this.initialCountry,
  });

  @override
  State<AddressDetailsDialog> createState() =>
      _AddressDetailsDialogState();
}

class _AddressDetailsDialogState
    extends State<AddressDetailsDialog> {
  late final TextEditingController streetController;
  late final TextEditingController cityController;
  late final TextEditingController stateController;
  late final TextEditingController zipController;
  late final TextEditingController countryController;

  String? _streetError;
  String? _cityError;
  String? _stateError;
  String? _zipError;
  String? _countryError;

  @override
  void initState() {
    super.initState();

    streetController = TextEditingController(
      text: widget.initialStreet,
    );

    cityController = TextEditingController(
      text: widget.initialCity,
    );

    stateController = TextEditingController(
      text: widget.initialState,
    );

    zipController = TextEditingController(
      text: widget.initialZip,
    );

    countryController = TextEditingController(
      text: widget.initialCountry,
    );

    streetController.addListener(_clearStreetError);
    cityController.addListener(_clearCityError);
    stateController.addListener(_clearStateError);
    zipController.addListener(_clearZipError);
    countryController.addListener(_clearCountryError);
  }

  @override
  void dispose() {
    streetController.removeListener(_clearStreetError);
    cityController.removeListener(_clearCityError);
    stateController.removeListener(_clearStateError);
    zipController.removeListener(_clearZipError);
    countryController.removeListener(_clearCountryError);

    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    countryController.dispose();

    super.dispose();
  }

  void _clearStreetError() {
    if (_streetError != null) setState(() => _streetError = null);
  }

  void _clearCityError() {
    if (_cityError != null) setState(() => _cityError = null);
  }

  void _clearStateError() {
    if (_stateError != null) setState(() => _stateError = null);
  }

  void _clearZipError() {
    if (_zipError != null) setState(() => _zipError = null);
  }

  void _clearCountryError() {
    if (_countryError != null) setState(() => _countryError = null);
  }

  Future<void> _openCountryPicker() async {
    FocusManager.instance.primaryFocus?.unfocus();

    await Future<void>.delayed(
      const Duration(milliseconds: 100),
    );

    if (!mounted) return;

    showCountryPicker(
      context: context,
      useRootNavigator: true,
      onSelect: (Country country) {
        if (!mounted) return;

        countryController.text = country.name;
      },
    );
  }

  Future<void> _closeDialog(
      Map<String, String>? result,
      ) async {
    FocusManager.instance.primaryFocus?.unfocus();

    await Future<void>.delayed(
      const Duration(milliseconds: 100),
    );

    if (!mounted) return;

    Navigator.of(context).pop(result);
  }

  void _submit() {
    final street = streetController.text.trim();
    final city = cityController.text.trim();
    final state = stateController.text.trim();
    final zip = zipController.text.trim();
    final country = countryController.text.trim();

    setState(() {
      _streetError =
      street.isEmpty ? 'Please enter the street address.' : null;
      _cityError = city.isEmpty ? 'Please enter the city.' : null;
      _stateError = state.isEmpty ? 'Please enter the county/state.' : null;
      _zipError = zip.isEmpty ? 'Please enter the zip code.' : null;
      _countryError =
      country.isEmpty ? 'Please enter the country.' : null;
    });

    if (_streetError != null ||
        _cityError != null ||
        _stateError != null ||
        _zipError != null ||
        _countryError != null) {
      return;
    }

    final result = <String, String>{
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
    };

    _closeDialog(result);
  }

  Widget _buildFieldError(String message) {
    return Padding(
      padding: EdgeInsets.only(top: 4.0.h, bottom: 4.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: const Color(0xFFFA5252),
            size: 14.0.w,
          ),
          SizedBox(width: 6.0.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: const Color(0xFFFA5252),
                fontFamily: 'Montserrat',
                fontSize: 10.0.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0.w),
      ),
      title: Text(
        'ENTER ADDRESS DETAILS',
        style: TextStyle(
          color: const Color(0xFF2C3E50),
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w800,
          fontSize: 14.0.sp,
          letterSpacing: 1.2,
        ),
      ),
      content: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior:
        ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AddressPopupField(
              controller: streetController,
              label: 'Street Address',
              hint: 'e.g. 1180 Folsom St',
            ),
            if (_streetError != null) _buildFieldError(_streetError!),
            SizedBox(height: 12.0.h),
            AddressPopupField(
              controller: cityController,
              label: 'City',
              hint: 'e.g. San Francisco',
            ),
            if (_cityError != null) _buildFieldError(_cityError!),
            SizedBox(height: 12.0.h),
            AddressPopupField(
              controller: stateController,
              label: 'County/State',
              hint: 'e.g. CA',
            ),
            if (_stateError != null) _buildFieldError(_stateError!),
            SizedBox(height: 12.0.h),
            AddressPopupField(
              controller: zipController,
              label: 'Zip Code',
              hint: 'e.g. 94103',
            ),
            if (_zipError != null) _buildFieldError(_zipError!),
            SizedBox(height: 12.0.h),
            AddressPopupField(
              controller: countryController,
              label: 'Country',
              hint: 'e.g. USA',

              // onTap: _openCountryPicker,
            ),
            if (_countryError != null) _buildFieldError(_countryError!),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _closeDialog(null),
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
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007BFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0.w),
            ),
          ),
          child: Text(
            'Submit',
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
  }
}