import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/features/auth/login/screen/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String role;
  final String userName;

  const SettingsScreen({
    super.key,
    required this.role,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
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
          'SETTINGS',
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
              const Text(
                'INTEGRATION PREFERENCES',
                style: TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.notifications_none_rounded,
                    title: 'Push Notifications',
                    subtitle: 'Configure inspection alert alerts.',
                    onTap: () {},
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.fingerprint_rounded,
                    title: 'Biometric Access',
                    subtitle: 'Secure profile nodes biometric check.',
                    onTap: () {},
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.cleaning_services_rounded,
                    title: 'Clear Cache',
                    subtitle: 'Erase cached document photo logs.',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cache data erased successfully.')),
                      );
                    },
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                ],
              ),
              const SizedBox(height: 36),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.offAll(() => const LoginScreen());
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: Color(0xFFE74C3C), size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Log Out Portal Connection',
                          style: TextStyle(
                            color: const Color(0xFFE74C3C),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color(0xFFF2F4F7),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF2C3E50),
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2C3E50),
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF7F8C8D),
          fontFamily: 'Montserrat',
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFBDC3C7),
        size: 20,
      ),
    );
  }
}
