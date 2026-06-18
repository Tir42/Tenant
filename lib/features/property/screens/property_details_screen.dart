import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/features/inspection/screens/inspection_flow_list_screen.dart';
import 'package:tenantsnap/features/dashboard/screens/settings_screen.dart';
import 'package:tenantsnap/features/auth/login/screen/login_screen.dart';
import 'package:tenantsnap/features/property/controllers/property_details_controller.dart';

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
  late final PropertyDetailsController _detailsController;

  @override
  void initState() {
    super.initState();
    _detailsController = Get.put(PropertyDetailsController());
    _detailsController.initializeData(
      initialRole: widget.role,
      initialUserName: widget.userName,
    );
  }

  @override
  void dispose() {
    Get.delete<PropertyDetailsController>();
    super.dispose();
  }

  void _showAddressDialog() {
    final streetController = TextEditingController();
    final cityController = TextEditingController(text: _detailsController.cityController.text);
    final stateController = TextEditingController(text: _detailsController.stateController.text);
    final zipController = TextEditingController(text: _detailsController.zipController.text);
    final countryController = TextEditingController(text: _detailsController.countryController.text);

    if (_detailsController.addressController.text.isNotEmpty) {
      final parts = _detailsController.addressController.text.split(',');
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

                _detailsController.updateAddress(
                  street: street,
                  city: city,
                  state: state,
                  zip: zip,
                  country: country,
                );

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
    final success = _detailsController.submitMetadata();

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Tenant Name, Landlord Name, and Full Address to proceed.'),
        ),
      );
      return;
    }

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
                              role: _detailsController.selectedRole.value,
                              userName: _detailsController.selectedRole.value == 'tenant' 
                                  ? _detailsController.tenantController.text 
                                  : _detailsController.landlordController.text,
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
                      Obx(() => _buildDropdownField(
                        label: 'Register as',
                        value: _detailsController.selectedRole.value,
                        items: ['Tenant', 'Landlord'],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _detailsController.updateSelectedRole(newValue);
                          }
                        },
                      )),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _detailsController.idCodeController,
                        label: 'ID CODE',
                        hintText: 'Enter ID code...',
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _detailsController.tenantController,
                        label: 'TENANT NAME',
                        hintText: 'Enter tenant name...',
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _detailsController.tenantPhoneController,
                        label: 'TENANT PHONE',
                        hintText: 'Enter tenant phone number...',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _detailsController.landlordController,
                        label: 'LANDLORD NAME',
                        hintText: 'Enter landlord name...',
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _detailsController.landlordPhoneController,
                        label: 'LANDLORD PHONE',
                        hintText: 'Enter landlord phone number...',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _detailsController.addressController,
                        label: 'FULL ADDRESS',
                        hintText: 'Enter address...',
                        readOnly: true,
                        onTap: _showAddressDialog,
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _detailsController.possessionDateController,
                        label: 'POSSESSION DATE',
                        hintText: 'Select date...',
                        isDatePicker: true,
                        onTap: () => _detailsController.selectDate(context, _detailsController.possessionDateController),
                      ),
                      const SizedBox(height: 18),

                      _buildFormTextField(
                        controller: _detailsController.leaseDateController,
                        label: 'AGREEMENT DATE',
                        hintText: 'Select date...',
                        isDatePicker: true,
                        onTap: () => _detailsController.selectDate(context, _detailsController.leaseDateController),
                      ),
                      const SizedBox(height: 18),

                      Obx(() => Row(
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
                            value: _detailsController.showPhoneInPdf.value,
                            onChanged: (bool val) {
                              _detailsController.toggleShowPhoneInPdf(val);
                            },
                            activeColor: const Color(0xFF007BFF),
                          ),
                        ],
                      )),
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
