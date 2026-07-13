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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final LoginController loginController;

  @override
  void initState() {
    super.initState();

    loginController = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController(), permanent: true);
  }

  void _handlePrimaryAction() async {
    if (!loginController.validateInputs()) return;

    final errorMsg = await loginController.login();

    if (!mounted) return;

    if (errorMsg == null) {
      loginController.clearLoginFields();
      final email = loginController.emailController.text.trim();
      final idCode = BaseController.idCode.value.toLowerCase();

      final role = (idCode.startsWith('ll') ||
          email.toLowerCase().contains('sterling') ||
          email.toLowerCase().contains('landlord'))
          ? 'landlord'
          : 'tenant';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Color(0xFF2ECC71),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      Get.off(
            () => HomeScreen(
          role: role,
          userName: BaseController.name.value,
        ),
      );
    } else {
      final msg = errorMsg.toLowerCase();

      if (msg.contains('password')) {
        loginController.passwordError.value = errorMsg;
      } else if (msg.contains('user') || msg.contains('email')) {
        loginController.emailError.value = errorMsg;
      } else {
        loginController.passwordError.value = errorMsg;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: const Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }


  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? errorText,
    TextStyle? hintStyle,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0.w),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFE74C3C)
                  : const Color(0xFFE2E8F0),
              width: hasError ? 1.5.w : 1.0.w,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2C3E50).withValues(alpha: 0.03),
                blurRadius: 10.0.w,
                offset: Offset(0, 4.0.h),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,

            style: TextStyle(
              color: const Color(0xFF2C3E50),
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              fontSize: 14.0.sp,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: hintStyle ??
                  TextStyle(
                    color: const Color(0xFF95A5A6),
                    fontSize: 13.0.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 16.0.w, right: 12.0.w),
                child: Icon(
                  icon,
                  color: hasError
                      ? const Color(0xFFE74C3C)
                      : const Color(0xFF7F8C8D),
                  size: 18.w,
                ),
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 14.0.h,
                horizontal: 16.0.w,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.0.h),
          Padding(
            padding: EdgeInsets.only(left: 16.0.w),
            child: Text(
              errorText,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AntigravityColors.bgGradient,
            ),
          ),

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

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                              fontSize: 15.0.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28.0.h),

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
                                      color:
                                      Colors.black.withValues(alpha: 0.05),
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
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Montserrat',
                                      fontSize: 15.0.sp,
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
                                child: Center(
                                  child: Text(
                                    'Create account',
                                    style: TextStyle(
                                      color: const Color(0xFF7F8C8D),
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Montserrat',
                                      fontSize: 15.0.sp,
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

                    _StaggeredEntrance(
                      delayMs: 260,
                      child: Obx(
                            () => _buildCustomTextField(
                          controller: loginController.emailController,
                          hintText: 'you@home.com',
                          hintStyle: TextStyle(
                            fontSize: 16.0.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          errorText: loginController.emailError.value,
                              onChanged: (_) {
                                loginController.emailError.value = null;
                              },
                        ),
                      ),
                    ),

                    SizedBox(height: 14.0.h),

                    _StaggeredEntrance(
                      delayMs: 340,
                      child: Obx(
                            () => _buildCustomTextField(
                          controller: loginController.passwordController,
                          hintText: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: loginController.obscurePassword.value,
                          errorText: loginController.passwordError.value,
                              onChanged: (_) {
                                loginController.passwordError.value = null;
                              },
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
                        ),
                      ),
                    ),

                    SizedBox(height: 20.0.h),

                    _StaggeredEntrance(
                      delayMs: 420,
                      child: Obx(
                            () => Container(
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
                                color: const Color(0xFF3B82F6)
                                    .withValues(alpha: 0.35),
                                blurRadius: 8.0.w,
                                offset: Offset(0, 4.0.h),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: loginController.isLoading.value
                                ? null
                                : _handlePrimaryAction,
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
                                valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
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
                        ),
                      ),
                    ),

                    SizedBox(height: 24.0.h),

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

class _StaggeredEntranceState extends State<_StaggeredEntrance>
    with SingleTickerProviderStateMixin {
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
      if (mounted) _controller.forward();
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
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _yOffset.value),
            child: child,
          ),
        );
      },
    );
  }
}

class _FloatingWidget extends StatefulWidget {
  final Widget child;

  const _FloatingWidget({required this.child});

  @override
  State<_FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<_FloatingWidget>
    with SingleTickerProviderStateMixin {
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
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
    );
  }
}