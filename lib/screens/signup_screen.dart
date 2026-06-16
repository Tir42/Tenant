import 'package:flutter/material.dart';
import 'package:tenantsnap/screens/theme.dart';

import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handlePrimaryAction() {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all details to create your profile.'),
        ),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating new secure tenant profile...'),
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
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
                      children: [
                        // --- 1. VECTOR LOGO ---
                        CustomPaint(
                          size: const Size(80, 70),
                          painter: SignUpLogoPainter(),
                        ),
                        const SizedBox(height: 16),

                        // --- 2. TITLE ---
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              fontFamily: 'Montserrat',
                            ),
                            children: [
                              TextSpan(text: 'Tenant'),
                              TextSpan(
                                text: 'Snap',
                                style: TextStyle(
                                  color: Color(0xFF2ECC71),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),

                        // --- 3. SUBTITLE ---
                        const Text(
                          'Create Secure Account',
                          style: TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // --- 4. TEXT FIELDS ---
                        // First Name & Last Name
                        Row(
                          children: [
                            Expanded(
                              child: _buildCustomTextField(
                                controller: _firstNameController,
                                hintText: 'First Name',
                                icon: Icons.person_outline,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCustomTextField(
                                controller: _lastNameController,
                                hintText: 'Last Name',
                                icon: Icons.person_outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Email Field
                        _buildCustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),

                        // Phone Number
                        _buildCustomTextField(
                          controller: _phoneController,
                          hintText: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),

                        // Password Field
                        _buildCustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 14),

                        // Confirm Password Field
                        _buildCustomTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),

                        // --- 5. PRIMARY BUTTON ---
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF007BFF),
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
                            onPressed: _handlePrimaryAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24)),
                            ),
                            child: Text(
                              'Create Account',
                              style: AntigravityTextStyles.bodyLarge(Colors.white).copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- 6. NAVIGATE BACK TO SIGN IN ---
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Already have an account? Sign In',
                            style: TextStyle(
                              color: Color(0xFF007BFF),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFF2C3E50),
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF95A5A6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF7F8C8D),
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }
}

// Custom Painter for the Logo (matching the design)
class SignUpLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint housePaint = Paint()
      ..color = const Color(0xFF007BFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final Path housePath = Path()
      ..moveTo(w * 0.15, h * 0.55)
      ..lineTo(w * 0.15, h * 0.9)
      ..lineTo(w * 0.85, h * 0.9)
      ..lineTo(w * 0.85, h * 0.55)
      ..moveTo(w * 0.1, h * 0.55)
      ..lineTo(w * 0.5, h * 0.15)
      ..lineTo(w * 0.9, h * 0.55);

    canvas.drawPath(housePath, housePaint);

    final center = Offset(w * 0.5, h * 0.65);
    final radius = w * 0.18;

    final Paint lensPaint = Paint()
      ..color = const Color(0xFF007BFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius, lensPaint);
    canvas.drawCircle(center, w * 0.07, Paint()..color = const Color(0xFF00C6FF));
    canvas.drawCircle(center + const Offset(3, -3), w * 0.02, Paint()..color = Colors.white);

    final Paint checkPaint = Paint()
      ..color = const Color(0xFF00FF66)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final Path checkPath = Path()
      ..moveTo(w * 0.72, h * 0.22)
      ..lineTo(w * 0.8, h * 0.3)
      ..lineTo(w * 0.95, h * 0.1);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
