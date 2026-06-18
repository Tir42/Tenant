import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/core/controllers/base_controller.dart';
import 'package:tenantsnap/features/auth/signup/controller/signup_controller.dart';
import 'package:tenantsnap/features/dashboard/screens/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final signUpController = Get.put(SignUpController());
  Country _selectedCountry = Country(
    phoneCode: '1',
    countryCode: 'US',
    e164Sc: 1,
    geographic: true,
    level: 1,
    name: 'United States',
    example: '2015550123',
    displayName: 'United States (US) [+1]',
    displayNameNoCountryCode: 'United States (US)',
    e164Key: '1-US-0',
  );

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _idCodeError;
  String? _passwordError;
  String? _confirmPasswordError;

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
      padding: const EdgeInsets.only(left: 16.0, top: 6.0, right: 16.0),
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
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${(strength * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: strength,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  void _handlePrimaryAction() async {
    final firstName = signUpController.firstNameController.text.trim();
    final lastName = signUpController.lastNameController.text.trim();
    final email = signUpController.emailController.text.trim();
    final phone = signUpController.phoneController.text.trim();
    final password = signUpController.passwordController.text;
    final confirmPassword = signUpController.confirmPasswordController.text;
    final idCode = signUpController.idCodeController.text.trim();

    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _phoneError = null;
      _idCodeError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool hasValidationError = false;

    // 1. First Name Validation
    if (firstName.isEmpty) {
      setState(() => _firstNameError = 'First name is required.');
      hasValidationError = true;
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(firstName)) {
      setState(() => _firstNameError = 'First name must contain letters only.');
      hasValidationError = true;
    }

    // 2. Last Name Validation
    if (lastName.isEmpty) {
      setState(() => _lastNameError = 'Last name is required.');
      hasValidationError = true;
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(lastName)) {
      setState(() => _lastNameError = 'Last name must contain letters only.');
      hasValidationError = true;
    }

    // 3. Email Validation
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required.');
      hasValidationError = true;
    } else if (!GetUtils.isEmail(email)) {
      setState(() => _emailError = 'Please enter a valid email address.');
      hasValidationError = true;
    }

    // 4. Phone Validation
    if (phone.isEmpty) {
      setState(() => _phoneError = 'Phone number is required.');
      hasValidationError = true;
    } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      setState(() => _phoneError = 'Phone number must contain digits only.');
      hasValidationError = true;
    } else if (phone.length < 8 || phone.length > 15) {
      setState(() => _phoneError = 'Enter a valid phone number (8-15 digits).');
      hasValidationError = true;
    }

    // 5. Tenant ID Code Validation
    if (idCode.isEmpty) {
      setState(() => _idCodeError = 'Tenant ID Code is required.');
      hasValidationError = true;
    }

    // 6. Password Validation
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required.');
      hasValidationError = true;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters.');
      hasValidationError = true;
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      setState(() => _passwordError = 'Password must contain at least one number.');
      hasValidationError = true;
    }

    // 7. Confirm Password Validation
    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = 'Please confirm your password.');
      hasValidationError = true;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'Passwords do not match.');
      hasValidationError = true;
    }

    if (hasValidationError) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating new secure tenant profile...'),
      ),
    );

    // Format phone number to append the country code prefix before api request
    final String rawPhoneInput = phone;
    signUpController.phoneController.text = '+${_selectedCountry.phoneCode} $rawPhoneInput';

    final success = await signUpController.signUp();

    if (success && mounted) {
      final idCodeLower = BaseController.idCode.value.toLowerCase();
      final role = (idCodeLower.startsWith('ll') || email.toLowerCase().contains('sterling') || email.toLowerCase().contains('landlord')) ? 'landlord' : 'tenant';
      Get.off(() => HomeScreen(
        role: role,
        userName: BaseController.name.value.isNotEmpty ? BaseController.name.value : '$firstName $lastName',
      ));
    } else {
      // Restore the raw phone number if registration failed so user can edit it
      signUpController.phoneController.text = rawPhoneInput;
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- 1. VECTOR LOGO, TITLE, SUBTITLE ---
                  _StaggeredEntrance(
                    delayMs: 100,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomPaint(
                          size: const Size(80, 70),
                          painter: SignUpLogoPainter(),
                        ),
                        const SizedBox(height: 16),
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
                          'Create Secure Account',
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

                  // --- 2. TOGGLE TABS ---
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
                            child: GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: const Center(
                                  child: Text(
                                    'Sign in',
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
                                  'Create account',
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 3. FIRST & LAST NAME (ROW) ---
                  _StaggeredEntrance(
                    delayMs: 260,
                    child: isNarrow
                        ? Column(
                            children: [
                              _buildCustomTextField(
                                controller: signUpController.firstNameController,
                                hintText: 'First Name',
                                icon: Icons.person_outline,
                                errorText: _firstNameError,
                              ),
                              const SizedBox(height: 14),
                              _buildCustomTextField(
                                controller: signUpController.lastNameController,
                                hintText: 'Last Name',
                                icon: Icons.person_outline,
                                errorText: _lastNameError,
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
                                  errorText: _firstNameError,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCustomTextField(
                                  controller: signUpController.lastNameController,
                                  hintText: 'Last Name',
                                  icon: Icons.person_outline,
                                  errorText: _lastNameError,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 14),

                  // --- 4. EMAIL ---
                  _StaggeredEntrance(
                    delayMs: 340,
                    child: _buildCustomTextField(
                      controller: signUpController.emailController,
                      hintText: 'Email',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // --- 5. COUNTRY PICKER & PHONE NUMBER ---
                  _StaggeredEntrance(
                    delayMs: 420,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _showCountryPickerDialog(context),
                          child: Container(
                            height: 50,
                            constraints: const BoxConstraints(minWidth: 70),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: (_phoneError != null && _phoneError!.isNotEmpty)
                                    ? const Color(0xFFE74C3C)
                                    : const Color(0xFFE2E8F0),
                                width: (_phoneError != null && _phoneError!.isNotEmpty) ? 1.5 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2C3E50).withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '+${_selectedCountry.phoneCode}',
                                  style: const TextStyle(
                                    color: Color(0xFF2C3E50),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFF7F8C8D),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCustomTextField(
                            controller: signUpController.phoneController,
                            hintText: 'Phone Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            errorText: _phoneError,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // --- 6. TENANT ID CODE ---
                  _StaggeredEntrance(
                    delayMs: 500,
                    child: _buildCustomTextField(
                      controller: signUpController.idCodeController,
                      hintText: 'Tenant ID Code',
                      icon: Icons.qr_code_outlined,
                      errorText: _idCodeError,
                    ),
                  ),
                  const SizedBox(height: 14),

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
                          errorText: _passwordError,
                          suffixIcon: IconButton(
                            icon: Icon(
                              signUpController.obscurePassword.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF7F8C8D),
                              size: 18,
                            ),
                            onPressed: signUpController.toggleObscurePassword,
                          ),
                        )),
                        _buildPasswordStrengthBar(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // --- 8. CONFIRM PASSWORD ---
                  _StaggeredEntrance(
                    delayMs: 660,
                    child: Obx(() => _buildCustomTextField(
                      controller: signUpController.confirmPasswordController,
                      hintText: 'Confirm Password',
                      icon: Icons.lock_outline,
                      obscureText: signUpController.obscurePassword.value,
                      errorText: _confirmPasswordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          signUpController.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF7F8C8D),
                          size: 18,
                        ),
                        onPressed: signUpController.toggleObscurePassword,
                      ),
                    )),
                  ),
                  const SizedBox(height: 24),

                  // --- 9. PRIMARY BUTTON ---
                  _StaggeredEntrance(
                    delayMs: 740,
                    child: Obx(() => Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF007BFF),
                            Color(0xFF0056B3),
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
                        onPressed: signUpController.isLoading.value ? null : _handlePrimaryAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                        child: signUpController.isLoading.value
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
                                    'Create Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
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

  void _showCountryPickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CountryPickerDialog(
        selectedCountry: _selectedCountry,
        onSelect: (Country country) {
          setState(() {
            _selectedCountry = country;
          });
        },
      ),
    );
  }
}

class SignUpLogoPainter extends CustomPainter {
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
          Color(0xFF007BFF),
          Color(0xFF2ECC71),
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

    final Paint cameraPaint = Paint()..color = Colors.white;
    final RRect cameraBody = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.24, h * 0.50, w * 0.76, h * 0.88),
      const Radius.circular(8.0),
    );
    canvas.drawRRect(cameraBody, cameraPaint);

    final RRect cameraBump = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.32, h * 0.44, w * 0.46, h * 0.50),
      const Radius.circular(2.0),
    );
    canvas.drawRRect(cameraBump, cameraPaint);

    final Paint lensOutlinePaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(w * 0.5, h * 0.69);
    canvas.drawCircle(center, w * 0.16, lensOutlinePaint);

    final Paint lensDarkPaint = Paint()..color = const Color(0xFF1B2A47);
    canvas.drawCircle(center, w * 0.15, lensDarkPaint);

    final Paint lensReflectionPaint = Paint()..color = const Color(0xFF007BFF);
    canvas.drawCircle(center, w * 0.09, lensReflectionPaint);

    final Paint lensPupilPaint = Paint()..color = const Color(0xFF0D1B2A);
    canvas.drawCircle(center, w * 0.05, lensPupilPaint);

    final Paint shinyPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center + Offset(w * 0.04, -h * 0.04), w * 0.022, shinyPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
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
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Country',
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF7F8C8D), size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search country...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            child: const Icon(Icons.clear, color: Color(0xFF64748B), size: 18),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: _filteredCountries.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No countries found',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFE0F2FE) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    country.flagEmoji,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    '+${country.phoneCode}',
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFF0369A1) : const Color(0xFF2C3E50),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      country.name,
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFF0369A1) : const Color(0xFF64748B),
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF0284C7),
                                      size: 20,
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
