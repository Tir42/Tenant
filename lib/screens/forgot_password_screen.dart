import 'package:flutter/material.dart';
import 'package:tenantsnap/screens/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendReset() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email.')),
      );
      return;
    }
    // Placeholder for real password‑reset logic.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset link sent (mock).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  CustomPaint(
                    size: const Size(80, 70),
                    painter: LoginLogoPainter(),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'Forgot Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Email field
                  Container(
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Color(0xFF2C2C2C),
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: const TextStyle(
                          color: Color(0xFF95A5A6),
                        ),
                        prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF7F8C8D)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Send button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _sendReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Send Reset Link', style: TextStyle(color: Colors.white, fontFamily: 'Montserrat')),
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
}

// Re‑use the same logo painter from login_screen.dart for visual consistency.
class LoginLogoPainter extends CustomPainter {
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
