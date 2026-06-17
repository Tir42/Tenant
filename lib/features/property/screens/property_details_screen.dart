import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/features/inspection/controllers/inspection_controller.dart';
import 'package:tenantsnap/features/inspection/screens/inspection_flow_list_screen.dart';
import 'package:tenantsnap/features/dashboard/screens/settings_screen.dart';
import 'package:tenantsnap/features/auth/screens/login_screen.dart';
import 'package:tenantsnap/features/auth/controllers/auth_controller.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final String role;
  final String? userName;

  const PropertyDetailsScreen({
    super.key,
    this.role = 'tenant',
    this.userName,
  });

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  String _selectedRole = 'tenant';
  final _tenantController = TextEditingController();
  final _landlordController = TextEditingController();
  final _tenantPhoneController = TextEditingController();
  final _landlordPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _possessionDateController = TextEditingController();
  final _leaseDateController = TextEditingController();
  final _idCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();
  bool _showPhoneInPdf = true;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.role;

    final controller = Get.find<InspectionController>();
    final authController = Get.find<AuthController>();

    _idCodeController.text = controller.idCode.value;
    if (_idCodeController.text == 'TS-402-URBL' && authController.idCode.value.isNotEmpty) {
      _idCodeController.text = authController.idCode.value;
    }

    _tenantController.text = controller.tenantName.value;
    if (_tenantController.text == 'Liam Carter' && _selectedRole == 'tenant' && authController.name.value.isNotEmpty) {
      _tenantController.text = authController.name.value;
    }

    _landlordController.text = controller.landlordName.value;
    if (_landlordController.text == 'Victoria Sterling' && _selectedRole == 'landlord' && authController.name.value.isNotEmpty) {
      _landlordController.text = authController.name.value;
    }

    _tenantPhoneController.text = controller.tenantPhone.value;
    if (_tenantPhoneController.text == '+1 (555) 012-3456' && _selectedRole == 'tenant' && authController.phone.value.isNotEmpty) {
      _tenantPhoneController.text = authController.phone.value;
    }

    _landlordPhoneController.text = controller.landlordPhone.value;
    if (_landlordPhoneController.text == '+1 (555) 019-2834' && _selectedRole == 'landlord' && authController.phone.value.isNotEmpty) {
      _landlordPhoneController.text = authController.phone.value;
    }

    _showPhoneInPdf = controller.showPhoneInPdf.value;

    _addressController.text = controller.propertyAddress.value;
    _cityController.text = controller.city.value;
    _stateController.text = controller.state.value;
    _zipController.text = controller.zipcode.value;
    _countryController.text = controller.country.value;
    _possessionDateController.text = controller.possessionDate.value;
    _leaseDateController.text = controller.agreementDate.value;

    if (widget.userName != null && widget.userName!.isNotEmpty) {
      if (_selectedRole == 'tenant') {
        _tenantController.text = widget.userName!;
      } else {
        _landlordController.text = widget.userName!;
      }
    }
  }

  @override
  void dispose() {
    _tenantController.dispose();
    _landlordController.dispose();
    _tenantPhoneController.dispose();
    _landlordPhoneController.dispose();
    _addressController.dispose();
    _possessionDateController.dispose();
    _leaseDateController.dispose();
    _idCodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
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
      setState(() {
        controller.text = "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _showAddressDialog() {
    final streetController = TextEditingController();
    final cityController = TextEditingController(text: _cityController.text);
    final stateController = TextEditingController(text: _stateController.text);
    final zipController = TextEditingController(text: _zipController.text);
    final countryController = TextEditingController(text: _countryController.text);

    if (_addressController.text.isNotEmpty) {
      final parts = _addressController.text.split(',');
      if (parts.isNotEmpty) {
        streetController.text = parts[0].trim();
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          title: const Text(
            'ENTER ADDRESS DETAILS',
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          content: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPopupField(controller: streetController, label: 'STREET ADDRESS', hint: 'e.g. 1180 Folsom St'),
                const SizedBox(height: 12),
                _buildPopupField(controller: cityController, label: 'CITY', hint: 'e.g. San Francisco'),
                const SizedBox(height: 12),
                _buildPopupField(controller: stateController, label: 'STATE', hint: 'e.g. CA'),
                const SizedBox(height: 12),
                _buildPopupField(controller: zipController, label: 'ZIP CODE', hint: 'e.g. 94103'),
                const SizedBox(height: 12),
                _buildPopupField(controller: countryController, label: 'COUNTRY / COUNTY', hint: 'e.g. USA'),
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
                final street = streetController.text.trim();
                final city = cityController.text.trim();
                final state = stateController.text.trim();
                final zip = zipController.text.trim();
                final country = countryController.text.trim();

                setState(() {
                  _cityController.text = city;
                  _stateController.text = state;
                  _zipController.text = zip;
                  _countryController.text = country;
                  
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

                  _addressController.text = addressParts.join(', ');
                });

                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit',
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
  }

  Widget _buildPopupField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7F8C8D),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF95A5A6),
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    final String idCodeVal = _idCodeController.text.trim();
    final String tenantNameVal = _tenantController.text.trim();
    final String landlordNameVal = _landlordController.text.trim();
    final String tenantPhoneVal = _tenantPhoneController.text.trim();
    final String landlordPhoneVal = _landlordPhoneController.text.trim();
    final String addressVal = _addressController.text.trim();
    final String cityVal = _cityController.text.trim();
    final String stateVal = _stateController.text.trim();
    final String zipVal = _zipController.text.trim();
    final String countryVal = _countryController.text.trim();
    final String possessionDateVal = _possessionDateController.text.trim();
    final String agreementDateVal = _leaseDateController.text.trim();

    if (tenantNameVal.isEmpty || landlordNameVal.isEmpty || addressVal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Tenant Name, Landlord Name, and Full Address to proceed.'),
        ),
      );
      return;
    }

    final controller = Get.find<InspectionController>();
    controller.updateMetadata(
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
      showPhone: _showPhoneInPdf,
    );

    Get.off(() => const InspectionFlowListScreen());
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: BACK ARROW & ACTIONS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Color(0xFF2C3E50),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Property Details',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xFF2C3E50),
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Register address & lease data',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xFF7F8C8D),
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(() => SettingsScreen(
                              role: _selectedRole,
                              userName: _selectedRole == 'tenant' ? _tenantController.text : _landlordController.text,
                            ));
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.settings_outlined,
                                color: Color(0xFF2C3E50),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Get.offAll(() => const LoginScreen());
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.logout_rounded,
                                color: Color(0xFF2C3E50),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- FORM CARD CONTAINER ---
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2C3E50).withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDropdownField(
                        label: 'Register as',
                        value: _selectedRole,
                        items: ['Tenant', 'Landlord'],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedRole = newValue.toLowerCase();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _idCodeController,
                        label: 'ID CODE',
                        hintText: 'Enter ID code...',
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _tenantController,
                        label: 'TENANT NAME',
                        hintText: 'Enter tenant name...',
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _tenantPhoneController,
                        label: 'TENANT PHONE',
                        hintText: 'Enter tenant phone number...',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _landlordController,
                        label: 'LANDLORD NAME',
                        hintText: 'Enter landlord name...',
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _landlordPhoneController,
                        label: 'LANDLORD PHONE',
                        hintText: 'Enter landlord phone number...',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _addressController,
                        label: 'FULL ADDRESS',
                        hintText: 'Enter address...',
                        readOnly: true,
                        onTap: _showAddressDialog,
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _possessionDateController,
                        label: 'POSSESSION DATE',
                        hintText: 'Select date...',
                        isDatePicker: true,
                        onTap: () => _selectDate(context, _possessionDateController),
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _leaseDateController,
                        label: 'AGREEMENT DATE',
                        hintText: 'Select date...',
                        isDatePicker: true,
                        onTap: () => _selectDate(context, _leaseDateController),
                      ),
                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SHOW PHONE NUMBERS IN PDF',
                            style: TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Switch(
                            value: _showPhoneInPdf,
                            onChanged: (bool val) {
                              setState(() {
                                _showPhoneInPdf = val;
                              });
                            },
                            activeColor: const Color(0xFF007BFF),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3B82F6), 
                              Color(0xFF2563EB),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Save & Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildFormTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    bool readOnly = false,
    bool isDatePicker = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7F8C8D),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly || isDatePicker,
            onTap: onTap,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF95A5A6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xFF007BFF), width: 1.5),
              ),
              suffixIcon: isDatePicker
                  ? const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF2C3E50),
                        size: 18,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    String displayValue = value.substring(0, 1).toUpperCase() + value.substring(1);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: displayValue,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF7F8C8D),
                size: 20,
              ),
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                fontSize: 14,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
