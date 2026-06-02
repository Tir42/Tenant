import 'package:flutter/material.dart';
import '../theme.dart';
import 'property_details_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool isSignUpMode = true; // true = Create Account, false = Sign In
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handlePrimaryAction() {
    // Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all security nodes.'),
        ),
      );
      return;
    }

    // Success - transition to Role Selection Screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSignUpMode ? 'Generating new secure tenant profile...' : 'Decrypting credentials profile...'),
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PropertyDetailsScreen(),
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
                  // White Card Centered Container (Matching room_detail and inspection_flow list screen styles)
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
                        // --- 1. VECTOR LOGO (House + Camera Lens + Check) ---
                        CustomPaint(
                          size: const Size(80, 70),
                          painter: LoginLogoPainter(),
                        ),
                        const SizedBox(height: 16),

                        // --- 2. TITLE WITH STYLIZED SNAP ---
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Color(0xFF2C3E50), // High legibility dark slate
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
                                  color: Color(0xFF2ECC71), // Clean high-contrast green snap
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        
                        // --- 3. SUBTITLE ---
                        const Text(
                          'Effortless Home Documentation',
                          style: TextStyle(
                            color: Color(0xFF7F8C8D), // Legible grey for light mode
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // --- 4. TEXT FIELDS (Matches rounded white card aesthetic in screenshot) ---
                        if (isSignUpMode) ...[
                          // Name Field (Only in Create Account Mode)
                          _buildCustomTextField(
                            controller: _nameController,
                            hintText: 'Full Name',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 14),
                        ],
                        
                        // Email Field
                        _buildCustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),

                        // Password Field
                        _buildCustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 18),

                        // --- 5. FORGOT PASSWORD LINK ---
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Dispatching password recovery telemetry...'),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontFamily: 'Montserrat',
                              decoration: TextDecoration.underline,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- 6. PRIMARY ROUNDED BUTTON ---
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
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
                            onPressed: _handlePrimaryAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              isSignUpMode ? 'Create Account' : 'Sign In',
                              style: AntigravityTextStyles.bodyLarge(Colors.white).copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- 7. TOGGLE VIEW ACTION (Sign In vs Create Account) ---
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSignUpMode = !isSignUpMode;
                            });
                          },
                          child: Text(
                            isSignUpMode
                                ? 'Already have an account? Sign In'
                                : "Don't have an account? Create one",
                            style: const TextStyle(
                              color: Color(0xFF007BFF), // Cohesive brand blue
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
        color: Colors.white, // Pure white background as in screenshot
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

// Custom Painter for the Logo (matching the screenshot exactly)
class LoginLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Draw house outline
    final Paint housePaint = Paint()
      ..color = const Color(0xFF007BFF) // Cool blue
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

    // Draw camera lens circle inside the house
    final center = Offset(w * 0.5, h * 0.65);
    final radius = w * 0.18;

    final Paint lensPaint = Paint()
      ..color = const Color(0xFF007BFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius, lensPaint);
    
    // Camera lens core dot
    canvas.drawCircle(center, w * 0.07, Paint()..color = const Color(0xFF00C6FF));
    canvas.drawCircle(center + const Offset(3, -3), w * 0.02, Paint()..color = Colors.white);

    // Green checkmark at top right
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
