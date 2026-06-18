import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/core/controllers/base_controller.dart';
import 'package:tenantsnap/features/auth/login/controller/login_controller.dart';
import 'forgot_password_screen.dart';
import '../../signup/screen/signup_screen.dart';
import 'package:tenantsnap/features/dashboard/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final loginController = Get.put(LoginController());
  
  String? _emailError;
  String? _passwordError;

  void _handlePrimaryAction() async {
    final email = loginController.emailController.text.trim();
    final password = loginController.passwordController.text;

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool hasValidationError = false;

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required.');
      hasValidationError = true;
    } else if (!GetUtils.isEmail(email)) {
      setState(() => _emailError = 'Please enter a valid email address.');
      hasValidationError = true;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required.');
      hasValidationError = true;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters.');
      hasValidationError = true;
    }

    if (hasValidationError) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Decrypting credentials profile...'),
        duration: Duration(milliseconds: 500),
      ),
    );

    final errorMsg = await loginController.login();
    if (errorMsg == null && mounted) {
      final idCode = BaseController.idCode.value.toLowerCase();
      final role = (idCode.startsWith('ll') || email.toLowerCase().contains('sterling') || email.toLowerCase().contains('landlord')) ? 'landlord' : 'tenant';
      Get.off(() => HomeScreen(
        role: role,
        userName: BaseController.name.value,
      ));
    } else if (errorMsg != null && mounted) {
      setState(() {
        if (errorMsg.toLowerCase().contains('password')) {
          _passwordError = errorMsg;
        } else if (errorMsg.toLowerCase().contains('user') || errorMsg.toLowerCase().contains('email')) {
          _emailError = errorMsg;
        } else {
          _passwordError = errorMsg;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Deep dynamic background (Base gradient + Glowing blurred aurora blobs)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AntigravityColors.bgGradient,
            ),
          ),
          // Soft Violet Blob (Top-left)
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.12),
              ),
            ),
          ),
          // Soft Blue-Teal Blob (Bottom-right)
          Positioned(
            bottom: -80,
            right: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06B6D4).withOpacity(0.12),
              ),
            ),
          ),
          // Gaussian Blur Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ),
          
          // 2. Interactive Scrollable content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- Logo, Title, Subtitle ---
                    _StaggeredEntrance(
                      delayMs: 100,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Custom bobbing animation for the high-tech logo
                          _FloatingWidget(
                            child: CustomPaint(
                              size: const Size(85, 75),
                              painter: LoginLogoPainter(),
                            ),
                          ),
                          const SizedBox(height: 18),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: Color(0xFF2C3E50),
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
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
                          const Text(
                            'Effortless Home Documentation',
                            style: TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- Toggle Tabs (Sign in / Create account) ---
                    _StaggeredEntrance(
                      delayMs: 180,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2F6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'Sign in',
                                    style: TextStyle(
                                      color: Color(0xFF2C3E50),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(() => const SignUpScreen());
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  child: const Center(
                                    child: Text(
                                      'Create account',
                                      style: TextStyle(
                                        color: Color(0xFF7F8C8D),
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Email Field ---
                    _StaggeredEntrance(
                      delayMs: 260,
                      child: _buildCustomTextField(
                        controller: loginController.emailController,
                        hintText: 'you@home.com',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // --- Password Field ---
                    _StaggeredEntrance(
                      delayMs: 340,
                      child: Obx(() => _buildCustomTextField(
                        controller: loginController.passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: loginController.obscurePassword.value,
                        errorText: _passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            loginController.obscurePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF7F8C8D),
                            size: 18,
                          ),
                          onPressed: loginController.toggleObscurePassword,
                        ),
                      )),
                    ),
                    const SizedBox(height: 20),

                    // --- Sign In Button ---
                    _StaggeredEntrance(
                      delayMs: 420,
                      child: Obx(() => Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3B82F6), // Vibrant Blue
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
                          onPressed: loginController.isLoading.value ? null : _handlePrimaryAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: loginController.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Sign in',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                        fontSize: 15,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                        ),
                      )),
                    ),
                    const SizedBox(height: 24),

                    // --- Bottom Links ---
                    _StaggeredEntrance(
                      delayMs: 500,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const ForgotPasswordScreen());
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Color(0xFF7F8C8D),
                                fontFamily: 'Montserrat',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const SignUpScreen());
                            },
                            child: const Text(
                              'Create one',
                              style: TextStyle(
                                color: Color(0xFF007BFF),
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return _CustomFocusTextField(
      controller: controller,
      hintText: hintText,
      icon: icon,
      obscureText: obscureText,
      keyboardType: keyboardType,
      suffixIcon: suffixIcon,
      errorText: errorText,
    );
  }
}

// Re‑use the same logo painter for visual consistency.
class LoginLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint housePaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF3B82F6), // Vibrant Blue
          Color(0xFF00D1FF), // Cyan Accent
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final Path housePath = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..lineTo(w * 0.95, h * 0.42)
      ..lineTo(w * 0.83, h * 0.42)
      ..lineTo(w * 0.83, h * 0.95)
      ..lineTo(w * 0.17, h * 0.95)
      ..lineTo(w * 0.17, h * 0.42)
      ..lineTo(w * 0.05, h * 0.42)
      ..close();

    canvas.drawPath(housePath, housePaint);

    final Paint cameraBodyPaint = Paint()..color = Colors.white;
    final RRect cameraBody = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.26, h * 0.52, w * 0.74, h * 0.88),
      const Radius.circular(6.0),
    );
    canvas.drawRRect(cameraBody, cameraBodyPaint);

    final Paint lensBorder = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final center = Offset(w * 0.5, h * 0.70);
    canvas.drawCircle(center, w * 0.14, lensBorder);

    final Paint lensDark = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(center, w * 0.13, lensDark);

    final Paint lensReflection = Paint()..color = const Color(0xFF3B82F6);
    canvas.drawCircle(center, w * 0.08, lensReflection);

    final Paint shine = Paint()..color = Colors.white;
    canvas.drawCircle(center + Offset(w * 0.03, -h * 0.03), w * 0.02, shine);

    final Paint checkOutline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.82, h * 0.26), w * 0.15, checkOutline);

    final Paint checkCircle = Paint()
      ..color = const Color(0xFF10B981) // Emerald Green
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.82, h * 0.26), w * 0.13, checkCircle);

    final Paint checkMark = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final Path checkPath = Path()
      ..moveTo(w * 0.76, h * 0.26)
      ..lineTo(w * 0.80, h * 0.30)
      ..lineTo(w * 0.88, h * 0.20);
    canvas.drawPath(checkPath, checkMark);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const _StaggeredEntrance({
    required this.child,
    required this.delayMs,
  });

  @override
  State<_StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<_StaggeredEntrance> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _yOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _yOffset = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _yOffset.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _CustomFocusTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? errorText;

  const _CustomFocusTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.errorText,
  });

  @override
  State<_CustomFocusTextField> createState() => _CustomFocusTextFieldState();
}

class _CustomFocusTextFieldState extends State<_CustomFocusTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    Color borderColor = const Color(0xFFE2E8F0);
    double borderWidth = 1.0;
    if (hasError) {
      borderColor = const Color(0xFFE74C3C);
      borderWidth = 1.5;
    } else if (_isFocused) {
      borderColor = const Color(0xFF007BFF);
      borderWidth = 1.5;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            boxShadow: [
              if (_isFocused && !hasError)
                BoxShadow(
                  color: const Color(0xFF007BFF).withOpacity(0.08),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                )
              else
                BoxShadow(
                  color: const Color(0xFF2C3E50).withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: TextField(
            focusNode: _focusNode,
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            style: const TextStyle(
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF95A5A6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  widget.icon,
                  color: hasError
                      ? const Color(0xFFE74C3C)
                      : (_isFocused ? const Color(0xFF007BFF) : const Color(0xFF7F8C8D)),
                  size: 18,
                ),
              ),
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: Color(0xFFE74C3C),
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FloatingWidget extends StatefulWidget {
  final Widget child;
  const _FloatingWidget({required this.child});

  @override
  State<_FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<_FloatingWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
