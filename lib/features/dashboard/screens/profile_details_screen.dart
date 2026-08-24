import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tenantsnap/core/controllers/base_controller.dart';
import 'package:tenantsnap/features/auth/login/screen/login_screen.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final String role;
  final String userName;

  const ProfileDetailsScreen({
    super.key,
    required this.role,
    required this.userName,
  });

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late String _activeRole;
  late String _userName;

  @override
  void initState() {
    super.initState();
    _activeRole = widget.role;
    _userName = BaseController.name.value.isNotEmpty ? BaseController.name.value : widget.userName;
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = _activeRole == 'tenant' ? const Color(0xFF007BFF) : const Color(0xFF2ECC71);
    final String activeEmail = BaseController.email.value.isNotEmpty ? BaseController.email.value : '';
    final String activePhone = BaseController.phone.value.isNotEmpty ? BaseController.phone.value : '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'MY PROFILE',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: Color(0xFFE2E8F0),
            height: 1.0,
            thickness: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: activeColor, width: 2.0),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE5EEF5), Color(0xFFC6DBED)],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                              style: TextStyle(
                                  color: activeColor,
                                  fontFamily: 'Montserrat',
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Montserrat',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeEmail,
                      style: const TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: activeColor.withValues(alpha: 0.2), width: 0.8),
                      ),
                      child: Text(
                        _activeRole == 'tenant' ? 'SECURE TENANT NODE' : 'VERIFIED LANDLORD PORTAL',
                        style: TextStyle(
                          color: activeColor,
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'USER CREDENTIAL NODE DETAILS',
                style: TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildTelemetryRow('Registered Email', activeEmail),
              const Divider(color: Color(0xFFE2E8F0), height: 24),
              _buildTelemetryRow('Registered Phone', activePhone),
              const Divider(color: Color(0xFFE2E8F0), height: 24),
              _buildTelemetryRow('Workspace Node ID', 'WSN-0294-SF82'),
              const Divider(color: Color(0xFFE2E8F0), height: 24),
              _buildTelemetryRow('Last Synced Stamp', 'June 16, 2026 • 17:30'),
              const Divider(color: Color(0xFFE2E8F0), height: 24),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: const Color(0xFFFFF5F5), // Light elegant red backdrop
                  border: Border.all(color: const Color(0xFFFFC9C9), width: 1.0),
                ),
                child: InkWell(
                  onTap: () async {
                    final box = GetStorage();

                    // Clear saved login session
                    await box.write('isLoggedIn', false);
                    await box.remove('loginTime');
                    await box.remove('role');
                    await box.remove('userName');

                    // Clear global user details
                    BaseController.name.value = '';
                    BaseController.email.value = '';
                    BaseController.phone.value = '';
                    BaseController.idCode.value = '';

                    Get.snackbar(
                      'Disconnected',
                      'Secure session closed successfully.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF2C3E50),
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    );

                    // Remove all previous screens
                    Get.offAll(
                          () => const LoginScreen(),
                      transition: Transition.fade,
                      duration: const Duration(milliseconds: 600),
                    );
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFFA5252),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'SECURE LOG OUT',
                          style: TextStyle(
                            color: Color(0xFFFA5252),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7F8C8D),
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
