import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/core/utils/responsive/responsive_extension.dart';
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
  
  void _handlePrimaryAction() async {
    if (!loginController.validateInputs()) {
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
      final email = loginController.emailController.text.trim();
      final idCode = BaseController.idCode.value.toLowerCase();
      final role = (idCode.startsWith('ll') || email.toLowerCase().contains('sterling') || email.toLowerCase().contains('landlord')) ? 'landlord' : 'tenant';
      Get.off(() => HomeScreen(
        role: role,
        userName: BaseController.name.value,
      ));
    } else if (errorMsg != null && mounted) {
      if (errorMsg.toLowerCase().contains('password')) {
        loginController.passwordError.value = errorMsg;
      } else if (errorMsg.toLowerCase().contains('user') || errorMsg.toLowerCase().contains('email')) {
        loginController.emailError.value = errorMsg;
      } else {
        loginController.passwordError.value = errorMsg;
      }
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
            top: -120.h,
            left: -120.w,
            child: Container(
              width: 320.w,
              height: 320.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              ),
            ),
          ),
          // Soft Blue-Teal Blob (Bottom-right)
          Positioned(
            bottom: -80.h,
            right: -100.w,
            child: Container(
              width: 360.w,
              height: 360.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
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
                padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- Logo, Title, Subtitle ---
                    _StaggeredEntrance(
                      delayMs: 100,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _FloatingWidget(
                            child: Image.asset(
                              'assets/app_icon.png',
                              width: 85.0.w,
                              height: 75.0.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 18.0.h),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: const Color(0xFF2C3E50),
                                fontSize: 30.0.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                fontFamily: 'Montserrat',
                              ),
                              children: const [
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
                          SizedBox(height: 6.0.h),
                          Text(
                            'Effortless Home Documentation',
                            style: TextStyle(
                              color: const Color(0xFF7F8C8D),
                              fontFamily: 'Montserrat',
                              fontSize: 13.0.sp,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 28.0.h),

                    // --- Toggle Tabs (Sign in / Create account) ---
                    _StaggeredEntrance(
                      delayMs: 180,
                      child: Container(
                        width: double.infinity,
                        height: 48.0.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2F6),
                          borderRadius: BorderRadius.circular(24.0.w),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.all(4.0.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0.w),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4.0.w,
                                      offset: Offset(0, 2.0.h),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Sign in',
                                    style: TextStyle(
                                      color: const Color(0xFF2C3E50),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      fontSize: 13.0.sp,
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
                                  child: Center(
                                    child: Text(
                                      'Create account',
                                      style: TextStyle(
                                        color: const Color(0xFF7F8C8D),
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                        fontSize: 13.0.sp,
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
                    SizedBox(height: 24.0.h),

                    // --- Email Field ---
                    _StaggeredEntrance(
                      delayMs: 260,
                      child: Obx(() => _buildCustomTextField(
                        controller: loginController.emailController,
                        hintText: 'you@home.com',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        errorText: loginController.emailError.value,
                      )),
                    ),
                    SizedBox(height: 14.0.h),

                    // --- Password Field ---
                    _StaggeredEntrance(
                      delayMs: 340,
                      child: Obx(() => _buildCustomTextField(
                        controller: loginController.passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: loginController.obscurePassword.value,
                        errorText: loginController.passwordError.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            loginController.obscurePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF7F8C8D),
                            size: 18.w,
                          ),
                          onPressed: loginController.toggleObscurePassword,
                        ),
                      )),
                    ),
                    SizedBox(height: 20.0.h),

                    // --- Sign In Button ---
                    _StaggeredEntrance(
                      delayMs: 420,
                      child: Obx(() => Container(
                        width: double.infinity,
                        height: 50.0.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0.w),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3B82F6), // Vibrant Blue
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
                        child: ElevatedButton(
                          onPressed: loginController.isLoading.value ? null : _handlePrimaryAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0.w),
                            ),
                          ),
                          child: loginController.isLoading.value
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2.0.w,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Sign in',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                        fontSize: 15.0.sp,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(width: 8.0.w),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 16.w,
                                    ),
                                  ],
                                ),
                        ),
                      )),
                    ),
                    SizedBox(height: 24.0.h),

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
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: const Color(0xFF7F8C8D),
                                fontFamily: 'Montserrat',
                                fontSize: 13.0.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const SignUpScreen());
                            },
                            child: Text(
                              'Create one',
                              style: TextStyle(
                                color: const Color(0xFF007BFF),
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0.sp,
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
    double borderWidth = 1.0.w;
    if (hasError) {
      borderColor = const Color(0xFFE74C3C);
      borderWidth = 1.5.w;
    } else if (_isFocused) {
      borderColor = const Color(0xFF007BFF);
      borderWidth = 1.5.w;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0.w),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            boxShadow: [
              if (_isFocused && !hasError)
                BoxShadow(
                  color: const Color(0xFF007BFF).withValues(alpha: 0.08),
                  blurRadius: 8.0.w,
                  spreadRadius: 1.0.w,
                  offset: Offset(0, 2.0.h),
                )
              else
                BoxShadow(
                  color: const Color(0xFF2C3E50).withValues(alpha: 0.03),
                  blurRadius: 10.0.w,
                  offset: Offset(0, 4.0.h),
                ),
            ],
          ),
          child: TextField(
            focusNode: _focusNode,
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            style: TextStyle(
              color: const Color(0xFF2C3E50),
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              fontSize: 14.0.sp,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: const Color(0xFF95A5A6),
                fontSize: 13.0.sp,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 16.0.w, right: 12.0.w),
                child: Icon(
                  widget.icon,
                  color: hasError
                      ? const Color(0xFFE74C3C)
                      : (_isFocused ? const Color(0xFF007BFF) : const Color(0xFF7F8C8D)),
                  size: 18.w,
                ),
              ),
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14.0.h, horizontal: 16.0.w),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.0.h),
          Padding(
            padding: EdgeInsets.only(left: 16.0.w),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: const Color(0xFFE74C3C),
                fontFamily: 'Montserrat',
                fontSize: 11.0.sp,
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
