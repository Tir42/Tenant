import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/core/utils/responsive/responsive_extension.dart';
import 'package:tenantsnap/core/controllers/base_controller.dart';
import 'package:tenantsnap/features/auth/signup/controller/signup_controller.dart';
import 'package:tenantsnap/features/dashboard/screens/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final signUpController = Get.isRegistered<SignUpController>()
      ? Get.find<SignUpController>()
      : Get.put(SignUpController());

  @override
  void initState() {
    super.initState();
    signUpController.passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    signUpController.passwordController.removeListener(_onPasswordChanged);
    super.dispose();
  }

  void _onPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }



  @override
  Widget build(BuildContext context) {
    final bool isNarrow = MediaQuery.of(context).size.width < 360;
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
              padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.0.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- 1. VECTOR LOGO, TITLE, SUBTITLE ---
                  _StaggeredEntrance(
                    delayMs: 100,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/app_icon.png',
                          width: 80.0.w,
                          height: 70.0.h,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 16.0.h),
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
                          'Create Secure Account',
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

                  // --- 2. TOGGLE TABS ---
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
                            child: GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: Text(
                                    'Sign in',
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
                                  'Create account',
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
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0.h),

                  // --- 3. FIRST & LAST NAME (ROW) ---
                  _StaggeredEntrance(
                    delayMs: 260,
                    child: Obx(() {
                      final fErr = signUpController.firstNameError.value;
                      final lErr = signUpController.lastNameError.value;
                      return isNarrow
                          ? Column(
                              children: [
                                _buildCustomTextField(
                                  controller: signUpController.firstNameController,
                                  hintText: 'First Name',
                                  icon: Icons.person_outline,
                                  errorText: fErr,
                                  onChanged: (_) {
                                    signUpController.firstNameError.value = null;
                                  },

                                ),
                                SizedBox(height: 14.0.h),
                                _buildCustomTextField(
                                  controller: signUpController.lastNameController,
                                  hintText: 'Last Name',
                                  icon: Icons.person_outline,
                                  errorText: lErr,
                                  onChanged: (_) {
                                    signUpController.lastNameError.value = null;
                                  },
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildCustomTextField(
                                    controller: signUpController.firstNameController,
                                    hintText: 'First Name',
                                    icon: Icons.person_outline,
                                    errorText: fErr,
                                    onChanged: (_) {
                                      signUpController.firstNameError.value = null;
                                    },


                                  ),
                                ),
                                SizedBox(width: 12.0.w),
                                Expanded(
                                  child: _buildCustomTextField(
                                    controller: signUpController.lastNameController,
                                    hintText: 'Last Name',
                                    icon: Icons.person_outline,
                                    errorText: lErr,
                                    onChanged: (_) {
                                      signUpController.lastNameError.value = null;
                                    },

                                  ),
                                ),
                              ],
                            );
                    }),
                  ),
                  SizedBox(height: 14.0.h),

                  // --- 4. EMAIL ---
                  _StaggeredEntrance(
                    delayMs: 340,
                    child: Obx(() => _buildCustomTextField(
                      controller: signUpController.emailController,
                      hintText: 'Email',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      errorText: signUpController.emailError.value,
                      onChanged: (value) {
                        signUpController.emailError.value = null;
                        signUpController.emailText.value = value;

                      },
                    )),
                  ),
                  SizedBox(height: 14.0.h),

                  // --- 5. COUNTRY PICKER & PHONE NUMBER ---
                  _StaggeredEntrance(
                    delayMs: 420,
                    child: Obx(() {
                      final pErr = signUpController.phoneError.value;
                      final country = signUpController.selectedCountry.value;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _showCountryPickerDialog(context),
                            child: Container(
                              height: 50.0.h,
                              constraints: BoxConstraints(minWidth: 70.w),
                              padding: EdgeInsets.symmetric(horizontal: 12.0.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.0.w),
                                border: Border.all(
                                  color: (pErr != null && pErr.isNotEmpty)
                                      ? const Color(0xFFE74C3C)
                                      : const Color(0xFFE2E8F0),
                                  width: (pErr != null && pErr.isNotEmpty) ? 1.5.w : 1.0.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2C3E50).withValues(alpha: 0.03),
                                    blurRadius: 10.0.w,
                                    offset: Offset(0, 4.0.h),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '+${country.phoneCode}',
                                    style: TextStyle(
                                      color: const Color(0xFF2C3E50),
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Montserrat',
                                      fontSize: 14.0.sp,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: const Color(0xFF7F8C8D),
                                    size: 16.w,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0.w),
                          Expanded(
                            child: _buildCustomTextField(
                              controller: signUpController.phoneController,
                              hintText: 'Phone Number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              errorText: pErr,
                              onChanged: (value) {
                                signUpController.phoneError.value = null;
                                signUpController.phoneText.value = value;
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  SizedBox(height: 14.0.h),

                  // --- 6. TENANT ID CODE ---
                  _StaggeredEntrance(
                    delayMs: 500,
                    child: Obx(() => _buildCustomTextField(
                      controller: signUpController.idCodeController,
                      hintText: 'ID Code',
                      icon: Icons.qr_code_outlined,
                      errorText: signUpController.idCodeError.value,
                      onChanged: (value) {
                        signUpController.idCodeError.value = null;
                        signUpController.idCodeText.value = value;
                      },
                    )),
                  ),
                  SizedBox(height: 14.0.h),

                  // --- 7. PASSWORD & STRENGTH INDICATOR ---
                  _StaggeredEntrance(
                    delayMs: 580,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => _buildCustomTextField(
                          controller: signUpController.passwordController,
                          hintText: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: signUpController.obscurePassword.value,
                          errorText: signUpController.passwordError.value,
                          onChanged: (_) {
                            signUpController.passwordError.value = null;

                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              signUpController.obscurePassword.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF7F8C8D),
                              size: 18.w,
                            ),
                            onPressed: signUpController.toggleObscurePassword,
                          ),
                        )),
                        _buildPasswordStrengthBar(),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.0.h),

                  // --- 8. CONFIRM PASSWORD ---
                  _StaggeredEntrance(
                    delayMs: 660,
                    child: Obx(() => _buildCustomTextField(
                      controller: signUpController.confirmPasswordController,
                      hintText: 'Confirm Password',
                      icon: Icons.lock_outline,
                      obscureText: signUpController.obscurePassword.value,
                      errorText: signUpController.confirmPasswordError.value,
                      onChanged: (_) {


                        signUpController.confirmPasswordError.value = null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          signUpController.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF7F8C8D),
                          size: 18.w,
                        ),
                        onPressed: signUpController.toggleObscurePassword,
                      ),
                    )),
                  ),
                  SizedBox(height: 24.0.h),

                  // --- 9. PRIMARY BUTTON ---
                  _StaggeredEntrance(
                    delayMs: 740,
                    child: Obx(() => Container(
                      width: double.infinity,
                      height: 50.0.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0.w),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF007BFF),
                            Color(0xFF0056B3),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF007BFF).withValues(alpha: 0.35),
                            blurRadius: 8.0.w,
                            offset: Offset(0, 4.0.h),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: signUpController.isLoading.value ? null : _handlePrimaryAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0.w)),
                        ),
                        child: signUpController.isLoading.value
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
                                    'Create Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      fontSize: 15.0.sp,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 8.0.w),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16.w),
                                ],
                              ),
                      ),
                    )),
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
    Widget? suffixIcon,
    String? errorText,
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
              hintStyle: TextStyle(
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

  void _showCountryPickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CountryPickerDialog(
        selectedCountry: signUpController.selectedCountry.value,
        onSelect: (Country country) {
          signUpController.selectedCountry.value = country;
        },
      ),
    );
  }

  double _getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    if (password.length < 6) return 0.3;
    if (!RegExp(r'[0-9]').hasMatch(password)) return 0.6;
    return 1.0;
  }

  Color _getPasswordStrengthColor(double strength) {
    if (strength <= 0.3) return const Color(0xFFE74C3C); // Red
    if (strength <= 0.6) return const Color(0xFFF1C40F); // Yellow
    return const Color(0xFF2ECC71); // Green
  }

  String _getPasswordStrengthText(double strength) {
    if (strength <= 0.3) return 'Weak';
    if (strength <= 0.6) return 'Medium';
    return 'Strong';
  }

  Widget _buildPasswordStrengthBar() {
    final password = signUpController.passwordController.text;
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = _getPasswordStrength(password);
    final color = _getPasswordStrengthColor(strength);
    final text = _getPasswordStrengthText(strength);

    return Padding(
      padding: EdgeInsets.only(left: 16.0.w, top: 6.0.h, right: 16.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password Strength: $text',
                style: TextStyle(
                  color: color,
                  fontFamily: 'Montserrat',
                  fontSize: 11.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${(strength * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontFamily: 'Montserrat',
                  fontSize: 11.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.0.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0.w),
            child: LinearProgressIndicator(
              value: strength,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4.0.h,
            ),
          ),
        ],
      ),
    );
  }

  void _handlePrimaryAction() async {
    if (!signUpController.validateInputs()) return;

    final firstName = signUpController.firstNameController.text.trim();
    final lastName = signUpController.lastNameController.text.trim();
    final email = signUpController.emailController.text.trim();

    final errorMsg = await signUpController.signUp();

    if (!mounted) return;

    if (errorMsg == null) {
      final idCodeLower = BaseController.idCode.value.toLowerCase();

      final role = (idCodeLower.startsWith('ll') ||
          email.toLowerCase().contains('sterling') ||
          email.toLowerCase().contains('landlord'))
          ? 'landlord'
          : 'tenant';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
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
          userName: BaseController.name.value.isNotEmpty
              ? BaseController.name.value
              : '$firstName $lastName',
        ),
      );
    } else {
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
}




class _CountryPickerDialog extends StatefulWidget {
  final Country selectedCountry;
  final ValueChanged<Country> onSelect;

  const _CountryPickerDialog({
    required this.selectedCountry,
    required this.onSelect,
  });

  @override
  State<_CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<_CountryPickerDialog> {
  late List<Country> _countries;
  late List<Country> _filteredCountries;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _countries = CountryService().getAll();
    _filteredCountries = List.from(_countries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.0.w),
          topRight: Radius.circular(28.0.w),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 10.0.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.0.w),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.0.w, 12.0.h, 16.0.w, 8.0.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Country',
                    style: TextStyle(
                      color: const Color(0xFF2C3E50),
                      fontSize: 18.0.sp,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: const Color(0xFF7F8C8D), size: 22.w),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 8.0.h),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24.0.w),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.0.w,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: TextStyle(
                    color: const Color(0xFF2C3E50),
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search country...',
                    hintStyle: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: 13.0.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                    prefixIcon: Icon(Icons.search, color: const Color(0xFF64748B), size: 20.w),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            child: Icon(Icons.clear, color: const Color(0xFF64748B), size: 18.w),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0.h, horizontal: 16.0.w),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.0.h),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: _filteredCountries.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(32.0.w),
                        child: Text(
                          'No countries found',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF7F8C8D),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
                        itemCount: _filteredCountries.length,
                        itemBuilder: (context, index) {
                          final country = _filteredCountries[index];
                          final isSelected = country.countryCode == widget.selectedCountry.countryCode;

                          return GestureDetector(
                            onTap: () {
                              widget.onSelect(country);
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4.0.h),
                              padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 12.0.h),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFE0F2FE) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16.0.w),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    country.flagEmoji,
                                    style: TextStyle(fontSize: 22.0.sp),
                                  ),
                                  SizedBox(width: 14.0.w),
                                  Text(
                                    '+${country.phoneCode}',
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFF0369A1) : const Color(0xFF2C3E50),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.0.sp,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  SizedBox(width: 14.0.w),
                                  Expanded(
                                    child: Text(
                                      country.name,
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFF0369A1) : const Color(0xFF64748B),
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 14.0.sp,
                                        fontFamily: 'Montserrat',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: const Color(0xFF0284C7),
                                      size: 20.w,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredCountries = _countries.where((country) {
        return country.name.toLowerCase().contains(lowercaseQuery) ||
            country.phoneCode.contains(lowercaseQuery) ||
            country.countryCode.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });
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



