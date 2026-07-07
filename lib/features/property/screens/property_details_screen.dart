import 'package:flutter/material.dart';
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AddressPopupField(controller: streetController, label: 'STREET ADDRESS', hint: 'e.g. 1180 Folsom St'),
                SizedBox(height: 12.0.h),
                AddressPopupField(controller: cityController, label: 'CITY', hint: 'e.g. San Francisco'),
                SizedBox(height: 12.0.h),
                AddressPopupField(controller: stateController, label: 'STATE', hint: 'e.g. CA'),
                SizedBox(height: 12.0.h),
                AddressPopupField(controller: zipController, label: 'ZIP CODE', hint: 'e.g. 94103'),
                SizedBox(height: 12.0.h),
                AddressPopupField(
                  controller: countryController,
                  label: 'COUNTRY / COUNTY',
                  hint: 'e.g. USA',
                  readOnly: true,
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      onSelect: (Country country) {
                        countryController.text = country.name;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
      },
    );
  }


  void _handleSubmit() async {
    final success = await _detailsController.submitMetadata();

    if (!success) {
      if (!mounted) return;
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
            padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 16.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: BACK ARROW & ACTIONS ---
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44.w,
                        height: 44.h,
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
                            size: 20.w,
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
                ),
                SizedBox(height: 24.0.h),

                // --- FORM CARD CONTAINER ---
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32.0.w),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2C3E50).withValues(alpha: 0.06),
                        blurRadius: 24.0.w,
                        offset: Offset(0, 10.0.h),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 28.0.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => _buildDropdownField(
                        label: 'Register as',
                        value: _detailsController.selectedRole.value,
                        items: const ['Tenant', 'Landlord'],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _detailsController.updateSelectedRole(newValue);
                          }
                        },
                      )),
                      SizedBox(height: 18.0.h),

                      PropertyFormTextField(
                        controller: _detailsController.idCodeController,
                        label: 'ID CODE',
                        hintText: 'Enter ID code...',
                      ),
                      SizedBox(height: 18.0.h),

                      PropertyFormTextField(
                        controller: _detailsController.tenantController,
                        label: 'TENANT NAME',
                        hintText: 'Enter tenant name...',
                      ),
                      SizedBox(height: 18.0.h),

                      PropertyFormTextField(
                        controller: _detailsController.tenantPhoneController,
                        label: 'TENANT PHONE',
                        hintText: 'Enter tenant phone number...',
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 18.0.h),

                      PropertyFormTextField(
                        controller: _detailsController.landlordController,
                        label: 'LANDLORD NAME',
                        hintText: 'Enter landlord name...',
                      ),
                      SizedBox(height: 18.0.h),

                      PropertyFormTextField(
                        controller: _detailsController.landlordPhoneController,
                        label: 'LANDLORD PHONE',
                        hintText: 'Enter landlord phone number...',
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 18.0.h),

                      PropertyFormTextField(
                        controller: _detailsController.addressController,
                        label: 'FULL ADDRESS',
                        hintText: 'Enter address...',
                        readOnly: true,
                        onTap: _showAddressDialog,
                      ),
                      SizedBox(height: 18.0.h),

                      PropertyFormTextField(
                        controller: _detailsController.possessionDateController,
                        label: 'POSSESSION DATE',
                        hintText: 'Select date...',
                        isDatePicker: true,
                        onTap: () => _detailsController.selectDate(context, _detailsController.possessionDateController),
                      ),
                      SizedBox(height: 18.0.h),

                      PropertyFormTextField(
                        controller: _detailsController.leaseDateController,
                        label: 'AGREEMENT DATE',
                        hintText: 'Select date...',
                        isDatePicker: true,
                        onTap: () => _detailsController.selectDate(context, _detailsController.leaseDateController),
                      ),
                      SizedBox(height: 18.0.h),

                      Obx(() => _buildDropdownField(
                        label: 'INSPECTION TYPE',
                        value: _detailsController.inspectionType.value,
                        items: const ['Move-In', 'Move-Out'],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _detailsController.inspectionType.value = newValue;
                          }
                        },
                      )),
                      SizedBox(height: 18.0.h),

                      Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SHOW PHONE NUMBERS IN PDF',
                            style: TextStyle(
                              color: const Color(0xFF7F8C8D),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 11.0.sp,
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
                      SizedBox(height: 28.0.h),

                      Container(
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
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                              blurRadius: 8.0.w,
                              offset: Offset(0, 4.0.h),
                            ),
                          ],
                        ),
                        child: Obx(() => ElevatedButton(
                          onPressed: _detailsController.isLoading.value ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0.w),
                            ),
                          ),
                          child: _detailsController.isLoading.value
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
                        )),
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
          style: TextStyle(
            color: const Color(0xFF2C3E50),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 13.0.sp,
          ),
        ),
        SizedBox(height: 8.0.h),
        Container(
          height: 48.0.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0.w),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0.w),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.0.w),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: displayValue,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFF7F8C8D),
                size: 20.w,
              ),
              style: TextStyle(
                color: const Color(0xFF2C3E50),
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                fontSize: 14.0.sp,
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
