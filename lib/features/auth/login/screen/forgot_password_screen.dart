import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/core/utils/responsive/responsive_extension.dart';
import 'package:tenantsnap/features/auth/login/controller/login_controller.dart';
import 'package:tenantsnap/features/auth/login/screen/login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with TickerProviderStateMixin {
  // Navigation Step
  // 0: Email Input, 1: OTP verification, 2: Reset Password, 3: Success state
  int _currentStep = 0;

  // Controllers
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // Password Visibility
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // OTP Countdown Timer
  Timer? _timer;
  int _start = 59;
  String? _simulatedOtp;

  // Background Aurora Controllers
  late final AnimationController _auroraController;
  late final Animation<double> _blob1AnimX;
  late final Animation<double> _blob1AnimY;
  late final Animation<double> _blob2AnimX;
  late final Animation<double> _blob2AnimY;

  @override
  void initState() {
    super.initState();

    // 1. Slow, organic background blob drift
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _blob1AnimX = Tween<double>(begin: -150, end: -50).animate(
      CurvedAnimation(parent: _auroraController, curve: Curves.easeInOutQuad),
    );
    _blob1AnimY = Tween<double>(begin: -150, end: -80).animate(
      CurvedAnimation(parent: _auroraController, curve: Curves.easeInOutSine),
    );
    _blob2AnimX = Tween<double>(begin: -120, end: -40).animate(
      CurvedAnimation(parent: _auroraController, curve: Curves.easeInOutSine),
    );
    _blob2AnimY = Tween<double>(begin: -120, end: -60).animate(
      CurvedAnimation(parent: _auroraController, curve: Curves.easeInOutQuad),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    _auroraController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _start = 59;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        if (mounted) {
          setState(() {
            timer.cancel();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _start--;
          });
        }
      }
    });
  }

  void _sendOtpCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar(
        'Required', 
        'Please enter your email address.', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2C3E50),
        colorText: Colors.white,
      );
      return;
    }
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Invalid', 
        'Please enter a valid email address.', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2C3E50),
        colorText: Colors.white,
      );
      return;
    }

    final loginController = Get.find<LoginController>();
    final result = await loginController.sendOtp(email);

    if (result['success'] == true) {
      setState(() {
        _simulatedOtp = result['otp'];
        _currentStep = 1;
      });
      debugPrint("Simulated OTP for $email: $_simulatedOtp");
      _startTimer();
      Get.snackbar(
        'OTP Sent',
        'Verification code generated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2C3E50),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        result['message'] ?? 'Unable to send verification code.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE74C3C),
        colorText: Colors.white,
      );
    }
  }

  void _verifyOtpCode() {
    final enteredOtp = _otpControllers.map((c) => c.text).join();
    if (enteredOtp.length < 6) {
      Get.snackbar(
        'Required', 
        'Please enter the full 6-digit code.', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2C3E50),
        colorText: Colors.white,
      );
      return;
    }
    if (enteredOtp != _simulatedOtp) {
      Get.snackbar(
        'Incorrect', 
        'Invalid verification code. Please check and try again.', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE74C3C),
        colorText: Colors.white,
      );
      return;
    }
    setState(() {
      _currentStep = 2;
    });
  }

  void _performPasswordReset() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar(
        'Required', 
        'Please fill in both password fields.', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2C3E50),
        colorText: Colors.white,
      );
      return;
    }
    if (newPass.length < 6) {
      Get.snackbar(
        'Weak Password', 
        'Password must be at least 6 characters.', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2C3E50),
        colorText: Colors.white,
      );
      return;
    }
    if (newPass != confirmPass) {
      Get.snackbar(
        'Mismatch', 
        'Passwords do not match.', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE74C3C),
        colorText: Colors.white,
      );
      return;
    }

    final email = _emailController.text.trim();
    final otp = _otpControllers.map((c) => c.text).join();
    
    final loginController = Get.find<LoginController>();
    final errorMsg = await loginController.resetPassword(email, otp, newPass, confirmPass);

    if (errorMsg == null) {
      setState(() {
        _currentStep = 3;
      });
    } else {
      Get.snackbar(
        'Failed',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE74C3C),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Deep dynamic background (Antigravity gradient)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AntigravityColors.bgGradient,
            ),
          ),
          
          // Floating Violet Blob (Top-left)
          AnimatedBuilder(
            animation: _auroraController,
            builder: (context, child) {
              return Positioned(
                top: _blob1AnimY.value,
                left: _blob1AnimX.value,
                child: Container(
                  width: 350.w,
                  height: 350.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  ),
                ),
              );
            },
          ),
          
          // Floating Blue-Teal Blob (Bottom-right)
          AnimatedBuilder(
            animation: _auroraController,
            builder: (context, child) {
              return Positioned(
                bottom: _blob2AnimY.value,
                right: _blob2AnimX.value,
                child: Container(
                  width: 380.w,
                  height: 380.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                  ),
                ),
              );
            },
          ),
          
          // Gaussian Blur Overlay for Liquid Glass effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ),
          
          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Minimalist Back Navigation
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFF2C3E50), size: 20.w),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                      child: Container(
                        padding: EdgeInsets.all(24.0.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(30.0.w),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5.w),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20.0.w,
                              offset: Offset(0, 8.0.h),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Step indicators (Except for success state)
                            if (_currentStep < 3) ...[
                              _buildStepIndicator(),
                              SizedBox(height: 28.0.h),
                            ],
                            
                            // Dynamic Step Layout Switcher
                            _buildActiveStepLayout(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Multi-step view dispatcher
  Widget _buildActiveStepLayout() {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildOtpStep();
      case 2:
        return _buildNewPasswordStep();
      case 3:
        return _buildSuccessStep();
      default:
        return _buildEmailStep();
    }
  }

  // --- Step Indicators Widget ---
  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepNode(0, 'Email', Icons.email_outlined),
        _buildStepConnector(0),
        _buildStepNode(1, 'Verify', Icons.lock_clock_outlined),
        _buildStepConnector(1),
        _buildStepNode(2, 'Reset', Icons.published_with_changes_rounded),
      ],
    );
  }

  Widget _buildStepNode(int step, String label, IconData icon) {
    final bool isActive = _currentStep == step;
    final bool isCompleted = _currentStep > step;
    
    final Color nodeColor = isCompleted
        ? const Color(0xFF2ECC71) // Completed: Green
        : (isActive ? const Color(0xFF007BFF) : const Color(0xFF7F8C8D));

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFFEBFBEE) : (isActive ? const Color(0xFFEBF5FF) : Colors.white),
            shape: BoxShape.circle,
            border: Border.all(color: nodeColor, width: 2.0.w),
          ),
          child: Center(
            child: Icon(
              isCompleted ? Icons.check_rounded : icon,
              color: nodeColor,
              size: 16.w,
            ),
          ),
        ),
        SizedBox(height: 6.0.h),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF2C3E50) : const Color(0xFF7F8C8D),
            fontFamily: 'Montserrat',
            fontSize: 10.0.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          ),
        )
      ],
    );
  }

  Widget _buildStepConnector(int stepIndex) {
    final bool isCompleted = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        height: 2.0.h,
        margin: EdgeInsets.only(bottom: 16.0.h, left: 8.0.w, right: 8.0.w),
        color: isCompleted ? const Color(0xFF2ECC71) : const Color(0xFFE2E8F0),
      ),
    );
  }

  // --- Step 1: Email Request View ---
  Widget _buildEmailStep() {
    final loginController = Get.find<LoginController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reset Password',
          style: TextStyle(
            color: const Color(0xFF2C3E50),
            fontSize: 22.0.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 8.0.h),
        Text(
          'Enter your registered Gmail address below and we will dispatch a 6-digit OTP code to verify your identity.',
          style: TextStyle(
            color: const Color(0xFF7F8C8D),
            fontSize: 12.0.sp,
            height: 1.4,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 24.0.h),
        
        // Styled Email Field Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0.w),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0.w),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2C3E50).withValues(alpha: 0.02),
                blurRadius: 8.0.w,
                offset: Offset(0, 4.0.h),
              )
            ],
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: const Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: 14.0.sp,
            ),
            decoration: InputDecoration(
              hintText: 'you@gmail.com',
              hintStyle: TextStyle(
                color: const Color(0xFF95A5A6),
                fontSize: 13.0.sp,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                child: Icon(Icons.mail_outline, color: const Color(0xFF7F8C8D), size: 18.w),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14.0.h, horizontal: 16.0.w),
            ),
          ),
        ),
        SizedBox(height: 24.0.h),

        // Action Button
        Obx(() {
          final isLoading = loginController.isLoading.value;
          return SizedBox(
            width: double.infinity,
            height: 50.0.h,
            child: ElevatedButton(
              onPressed: isLoading ? null : _sendOtpCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0.w)),
                elevation: 2,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0.w,
                      ),
                    )
                  : Text(
                      'Send Verification Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0.sp,
                      ),
                    ),
            ),
          );
        }),
      ],
    );
  }

  // --- Step 2: OTP Verification View ---
  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Code',
          style: TextStyle(
            color: const Color(0xFF2C3E50),
            fontSize: 22.0.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 8.0.h),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: const Color(0xFF7F8C8D),
              fontSize: 12.0.sp,
              height: 1.4,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
            children: [
              const TextSpan(text: 'We have dispatched a 6-digit security code to '),
              TextSpan(
                text: _emailController.text,
                style: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '. Input it below to unlock the credential reset.'),
            ],
          ),
        ),
        SizedBox(height: 24.0.h),

        // 6-digit code Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildOtpDigitBox(index)),
        ),
        SizedBox(height: 20.0.h),

        // Countdown Timer & Resend Button
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _start > 0 ? 'Resend code in ' : 'Didn\'t receive code? ',
                style: TextStyle(
                  color: const Color(0xFF7F8C8D),
                  fontSize: 12.0.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
              _start > 0
                  ? Text(
                      '0:${_start.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: const Color(0xFF007BFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0.sp,
                        fontFamily: 'Montserrat',
                      ),
                    )
                  : GestureDetector(
                      onTap: _sendOtpCode,
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: const Color(0xFF007BFF),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0.sp,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
            ],
          ),
        ),
        SizedBox(height: 24.0.h),



        // Verify button
        SizedBox(
          width: double.infinity,
          height: 50.0.h,
          child: ElevatedButton(
            onPressed: _verifyOtpCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0.w)),
            ),
            child: Text(
              'Verify Code',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 14.0.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpDigitBox(int index) {
    return Container(
      width: 40.w,
      height: 46.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0.w),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4.0.w,
            offset: Offset(0, 2.0.h),
          ),
        ],
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          color: const Color(0xFF2C3E50),
          fontWeight: FontWeight.bold,
          fontSize: 18.0.sp,
          fontFamily: 'Montserrat',
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _otpFocusNodes[index + 1].requestFocus();
            } else {
              _otpFocusNodes[index].unfocus();
            }
          } else {
            if (index > 0) {
              _otpFocusNodes[index - 1].requestFocus();
            }
          }
        },
      ),
    );
  }

  // --- Step 3: New Password Input View ---
  Widget _buildNewPasswordStep() {
    final loginController = Get.find<LoginController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Password',
          style: TextStyle(
            color: const Color(0xFF2C3E50),
            fontSize: 22.0.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 8.0.h),
        Text(
          'Formulate a highly secure new password configuration below to encrypt your account details.',
          style: TextStyle(
            color: const Color(0xFF7F8C8D),
            fontSize: 12.0.sp,
            height: 1.4,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 24.0.h),

        // New Password Field
        _buildCustomPasswordField(
          controller: _newPasswordController,
          hintText: 'New Password',
          obscureText: _obscureNewPassword,
          onToggleVisible: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
        ),
        SizedBox(height: 14.0.h),

        // Confirm Password Field
        _buildCustomPasswordField(
          controller: _confirmPasswordController,
          hintText: 'Confirm Password',
          obscureText: _obscureConfirmPassword,
          onToggleVisible: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
        SizedBox(height: 24.0.h),

        // Action Button
        Obx(() {
          final isLoading = loginController.isLoading.value;
          return SizedBox(
            width: double.infinity,
            height: 50.0.h,
            child: ElevatedButton(
              onPressed: isLoading ? null : _performPasswordReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0.w)),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0.w,
                      ),
                    )
                  : Text(
                      'Update Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0.sp,
                      ),
                    ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCustomPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisible,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0.w),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withValues(alpha: 0.02),
            blurRadius: 8.0.w,
            offset: Offset(0, 4.0.h),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: const Color(0xFF2C3E50),
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          fontSize: 14.0.sp,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color(0xFF95A5A6),
            fontSize: 13.0.sp,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
            child: Icon(Icons.lock_outline_rounded, color: const Color(0xFF7F8C8D), size: 18.w),
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 8.0.w),
            child: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF7F8C8D),
                size: 18.w,
              ),
              onPressed: onToggleVisible,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.0.h, horizontal: 16.0.w),
        ),
      ),
    );
  }

  // --- Step 4: Success Redirection View ---
  Widget _buildSuccessStep() {
    return Column(
      children: [
        SizedBox(height: 16.0.h),
        // Neon Glowing check circle
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: const Color(0xFFEBFBEE),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2ECC71), width: 3.0.w),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2ECC71).withValues(alpha: 0.2),
                blurRadius: 15.0.w,
                spreadRadius: 2.0.w,
              )
            ],
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              color: const Color(0xFF2ECC71),
              size: 44.w,
            ),
          ),
        ),
        SizedBox(height: 24.0.h),
        Text(
          'Password Reset!',
          style: TextStyle(
            color: const Color(0xFF2C3E50),
            fontSize: 22.0.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 8.0.h),
        Text(
          'Your password has been securely updated. You can now proceed to log in with your updated credentials.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF7F8C8D),
            fontSize: 12.0.sp,
            height: 1.4,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 28.0.h),

        // Direct return to Login Screen
        SizedBox(
          width: double.infinity,
          height: 50.0.h,
          child: ElevatedButton(
            onPressed: () {
              Get.offAll(
                () => const LoginScreen(),
                transition: Transition.fade,
                duration: const Duration(milliseconds: 600),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0.w)),
              elevation: 2,
            ),
            child: Text(
              'Return to Login',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 14.0.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
