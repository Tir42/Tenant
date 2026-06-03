import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:tenantsnap/screens/theme.dart';

import 'inspection_flow_list_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  String _selectedRole = 'tenant'; // 'tenant' or 'landlord'
  final _tenantController = TextEditingController();
  final _landlordController = TextEditingController();
  final _addressController = TextEditingController();
  final _possessionDateController = TextEditingController();
  final _leaseDateController = TextEditingController();

  @override
  void dispose() {
    _tenantController.dispose();
    _landlordController.dispose();
    _addressController.dispose();
    _possessionDateController.dispose();
    _leaseDateController.dispose();
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
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _handleStartInspection() {
    final bool isTenant = _selectedRole == 'tenant';
    final String name = isTenant ? _tenantController.text : _landlordController.text;
    final String roleLabel = isTenant ? 'Tenant Name' : 'Landlord Name';

    if (name.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter the $roleLabel and Property Address to proceed.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const InspectionFlowListScreen(),
      ),
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Elegant white card centered container matching premium light theme
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
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- TITLE ---
                        const Text(
                          'Tell Us About Your\nNew Home',
                          style: TextStyle(
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // --- ROLE SELECTOR DROPDOWN ---
                        _buildCustomDropdownField(
                          value: _selectedRole,
                          icon: _selectedRole == 'tenant' ? Icons.person : Icons.apartment,
                          items: const [
                            DropdownMenuItem(
                              value: 'tenant',
                              child: Text(
                                'Register as Tenant',
                                style: TextStyle(
                                  color: Color(0xFF2C3E50),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'landlord',
                              child: Text(
                                'Register as Landlord',
                                style: TextStyle(
                                  color: Color(0xFF2C3E50),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedRole = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // --- DYNAMIC ROLE-BASED NAME FIELD ---
                        if (_selectedRole == 'tenant')
                          _buildCustomInputField(
                            controller: _tenantController,
                            hintText: 'Tenant Name',
                            icon: Icons.person,
                          )
                        else
                          _buildCustomInputField(
                            controller: _landlordController,
                            hintText: 'Landlord Name',
                            icon: Icons.apartment,
                          ),
                        const SizedBox(height: 16),

                        // --- 3. PROPERTY ADDRESS FIELD ---
                        _buildCustomInputField(
                          controller: _addressController,
                          hintText: 'Property Address',
                          icon: Icons.home,
                        ),
                        const SizedBox(height: 16),

                        // --- 4. POSSESSION DATE FIELD (With Date Picker Icon) ---
                        _buildCustomInputField(
                          controller: _possessionDateController,
                          hintText: 'Possession Date',
                          icon: Icons.location_on,
                          isDatePicker: true,
                        ),
                        const SizedBox(height: 16),

                        // --- 5. AGREEMENT DATE FIELD (With Date Picker Icon) ---
                        _buildCustomInputField(
                          controller: _leaseDateController,
                          hintText: 'Agreement Date',
                          icon: Icons.date_range,
                          isDatePicker: true,
                        ),
                        const SizedBox(height: 32),

                        // --- 6. START INSPECTION PILL BUTTON ---
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF007BFF), // Rich Blue as in screenshot
                                Color(0xFF00C6FF),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF007BFF).withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _handleStartInspection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'Start Inspection',
                              style: AntigravityTextStyles.bodyLarge(Colors.white).copyWith(
                                fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildCustomInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isDatePicker = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // White card as in screenshot
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: isDatePicker,
        onTap: isDatePicker ? () => _selectDate(context, controller) : null,
        style: const TextStyle(
          color: Color(0xFF2C3E50), // Muted dark slate text
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF95A5A6), // Muted placeholder grey
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF007BFF), // Custom blue icon color as in screenshot
            size: 20,
          ),
          suffixIcon: isDatePicker
              ? IconButton(
                  icon: const Icon(
                    Icons.calendar_month,
                    color: Color(0xFF007BFF),
                    size: 20,
                  ),
                  onPressed: () => _selectDate(context, controller),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildCustomDropdownField({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField2<String>(
        value: value,
        isExpanded: true,
        style: const TextStyle(
          color: Color(0xFF2C3E50),
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF007BFF),
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        buttonStyleData: const ButtonStyleData(
          height: 48,
          padding: EdgeInsets.zero,
        ),
        iconStyleData: const IconStyleData(
          icon: Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF007BFF),
              size: 24,
            ),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          elevation: 12,
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
