import 'package:flutter/material.dart';
import '../theme.dart';
import 'inspection_flow_list_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
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
            colorScheme: const ColorScheme.dark(
              primary: AntigravityColors.accentTeal,
              onPrimary: AntigravityColors.primaryDb,
              surface: Color(0xFF1B0C30),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AntigravityColors.primaryDb,
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
    if (_tenantController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the Tenant Name and Property Address to proceed.'),
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
                  // Glassmorphic Card matching the uploaded screenshot layout
                  AntigravityCard(
                    glowColor: AntigravityColors.accentTeal,
                    glowOpacity: 0.25,
                    borderRadius: 24.0,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    width: size.width * 0.9,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- TITLE ---
                        Text(
                          'Tell Us About Your\nNew Home',
                          style: AntigravityTextStyles.headingLarge(AntigravityColors.textMain).copyWith(
                            fontSize: 26,
                            height: 1.2,
                            shadows: [], // Crisp look as in screenshot
                          ),
                        ),
                        const SizedBox(height: 28),

                        // --- 1. TENANT NAME FIELD ---
                        _buildCustomInputField(
                          controller: _tenantController,
                          hintText: 'Tenant Name',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),

                        // --- 2. LANDLORD NAME FIELD ---
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
}
